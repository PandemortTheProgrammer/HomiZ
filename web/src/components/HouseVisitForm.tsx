import { Honeypot } from './Honeypot';
import { useState, type FormEvent } from 'react';
import { useNavigate } from 'react-router';
import { sendLead, type ApiError } from '../lib/api';
import { downloadLink } from '../lib/appLink';
import { priceUnit, type House } from '../lib/catalog';
import { longDate, money, t12 } from '../lib/format';
import { useLiveErrors } from '../lib/useLiveErrors';
import { clean, emailRepeat, emailStrict, futureDate, personName, phone, phoneChars, required, text, words, type Errors } from '../lib/validation';
import { budgetError } from './BudgetRange';
import { Dialog } from './Dialog';
import { EmailFields } from './EmailFields';
import { MoneyInput, moneyText } from './NumberInput';
import { PrivacyLink } from './PrivacyNotice';
import { VisitSlotPicker } from './VisitSlotPicker';
import { Field, invalid, Opt } from './Field';
import { ReviewAccountNote } from './ReviewAccountNote';
import { Icon } from './Icon';
import { useToast } from './Toasts';

/* ==========================================================================
   «¿Te imaginas viviendo aquí?»: solicitud de visita dentro de la ficha de una casa.
   Al enviar se guarda un resumen para la página de Gracias y se pasa a ella.
   ========================================================================== */
const PAYMENT: [string, string][] = [['contado', 'De contado'], ['credito-bancario', 'Crédito bancario'], ['infonavit', 'Infonavit o Fovissste'], ['no-se', 'Aún no lo sé']];
export const LAST_CONTACT_KEY = 'zugar-ultimo-contacto';

const EMPTY = {
  nombre: '', correo: '', correo2: '', telefono: '', nacionalidad: '', ocupacion: '', presupuesto: '', forma_pago: '',
  personas: '2', mascotas: '' as '' | 'si' | 'no', mascotas_detalle: '', fecha: '', horario: '', comentarios: '', privacidad: false,
};
type Form = typeof EMPTY;

