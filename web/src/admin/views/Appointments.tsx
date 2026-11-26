import { useEffect, useRef, useState, type FormEvent } from 'react';
import { Link, useNavigate } from 'react-router';
import { apiActive, createContract, errorText, Finance, load, request, Requests, ZApi, type ApiFailure } from '../api';
import { MoneyInput } from '../../components/NumberInput';
import { FormSections } from './Requests';
import { can, isAdminSession } from '../auth';
import { useOverlay } from '../components/Overlay';
import { ApptBadge, brokerOptions, Cover, Crumbs, err, FieldError, Icon, Metric, Options, PageHead, Tabs, TimeInput, useErrors, useUrlParams, VISIT_TIMES } from '../components/ui';
import {
  appt, broker, D as Data, money, dateLong, dateShort, dayShort, downloadCSV, isoDate, monthName, monthShort, norm, parseDate, person,
  plural, prop, rerender, sortAppts, upcoming, useStore, viewState, Z, type Appointment, t12 } from '../store';

/** La visita dura 15 minutos */
export const VISIT_MINUTES = 15;
const S = viewState.citas;
/** «Prospecto CLI-0012» / «Inquilino CLI-0004» para distinguir a las personas con el mismo nombre */
export const personLabel = (id: string) => {
  const p = person(id);
  return `${p.code ? p.code + ' · ' : ''}${p.name} · ${p.type === 'inquilino' ? 'Inquilino' : 'Prospecto'}`;
};
/** Personas con más de una cita vigente (por confirmar o confirmada, de hoy en adelante): posibles duplicados */
const duplicated = () => {
  const n: Record<string, number> = {};
  Data.appointments.filter((a) => (a.status === 'por-confirmar' || a.status === 'confirmada') && a.date >= Z.TODAY).forEach((a) => (n[a.person] = (n[a.person] ?? 0) + 1));
  return new Set(Object.keys(n).filter((k) => n[k] > 1));
};

function weekDays() {
  const start = parseDate(Z.TODAY);
  start.setDate(start.getDate() + S.offset * 7);
  return Array.from({ length: 7 }, (_, i) => { const d = new Date(start); d.setDate(start.getDate() + i); return d; });
}
const rangeLabel = (days: Date[]) => {
  const [a, b] = [days[0], days[6]];
  return a.getMonth() === b.getMonth() ? `${a.getDate()}–${b.getDate()} ${monthShort(b)}` : `${a.getDate()} ${monthShort(a)}–${b.getDate()} ${monthShort(b)}`;
};
const brokerClash = (brokerId: string, date: string, start: string, exceptId?: string) =>
  Data.appointments.some((a) => a.id !== exceptId && a.broker === brokerId && a.date === date && a.start === start && a.status !== 'cancelada');
function goToWeekOf(iso: string) {
  const diff = Math.floor((parseDate(iso).getTime() - parseDate(Z.TODAY).getTime()) / 86400000);
  S.offset = Math.floor(diff / 7);
}

/** Reprogramar una cita (diálogo) */
function Reschedule({ a, close }: { a: Appointment; close: () => void }) {
  const { toast } = useOverlay();
  const { errors, check, live, clear } = useErrors();
  const p = prop(a.property);
  const [busy, setBusy] = useState(false);
  const [saveError, setSaveError] = useState('');
  const onSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (busy) return;
    const date = (document.getElementById('rs-date') as HTMLInputElement).value;
    const time = (document.getElementById('rs-time') as HTMLSelectElement).value;
    const extra = [];
    if (date && date < Z.TODAY) extra.push({ id: 'rs-date', msg: 'Elige una fecha a partir de hoy.' });
    else if (date && brokerClash(a.broker, date, time, a.id)) extra.push({ id: 'rs-time', msg: broker(a.broker).name + ' ya tiene una cita a esa hora.' });
    if (!check(e.currentTarget, extra)) return;
    // POST /appointments/:id/reschedule: la nueva fecha la propone el personal y queda por confirmar (409 si el horario está ocupado)
    const why = (document.getElementById('rs-why') as HTMLInputElement).value.trim();
    const name = person(a.person).name;
    setBusy(true);
    setSaveError('');
    try {
      await ZApi.appointmentReschedule(a, date, time, why);
      toast(`Nueva fecha propuesta: ${dateLong(date)}, ${t12(time)}. Le avisamos a ${name} para que la acepte.`);
      S.selected = a.id; S.day = null;
      close();
      goToWeekOf(date);
      rerender();
    } catch (err) {
      setSaveError(errorText(err));
      setBusy(false);
    }
  };
  return (
    <>
      <span className="dialog__icon dialog__icon--info"><Icon id="cal-clock" className="icon--lg" /></span>
      <h2 id="dialog-title">Reprogramar cita</h2>
      <p className="lead">{person(a.person).name} · {p?.name ?? ''}. Le avisamos al cliente y la cita queda por confirmar hasta que acepte la nueva fecha en su app (o proponga otra).</p>
      <form id="rs-form" noValidate {...live} onSubmit={onSubmit}>
        <div className="form-grid">
          <div className="field"><label className="field__label" htmlFor="rs-date">Nueva fecha *</label>
            <input className="input" id="rs-date" type="date" required min={Z.TODAY} defaultValue={a.date} onInput={() => clear('rs-date')} {...err(errors, 'rs-date')} /><FieldError errors={errors} id="rs-date" /></div>
          <div className="field"><label className="field__label" htmlFor="rs-time-h">Horario *</label>
            <TimeInput id="rs-time" required defaultValue={a.start} invalid={!!errors['rs-time']} onChange={() => clear('rs-time')} /><FieldError errors={errors} id="rs-time" /></div>
          <div className="field span-all"><label className="field__label" htmlFor="rs-why">Motivo del cambio</label><input className="input" id="rs-why" placeholder="Por ejemplo: el cliente pidió más temprano" /></div>
        </div>
        {saveError && <div className="callout callout--error" role="alert" style={{ marginTop: '1rem' }}><strong>No se guardó</strong>{saveError}</div>}
        <div className="dialog__actions"><button className="btn btn--secondary" type="button" onClick={close}>Cancelar</button><button className="btn" type="submit" disabled={busy} aria-busy={busy}>{busy ? 'Guardando…' : 'Guardar nuevo horario'}</button></div>
      </form>
    </>
  );
}

