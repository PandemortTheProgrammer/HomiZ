import { useEffect, useRef, useState, type FormEvent } from 'react';
import { Link } from 'react-router';
import { apiActive, load, Requests, toIso, type ApiFailure, type Lead, type LeadMessage } from '../api';
import { currentSession } from '../auth';
import { useOverlay } from '../components/Overlay';
import { ApptBadge, Badge, brokerOptions, Crumbs, err, FieldError, Icon, Options, PageHead, Tabs, TimeInput, useErrors, useUrlParams } from '../components/ui';
import { dateFull, dateShort, money, opLabel, plural, rerender, t12, useStore, Z, type Property } from '../store';
import { brokerMatches } from '../brokerMatch';
import { NeedsServer, useApiData } from './Payments';

/* ==========================================================================
   Solicitudes del sitio (Contáctanos, visitas) y de la app («Busco casa»).
   En lugar de responder por correo, el asesor contesta y propone casas aquí;
   el cliente lo ve en la app, en «Mis solicitudes», y recibe un aviso.
   ========================================================================== */
const REASON: Record<Lead['reason'], string> = { visita: 'Visita', rentar: 'Quiere rentar', comprar: 'Quiere comprar', publicar: 'Publicar su casa', otro: 'Otro motivo' };
const TONE: Record<Lead['status'], string> = { nuevo: 'warn', en_seguimiento: 'info', cerrado: 'gris' };
const TABS: [string, string][] = [['nuevo', 'Nuevas'], ['en_seguimiento', 'En seguimiento'], ['cerrado', 'Cerradas'], ['', 'Todas']];
/** Administración ve además las que aún no tienen broker (las asigna ella) */
const UNASSIGNED = 'sin_asignar';
const tabsFor = (admin: boolean): [string, string][] => (admin ? [[UNASSIGNED, 'Sin asignar'], ...TABS] : TABS);
const tabQuery = (t: string) => (t === UNASSIGNED ? 'unassigned=true&' : t ? 'status=' + t + '&' : '');
/** Nombres legibles de los campos del formulario (payload) */
const FIELD: Record<string, string> = {
  operacion: 'Operación', presupuesto: 'Presupuesto', recamaras: 'Recámaras', banos: 'Baños', personas: 'Personas', mascotas: 'Mascotas',
  mascotas_detalle: 'Cuáles mascotas', nacionalidad: 'Nacionalidad', ocupacion: 'Ocupación', zona: 'Ubicación', ubicacion: 'Ubicación',
  tipo_inmueble: 'Tipo de inmueble', inmueble_tipo: 'Tipo de inmueble', inmueble_operacion: 'Quiere', inmueble_zona: 'Colonia o residencial', inmueble_recamaras: 'Recámaras', inmueble_precio: 'Precio esperado',
  mudanza: 'Quiere mudarse', plazo_renta: 'Tiempo de renta', forma_pago: 'Forma de pago', inmueble_banos: 'Baños', inmueble_m2: 'Metros cuadrados', inmueble_disponible: 'Disponible', asunto: 'Asunto',
  origen: 'Origen', presupuesto_min: 'Presupuesto desde', presupuesto_max: 'Presupuesto hasta', fecha_preferida: 'Fecha preferida', horario: 'Horario',
};
/** Campos con importes: los números se muestran como dinero */
const MONEY = new Set(['presupuesto_min', 'presupuesto_max', 'inmueble_precio']);
const shown = (k: string, v: unknown) => (MONEY.has(k) && typeof v === 'number' ? money(v) : VALUE[String(v)] ?? String(v));
/** Presupuesto en la lista: el rango numérico nuevo o el texto de los formularios anteriores */
function budgetOf(p: Lead['payload']) {
  const min = typeof p.presupuesto_min === 'number' ? p.presupuesto_min : null;
  const max = typeof p.presupuesto_max === 'number' ? p.presupuesto_max : null;
  if (min && max) return `${money(min)} – ${money(max)}`;
  if (max) return `hasta ${money(max)}`;
  if (min) return `desde ${money(min)}`;
  return p.presupuesto ? String(p.presupuesto) : '';
}
/** Valores del formulario escritos para personas */
const VALUE: Record<string, string> = {
  true: 'Sí', false: 'No', si: 'Sí', no: 'No', renta: 'Renta', compra: 'Compra', venta: 'Venta', ambas: 'Aún no lo decide',
  casa: 'Casa', 'casa-condominio': 'Casa en condominio', townhouse: 'Townhouse',
};
/** Grupos del formulario, en el orden en que la persona los llenó. Lo que no esté aquí sale en «Otros datos». */
const GROUPS: [string, string[]][] = [
  ['Asunto', ['asunto']],
  ['Qué busca', ['operacion', 'tipo_inmueble', 'presupuesto_min', 'presupuesto_max', 'presupuesto', 'recamaras', 'banos', 'personas', 'mascotas', 'mascotas_detalle', 'zona', 'ubicacion', 'mudanza', 'plazo_renta', 'forma_pago']],
  ['Sobre la persona', ['nacionalidad', 'ocupacion']],
  ['Su casa para publicar', ['inmueble_tipo', 'inmueble_operacion', 'inmueble_zona', 'inmueble_recamaras', 'inmueble_banos', 'inmueble_m2', 'inmueble_disponible', 'inmueble_precio']],
  ['Visita', ['fecha_preferida', 'horario']],
];
const ORIGIN: Record<string, string> = { app: 'App Homiz', panel: 'Registrada en el panel', sitio: 'Sitio web' };
const filled = (v: unknown) => v !== '' && v !== null && v !== undefined;

