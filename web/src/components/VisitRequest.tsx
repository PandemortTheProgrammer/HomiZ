import { Honeypot } from './Honeypot';
import { useMemo, useState, type FormEvent } from 'react';
import { sendLead, type ApiError } from '../lib/api';
import { longDate, t12 } from '../lib/format';
import { useLiveErrors } from '../lib/useLiveErrors';
import { clean, emailRepeat, emailStrict, futureDate, personName, phone, phoneChars, text, words, type Errors } from '../lib/validation';
import { BudgetRange, budgetError, budgetLabel, toAmount } from './BudgetRange';
import { useCatalog } from './CatalogProvider';
import { Dialog } from './Dialog';
import { EmailFields } from './EmailFields';
import { PrivacyLink } from './PrivacyNotice';
import { ReviewAccountNote } from './ReviewAccountNote';
import { VisitSlotPicker } from './VisitSlotPicker';
import { Field, invalid, Opt } from './Field';
import { Icon } from './Icon';
import { LeadDone } from './LeadDone';
import { useToast } from './Toasts';

/* ==========================================================================
   Solicitud (sección «Contáctanos» del inicio): qué busca la persona, zona de preferencia
   (opcional) y presupuesto mínimo y máximo. Antes de enviar se muestra un resumen.
   Al enviar se crea sola su cuenta de la app Homiz, donde su asesor le contesta y le propone casas.
   Envía a POST /public/leads; sin servidor muestra el error (no simula el envío).
   ========================================================================== */

const EMPTY = {
  nombre: '', correo: '', correo2: '', telefono: '', nacionalidad: '', ocupacion: '',
  operacion: 'renta' as 'renta' | 'compra', zona: '', presupuesto_min: '', presupuesto_max: '',
  recamaras: '3', banos: '2', personas: '2', mascotas: '' as '' | 'si' | 'no', mascotas_detalle: '',
  fecha: '', horario: '', comentarios: '',
};
type Form = typeof EMPTY;