/** Nueva cita (diálogo) */
function NewAppointment({ personId, close, onDone }: { personId: string | null; close: () => void; onDone: () => void }) {
  const D = useStore();
  const { toast } = useOverlay();
  const { errors, check, live, clear } = useErrors();
  /** Casa ya elegida por la persona: la de su cita vigente o la de su expediente, si no está rentada ni vendida */
  const chosenHouse = (id: string) => {
    const pr = D.people.find((x) => x.id === id);
    const active = D.appointments.find((x) => x.person === id && (x.status === 'por-confirmar' || x.status === 'confirmada') && x.date >= Z.TODAY);
    const h = prop(active?.property ?? pr?.property ?? '');
    return h && h.status !== 'rentada' && h.status !== 'vendida' ? h.id : '';
  };
  const [chosen, setChosen] = useState(personId ? chosenHouse(personId) : '');
  const [picked, setPicked] = useState('');
  const propId = chosen || picked;
  // El broker lo pone la casa (y lo cambia la asignación de la solicitud), no este formulario
  const brokerId = prop(propId)?.broker ?? '';
  const v = (id: string) => (document.getElementById(id) as HTMLInputElement).value;
  const [busy, setBusy] = useState(false);
  const [saveError, setSaveError] = useState('');

  const onSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (busy) return;
    const extra = [];
    if (v('nc-date') && v('nc-date') < Z.TODAY) extra.push({ id: 'nc-date', msg: 'Elige una fecha a partir de hoy.' });
    else if (v('nc-date') && v('nc-time') && brokerId && brokerClash(brokerId, v('nc-date'), v('nc-time'))) extra.push({ id: 'nc-time', msg: broker(brokerId).name + ' ya tiene una cita a esa hora.' });
    if (!check(e.currentTarget, extra)) return;
    // POST /appointments. Cada persona tiene una sola cita vigente: si ya tenía una, el servidor la cambia (moved)
    const data = { person: v('nc-person'), property: propId, date: v('nc-date'), start: v('nc-time'), note: v('nc-note').trim() };
    const name = person(data.person).name;
    setBusy(true);
    setSaveError('');
    try {
      const r = await ZApi.appointmentNew(data);
      toast(r.moved ? `${name} ya tenía una cita: se cambió ${r.code} a ${dateLong(data.date)}, ${t12(data.start)}.` : `Cita ${r.code} agendada · ${dateLong(data.date)}, ${t12(data.start)}.`);
      S.selected = r.code; S.day = null; S.tab = 'todas';
      close();
      goToWeekOf(data.date);
      onDone();
    } catch (err) {
      setSaveError(errorText(err)); // 409 SCHEDULE_CONFLICT, 400 datos inválidos o sin conexión
      setBusy(false);
    }
  };
  return (
    <>
      <h2 id="dialog-title">Nueva cita</h2>
      <p className="lead">Agenda una visita presencial de 15 minutos. Quedará por confirmar hasta que el cliente acepte. Cada persona tiene una sola cita vigente: si ya tiene una, solo cambia su fecha.</p>
      <form id="nc-form" noValidate {...live} onSubmit={onSubmit}>
        <div className="form-grid">
          <div className="field"><label className="field__label" htmlFor="nc-person">Persona (ID · nombre · tipo) *</label>
            <select className="select" id="nc-person" required defaultValue={personId || ''} {...err(errors, 'nc-person')}
              onChange={(e) => {
                clear('nc-person');
                setChosen(chosenHouse(e.target.value));
              }}>
              {(['cliente', 'inquilino'] as const).map((t) => (
                <optgroup key={t} label={t === 'inquilino' ? 'Inquilinos' : 'Prospectos'}>
                  {D.people.filter((p) => p.type === t).sort((a, b) => (a.code ?? a.name).localeCompare(b.code ?? b.name)).map((p) => <option key={p.id} value={p.id}>{personLabel(p.id)}</option>)}
                </optgroup>
              ))}
              {!personId && <option value="" disabled hidden>Elige a una persona</option>}
            </select><FieldError errors={errors} id="nc-person" /></div>
          <div className="field"><label className="field__label" htmlFor="nc-prop">Propiedad *</label>
            {chosen ? (
              <>
                <input className="input" id="nc-prop" readOnly value={chosen + ' · ' + (prop(chosen)?.name ?? '')} />
                <p className="field__hint">Es la casa que eligió la persona. Para sugerirle otra, propónsela desde la app.</p>
              </>
            ) : (
              <select className="select" id="nc-prop" required value={picked} {...err(errors, 'nc-prop')} onChange={(e) => { clear('nc-prop'); setPicked(e.target.value); }}>
                <Options list={D.properties.filter((p) => p.status !== 'rentada' && p.status !== 'vendida').map((p): [string, string] => [p.id, p.id + ' · ' + p.name])} placeholder="Elige una propiedad" />
              </select>
            )}<FieldError errors={errors} id="nc-prop" /></div>
          <div className="field"><label className="field__label" htmlFor="nc-date">Fecha *</label>
            <input className="input" id="nc-date" type="date" required min={Z.TODAY} onInput={() => clear('nc-date')} {...err(errors, 'nc-date')} /><FieldError errors={errors} id="nc-date" /></div>
          <div className="field"><label className="field__label" htmlFor="nc-time-h">Horario *</label>
            <TimeInput id="nc-time" required invalid={!!errors['nc-time']} onChange={() => clear('nc-time')} /><FieldError errors={errors} id="nc-time" /></div>
          <div className="field span-all"><span className="field__label">Broker responsable</span>
            <p>{brokerId ? broker(brokerId).name : 'Se define con la casa'}</p></div>
          <div className="field span-all"><label className="field__label" htmlFor="nc-note">Nota del cliente</label><textarea className="textarea" id="nc-note" placeholder="Lo que le interesa ver en la visita" /></div>
        </div>
        {saveError && <div className="callout callout--error" role="alert" style={{ marginTop: '1rem' }}><strong>No se agendó</strong>{saveError}</div>}
        <div className="dialog__actions"><button className="btn btn--secondary" type="button" onClick={close}>Cancelar</button><button className="btn" type="submit" disabled={busy} aria-busy={busy}>{busy ? 'Agendando…' : 'Agendar cita'}</button></div>
      </form>
    </>
  );
}