/** Datos del formulario que usan las secciones (una solicitud o el formulario ligado a una cita) */
type FormData = Pick<Lead, 'name' | 'email' | 'phone' | 'payload' | 'message' | 'preferredDate' | 'preferredTime' | 'createdAt'> & { property: { code: string; name: string } | null };

/** Todo lo que llenó en el formulario, por secciones (contacto, qué busca, la persona, visita, mensaje). */
export function FormSections({ l }: { l: FormData }) {
  const p = l.payload;
  // Con el rango numérico, el texto «presupuesto» repite lo mismo
  const skip = new Set(['origen', ...(filled(p.presupuesto_min) || filled(p.presupuesto_max) ? ['presupuesto'] : [])]);
  const known = new Set(GROUPS.flatMap(([, keys]) => keys));
  const visit: [string, string][] = [
    ...(l.property ? [['Casa', `${l.property.name} · ${l.property.code}`] as [string, string]] : []),
    ...(l.preferredDate ? [['Fecha preferida', dateFull(l.preferredDate)] as [string, string]] : []),
    ...(l.preferredTime ? [['Horario', t12(l.preferredTime.slice(0, 5))] as [string, string]] : []),
  ];
  const sections: [string, [string, string][]][] = [
    ['Contacto', [['Nombre', l.name], ['Correo', l.email], ['Teléfono', l.phone || '—'], ['Llegó por', ORIGIN[String(p.origen ?? 'sitio')] ?? String(p.origen)], ['Fecha', dateFull(l.createdAt.slice(0, 10))]]],
    ...GROUPS.map(([title, keys]): [string, [string, string][]] => [
      title,
      [...(title === 'Visita' ? visit : []), ...keys.filter((k) => filled(p[k]) && !skip.has(k)).map((k): [string, string] => [FIELD[k] ?? k, shown(k, p[k])])],
    ]),
    ['Otros datos', Object.entries(p).filter(([k, v]) => filled(v) && !known.has(k) && !skip.has(k)).map(([k, v]): [string, string] => [FIELD[k] ?? k.replace(/_/g, ' '), shown(k, v)])],
  ];
  return (
    <div className="form-sections">
      {sections.filter(([, rows]) => rows.length).map(([title, rows]) => (
        <div key={title}>
          <h3 className="label-xs">{title}</h3>
          <dl className="facts-list">
            {rows.map(([k, v]) => <div key={k}><dt>{k}</dt><dd>{v}</dd></div>)}
          </dl>
        </div>
      ))}
      <div>
        <h3 className="label-xs">Mensaje</h3>
        {l.message ? <p className="quote" style={{ marginTop: 0 }}>“{l.message}”</p> : <p className="muted small">No escribió mensaje.</p>}
      </div>
    </div>
  );
}

const failMsg = (e: unknown) => (e as ApiFailure)?.mensaje || 'No se pudo guardar. Inténtalo de nuevo.';
const S = { tab: 'nuevo', selected: '' as string };

export const ReasonBadge = ({ l }: { l: Lead }) => <Badge label={l.statusLabel} tone={TONE[l.status]} />;
/** Eliminar solicitudes: solo administración (y propietario) */
const priorityLabel = (l: Lead) => l.priority && `Prioridad de ${l.priority.brokerName} hasta las ${new Date(l.priority.until).toLocaleTimeString('es-MX', { timeZone: 'America/Cancun', hour: 'numeric', minute: '2-digit', hourCycle: 'h12' })}`;

const isAdminSession = () => (currentSession()?.roles ?? []).some((r) => r === 'admin' || r === 'owner');
const val = (id: string) => (document.getElementById(id) as HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement).value.trim();
/** Casas a las que se puede agendar visita: las que no están rentadas ni vendidas; primero las propuestas y la de la solicitud */
function visitable(D: { properties: Property[] }, l?: Lead) {
  const first = new Set([...(l?.proposals ?? []).map((p) => p.property.code), ...(l?.property ? [l.property.code] : [])]);
  return D.properties.filter((p) => p.status !== 'rentada' && p.status !== 'vendida' && p._id)
    .sort((a, b) => Number(first.has(b.id)) - Number(first.has(a.id)) || a.name.localeCompare(b.name));
}

/** Quién tiene casas que encajan con lo que pidió la persona, para elegir al broker con esa información */
function BrokerMatches({ l, busy, onAssign }: { l: Lead; busy: boolean; onAssign: (id: string, name: string) => void }) {
  const list = brokerMatches(l);
  if (!list) return null;
  return (
    <div className="broker-matches">
      <h3 className="label-xs">Brokers recomendados</h3>
      {list.length ? list.slice(0, 4).map(({ broker: b, houses, requested, visits }) => (
        <div className="broker-match" key={b.id}>
          <div className="broker-match__head">
            <strong>{b.name}</strong>
            {l.broker?.id === b.id ? <Badge label="Asignado" tone="ok" /> : <button className="btn btn--sm btn--secondary" type="button" disabled={busy} onClick={() => onAssign(b.id, b.name)}>Asignar</button>}
          </div>
          <p className="small muted">{requested ? 'Atiende la casa que pidió · ' : ''}{houses.length} {plural(houses.length, 'casa encaja', 'casas encajan')} · {visits} {plural(visits, 'cita pendiente', 'citas pendientes')}</p>
          {houses.length > 0 && <ul>{houses.slice(0, 3).map(({ house: h, why }) => <li key={h.id}>{h.name} · {money(h.price)}{h.op === 'renta' ? ' / mes' : ''}{why.length ? ' · ' + why.join(', ') : ''}</li>)}</ul>}
        </div>
      )) : <p className="small muted">Ningún broker tiene casas disponibles que encajen con lo que pidió. Asigna a quien pueda conseguirle una.</p>}
    </div>
  );
}