export function HouseVisitForm({ house: c }: { house: House }) {
  const toast = useToast();
  const navigate = useNavigate();
  const [f, setF] = useState<Form>(EMPTY);
  const [reviewing, setReviewing] = useState(false);
  const [sending, setSending] = useState(false);
  const sale = c.op === 'venta';
  const advisor = c.asesor || 'Tu asesora de Zugar';
  const first = advisor.split(' ')[0];

  const validate = (x: Form): Errors =>
    clean({
      nombre: personName(x.nombre), correo: emailStrict(x.correo), correo2: emailRepeat(x.correo, x.correo2), telefono: phone(x.telefono),
      nacionalidad: words(x.nacionalidad, 3, 40), ocupacion: text(x.ocupacion, 3, 80), presupuesto: budgetError('', x.presupuesto, sale ? 'compra' : 'renta'),
      forma_pago: sale ? required(x.forma_pago, true) : '',
      mascotas: x.mascotas ? '' : 'Elige una opción.',
      mascotas_detalle: x.mascotas === 'si' ? text(x.mascotas_detalle, 3, 200) : '',
      fecha: futureDate(x.fecha) && 'Elige el día de tu cita en el calendario.', horario: x.horario ? '' : 'Elige la hora de tu cita.',
      privacidad: x.privacidad ? '' : 'Marca esta casilla para continuar.',
    });

  const errors = validate(f);
  const live = useLiveErrors(errors);

  const set = <K extends keyof Form>(k: K, v: Form[K]) => {
    live.touch(k);
    setF((x) => ({ ...x, [k]: v }));
  };

  const onSubmit = (e: FormEvent) => {
    e.preventDefault();
    live.showAll();
    const firstError = Object.keys(errors)[0];
    if (firstError) {
      document.getElementById(firstError === 'mascotas' ? 'mascotas-si' : `b-${firstError}`)?.focus();
      return;
    }
    setReviewing(true);
  };

  const send = async () => {
    setReviewing(false);
    setSending(true);
    try {
      const { nombre, correo, correo2: _c2, telefono, comentarios, fecha, horario, privacidad: _ok, presupuesto, ...rest } = f;
      const r = await sendLead({
        reason: 'visita', name: nombre.trim(), email: correo.trim(), phone: telefono, message: comentarios,
        propertyCode: c.code, propertySlug: c.slug, preferredDate: fecha, preferredTime: horario,
        payload: { ...rest, presupuesto: moneyText(presupuesto) + ' ' + priceUnit(c), presupuesto_max: Number(presupuesto) || null } as Record<string, string | number | null>,
      });
      try {
        sessionStorage.setItem(LAST_CONTACT_KEY, JSON.stringify({
          nombre: nombre.trim(), motivo: 'visita', folio: r.folio, fecha: longDate(fecha), hora: horario, asesor: c.asesor, slug: c.slug,
          // Para «Cambiar mis datos» en la página de Gracias (2 horas)
          correo: correo.trim(), telefono: telefono.trim(), editToken: 'editToken' in r ? r.editToken : null,
        }));
      } catch {
        /* sin almacenamiento: la página de Gracias muestra el texto general */
      }
      navigate('/gracias');
    } catch (err) {
      const e = err as ApiError;
      if (!e?.mensaje) console.error(err);
      toast(e?.sinConexion ? 'No hay conexión con el servidor de Zugar: tu solicitud no se envió. Revisa tu internet e inténtalo de nuevo en unos minutos.' : e?.mensaje || 'No pudimos enviar tu solicitud. Inténtalo de nuevo o usa la app Homiz.');
      setSending(false);
    }
  };

  const err = live.err;
  const rows: [string, string][] = [
    ['Nombre completo', f.nombre], ['Correo electrónico (tu cuenta de la app)', f.correo], ['Teléfono', f.telefono], ['Nacionalidad', f.nacionalidad],
    ['¿En qué trabajas?', f.ocupacion], ['Casa de interés', c.name + (c.code ? ' · ' + c.code : '')], ['Presupuesto máximo', f.presupuesto ? moneyText(f.presupuesto) + ' ' + priceUnit(c) : ''],
    ['¿Cómo planeas comprar?', sale ? PAYMENT.find(([v]) => v === f.forma_pago)?.[1] ?? '' : ''],
    ['Personas que vivirán en la casa', f.personas === '5' ? '5 o más' : f.personas], ['¿Tienes mascotas?', f.mascotas === 'si' ? 'Sí' : f.mascotas === 'no' ? 'No' : ''],
    ['¿Cuáles y cuántas mascotas?', f.mascotas === 'si' ? f.mascotas_detalle : ''], ['Fecha de la cita', longDate(f.fecha)],
    ['Hora', f.horario ? t12(f.horario) + ' (15 minutos)' : ''], ['Comentarios', f.comentarios],
  ];

  return (
    <>
      <form className="booking-form booking-form--card" noValidate onSubmit={onSubmit} onBlur={live.onBlur}>
        <Honeypot />
        {live.pending && (
          <div className="alert alert-error is-visible" role="alert">
            <Icon id="alert" />
            <div><strong>Revisa los campos señalados</strong>Tu solicitud aún no se ha enviado. Lo que escribiste se conserva.</div>
          </div>
        )}
        <fieldset>
          <legend>1. Tus datos</legend>
          <div className="form-grid">
            <Field id="b-nombre" label="Nombre completo *" error={err('nombre')}>
              <input className="input" id="b-nombre" type="text" autoComplete="name" maxLength={80} placeholder="Nombre y apellidos" value={f.nombre} onChange={(e) => set('nombre', e.target.value)} {...invalid('b-nombre', err('nombre'))} />
            </Field>
            <EmailFields prefix="b" value={f.correo} repeat={f.correo2} error={err('correo')} repeatError={err('correo2')}
              onChange={(v, r) => { if (v !== f.correo) live.touch('correo'); if (r !== f.correo2) live.touch('correo2'); setF((x) => ({ ...x, correo: v, correo2: r })); }} />
            <Field id="b-telefono" label={<>Teléfono <Opt>(opcional)</Opt></>} error={err('telefono')} help={err('telefono') ? undefined : 'Para confirmar tu visita por WhatsApp.'}>
              <input className="input" id="b-telefono" type="tel" autoComplete="tel" maxLength={17} placeholder="998 000 0000" value={f.telefono} onChange={(e) => set('telefono', phoneChars(e.target.value))} {...invalid('b-telefono', err('telefono'))} />
            </Field>
            <Field id="b-nacionalidad" label="Nacionalidad *" error={err('nacionalidad')}>
              <input className="input" id="b-nacionalidad" type="text" autoComplete="country-name" maxLength={40} placeholder="Mexicana" value={f.nacionalidad} onChange={(e) => set('nacionalidad', e.target.value)} {...invalid('b-nacionalidad', err('nacionalidad'))} />
            </Field>
            <Field id="b-ocupacion" label="¿En qué trabajas? *" error={err('ocupacion')}>
              <input className="input" id="b-ocupacion" type="text" autoComplete="organization-title" maxLength={80} placeholder="Por ejemplo: diseño de interiores" value={f.ocupacion} onChange={(e) => set('ocupacion', e.target.value)} {...invalid('b-ocupacion', err('ocupacion'))} />
            </Field>
          </div>
        </fieldset>
        <fieldset>
          <legend>2. Esta casa</legend>
          <div className="form-grid">
            <Field id="b-casa-ref" label="Casa de interés">
              <input className="input" id="b-casa-ref" type="text" value={c.name + (c.code ? ' · ' + c.code : '')} readOnly />
            </Field>
            <Field id="b-presupuesto" label={`Presupuesto máximo ${sale ? '' : 'al mes '}*`} error={err('presupuesto')}
              help={err('presupuesto') ? undefined : 'Lo más que quieres pagar. Con este límite te presentamos también cualquier otra casa que no lo pase.'}>
              <MoneyInput id="b-presupuesto" placeholder={`${money(c.price)} ${priceUnit(c)}`} value={f.presupuesto} onChange={(v) => set('presupuesto', v)} {...invalid('b-presupuesto', err('presupuesto'))} />
            </Field>
            {sale && (
              <Field id="b-forma_pago" label="¿Cómo planeas comprar? *" error={err('forma_pago')}>
                <select className="select" id="b-forma_pago" value={f.forma_pago} onChange={(e) => set('forma_pago', e.target.value)} {...invalid('b-forma_pago', err('forma_pago'))}>
                  <option value="">Elige una opción</option>
                  {PAYMENT.map(([v, t]) => <option key={v} value={v}>{t}</option>)}
                </select>
              </Field>
            )}
            <Field id="b-personas" label="Personas que vivirán en la casa *">
              <select className="select" id="b-personas" value={f.personas} onChange={(e) => set('personas', e.target.value)}>
                <option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5 o más</option>
              </select>
            </Field>
            <Field id="b-mascotas" label="¿Tienes mascotas? *" error={err('mascotas')} group>
              <div className="choice-group">
                {(['si', 'no'] as const).map((v) => (
                  <label key={v} className="choice">
                    <input type="radio" id={`mascotas-${v}`} name="mascotas" value={v} checked={f.mascotas === v} onChange={() => set('mascotas', v)} />
                    <span>{v === 'si' ? 'Sí' : 'No'}</span>
                  </label>
                ))}
              </div>
            </Field>
            {f.mascotas === 'si' && (
              <Field id="b-mascotas_detalle" label="¿Cuáles y cuántas mascotas? *" error={err('mascotas_detalle')} help={err('mascotas_detalle') ? undefined : c.pets ? 'Esta casa acepta mascotas.' : 'Esta casa no acepta mascotas; cuéntanos si tienes alguna.'}>
                <input className="input" id="b-mascotas_detalle" type="text" maxLength={200} placeholder="Por ejemplo: 1 perro pequeño" value={f.mascotas_detalle} onChange={(e) => set('mascotas_detalle', e.target.value)} {...invalid('b-mascotas_detalle', err('mascotas_detalle'))} />
              </Field>
            )}
          </div>
        </fieldset>
        <fieldset>
          <legend>3. ¿Te gustaría agendar una cita?</legend>
          <VisitSlotPicker id="b" slug={c.slug} date={f.fecha} time={f.horario} dateError={err('fecha')} timeError={err('horario')}
            onChange={(fecha, horario) => { if (fecha) live.touch('fecha'); if (horario) live.touch('horario'); setF((x) => ({ ...x, fecha, horario })); }} />
          <div className="form-grid">
            <Field id="b-comentarios" label={<>Comentarios <Opt>(opcional)</Opt></>}>
              <textarea className="textarea" id="b-comentarios" rows={3} maxLength={1000} placeholder="Por ejemplo: nos gustaría ver el jardín por la mañana." value={f.comentarios} onChange={(e) => set('comentarios', e.target.value)} />
            </Field>
          </div>
        </fieldset>
        <div className={err('privacidad') ? 'is-error' : undefined}>
          <label className="check">
            <input type="checkbox" id="b-privacidad" checked={f.privacidad} onChange={(e) => set('privacidad', e.target.checked)} {...invalid('b-privacidad', err('privacidad'))} />
            <span>Acepto el <PrivacyLink>aviso de privacidad</PrivacyLink> y que me contacten sobre esta propiedad.</span>
          </label>
          {err('privacidad') && <p className="field__error flex" id="b-privacidad-error"><Icon id="alert" size="sm" />{err('privacidad')}</p>}
        </div>
        <div className="form-actions">
          <button className="btn btn--lg btn--block" type="submit" disabled={sending} aria-busy={sending || undefined}>
            {sending ? 'Enviando…' : <>Revisar solicitud<Icon id="arrow" /></>}
          </button>
          <a className="btn btn--secondary btn--lg btn--block" href={downloadLink(c.slug)} target="_blank" rel="noopener"><Icon id="download" />Descarga nuestra app</a>
        </div>
        <p className="secure"><Icon id="shield" size="sm" />Tus datos se comparten solo con tu asesora.</p>
      </form>

      <Dialog open={reviewing} onClose={() => setReviewing(false)} labelledBy="dlg-title">
        <h2 id="dlg-title">Revisa tu solicitud</h2>
        <p className="dlg-lead">Estos son tus datos. Confirma que estén correctos: {first} te confirmará el día y la hora.</p>
        <ReviewAccountNote email={f.correo} />
        <dl className="review">
          {rows.filter(([, v]) => v && v.trim()).map(([k, v]) => <div key={k}><dt>{k}</dt><dd>{v.trim()}</dd></div>)}
        </dl>
        <div className="dlg-actions">
          <button className="btn btn--secondary" type="button" onClick={() => setReviewing(false)}>Corregir datos</button>
          <button className="btn" type="button" onClick={send} autoFocus>Enviar solicitud</button>
        </div>
      </Dialog>
    </>
  );
}