/** Módulo 5 · Citas */
export function Appointments() {
  const D = useStore();
  const navigate = useNavigate();
  const { toast, open, confirm } = useOverlay();
  const panelTitle = useRef(false);
  const pendingNew = useRef<string | null>(null);
  // Solicitudes nuevas o en seguimiento: de ahí se agendan las citas
  const [openLeads, setOpenLeads] = useState<number | null>(null);
  useEffect(() => {
    if (!apiActive() || !can('leads.manage')) return;
    Promise.all(['nuevo', 'en_seguimiento'].map((s) => Requests.list(`status=${s}&limit=1`).then((r) => r.pagination.total)))
      .then(([a, b]) => setOpenLeads(a + b), () => {});
  }, []);

  useUrlParams((p) => {
    const c = p.get('cita');
    if (c && appt(c)) { S.selected = c; S.day = null; S.tab = appt(c)!.status === 'cancelada' ? 'cancelada' : 'todas'; S.q = ''; S.broker = ''; goToWeekOf(appt(c)!.date); }
    if (p.get('nueva')) pendingNew.current = p.get('nueva');
  });

  const newAppointment = (personId: string | null) =>
    open((close) => <NewAppointment personId={personId} close={close} onDone={() => { navigate('/citas'); rerender(); }} />, { wide: true });

  useEffect(() => {
    if (pendingNew.current) { const id = pendingNew.current; pendingNew.current = null; newAppointment(id); }
    if (panelTitle.current) { panelTitle.current = false; document.getElementById('ap-title')?.focus({ preventScroll: true }); }
  });

  const days = weekDays();
  const inWeek = (a: Appointment) => a.date >= isoDate(days[0]) && a.date <= isoDate(days[6]);
  const week = D.appointments.filter(inWeek);
  const c = (s: string) => week.filter((a) => a.status === s).length;
  // Las canceladas salen de la agenda; quedan en la pestaña «Canceladas» como historial.
  const live = (a: Appointment) => a.status !== 'cancelada';
  const q = norm(S.q);
  const dups = duplicated();
  // Mañana 06:00–11:59 · tarde 12:00–18:59 · noche 19:00–05:59 · o una hora exacta
  const hourOk = (a: Appointment) => !S.hour || (S.hour === 'manana' ? a.start >= '06:00' && a.start < '12:00'
    : S.hour === 'tarde' ? a.start >= '12:00' && a.start < '19:00'
    : S.hour === 'noche' ? a.start >= '19:00' || a.start < '06:00' : a.start === S.hour);
  const fits = (a: Appointment) => {
    const p = prop(a.property), pe = person(a.person);
    return (S.tab === 'todas' ? live(a) : a.status === S.tab) && (!S.broker || a.broker === S.broker) && hourOk(a) && (!S.prop || a.property === S.prop)
      && (!S.dup || dups.has(a.person)) && (!q || norm(pe.name + ' ' + (pe.code ?? '') + ' ' + (p ? p.name + ' ' + p.id : '') + ' ' + a.id).includes(q));
  };
  const list = sortAppts(week.filter((a) => (!S.day || a.date === S.day) && fits(a)));
  // Carrusel del detalle: todas las citas con los filtros actuales, de cualquier semana
  const deck = sortAppts(D.appointments.filter(fits));
  const chosen = appt(S.selected);
  const sel = chosen && fits(chosen) ? chosen : list[0];
  // Pendientes del personal: las que propuso el cliente (las que propuso el personal esperan al cliente)
  const pend = upcoming((a) => a.status === 'por-confirmar' && a.awaiting !== 'client')[0];
  const go = (a: Appointment) => { S.selected = a.id; S.day = null; goToWeekOf(a.date); rerender(); };

  // POST /appointments/:id/confirm · cancel · complete. El estado cambia en pantalla cuando el servidor lo confirma.
  const setStatus = (a: Appointment, status: string) => {
    const name = person(a.person).name;
    const i = deck.indexOf(a), next = deck[i + 1] ?? deck[i - 1];
    ZApi.appointmentStatus(a, status).then(
      () => {
        // La cancelada desaparece de la lista: el detalle pasa a la siguiente cita
        if (status === 'cancelada' && S.tab !== 'cancelada') S.selected = next ? next.id : null;
        toast(({ confirmada: `Cita confirmada con ${name}.`, realizada: `La visita de ${name} quedó como realizada.`, cancelada: `Se canceló la visita de ${name}.` } as Record<string, string>)[status]);
        rerender();
      },
      (err) => toast(`No se cambió la cita ${a.id}: ${errorText(err)}`),
    );
  };
  const cancel = (a: Appointment) => {
    const p = prop(a.property);
    confirm({
      icon: 'cal-clock', title: `¿Cancelar la visita de ${person(a.person).name}?`,
      lead: `${p?.name ?? ''} · ${dateLong(a.date)}, ${t12(a.start)}. Saldrá de la agenda y quedará en «Canceladas» como historial; avisa al cliente por teléfono o WhatsApp.`,
      cancel: 'Conservar cita', confirm: 'Sí, cancelar cita',
      onConfirm: () => setStatus(a, 'cancelada'),
    });
  };
  /** Confirmar: antes se muestran el día y la hora que se acuerdan (y se le avisa al cliente) */
  const confirmAppt = (a: Appointment) => {
    const p = prop(a.property);
    confirm({
      icon: 'cal-clock', title: `¿Confirmar la visita de ${person(a.person).name}?`,
      lead: `${dateLong(a.date)}, de ${t12(a.start)} a ${t12(a.end)} · ${p?.name ?? 'la propiedad'}. Le avisamos al cliente con este día y hora; si no le queda, usa «Reprogramar» y él la acepta en su app.`,
      check: null, cancel: 'Todavía no', confirm: `Confirmar ${dateShort(a.date)}, ${t12(a.start)}`,
      onConfirm: () => { S.selected = a.id; setStatus(a, 'confirmada'); },
    });
  };
  const reschedule = (a: Appointment) => open((close) => <Reschedule a={a} close={close} />);
  const exportCsv = () => {
    const rows: string[][] = [['Clave', 'Fecha', 'Inicio', 'Fin', 'Cliente', 'Correo', 'Teléfono', 'Propiedad', 'Broker', 'Estado', 'Nota']];
    sortAppts(D.appointments).forEach((x) => { const pe = person(x.person); rows.push([x.id, x.date, x.start, x.end, pe.name, pe.email, pe.phone, prop(x.property)?.name ?? '', broker(x.broker).name, Z.APPT_STATUS[x.status].label, x.note]); });
    downloadCSV('zugar-agenda-citas.csv', rows);
    toast('Se descargó zugar-agenda-citas.csv.');
  };

  return (
    <>
      <Crumbs items={[['Administración', '/resumen'], ['Citas']]} />
      <PageHead title="Cada visita, bien acompañada." sub="Coordina clientes, casas y brokers sin perder de vista el siguiente paso."
        actions={<>{openLeads !== null && <Link className="btn btn--secondary" to="/solicitudes"><Icon id="mail" />Solicitudes por agendar · {openLeads}</Link>}<button className="btn btn--secondary" type="button" onClick={exportCsv}><Icon id="download" />Exportar agenda</button><button className="btn" type="button" onClick={() => newAppointment(null)}><Icon id="plus" />Nueva cita</button></>} />
      <div className="metrics">
        <Metric label="Citas de la semana" value={week.length} note={`${days[0].getDate()}–${days[6].getDate()} de ${monthName(days[6]).toLowerCase()}`} />
        <Metric label="Confirmadas" value={c('confirmada')} note="Listas para la visita" />
        <Metric label="Por confirmar" value={c('por-confirmar')} note="Pendiente de contacto" />
        <Metric label="Realizadas / canceladas" value={`${c('realizada')} / ${c('cancelada')}`} note="Historial de la semana" />
      </div>
      <div className="grid-2 grid-2--wide-side">
        <div>
          <div className="week-head">
            <h2>{monthName(days[0])} {days[0].getFullYear()}</h2>
            <div className="week-nav">
              <button className="icon-btn" type="button" aria-label="Semana anterior" onClick={() => { S.offset -= 1; S.day = null; S.selected = null; rerender(); }}><Icon id="left" /></button>
              <span aria-live="polite">{rangeLabel(days)}</span>
              <button className="icon-btn" type="button" aria-label="Semana siguiente" onClick={() => { S.offset += 1; S.day = null; S.selected = null; rerender(); }}><Icon id="right" /></button>
            </div>
          </div>
          <div className="days" role="group" aria-label="Días de la semana">
            {days.map((d) => {
              const iso = isoDate(d), n = week.filter((a) => a.date === iso && live(a)).length;
              const pressed = S.day === iso || (!S.day && sel?.date === iso);
              return (
                <button key={iso} className={'day' + (iso === Z.TODAY ? ' is-today' : '')} type="button" id={'day-' + iso} aria-pressed={pressed}
                  aria-label={`${dateLong(iso)}, ${n} ${plural(n, 'cita', 'citas')}${iso === Z.TODAY ? ', hoy' : ''}`}
                  onClick={() => {
                    S.day = S.day === iso ? null : iso;
                    if (S.day) { const f = list.find((a) => a.date === iso) || sortAppts(week.filter((x) => x.date === iso && fits(x)))[0]; S.selected = f ? f.id : null; }
                    rerender();
                  }}>
                  <span>{dayShort(d)}</span><strong>{d.getDate()}</strong><small>{n} {plural(n, 'cita', 'citas')}</small>
                </button>
              );
            })}
          </div>
          <div id="ct-tabs">
            <Tabs name="ct" label="Filtrar por estado" selected={S.tab} onSelect={(v) => { S.tab = v; rerender(); }}
              items={[['todas', 'Todas · ' + week.filter(live).length], ['confirmada', 'Confirmadas · ' + c('confirmada')], ['por-confirmar', 'Por confirmar · ' + c('por-confirmar')], ['cancelada', 'Canceladas · ' + c('cancelada')]]} />
          </div>
          <div className="filters filters--2" role="search" aria-label="Filtrar citas">
            <div className="field"><label className="field__label" htmlFor="ct-q">Buscar cita</label><input className="input input-search" id="ct-q" type="search" placeholder="ID, persona, propiedad o CIT-…" defaultValue={S.q} onChange={(e) => { S.q = e.target.value; rerender(); }} /></div>
            <div className="field"><label className="field__label" htmlFor="ct-broker">Broker</label>
              <select className="select" id="ct-broker" value={S.broker} onChange={(e) => { S.broker = e.target.value; rerender(); }}><Options list={brokerOptions(D.brokers, S.broker)} placeholder="Todos" /></select></div>
            <div className="field"><label className="field__label" htmlFor="ct-hour">Horario</label>
              <select className="select" id="ct-hour" value={S.hour} onChange={(e) => { S.hour = e.target.value; rerender(); }}>
                <option value="">Todo el día</option><option value="manana">Mañana (06:00–11:59)</option><option value="tarde">Tarde (12:00–18:59)</option><option value="noche">Noche (19:00–05:59)</option>
                <optgroup label="Hora exacta">{VISIT_TIMES.map((t) => <option key={t} value={t}>{t12(t)}</option>)}</optgroup>
              </select></div>
            <div className="field"><label className="field__label" htmlFor="ct-prop">Propiedad visitada</label>
              <select className="select" id="ct-prop" value={S.prop} onChange={(e) => { S.prop = e.target.value; rerender(); }}>
                <Options list={[...new Set(D.appointments.map((a) => a.property))].filter((id) => prop(id)).sort().map((id): [string, string] => [id, id + ' · ' + prop(id)!.name])} placeholder="Todas" />
              </select></div>
            <label className="check-inline span-all">
              <input type="checkbox" checked={S.dup} onChange={(e) => { S.dup = e.target.checked; rerender(); }} />
              <span>Solo personas con más de una cita vigente {dups.size ? `(${dups.size})` : ''} · posibles duplicados</span>
            </label>
          </div>
          <p className="small muted" id="ct-dayline" style={{ marginBlock: '1rem .5rem' }}>
            {S.day && <>Mostrando las citas del {dateLong(S.day).toLowerCase()} · <button className="link" type="button" onClick={() => { S.day = null; rerender(); document.getElementById('ct-q')?.focus(); }}>Ver toda la semana</button></>}
          </p>
          <div className="table-wrap">
            <table className="table">
              <caption className="sr-only">Citas de la semana</caption>
              <thead><tr><th scope="col">Fecha / Hora</th><th scope="col">Cliente / Propiedad</th><th scope="col">Broker</th><th scope="col">Estado</th></tr></thead>
              <tbody id="ct-rows">
                {list.length ? list.map((a) => {
                  const p = prop(a.property);
                  return (
                    <tr key={a.id} className={a.id === sel?.id ? 'is-selected' : ''}>
                      <td><span className="strong">{dateShort(a.date)}</span><span className="sub">{t12(a.start)}–{t12(a.end)}</span></td>
                      <td><button className="link strong" type="button" style={{ color: 'var(--marino)' }} aria-pressed={a.id === sel?.id} onClick={() => { S.selected = a.id; panelTitle.current = true; rerender(); }}>{person(a.person).name}</button>
                        <span className="sub">{person(a.person).code ? person(a.person).code + ' · ' : ''}{person(a.person).type === 'inquilino' ? 'Inquilino' : 'Prospecto'} · {p ? p.id + ' ' + p.name : 'Propiedad eliminada'}</span>
                        {dups.has(a.person) && live(a) && a.date >= Z.TODAY && <span className="badge badge--warn" style={{ marginTop: '.25rem' }}>Más de una cita vigente</span>}</td>
                      <td>{broker(a.broker).name}</td>
                      <td><ApptBadge s={a.status} /></td>
                    </tr>
                  );
                }) : <tr><td colSpan={4} className="table-empty">{week.length ? 'No hay citas con estos filtros.' : 'No hay citas registradas esta semana.'}</td></tr>}
              </tbody>
            </table>
          </div>
          <p className="small muted" id="ct-meta" style={{ marginTop: '.75rem' }}>{list.length} {plural(list.length, 'cita', 'citas')} · Zona horaria de Cancún (UTC-5)</p>
          <div id="ct-pending" style={{ marginTop: '1.5rem' }}>
            <section className="card card--pad" aria-labelledby="sp-title">
              <h2 className="card__title" id="sp-title" style={{ marginBottom: '.75rem' }}>Seguimiento pendiente</h2>
              {pend ? (
                <>
                  <p>{person(pend.person).name} pidió visitar {prop(pend.property)?.name ?? 'la propiedad'} el {dateShort(pend.date)}, {t12(pend.start)}. Confírmala o propón otra fecha.</p>
                  <div className="page-actions" style={{ marginTop: '1rem' }}>
                    <button className="btn" type="button" onClick={() => confirmAppt(pend)}>Confirmar cita</button>
                    <button className="btn btn--secondary" type="button" onClick={() => reschedule(pend)}>Reprogramar</button>
                  </div>
                </>
              ) : <p className="muted">Todas las visitas próximas están confirmadas.</p>}
            </section>
          </div>
        </div>
        <div id="ct-panel"><AppointmentPanel a={sel} deck={deck} onGo={go} onStatus={setStatus} onConfirm={confirmAppt} onReschedule={reschedule} onCancel={cancel} onNew={newAppointment}
          onTenant={(x) => open((close) => <TenantForm a={x} close={close} onDone={(m) => { toast(m); load().then(rerender, () => {}); }} />, { wide: true })} /></div>
      </div>
    </>
  );
}