/** Cita vigente (por confirmar o confirmada) agendada desde la solicitud */
const activeAppt = (l: Lead) => (l.appointments ?? []).find((a) => a.status === 'por-confirmar' || a.status === 'confirmada');

/** Agendar la visita desde la solicitud (diálogo): la cita queda «por confirmar» y ligada a la solicitud. */
function ScheduleForm({ l, close, onDone }: { l: Lead; close: () => void; onDone: (msg: string) => void }) {
  const D = useStore();
  const { errors, check, live, clear } = useErrors();
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const houses = visitable(D, l);
  // La casa que mandó el cliente no se cambia aquí: otra se le propone desde la app
  const fixedId = activeAppt(l)?.property.code ?? (l.property && houses.some((p) => p.id === l.property!.code) ? l.property.code : '');
  const fixed = fixedId ? D.properties.find((p) => p.id === fixedId) : undefined;
  // Cita vigente de la solicitud: se reprograma esa (no se crea otra)
  const active = activeAppt(l);
  const suggested = new Set([...(active ? [active.property.code] : []), ...(l.proposals ?? []).map((p) => p.property.code), ...(l.property ? [l.property.code] : [])]);
  const submit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const extra = val('sc-date') && val('sc-date') < Z.TODAY ? [{ id: 'sc-date', msg: 'Elige una fecha a partir de hoy.' }] : [];
    if (!check(e.currentTarget, extra)) return;
    const p = D.properties.find((x) => x.id === val('sc-prop'))!;
    setBusy(true);
    Requests.schedule(l.id, { propertyId: p._id!, scheduledAt: toIso(val('sc-date'), val('sc-time')), note: val('sc-note') || null })
      .then((r) => { close(); onDone(`Cita ${r.appointment.code} ${r.rescheduled ? 'cambiada' : 'agendada'} para ${l.name}: ${p.name}, ${dateShort(val('sc-date'))}, ${t12(val('sc-time'))}. Quedó por confirmar y le avisamos en la app.`); },
        (er: ApiFailure) => { setError(er?.mensaje || 'No se pudo agendar la cita.'); setBusy(false); });
  };
  return (
    <>
      <span className="dialog__icon dialog__icon--info"><Icon id="cal-clock" className="icon--lg" /></span>
      <h2 id="dialog-title">{active ? `Cambiar la cita de ${l.name}` : `Agendar cita para ${l.name}`}</h2>
      <p className="lead">{active
        ? `Ya tiene la cita ${active.code} (${active.property.name}). Elige el nuevo día y horario: se mueve esa misma cita y queda por confirmar.`
        : 'Visita presencial de 15 minutos. Aparece en Citas como «por confirmar» y a la persona le llega el aviso en la app.'}</p>
      <form noValidate {...live} onSubmit={submit}>
        {error && <div className="notice notice--error" role="alert"><Icon id="alert" /><span>{error}</span></div>}
        <div className="form-grid">
          <div className="field span-all"><label className="field__label" htmlFor={fixed ? 'sc-prop-name' : 'sc-prop'}>Casa *</label>
            {fixed ? (
              <>
                <input type="hidden" id="sc-prop" value={fixed.id} />
                <input className="input" id="sc-prop-name" readOnly value={`${fixed.name} · ${fixed.zone}`} />
                <p className="field__hint">Es la casa que eligió la persona. Para sugerirle otra, propónsela desde la app.</p>
              </>
            ) : (
              <>
                <select className="select" id="sc-prop" required defaultValue={houses.find((p) => suggested.has(p.id))?.id ?? ''} onChange={() => clear('sc-prop')} {...err(errors, 'sc-prop')}>
                  <Options list={houses.map((p): [string, string] => [p.id, `${suggested.has(p.id) ? '★ ' : ''}${p.name} · ${p.zone} · ${opLabel(p)} ${money(p.price)}`])} placeholder="Elige la casa a visitar" />
                </select>
                <p className="field__hint">{l.property ? `${l.property.name} ya no está disponible. ` : ''}★ = las casas que le propusiste.</p>
              </>
            )}<FieldError errors={errors} id="sc-prop" /></div>
          <div className="field"><label className="field__label" htmlFor="sc-date">Fecha *</label>
            <input className="input" id="sc-date" type="date" required min={Z.TODAY} defaultValue={l.preferredDate && l.preferredDate >= Z.TODAY ? l.preferredDate : ''} onInput={() => clear('sc-date')} {...err(errors, 'sc-date')} /><FieldError errors={errors} id="sc-date" /></div>
          <div className="field"><label className="field__label" htmlFor="sc-time-h">Horario *</label>
            <TimeInput id="sc-time" required defaultValue={l.preferredTime?.slice(0, 5) ?? ''} invalid={!!errors['sc-time']} onChange={() => clear('sc-time')} /><FieldError errors={errors} id="sc-time" /></div>
          <div className="field span-all"><label className="field__label" htmlFor="sc-note">Nota para la visita</label><textarea className="textarea" id="sc-note" defaultValue={l.message ?? ''} placeholder="Lo que le interesa ver" /></div>
        </div>
        <div className="dialog__actions">
          <button className="btn btn--secondary" type="button" onClick={close}>Cancelar</button>
          <button className="btn" type="submit" disabled={busy}>{busy ? 'Guardando…' : active ? 'Cambiar fecha' : 'Agendar cita'}</button>
        </div>
      </form>
    </>
  );
}