export function VisitRequest() {
  const { houses, loading } = useCatalog();
  const toast = useToast();
  const [f, setF] = useState<Form>(EMPTY);
  const [reviewing, setReviewing] = useState(false);
  const [sending, setSending] = useState(false);
  const [done, setDone] = useState<{ folio: string; text: string; account: 'created' | 'existing' | null; editToken?: string | null } | null>(null);
  // Sugerencias para «Zona de preferencia»: las zonas de las casas publicadas (se puede escribir cualquier otra)
  const places = useMemo(() => [...new Set(houses.map((h) => h.zona))].sort(), [houses]);
  const budget = budgetLabel(f.presupuesto_min, f.presupuesto_max, f.operacion);

  const validate = (x: Form): Errors =>
    clean({
      nombre: personName(x.nombre),
      correo: emailStrict(x.correo),
      correo2: emailRepeat(x.correo, x.correo2),
      telefono: phone(x.telefono),
      nacionalidad: words(x.nacionalidad, 3, 40),
      ocupacion: text(x.ocupacion, 3, 80),
      zona: text(x.zona, 2, 80, false),
      presupuesto_max: budgetError(x.presupuesto_min, x.presupuesto_max, x.operacion),
      mascotas: x.mascotas ? '' : 'Elige una opción.',
      mascotas_detalle: x.mascotas === 'si' ? text(x.mascotas_detalle, 3, 200) : '',
      fecha: futureDate(x.fecha) && 'Elige el día de tu cita en el calendario.',
      horario: x.horario ? '' : 'Elige la hora de tu cita.',
    });

  const errors = validate(f);
  const live = useLiveErrors(errors);

  const set = <K extends keyof Form>(k: K, v: Form[K]) => {
    live.touch(k);
    setF((x) => ({ ...x, [k]: v }));
  };
  // El máximo se revisa cuando ya lo escribió; mientras solo llena el mínimo no se le reclama
  const setBudget = (min: string, max: string) => {
    if (max !== f.presupuesto_max || (min && max)) live.touch('presupuesto_max');
    setF((x) => ({ ...x, presupuesto_min: min, presupuesto_max: max }));
  };

  const onSubmit = (e: FormEvent) => {
    e.preventDefault();
    if (loading) return; // aún se carga el catálogo
    live.showAll();
    const first = Object.keys(errors)[0];
    if (first) {
      document.getElementById(first === 'mascotas' ? 'mascotas-si' : first === 'presupuesto_max' ? 'b-pres-max' : `b-${first}`)?.focus();
      return;
    }
    setReviewing(true);
  };

  const send = async () => {
    setReviewing(false);
    setSending(true);
    try {
      const { nombre, correo, correo2: _c2, telefono, comentarios, fecha, horario, presupuesto_min, presupuesto_max, ...rest } = f;
      const r = await sendLead({
        reason: f.operacion === 'compra' ? 'comprar' : 'rentar', name: nombre.trim(), email: correo.trim(), phone: telefono, message: comentarios,
        // Montos como número; «presupuesto» es el texto legible para el asesor
        payload: { ...rest, presupuesto: budget, presupuesto_min: toAmount(presupuesto_min), presupuesto_max: toAmount(presupuesto_max), fecha_preferida: fecha, horario },
      });
      const first = nombre.trim().split(' ')[0];
      setDone({
        folio: r.folio,
        account: r.account,
        editToken: 'editToken' in r ? r.editToken : null,
        text: `¡Gracias, ${first}! Recibimos tu solicitud.|Tu asesor te propondrá casas ${f.operacion === 'compra' ? 'en venta' : 'en renta'} y te contactará para visitarlas el ${longDate(fecha).toLowerCase()} a las ${t12(horario)}.`,
      });
    } catch (err) {
      const e = err as ApiError;
      if (!e?.mensaje) console.error(err);
      toast(e?.sinConexion ? 'No hay conexión con el servidor de Zugar: tu solicitud no se envió. Revisa tu internet e inténtalo de nuevo en unos minutos.' : e?.mensaje || 'No pudimos enviar tu solicitud. Inténtalo de nuevo o usa la app Homiz.');
    } finally {
      setSending(false);
    }
  };

  const reset = () => {
    setF(EMPTY); live.reset(); setDone(null);
    setTimeout(() => document.getElementById('b-nombre')?.focus(), 0);
  };

  const reviewRows = ([
    ['Nombre completo', f.nombre], ['Correo electrónico (tu cuenta de la app)', f.correo], ['Teléfono', f.telefono], ['Nacionalidad', f.nacionalidad],
    ['¿En qué trabajas?', f.ocupacion], ['Operación', f.operacion === 'compra' ? 'Compra' : 'Renta'], ['Zona de preferencia', f.zona || 'Sin preferencia'],
    ['Presupuesto', budget], ['Número de recámaras', f.recamaras === '4' ? '4 o más' : f.recamaras], ['Número de baños', f.banos === '3' ? '3 o más' : f.banos],
    ['Personas que vivirán en la casa', f.personas === '5' ? '5 o más' : f.personas], ['¿Tienes mascotas?', f.mascotas === 'si' ? 'Sí' : f.mascotas === 'no' ? 'No' : ''],
    ['¿Cuáles y cuántas mascotas?', f.mascotas === 'si' ? f.mascotas_detalle : ''], ['Fecha de la cita', f.fecha ? longDate(f.fecha) : ''],
    ['Hora', f.horario ? t12(f.horario) + ' (15 minutos)' : ''], ['Comentarios', f.comentarios],
  ] as [string, string][]).filter(([, v]) => v.trim());

  const err = live.err;

  return (
    <div className="booking__layout">
      <aside className="booking__aside" aria-label="Resumen de tu solicitud">
        <section className="summary" id="resumen" aria-labelledby="resumen-titulo" aria-live="polite">
          <span className="eyebrow">Tu solicitud</span>
          <h3 id="resumen-titulo">{f.operacion === 'compra' ? 'Quieres comprar' : 'Quieres rentar'}</h3>
          <p className="summary__loc">{f.zona ? `Zona de preferencia: ${f.zona}` : 'Te propondremos casas según lo que buscas.'}</p>
          {budget && <p className="summary__price"><strong>{budget}</strong></p>}
          <p className="summary__specs">{`${f.recamaras === '4' ? '4 o más' : f.recamaras} recámaras · ${f.banos === '3' ? '3 o más' : f.banos} baños`}{f.mascotas === 'si' ? ' · Con mascotas' : ''}</p>
          <dl>
            <div><dt>Operación</dt><dd>{f.operacion === 'compra' ? 'Compra' : 'Renta'}</dd></div>
            <div><dt>Para visitar</dt><dd>{f.fecha ? longDate(f.fecha) + (f.horario ? ` · ${t12(f.horario)}` : '') : 'Elige fecha y horario'}</dd></div>
            <div><dt>Te acompaña</dt><dd>Tu asesora o asesor de Zugar</dd></div>
            <div><dt>Seguimiento</dt><dd>En la app Homiz: tu cuenta se crea al enviar</dd></div>
          </dl>
          <p className="summary__foot">Tu asesor te propondrá casas y confirmará la visita contigo en la app.</p>
        </section>
        <section className="side-card" aria-labelledby="hablar-titulo">
          <h3 id="hablar-titulo">¿Prefieres hablar?</h3>
          <ul className="side-card__list">
            <li><a href="tel:+529985550142"><Icon id="phone" />+52 998 555 0142</a></li>
            <li><a href="mailto:urielagz2530@gmail.com"><Icon id="mail" />urielagz2530@gmail.com</a></li>
            <li><span><Icon id="clock" />Lun–vie 9:00–18:00 · Sáb 10:00–14:00</span></li>
          </ul>
          <p className="side-card__note">No tenemos oficina física: te atendemos por teléfono, WhatsApp y directamente en cada casa.</p>
        </section>
      </aside>

      <form className="booking-form" noValidate onSubmit={onSubmit} onBlur={live.onBlur}>
        <Honeypot />
        {done ? (
          <LeadDone
            title={done.text.split('|')[0]} text={done.text.split('|')[1]} folio={done.folio} houses={houses} onReset={reset}
            email={f.correo.trim()} account={done.account} editToken={done.editToken} name={f.nombre.trim()} phone={f.telefono.trim()}
            wish={{ op: f.operacion === 'compra' ? 'venta' : 'renta', min: toAmount(f.presupuesto_min), max: toAmount(f.presupuesto_max), rec: f.recamaras, pets: f.mascotas === 'si', zone: f.zona }}
          />
        ) : (
          <>
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
                <Field id="b-ocupacion" label="¿En qué trabajas? *" error={err('ocupacion')} className="span-2">
                  <input className="input" id="b-ocupacion" type="text" autoComplete="organization-title" maxLength={80} placeholder="Por ejemplo: diseño de interiores" value={f.ocupacion} onChange={(e) => set('ocupacion', e.target.value)} {...invalid('b-ocupacion', err('ocupacion'))} />
                </Field>
              </div>
            </fieldset>

            <fieldset>
              <legend>2. La casa que buscas</legend>
              <div className="form-grid">
                <Field id="b-operacion" label="Operación *">
                  <select className="select" id="b-operacion" value={f.operacion} onChange={(e) => set('operacion', e.target.value as Form['operacion'])}>
                    <option value="renta">Renta</option>
                    <option value="compra">Compra</option>
                  </select>
                </Field>
                <Field id="b-zona" label={<>Zona de preferencia <Opt>(opcional)</Opt></>} error={err('zona')} help={err('zona') ? undefined : 'Colonia, ciudad o país.'}>
                  <input className="input" id="b-zona" type="text" list="b-zonas" maxLength={80} placeholder="Por ejemplo: Arbolada" value={f.zona} onChange={(e) => set('zona', e.target.value)} {...invalid('b-zona', err('zona'))} />
                  <datalist id="b-zonas">{places.map((z) => <option key={z} value={z} />)}</datalist>
                </Field>
                <BudgetRange idPrefix="b-pres" op={f.operacion} min={f.presupuesto_min} max={f.presupuesto_max} error={err('presupuesto_max')} onChange={setBudget} />
                <Field id="b-recamaras" label="Número de recámaras *">
                  <select className="select" id="b-recamaras" value={f.recamaras} onChange={(e) => set('recamaras', e.target.value)}>
                    <option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4 o más</option>
                  </select>
                </Field>
                <Field id="b-banos" label="Número de baños *">
                  <select className="select" id="b-banos" value={f.banos} onChange={(e) => set('banos', e.target.value)}>
                    <option value="1">1</option><option value="2">2</option><option value="3">3 o más</option>
                  </select>
                </Field>
                <Field id="b-personas" label="Personas que vivirán en la casa *">
                  <select className="select" id="b-personas" value={f.personas} onChange={(e) => set('personas', e.target.value)}>
                    <option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5 o más</option>
                  </select>
                </Field>
                <Field id="b-mascotas" label="¿Tienes mascotas? *" error={err('mascotas')} className="span-2" group>
                  <div className="choice-group">
                    {(['si', 'no'] as const).map((v) => (
                      <label key={v} className="choice">
                        <input type="radio" id={`mascotas-${v}`} name="mascotas" value={v} checked={f.mascotas === v} onChange={() => set('mascotas', v)} {...invalid('b-mascotas', err('mascotas'))} />
                        <span>{v === 'si' ? 'Sí' : 'No'}</span>
                      </label>
                    ))}
                  </div>
                </Field>
                {f.mascotas === 'si' && (
                  <Field id="b-mascotas_detalle" label="¿Cuáles y cuántas mascotas? *" error={err('mascotas_detalle')} className="span-2" help={err('mascotas_detalle') ? undefined : 'Así te mostramos solo casas donde sean bienvenidas.'}>
                    <input className="input" id="b-mascotas_detalle" type="text" maxLength={200} placeholder="Por ejemplo: 1 perro pequeño" value={f.mascotas_detalle} onChange={(e) => set('mascotas_detalle', e.target.value)} {...invalid('b-mascotas_detalle', err('mascotas_detalle'))} />
                  </Field>
                )}
              </div>
            </fieldset>

            <fieldset>
              <legend>3. ¿Te gustaría agendar una cita?</legend>
              <VisitSlotPicker id="b" date={f.fecha} time={f.horario} dateError={err('fecha')} timeError={err('horario')}
                onChange={(fecha, horario) => { if (fecha) live.touch('fecha'); if (horario) live.touch('horario'); setF((x) => ({ ...x, fecha, horario })); }} />
              <div className="form-grid">
                <Field id="b-comentarios" label={<>Comentarios <Opt>(opcional)</Opt></>} className="span-2">
                  <textarea className="textarea" id="b-comentarios" maxLength={1000} placeholder="Por ejemplo: nos gustaría conocer el patio y la iluminación de la casa por la mañana." value={f.comentarios} onChange={(e) => set('comentarios', e.target.value)} />
                </Field>
              </div>
            </fieldset>

            <div className="form-actions">
              <button className="btn btn--lg" type="submit" disabled={sending || loading} aria-busy={sending || undefined}>
                {sending ? 'Enviando…' : <>Revisar solicitud<Icon id="arrow-ur" /></>}
              </button>
              <p className="form-note">
                Te mostraremos un resumen antes de enviar. Al continuar aceptas nuestro <PrivacyLink />.
              </p>
            </div>
          </>
        )}
      </form>

      <Dialog open={reviewing} onClose={() => setReviewing(false)} labelledBy="dlg-title">
        <h2 id="dlg-title">Revisa tu solicitud</h2>
        <p className="dlg-lead">Estos son tus datos. Confirma que estén correctos antes de enviarlos.</p>
        <ReviewAccountNote email={f.correo} />
        <dl className="review">
          {reviewRows.map(([k, v]) => (
            <div key={k}><dt>{k}</dt><dd>{v}</dd></div>
          ))}
        </dl>
        <div className="dlg-actions">
          <button className="btn btn--secondary" type="button" onClick={() => setReviewing(false)}>Corregir datos</button>
          <button className="btn" type="button" onClick={send} autoFocus>Enviar solicitud</button>
        </div>
      </Dialog>
    </div>
  );
}