/** Contrato de renta desde una visita realizada: la persona queda como inquilina de la casa. */
/** Fechas de los pagarés: un pago al mes en el día de pago, desde el inicio hasta el fin (igual que el servidor) */
export function noteDates(start: string, end: string, day: number): string[] {
  if (!start || !end || !day) return [];
  const [y, m, d] = start.split('-').map(Number);
  let cur = new Date(y, m - 1, day, 12);
  if (cur.getDate() !== day || cur < new Date(y, m - 1, d, 12)) cur = new Date(y, m, day, 12);
  const out: string[] = [];
  const iso = (x: Date) => `${x.getFullYear()}-${String(x.getMonth() + 1).padStart(2, '0')}-${String(x.getDate()).padStart(2, '0')}`;
  for (let i = 0; i < 600 && iso(cur) <= end; i++) {
    out.push(iso(cur));
    cur = new Date(cur.getFullYear(), cur.getMonth() + 1, day, 12);
  }
  return out;
}

/** Casas que se pueden rentar: en renta, no rentadas y guardadas en el servidor */
const rentable = (id?: string) => { const h = id ? prop(id) : undefined; return !!h && h.op === 'renta' && h.status !== 'rentada' && !!h._id; };

/**
 * La casa que más probablemente va a rentar la persona: la que tiene asignada en su expediente o,
 * si no, la de su cita más reciente (primero las realizadas o confirmadas).
 */