/** Nueva solicitud (llamada, WhatsApp, oficina) o corregir una existente (diálogo). */
function LeadForm({ l, close, onDone }: { l?: Lead; close: () => void; onDone: (lead: Lead, msg: string) => void }) {
  const D = useStore();
  const { errors, check, live, clear } = useErrors();
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const [reason, setReason] = useState<Lead['reason']>(l?.reason ?? 'rentar');
  const [pets, setPets] = useState('');
  /** Datos del formulario de la casa (presupuesto máximo, personas, mascotas, nacionalidad, ocupación) */
  const housePayload = (): Record<string, string | number> => {
    if (reason === 'publicar' || reason === 'otro') return {};
    const max = Number(val('lf-budget')) || 0;
    const out: Record<string, string | number> = { personas: val('lf-people'), mascotas: pets };
    if (max) Object.assign(out, { presupuesto_max: max, presupuesto: `${money(max)} MXN${reason === 'comprar' ? '' : ' / mes'}` });
    if (pets === 'si') out.mascotas_detalle = val('lf-pets-d');
    if (val('lf-nat')) out.nacionalidad = val('lf-nat');
    if (val('lf-job')) out.ocupacion = val('lf-job');
    return out;
  };
  const submit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const extra = !l && reason === 'visita' && !val('lf-prop') ? [{ id: 'lf-prop', msg: 'Elige la casa que quiere visitar.' }] : [];
    if (!check(e.currentTarget, extra)) return;
    setBusy(true);
    const p = l ? Requests.update(l.id, { name: val('lf-name'), phone: val('lf-phone') || null, message: val('lf-msg') || null, reason })
      : Requests.create({ reason, name: val('lf-name'), email: val('lf-email'), phone: val('lf-phone') || null, message: val('lf-msg') || null, propertyCode: val('lf-prop') || null, payload: housePayload() });
    p.then((lead) => { close(); onDone(lead, l ? `Solicitud ${lead.folio} actualizada.` : `Solicitud ${lead.folio} registrada. Si no tenía cuenta, le enviamos el correo para entrar a la app.`); },
      (er: ApiFailure) => { setError(er?.mensaje || 'No se pudo guardar.'); setBusy(false); });
  };
  return (
    <>
      <h2 id="dialog-title">{l ? `Editar solicitud ${l.folio}` : 'Nueva solicitud'}</h2>
      <p className="lead">{l ? 'Corrige los datos que llegaron mal escritos.' : 'Para quien llamó, escribió por WhatsApp o vino a la oficina. Se le crea la cuenta de la app con su correo.'}</p>
      <form noValidate {...live} onSubmit={submit}>
        {error && <div className="notice notice--error" role="alert"><Icon id="alert" /><span>{error}</span></div>}
        <div className="form-grid">
          <div className="field"><label className="field__label" htmlFor="lf-name">Nombre *</label>
            <input className="input" id="lf-name" required minLength={2} maxLength={120} defaultValue={l?.name} onInput={() => clear('lf-name')} {...err(errors, 'lf-name')} /><FieldError errors={errors} id="lf-name" /></div>
          <div className="field"><label className="field__label" htmlFor="lf-email">Correo *</label>
            <input className="input" id="lf-email" type="email" required={!l} disabled={!!l} defaultValue={l?.email} onInput={() => clear('lf-email')} {...err(errors, 'lf-email')} />
            {l && <p className="field__hint">El correo es el de su cuenta; no se cambia aquí.</p>}<FieldError errors={errors} id="lf-email" /></div>
          <div className="field"><label className="field__label" htmlFor="lf-phone">Teléfono</label><input className="input" id="lf-phone" type="tel" maxLength={30} defaultValue={l?.phone ?? ''} /></div>
          <div className="field"><label className="field__label" htmlFor="lf-reason">Motivo *</label>
            <select className="select" id="lf-reason" value={reason} onChange={(e) => setReason(e.target.value as Lead['reason'])}>
              <Options list={Object.entries(REASON).map(([k, v]): [string, string] => [k, v])} />
            </select></div>
          {!l && (
            <div className="field span-all"><label className="field__label" htmlFor="lf-prop">Casa de interés {reason === 'visita' ? '*' : <span className="muted">(opcional)</span>}</label>
              <select className="select" id="lf-prop" defaultValue="" onChange={() => clear('lf-prop')} {...err(errors, 'lf-prop')}>
                <Options list={visitable(D).map((p): [string, string] => [p.id, `${p.name} · ${p.zone}`])} placeholder="Ninguna en particular" />
              </select><FieldError errors={errors} id="lf-prop" /></div>
          )}
          {!l && reason !== 'publicar' && reason !== 'otro' && (
            // Lo mismo que pide el formulario de la casa en el sitio
            <>
              <div className="field"><label className="field__label" htmlFor="lf-budget">Presupuesto máximo {reason === 'comprar' ? '' : 'al mes'} <span className="muted">(MXN)</span></label>
                <input className="input" id="lf-budget" inputMode="numeric" maxLength={12} placeholder="Lo más que quiere pagar" onInput={(e) => (e.currentTarget.value = e.currentTarget.value.replace(/\D/g, ''))} /></div>
              <div className="field"><label className="field__label" htmlFor="lf-people">Personas que vivirán</label>
                <select className="select" id="lf-people" defaultValue="2"><Options list={[['1', '1'], ['2', '2'], ['3', '3'], ['4', '4'], ['5', '5 o más']]} /></select></div>
              <div className="field"><label className="field__label" htmlFor="lf-pets">¿Tiene mascotas? *</label>
                <select className="select" id="lf-pets" required value={pets} onChange={(e) => { setPets(e.target.value); clear('lf-pets'); }} {...err(errors, 'lf-pets')}>
                  <Options list={[['no', 'No'], ['si', 'Sí']]} placeholder="Elige una opción" />
                </select><FieldError errors={errors} id="lf-pets" /></div>
              {pets === 'si' && (
                <div className="field"><label className="field__label" htmlFor="lf-pets-d">¿Cuáles y cuántas? *</label>
                  <input className="input" id="lf-pets-d" required maxLength={200} placeholder="Por ejemplo: 1 perro pequeño" onInput={() => clear('lf-pets-d')} {...err(errors, 'lf-pets-d')} /><FieldError errors={errors} id="lf-pets-d" /></div>
              )}
              <div className="field"><label className="field__label" htmlFor="lf-nat">Nacionalidad</label><input className="input" id="lf-nat" maxLength={60} placeholder="Mexicana" /></div>
              <div className="field"><label className="field__label" htmlFor="lf-job">¿En qué trabaja?</label><input className="input" id="lf-job" maxLength={80} /></div>
            </>
          )}
          <div className="field span-all"><label className="field__label" htmlFor="lf-msg">Qué busca o qué pidió</label><textarea className="textarea" id="lf-msg" maxLength={2000} defaultValue={l?.message ?? ''} /></div>
        </div>
        <div className="dialog__actions">
          <button className="btn btn--secondary" type="button" onClick={close}>Cancelar</button>
          <button className="btn" type="submit" disabled={busy}>{busy ? 'Guardando…' : l ? 'Guardar cambios' : 'Registrar solicitud'}</button>
        </div>
      </form>
    </>
  );
}