export function suggestHouse(personId: string): { id: string; why: string } | null {
  const per = person(personId);
  if (rentable(per.property)) return { id: per.property, why: 'la casa de su expediente' };
  const rank = (s: string) => (s === 'realizada' ? 0 : s === 'confirmada' ? 1 : s === 'por-confirmar' ? 2 : 3);
  const last = Data.appointments.filter((x) => x.person === personId && rentable(x.property))
    .sort((x, y) => rank(x.status) - rank(y.status) || (y.date + y.start).localeCompare(x.date + x.start))[0];
  return last ? { id: last.property, why: `su cita ${last.status === 'realizada' ? 'realizada' : 'más reciente'} (${dateShort(last.date)})` } : null;
}

/**
 * Rentar (hacer inquilino) en un solo formulario: la persona, la casa (ya elegida: la de su expediente o su última cita)
 * y el contrato. Se abre desde la persona, desde Rentas o desde la cita realizada.
 */
export function TenantForm({ a, close, onDone }: { a: { property?: string; person?: string }; close: () => void; onDone: (msg: string) => void }) {
  const D = useStore();
  const [personId, setPersonId] = useState(a.person ?? '');
  const sugg = !a.property && personId ? suggestHouse(personId) : null;
  const [houseId, setHouseId] = useState(a.property ?? sugg?.id ?? '');
  const houses = D.properties.filter((h) => rentable(h.id));
  const people = D.people.filter((x) => x.type === 'cliente').sort((x, y) => x.name.localeCompare(y.name));
  const choosePerson = (id: string) => { setPersonId(id); const s = suggestHouse(id); if (s) setHouseId(s.id); };
  const picker = (
    <>
      {!a.person && (
        <div className="field"><label className="field__label" htmlFor="tf-person">Cliente *</label>
          <select className="select" id="tf-person" value={personId} onChange={(e) => choosePerson(e.target.value)}>
            <Options list={people.map((x): [string, string] => [x.id, `${x.code ? x.code + ' · ' : ''}${x.name}`])} placeholder="Elige al cliente" />
          </select></div>
      )}
      <div className={'field' + (a.person ? ' span-all' : '')}><label className="field__label" htmlFor="tf-house">Casa *</label>
        <select className="select" id="tf-house" value={houseId} onChange={(e) => setHouseId(e.target.value)}>
          <Options list={houses.map((h): [string, string] => [h.id, `${h.id} · ${h.name} · ${money(h.price)} / mes`])} placeholder="Elige la casa" />
        </select>
        {personId && houseId && (sugg ?? suggestHouse(personId))?.id === houseId && <p className="field__hint">Elegida por {(sugg ?? suggestHouse(personId))!.why}. Puedes cambiarla.</p>}</div>
    </>
  );
  if (!personId || !houseId) {
    return (
      <>
        <h2 id="dialog-title">Rentar una casa</h2>
        <p className="lead">Elige al cliente: la casa se elige sola (la de su expediente o su última cita) y luego capturas el contrato.</p>
        <div className="form-grid">{picker}</div>
        <div className="dialog__actions"><button className="btn btn--secondary" type="button" onClick={close}>Cancelar</button></div>
      </>
    );
  }
  return <TenantFields key={houseId + personId} a={{ property: houseId, person: personId }} close={close} onDone={onDone} picker={picker} />;
}

/** El contrato: periodo, renta, día de pago, depósito, PDF (opcional) y agua y luz. Los pagarés se generan solos. */
function TenantFields({ a, close, onDone, picker }: { a: Pick<Appointment, 'property' | 'person'>; close: () => void; onDone: (msg: string) => void; picker: React.ReactNode }) {
  const p = prop(a.property)!;
  const per = person(a.person);
  const { errors, check, live, clear } = useErrors();
  const [error, setError] = useState('');
  const [busy, setBusy] = useState('');
  /** Fin del contrato: N meses después del inicio (un día antes) */
  const plusMonths = (iso: string, months: number) => { const d = new Date(iso + 'T12:00:00'); d.setMonth(d.getMonth() + months); d.setDate(d.getDate() - 1); return isoDate(d); };
  const year = (iso: string) => plusMonths(iso, 12);
  // La renta no empieza antes de la visita de esa persona a esa casa
  const visitDay = Data.appointments.filter((x) => x.person === a.person && x.property === a.property && ['realizada', 'confirmada', 'por-confirmar'].includes(x.status)).map((x) => x.date).sort().at(-1) ?? '';
  const firstDay = visitDay > Z.TODAY ? visitDay : Z.TODAY;
  const [f, setF] = useState({
    start: firstDay, end: year(firstDay), day: String(Math.min(28, Number(firstDay.slice(8)))), rent: String(p.price || ''), deposit: String(p.deposit || p.price || ''),
    cfe: p.utilities?.electricity ?? '', water: p.utilities?.water ?? '',
  });
  const [months, setMonths] = useState(12);
  const dates = noteDates(f.start, f.end, Number(f.day));
  const rent = Number(f.rent) || 0;
  const pdf = () => (document.getElementById('tf-contract') as HTMLInputElement).files?.[0];
  const submit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const contractPdf = pdf();
    const extra = [
      ...(f.start < Z.TODAY ? [{ id: 'tf-start', msg: 'La renta no puede empezar en una fecha que ya pasó.' }] : []),
      ...(visitDay && f.start < visitDay ? [{ id: 'tf-start', msg: `La renta no puede empezar antes de la visita (${dateShort(visitDay)}).` }] : []),
      ...(f.end <= f.start ? [{ id: 'tf-end', msg: 'La fecha de fin debe ser posterior al inicio.' }] : []),
      ...(!rent ? [{ id: 'tf-rent', msg: 'Escribe la renta mensual.' }] : []),
      ...(f.end > f.start && !dates.length ? [{ id: 'tf-day', msg: 'Con esas fechas no cae ningún día de pago.' }] : []),
      ...(contractPdf && contractPdf.type !== 'application/pdf' ? [{ id: 'tf-contract', msg: 'El contrato debe ser un PDF.' }] : []),
      ...(contractPdf && contractPdf.size > 50 * 1024 * 1024 ? [{ id: 'tf-contract', msg: 'El PDF pesa más de 50 MB. Escanéalo en menor resolución.' }] : []),
    ];
    if (!check(e.currentTarget, extra)) return;
    setBusy('Creando el contrato y los pagarés…');
    let contractId = '';
    const pending: string[] = [];
    try {
      contractId = (await createContract({
        propertyId: p._id!, clientId: a.person, startDate: f.start, endDate: f.end,
        monthlyRent: rent, paymentDay: Number(f.day), deposit: Number(f.deposit) || null,
      })).id;
      // Ya es inquilino y la casa quedó rentada y fuera del sitio: lo demás no lo detiene
      if (contractPdf) {
        setBusy(`Subiendo el contrato (${(contractPdf.size / 1024 / 1024).toFixed(1)} MB)…`);
        await Finance.attachContractPdf(contractId, p._id!, contractPdf).catch(() => pending.push('el PDF del contrato (súbelo en Rentas › Expediente)'));
      } else pending.push('el PDF del contrato (súbelo cuando lo tengas en Rentas › Expediente)');
      if (isAdminSession() && (f.cfe.trim() !== (p.utilities?.electricity ?? '') || f.water.trim() !== (p.utilities?.water ?? ''))) {
        await request('PATCH', `/properties/${p._id}`, { electricityServiceNumber: f.cfe.trim() || null, waterServiceNumber: f.water.trim() || null })
          .then(() => (p.utilities = { electricity: f.cfe.trim(), water: f.water.trim(), day: p.utilities?.day ?? 1 }), () => pending.push('los números de agua y luz'));
      }
      p.status = 'rentada';
      p.visibility = 'pausada';
      close();
      onDone(`Listo: ${per.name} es inquilino de ${p.name}. Se generaron ${dates.length} pagarés y la casa salió del sitio (pausada).${pending.length ? ' Falta ' + pending.join(' y ') + '.' : ''}`);
      load().then(rerender, () => {});
    } catch (er) {
      setError((er as ApiFailure)?.mensaje || 'No se pudo crear el contrato.');
      setBusy('');
    }
  };
  const duration = (m: number) => { setMonths(m); setF({ ...f, end: plusMonths(f.start, m) }); };
  const set = (k: keyof typeof f) => (v: string) => { clear('tf-' + k); setF({ ...f, [k]: v }); };
  return (
    <>
      <h2 id="dialog-title">Rentar {p.name} a {per.name}</h2>
      <p className="lead">Un solo paso: al guardar, {per.name.split(' ')[0]} pasa a inquilino, se generan sus pagarés mensuales y {p.name} sale del sitio (se pausa sola).</p>
      <form noValidate {...live} onSubmit={submit}>
        {error && <div className="notice notice--error" role="alert"><Icon id="alert" /><span>{error}</span></div>}
        <div className="form-grid">
          {picker}
          <div className="field"><label className="field__label" htmlFor="tf-start">Inicio de la renta *</label><input className="input" id="tf-start" type="date" required min={firstDay} value={f.start} onChange={(e) => { clear('tf-start'); setF({ ...f, start: e.target.value, end: e.target.value ? plusMonths(e.target.value, months) : f.end }); }} {...err(errors, 'tf-start')} /><FieldError errors={errors} id="tf-start" /></div>
          <div className="field"><label className="field__label" htmlFor="tf-end">Fin de la renta *</label><input className="input" id="tf-end" type="date" required min={f.start} value={f.end} onChange={(e) => set('end')(e.target.value)} {...err(errors, 'tf-end')} />
            <div className="choice-row" style={{ marginTop: '.375rem' }} role="group" aria-label="Duración">
              {[6, 12, 24].map((m) => <button key={m} type="button" className={'btn btn--sm' + (months === m && f.end === plusMonths(f.start, m) ? '' : ' btn--secondary')} onClick={() => duration(m)}>{m} meses</button>)}
            </div><FieldError errors={errors} id="tf-end" /></div>
          <div className="field"><label className="field__label" htmlFor="tf-rent">Renta mensual (MXN) *</label><MoneyInput id="tf-rent" required value={f.rent} onChange={set('rent')} {...err(errors, 'tf-rent')} /><FieldError errors={errors} id="tf-rent" /></div>
          <div className="field"><label className="field__label" htmlFor="tf-day">Día de pago de cada mes *</label>
            <select className="select" id="tf-day" required value={f.day} onChange={(e) => set('day')(e.target.value)} {...err(errors, 'tf-day')}>
              {Array.from({ length: 28 }, (_, i) => <option key={i} value={i + 1}>Día {i + 1}</option>)}
            </select><FieldError errors={errors} id="tf-day" /></div>
          <div className="field"><label className="field__label" htmlFor="tf-deposit">Depósito (MXN)</label><MoneyInput id="tf-deposit" value={f.deposit} onChange={set('deposit')} /></div>
          <div className="field span-all"><label className="field__label" htmlFor="tf-contract">Contrato firmado (PDF) <span className="muted">(opcional ahora)</span></label>
            <input className="input" id="tf-contract" type="file" accept="application/pdf" onChange={() => clear('tf-contract')} {...err(errors, 'tf-contract')} />
            <p className="field__hint">Todas sus páginas en un solo PDF, hasta 50 MB. Si aún no lo tienes, súbelo después en Rentas › Expediente.</p><FieldError errors={errors} id="tf-contract" /></div>
          {isAdminSession() && (
            <>
              <div className="field"><label className="field__label" htmlFor="tf-cfe">Número de servicio CFE (luz)</label>
                <input className="input" id="tf-cfe" inputMode="numeric" maxLength={20} value={f.cfe} onChange={(e) => set('cfe')(e.target.value.replace(/[^\d\s-]/g, ''))} placeholder="Opcional" /></div>
              <div className="field"><label className="field__label" htmlFor="tf-water">Contrato Aguakan (agua)</label>
                <input className="input" id="tf-water" maxLength={20} value={f.water} onChange={(e) => set('water')(e.target.value)} placeholder="Opcional" /></div>
            </>
          )}
        </div>
        <div className="note-preview" aria-live="polite">
          <strong>{dates.length ? `Se generarán ${dates.length} pagarés de ${money(rent)}` : 'Elige fechas y día de pago para ver los pagarés'}</strong>
          {dates.length > 0 && <ol>{dates.map((d, i) => <li key={d}><span>Pagaré {String(i + 1).padStart(2, '0')}</span><span>{dateShort(d)} {d.slice(0, 4)}</span></li>)}</ol>}
          <p className="small muted">Después, en Rentas › Pagarés y pagos, cada pagaré se marca pagado subiendo su PDF y la foto del sello.</p>
        </div>
        <div className="dialog__actions">
          <button className="btn btn--secondary" type="button" onClick={close} disabled={!!busy}>Cancelar</button>
          <button className="btn" type="submit" disabled={!!busy}>{busy || 'Crear contrato y pagarés'}</button>
        </div>
      </form>
    </>
  );
}
/** Detalle de la cita como carrusel: flechas, teclado (← →) o deslizar recorren todas las citas filtradas. */
function AppointmentPanel({ a, deck, onGo, onStatus, onConfirm, onReschedule, onCancel, onNew, onTenant }: {
  a?: Appointment; deck: Appointment[]; onGo: (a: Appointment) => void;
  onStatus: (a: Appointment, s: string) => void; onConfirm: (a: Appointment) => void; onReschedule: (a: Appointment) => void; onCancel: (a: Appointment) => void; onNew: (personId: string) => void; onTenant: (a: Appointment) => void;
}) {
  const touchX = useRef<number | null>(null);
  const first = deck.find((x) => x.date >= Z.TODAY) ?? deck[0];
  if (!a) return (
    <section className="card card--pad appt-panel">
      <p className="muted">{deck.length ? 'No hay citas esta semana con estos filtros.' : 'No hay citas con estos filtros.'}</p>
      {first && <button className="btn btn--secondary btn--block" type="button" style={{ marginTop: '1rem' }} onClick={() => onGo(first)}>Ver la próxima cita</button>}
    </section>
  );
  const i = deck.indexOf(a);
  const prev = i > 0 ? deck[i - 1] : undefined, next = i >= 0 ? deck[i + 1] : first;
  const step = (to?: Appointment) => { if (to) onGo(to); };
  const p = prop(a.property), per = person(a.person), b = broker(a.broker);
  const open = a.status === 'confirmada' || a.status === 'por-confirmar';
  return (
    <>
      <section className="card appt-panel" aria-labelledby="ap-title" aria-live="polite"
        onKeyDown={(e) => { if ((e.target as HTMLElement).closest('input,textarea,select')) return; if (e.key === 'ArrowLeft') step(prev); if (e.key === 'ArrowRight') step(next); }}
        onTouchStart={(e) => { touchX.current = e.touches[0].clientX; }}
        onTouchEnd={(e) => { if (touchX.current === null) return; const dx = e.changedTouches[0].clientX - touchX.current; touchX.current = null; if (Math.abs(dx) > 60) step(dx < 0 ? next : prev); }}>
        <div className="appt-carousel" role="group" aria-label="Recorrer citas">
          <button className="icon-btn" type="button" aria-label="Cita anterior" disabled={!prev} onClick={() => step(prev)}><Icon id="left" /></button>
          <span>{i >= 0 ? `Cita ${i + 1} de ${deck.length}` : `${deck.length} ${plural(deck.length, 'cita', 'citas')}`}</span>
          <button className="icon-btn" type="button" aria-label="Cita siguiente" disabled={!next || next === a} onClick={() => step(next)}><Icon id="right" /></button>
        </div>
        <div className="appt-panel__top"><ApptBadge s={a.status} /><span>{a.id}</span></div>
        <h2 id="ap-title" tabIndex={-1}>Una visita a {p ? p.name : 'una propiedad eliminada'}</h2>
        <p className="when">{dateLong(a.date)}</p>
        <p>{t12(a.start)}–{t12(a.end)} · Visita {a.kind.toLowerCase()}</p>
        {p && (
          <>
            <Cover p={p} />
            <p className="strong" style={{ fontWeight: 600, color: 'var(--marino)' }}><Link to={'/propiedades/' + p.id} style={{ color: 'inherit' }}>{p.name} · {p.id}</Link></p>
            <p className="small muted" style={{ marginTop: '.5rem' }}>{p.street}, {p.zone}, Cancún</p>
          </>
        )}
        <hr />
        <span className="label-xs">{per.type === 'inquilino' ? 'Inquilino' : 'Prospecto'}{per.code ? ' · ' + per.code : ''}</span>
        <p className="strong" style={{ fontWeight: 600, color: 'var(--marino)' }}>{per.name}</p>
        <p className="small muted"><a href={'mailto:' + per.email} style={{ color: 'inherit' }}>{per.email}</a> · {per.phone}</p>
        <span className="label-xs" style={{ marginTop: '1rem' }}>Broker responsable</span>
        <p className="strong" style={{ fontWeight: 600, color: 'var(--marino)' }}>{b.name}</p>
        <p className="small muted">{b.phone}</p>
        {a.note && <div className="note-box"><strong>Nota de {per.name.split(' ')[0]}</strong>{a.note}</div>}
        {a.lead && (
          <details className="appt-form" open>
            <summary>{a.lead.linked ? 'Formulario que llenó' : 'Su solicitud más reciente'} · <Link to={'/solicitudes?id=' + a.lead.id}>{a.lead.folio}</Link></summary>
            <FormSections l={a.lead} />
          </details>
        )}
        {a.status === 'realizada' && p && p.op === 'renta' && p.status !== 'rentada' && can('contracts.manage') && apiActive() && (
          <button className="btn btn--block" type="button" style={{ marginTop: '1rem' }} onClick={() => onTenant(a)}><Icon id="user-key" />Rentarle esta casa (inquilino)</button>
        )}
        <div className="appt-actions">
          {a.status === 'confirmada' && <button className="btn btn--block" type="button" onClick={() => onStatus(a, 'realizada')}>Marcar como realizada</button>}
          {a.status === 'por-confirmar' && (a.awaiting === 'client'
            // La fecha la propuso el personal: la acepta el cliente en su app
            ? <div className="notice" role="status"><Icon id="cal-clock" /><span>Esperando que {per.name.split(' ')[0]} acepte esta fecha en su app. Te avisamos cuando la acepte.</span></div>
            : <button className="btn btn--block" type="button" onClick={() => onConfirm(a)}>Confirmar {dateShort(a.date)}, {t12(a.start)}</button>)}
          {open ? (
            <>
              <button className="btn btn--secondary btn--block" type="button" onClick={() => onReschedule(a)}>Reprogramar cita</button>
              <button className="link link--danger" type="button" onClick={() => onCancel(a)}>Cancelar cita</button>
            </>
          ) : <button className="btn btn--secondary btn--block" type="button" onClick={() => onNew(a.person)}>Agendar otra visita</button>}
        </div>
      </section>
      <p className="small muted" style={{ marginTop: '.75rem' }}>
        {a.confirmedBy || (a.status === 'por-confirmar' ? 'Pendiente de confirmación del cliente.' : `Estado: ${Z.APPT_STATUS[a.status].label.toLowerCase()}.`)} Se conserva el historial de cada cambio.
      </p>
    </>
  );
}