/** Mensajes de la solicitud: al cliente le llegan a la app (y su respuesta llega aquí). Se actualiza cada 20 s. */
function Chat({ leadId, onSent }: { leadId: string; onSent: () => void }) {
  const { toast } = useOverlay();
  const [list, setList] = useState<LeadMessage[] | null>(null);
  const [text, setText] = useState('');
  const [busy, setBusy] = useState(false);
  const end = useRef<HTMLDivElement>(null);
  useEffect(() => {
    let alive = true;
    const load = () => Requests.messages(leadId).then((m) => alive && setList(m), () => alive && setList((x) => x ?? []));
    load();
    const t = setInterval(load, 20_000);
    return () => { alive = false; clearInterval(t); };
  }, [leadId]);
  useEffect(() => { end.current?.scrollIntoView({ block: 'nearest' }); }, [list?.length]);
  const send = (e: FormEvent) => {
    e.preventDefault();
    if (!text.trim()) return;
    setBusy(true);
    Requests.send(leadId, text.trim()).then((m) => { setList(m); setText(''); toast('Mensaje enviado. Le avisamos al cliente en la app.'); onSent(); }, (er) => toast(failMsg(er))).finally(() => setBusy(false));
  };
  return (
    <>
      <div className="chat" aria-live="polite">
        {list === null ? <p className="muted small">Cargando mensajes…</p>
          : list.length ? list.map((m) => (
            <div key={m.id} className={'chat__msg' + (m.fromStaff ? ' chat__msg--staff' : '')}>
              <span className="chat__who">{m.sender} · {new Date(m.createdAt).toLocaleString('es-MX', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit', hourCycle: 'h12' })}</span>
              <p>{m.body}</p>
            </div>
          )) : <p className="muted small">Aún no hay mensajes. Escríbele para darle seguimiento.</p>}
        <div ref={end} />
      </div>
      <form className="chat__form" onSubmit={send}>
        <label className="sr-only" htmlFor="rq-msg">Mensaje</label>
        <textarea className="textarea" id="rq-msg" rows={3} maxLength={2000} placeholder="Escribe al cliente: le llega a su app Homiz." value={text} onChange={(e) => setText(e.target.value)} />
        <button className="btn btn--block" type="submit" disabled={busy || !text.trim()}>{busy ? 'Enviando…' : 'Enviar mensaje'}</button>
      </form>
    </>
  );
}

function Detail({ id, onChanged, onDeleted, onOpen }: { id: string; onChanged: () => void; onDeleted: () => void; onOpen: (id: string) => void }) {
  const D = useStore();
  const { toast, confirm, open } = useOverlay();
  const lead = useApiData(() => Requests.get(id), [id]);
  const [busy, setBusy] = useState(false);
  const titleRef = useRef<HTMLHeadingElement>(null);
  useEffect(() => { titleRef.current?.focus(); }, [id]);

  if (lead.loading && !lead.data) return <p className="muted" role="status">Cargando solicitud…</p>;
  if (lead.error || !lead.data) return <div className="notice notice--error" role="alert"><Icon id="alert" /><span>{lead.error}</span></div>;
  const l = lead.data;
  const run = (p: Promise<unknown>, msg: string, after?: () => void) => {
    setBusy(true);
    p.then(() => { toast(msg); after?.(); lead.reload(); onChanged(); }, (e) => toast(failMsg(e))).finally(() => setBusy(false));
  };
  const appts = l.appointments ?? [];
  const schedule = () => open((close) => <ScheduleForm l={l} close={close} onDone={(m) => { toast(m); lead.reload(); onChanged(); load().then(rerender, () => {}); }} />, { wide: true });
  const edit = () => open((close) => <LeadForm l={l} close={close} onDone={(_x, m) => { toast(m); lead.reload(); onChanged(); }} />, { wide: true });
  const remove = () => confirm({
    title: `¿Eliminar la solicitud ${l.folio}?`, lead: `Se borran la solicitud de ${l.name}, sus casas propuestas y la conversación. Las citas que se agendaron se conservan en Citas.`,
    check: null, confirm: 'Eliminar solicitud', cancel: 'Conservar',
    onConfirm: () => { setBusy(true); Requests.remove(l.id).then(() => { toast(`Solicitud ${l.folio} eliminada.`); onDeleted(); }, (e) => { toast(failMsg(e)); setBusy(false); }); },
  });
  const origin = l.payload.origen === 'app' ? ' · desde la app' : l.payload.origen === 'panel' ? ' · registrada en el panel' : ' · desde el sitio';

  return (
    <div className="grid-2 grid-2--wide-side">
      <div className="stack">
        <section className="card card--pad" aria-labelledby="rq-title">
          <div className="card__head">
            <h2 className="card__title" id="rq-title" tabIndex={-1} ref={titleRef}>{l.name} · {l.folio}</h2>
            <ReasonBadge l={l} />
          </div>
          <p className="small muted" style={{ marginBottom: '.75rem' }}>{REASON[l.reason]} · {dateFull(l.createdAt.slice(0, 10))}{origin}</p>
          <div className="choice-row" style={{ marginBottom: '1rem' }}>
            <button className="btn btn--sm" type="button" disabled={busy} onClick={schedule}><Icon id="cal-clock" />{activeAppt(l) ? 'Cambiar fecha de la cita' : 'Agendar cita'}</button>
            <button className="btn btn--sm btn--secondary" type="button" disabled={busy} onClick={edit}>Editar datos</button>
            {isAdminSession() && <button className="btn btn--sm btn--secondary link--danger" type="button" disabled={busy} onClick={remove}>Eliminar</button>}
          </div>
          {l.property && <p style={{ marginBottom: '.75rem' }}>Casa que le interesa: <Link to={'/propiedades/' + l.property.code}>{l.property.name}</Link></p>}
          <FormSections l={l} />
        </section>

        {(l.others ?? []).length > 0 && (
          <section className="card card--pad" aria-labelledby="rq-others">
            <h2 className="card__title" id="rq-others" style={{ marginBottom: '.75rem' }}>Otras solicitudes de esta persona · {l.others!.length}</h2>
            <ul className="proposals">
              {l.others!.map((o) => (
                <li key={o.id}>
                  <div><button className="link strong" type="button" style={{ color: 'var(--marino)' }} onClick={() => onOpen(o.id)}>{o.folio} · {REASON[o.reason]}</button>
                    <span className="sub">{dateFull(o.createdAt.slice(0, 10))}{o.property ? ` · ${o.property}` : ''}{[budgetOf(o.payload), o.payload.recamaras && `${o.payload.recamaras} rec.`, o.payload.zona].filter(Boolean).map((x) => ' · ' + x).join('')}{o.message ? ` · «${o.message.length > 80 ? o.message.slice(0, 80) + '…' : o.message}»` : ''}</span></div>
                  <Badge label={o.statusLabel} tone={TONE[o.status]} />
                </li>
              ))}
            </ul>
          </section>
        )}

        <section className="card card--pad" aria-labelledby="rq-appts">
          <div className="card__head">
            <h2 className="card__title" id="rq-appts">Citas · {appts.length}</h2>
            <button className="btn btn--sm" type="button" disabled={busy} onClick={schedule}><Icon id="plus" />{activeAppt(l) ? 'Cambiar fecha' : 'Agendar cita'}</button>
          </div>
          {appts.length ? (
            <ul className="proposals">
              {appts.map((a) => (
                <li key={a.id}>
                  <div><Link className="strong" to={'/citas?cita=' + a.code}>{a.code} · {a.property.name}</Link>
                    <span className="sub">{new Date(a.scheduledAt).toLocaleString('es-MX', { timeZone: 'America/Cancun', weekday: 'long', day: 'numeric', month: 'long', hour: '2-digit', minute: '2-digit', hourCycle: 'h12' })}{a.broker ? ` · ${a.broker}` : ''}</span></div>
                  <ApptBadge s={a.status} />
                </li>
              ))}
            </ul>
          ) : <p className="muted">Aún no tiene cita. Con «Agendar cita» eliges el día y la hora; aparece en Citas y le avisamos en la app.</p>}
        </section>

        <section className="card card--pad" aria-labelledby="rq-props">
          <div className="card__head"><h2 className="card__title" id="rq-props">Casas propuestas · {(l.proposals || []).length}</h2></div>
          {(l.proposals || []).length ? (
            <ul className="proposals">
              {l.proposals!.map((p) => (
                <li key={p.id}>
                  <div><Link className="strong" to={'/propiedades/' + p.property.code}>{p.property.name}</Link>
                    <span className="sub">{p.property.zone} · {money(p.property.price)}{p.property.operation === 'renta' ? ' / mes' : ''} · {p.property.rec} rec.{p.note ? ` · «${p.note}»` : ''}</span></div>
                  <button className="link link--danger" type="button" disabled={busy}
                    onClick={() => confirm({ title: `¿Quitar ${p.property.name}?`, lead: 'El cliente dejará de verla en sus propuestas.', check: null, confirm: 'Quitar', cancel: 'Conservar', onConfirm: () => run(Requests.unpropose(l.id, p.id), `${p.property.name} se quitó de las propuestas.`) })}>Quitar</button>
                </li>
              ))}
            </ul>
          ) : <p className="muted">Aún no hay casas propuestas. Los brokers las proponen desde la app, en esta misma solicitud.</p>}
        </section>
      </div>

      <div className="stack">
        <section className={'card card--pad' + (l.broker ? '' : ' card--alert')} aria-labelledby="rq-broker">
          <h2 className="card__title" id="rq-broker" style={{ marginBottom: '.75rem' }}>Broker asignado</h2>
          {l.priority && <p className="small" style={{ marginBottom: '.5rem' }}>{priorityLabel(l)}</p>}
          {l.overdue && <p style={{ marginBottom: '.5rem' }}><Badge label="Sin atender" tone="err" /></p>}
          {isAdminSession() ? (
            <>
              <label className="sr-only" htmlFor="rq-assign">Broker</label>
              <select className="select" id="rq-assign" value={l.broker?.id ?? ''} disabled={busy}
                onChange={(e) => { const b = D.brokers.find((x) => x.id === e.target.value); if (b) run(Requests.assign(l.id, b.id), `Solicitud ${l.folio} asignada a ${b.name}. Le avisamos y su cita se va con ${b.name}.`); }}>
                {!l.broker && <option value="">Sin asignar · elige un broker</option>}
                <Options list={brokerOptions(D.brokers, l.broker?.id ?? '')} />
              </select>
              <p className="small muted" style={{ marginTop: '.5rem' }}>{l.broker ? 'Puedes cambiarlo: la cita vigente pasa al nuevo broker. Los datos de la persona no cambian.' : 'Llegó sin broker. Elige quién la atiende: le avisamos y la cita (si pidió una) queda con él.'}</p>
              <BrokerMatches l={l} busy={busy} onAssign={(bid, name) => run(Requests.assign(l.id, bid), `Solicitud ${l.folio} asignada a ${name}. Le avisamos y su cita se va con ${name}.`)} />
            </>
          ) : <p>{l.broker?.name ?? 'Sin asignar'}</p>}
        </section>
        <section className="card card--pad" aria-labelledby="rq-contact">
          <h2 className="card__title" id="rq-contact" style={{ marginBottom: '.75rem' }}>Contacto</h2>
          <div className="contact-lines"><a href={'mailto:' + l.email}>{l.email}</a>{l.phone && <a href={'tel:' + l.phone.replace(/\s/g, '')}>{l.phone}</a>}</div>
          <p className="small muted" style={{ marginTop: '.75rem' }}>La respuesta y las casas propuestas le llegan a la app Homiz, en «Mis solicitudes», si tiene cuenta con este correo.</p>
        </section>
        <section className="card card--pad" aria-labelledby="rq-answer">
          <h2 className="card__title" id="rq-answer" style={{ marginBottom: '.75rem' }}>Conversación con el cliente</h2>
          {l.response && <p className="quote" style={{ marginTop: 0 }}>“{l.response}”<span className="sub">{l.respondedBy ?? ''}{l.respondedAt ? ' · ' + dateShort(l.respondedAt.slice(0, 10)) : ''}</span></p>}
          <Chat leadId={l.id} onSent={() => { lead.reload(); onChanged(); }} />
        </section>
        <section className="card card--pad" aria-labelledby="rq-status">
          <h2 className="card__title" id="rq-status" style={{ marginBottom: '.75rem' }}>Seguimiento</h2>
          <div className="choice-row">
            {(['nuevo', 'en_seguimiento', 'cerrado'] as const).map((s) => (
              <button key={s} className={'btn btn--sm' + (l.status === s ? '' : ' btn--secondary')} type="button" aria-pressed={l.status === s} disabled={busy || l.status === s}
                onClick={() => run(Requests.update(l.id, { status: s }), `Solicitud ${l.folio}: ${{ nuevo: 'nueva', en_seguimiento: 'en seguimiento', cerrado: 'cerrada' }[s]}.`)}>
                {{ nuevo: 'Nueva', en_seguimiento: 'En seguimiento', cerrado: 'Cerrada' }[s]}
              </button>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}

/** Sección «Solicitudes» del menú */
export function RequestsPage() {
  const [tab, setTab] = useState(S.tab);
  const [selected, setSelected] = useState(S.selected);
  useUrlParams((p) => { const id = p.get('id'); if (id) { S.selected = id; setSelected(id); S.tab = ''; setTab(''); } });
  const tabs = tabsFor(isAdminSession());
  const list = useApiData(() => Requests.list(tabQuery(tab) + 'limit=100'), [tab]);
  // Las solicitudes nuevas aparecen solas: se vuelve a leer la lista cada 30 s
  useEffect(() => {
    const t = setInterval(() => list.reload(), 30_000);
    return () => clearInterval(t);
  }, [list.reload]);
  const counts = useApiData(() => Promise.all(tabs.map(([s]) => Requests.list(tabQuery(s) + 'limit=1').then((r) => r.pagination.total))), [list.data]);
  const rows = list.data?.data ?? [];
  const choose = (id: string) => { S.selected = id; setSelected(id); setTimeout(() => document.getElementById('rq-detail')?.scrollIntoView({ behavior: 'smooth', block: 'start' }), 50); };
  const { open, toast } = useOverlay();
  const create = () => open((close) => <LeadForm close={close} onDone={(lead, m) => { toast(m); S.tab = 'nuevo'; setTab('nuevo'); list.reload(); choose(lead.id); }} />, { wide: true });

  return (
    <>
      <Crumbs items={[['Administración', '/resumen'], ['Solicitudes']]} />
      <PageHead title="Cada solicitud, con respuesta." sub="Lo que piden en el sitio, en la app o por teléfono. Contesta, propón casas y agenda la cita: al cliente le llega a la app."
        actions={apiActive() ? <button className="btn" type="button" onClick={create}><Icon id="plus" />Nueva solicitud</button> : undefined} />
      {!apiActive() ? <NeedsServer what="Las solicitudes" /> : (
        <>
          <Tabs name="rq" label="Filtrar solicitudes" selected={tab} onSelect={(v) => { S.tab = v; setTab(v); }}
            items={tabs.map(([v, label], i) =>[v, label + (counts.data ? ' · ' + counts.data[i] : '')])} />
          {list.error ? <div className="notice notice--error" role="alert"><Icon id="alert" /><span>{list.error}</span></div> : (
            <div className="table-wrap">
              <table className="table">
                <caption className="sr-only">Solicitudes</caption>
                <thead><tr><th scope="col">Persona / Folio</th><th scope="col">Motivo</th><th scope="col">Busca</th><th scope="col">Recibida</th><th scope="col">Estado</th><th scope="col">Seguimiento</th><th scope="col"><span className="sr-only">Acciones</span></th></tr></thead>
                <tbody>
                  {list.loading && !list.data ? <tr><td colSpan={7} className="table-empty">Cargando…</td></tr>
                    : rows.length ? rows.map((l) => (
                      // Toda la fila abre la solicitud (además del nombre y del botón, para teclado)
                      <tr key={l.id} className={l.id === selected ? 'is-selected' : ''} data-row-select onClick={(e) => !(e.target as HTMLElement).closest('a,button') && choose(l.id)}>
                        <td><button className="link strong" type="button" style={{ color: 'var(--marino)' }} onClick={() => choose(l.id)}>{l.name}</button><span className="sub">{l.folio}{l.payload.origen === 'app' ? ' · app' : ''}</span></td>
                        <td>{REASON[l.reason]}</td>
                        <td className="small">{l.property ? l.property.name : [budgetOf(l.payload), l.payload.recamaras && `${l.payload.recamaras} rec.`, l.payload.zona || l.payload.inmueble_zona].filter(Boolean).join(' · ') || '—'}</td>
                        <td>{dateShort(l.createdAt.slice(0, 10))}</td>
                        <td><ReasonBadge l={l} />{l.broker ? <span className="sub">{l.broker.name}</span> : l.priority ? <span className="sub">{priorityLabel(l)}</span> : <span className="sub"><Badge label="Sin asignar" tone="error" /></span>}</td>
                        <td className="small">{[l.appointmentCount && `${l.appointmentCount} ${plural(l.appointmentCount, 'cita', 'citas')}`, l.proposalCount && `${l.proposalCount} ${plural(l.proposalCount, 'casa propuesta', 'casas propuestas')}`, !l.appointmentCount && !l.proposalCount && l.response && 'Respondida'].filter(Boolean).join(' · ') || '—'}</td>
                        <td><button className="btn btn--sm btn--secondary" type="button" onClick={() => choose(l.id)}>{l.id === selected ? 'Abierta' : 'Atender'}</button></td>
                      </tr>
                    )) : <tr><td colSpan={7} className="table-empty">No hay solicitudes {tab === 'nuevo' ? 'nuevas' : tab === 'en_seguimiento' ? 'en seguimiento' : tab === 'cerrado' ? 'cerradas' : tab === UNASSIGNED ? 'sin asignar' : ''}.</td></tr>}
                </tbody>
              </table>
            </div>
          )}
          <div id="rq-detail" style={{ marginTop: '1.5rem' }} aria-live="polite">
            {selected && <Detail id={selected} onChanged={() => list.reload()} onDeleted={() => { S.selected = ''; setSelected(''); list.reload(); }} onOpen={choose} />}
          </div>
        </>
      )}
    </>
  );
}
