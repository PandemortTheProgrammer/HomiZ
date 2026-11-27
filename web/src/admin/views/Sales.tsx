import { useEffect, useState, type FormEvent } from 'react';
import { Link } from 'react-router';
import { load, Sales, type ApiFailure, type Sale } from '../api';
import { MoneyInput } from '../../components/NumberInput';
import { can } from '../auth';
import { useOverlay } from '../components/Overlay';
import { Badge, Icon, Metric, Options, Tabs } from '../components/ui';
import { D as Data, dateShort, money, person, plural, prop, rerender, useStore, Z } from '../store';
import { useApiData } from './Payments';

/*
 * Ventas (decisión 124): la inmobiliaria no administra la casa vendida. Solo se registra el cierre:
 * folio VEN-###, comprobante en PDF para el comprador (en su app) y, si se tiene, el contrato firmado.
 */

const S = { tab: 'closed', selected: '' };
const failMsg = (e: unknown) => (e as ApiFailure)?.mensaje || 'No se pudo guardar. Inténtalo de nuevo.';
const PAYMENT_METHODS = ['Contado', 'Crédito bancario', 'Infonavit', 'Fovissste', 'Cofinavit', 'Otro'];
/** Umbral de aviso de la Ley Antilavado mientras llega el de la API (8,025 UMA × $117.31 de 2026) */
const FALLBACK_THRESHOLD = 941412.75;

/** Casas que se pueden vender: en venta, no vendidas y guardadas en el servidor */
const sellable = (id?: string) => { const h = id ? prop(id) : undefined; return !!h && h.op === 'venta' && h.status !== 'vendida' && !!h._id; };

/** La casa que más probablemente compró: la de su expediente o la de su cita más reciente */
function suggestHouse(personId: string): { id: string; why: string } | null {
  const per = person(personId);
  if (sellable(per.property)) return { id: per.property, why: 'la casa de su expediente' };
  const rank = (s: string) => (s === 'realizada' ? 0 : s === 'confirmada' ? 1 : s === 'por-confirmar' ? 2 : 3);
  const last = Data.appointments.filter((x) => x.person === personId && sellable(x.property))
    .sort((x, y) => rank(x.status) - rank(y.status) || (y.date + y.start).localeCompare(x.date + x.start))[0];
  return last ? { id: last.property, why: `su cita ${last.status === 'realizada' ? 'realizada' : 'más reciente'} (${dateShort(last.date)})` } : null;
}

/** «Registrar venta»: comprador, casa, fecha, precio, forma de pago, notaría, identificación y PDF (opcional). */
export function SaleForm({ pre = {}, close, onDone }: { pre?: { property?: string; person?: string }; close: () => void; onDone: (m: string) => void }) {
  const D = useStore();
  const [personId, setPersonId] = useState(pre.person ?? '');
  const [houseId, setHouseId] = useState(pre.property ?? (pre.person ? suggestHouse(pre.person)?.id ?? '' : ''));
  const [f, setF] = useState({ date: Z.TODAY, price: '', method: '', notary: '', notes: '', ine: false });
  const [threshold, setThreshold] = useState(FALLBACK_THRESHOLD);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState('');
  useEffect(() => { Sales.thresholds().then((t) => setThreshold(t.threshold), () => {}); }, []);
  const houses = D.properties.filter((h) => sellable(h.id));
  const people = D.people.slice().sort((x, y) => x.name.localeCompare(y.name));
  const house = houseId ? prop(houseId) : undefined;
  const sugg = personId ? suggestHouse(personId) : null;
  const price = Number(f.price) || 0;
  const overThreshold = price >= threshold;
  const choosePerson = (id: string) => { setPersonId(id); const s = suggestHouse(id); if (s) setHouseId(s.id); };
  const chooseHouse = (id: string) => { setHouseId(id); const h = prop(id); if (h && !f.price) setF((v) => ({ ...v, price: String(h.price || '') })); };
  useEffect(() => { if (house && !f.price) setF((v) => ({ ...v, price: String(house.price || '') })); }, [houseId]); // eslint-disable-line react-hooks/exhaustive-deps

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const pdf = (document.getElementById('sf-pdf') as HTMLInputElement | null)?.files?.[0];
    const problems = [
      !personId && 'elige al comprador',
      !houseId && 'elige la casa',
      !f.date && 'escribe la fecha de cierre',
      !price && 'escribe el precio de venta',
      overThreshold && !f.ine && `marca «Revisé su identificación oficial» (la venta es de ${money(threshold)} o más)`,
      pdf && pdf.type !== 'application/pdf' && 'el contrato debe ser un PDF',
      pdf && pdf.size > 50 * 1024 * 1024 && 'el PDF pesa más de 50 MB',
    ].filter(Boolean);
    if (problems.length) return setError('Falta: ' + problems.join(', ') + '.');
    setError('');
    setBusy('Registrando la venta…');
    try {
      const sale = await Sales.create({
        propertyId: house!._id!, clientId: personId, saleDate: f.date, price,
        paymentMethod: f.method || null, notary: f.notary.trim() || null, identityChecked: f.ine, notes: f.notes.trim() || null,
      });
      let pending = '';
      if (pdf) {
        setBusy(`Subiendo el contrato (${(pdf.size / 1024 / 1024).toFixed(1)} MB)…`);
        await Sales.attachPdf(sale, pdf).catch((er) => { pending = ` No se subió el PDF (${failMsg(er)}); súbelo desde la venta.`; });
      }
      house!.status = 'vendida';
      house!.visibility = 'pausada';
      close();
      onDone(`Venta ${sale.folio} registrada: ${house!.name} quedó vendida y fuera del sitio. ${person(personId).name} ya ve su comprobante en la app.${pending}`);
      load().then(rerender, () => {});
    } catch (er) {
      setError(failMsg(er));
      setBusy('');
    }
  };

  return (
    <>
      <h2 id="dialog-title">Registrar venta</h2>
      <p className="lead">Deja constancia de que el cliente cerró con nosotros. La casa queda vendida y sale del sitio; el comprador recibe su comprobante en la app. No administramos la casa después.</p>
      <form noValidate onSubmit={submit}>
        {error && <div className="notice notice--error" role="alert"><Icon id="alert" /><span>{error}</span></div>}
        <div className="form-grid">
          <div className="field"><label className="field__label" htmlFor="sf-person">Comprador *</label>
            <select className="select" id="sf-person" value={personId} onChange={(e) => choosePerson(e.target.value)}>
              <Options list={people.map((x): [string, string] => [x.id, `${x.code ? x.code + ' · ' : ''}${x.name}`])} placeholder="Elige al cliente" />
            </select>
            <p className="field__hint">¿No aparece? Regístralo primero en Personas.</p></div>
          <div className="field"><label className="field__label" htmlFor="sf-house">Casa vendida *</label>
            <select className="select" id="sf-house" value={houseId} onChange={(e) => chooseHouse(e.target.value)}>
              <Options list={houses.map((h): [string, string] => [h.id, `${h.id} · ${h.name} · ${money(h.price)}`])} placeholder="Elige la casa en venta" />
            </select>
            {sugg && sugg.id === houseId && <p className="field__hint">Elegida por {sugg.why}. Puedes cambiarla.</p>}</div>
          <div className="field"><label className="field__label" htmlFor="sf-date">Fecha de cierre *</label>
            <input className="input" id="sf-date" type="date" value={f.date} max={Z.TODAY} onChange={(e) => setF({ ...f, date: e.target.value })} />
            <p className="field__hint">Firma de la promesa o de la escritura.</p></div>
          <div className="field"><label className="field__label" htmlFor="sf-price">Precio de venta *</label>
            <MoneyInput id="sf-price" value={f.price} onChange={(v) => setF({ ...f, price: v })} suggestions={house?.price ? [house.price] : undefined} /></div>
          <div className="field"><label className="field__label" htmlFor="sf-method">Forma de pago</label>
            <select className="select" id="sf-method" value={f.method} onChange={(e) => setF({ ...f, method: e.target.value })}>
              <Options list={PAYMENT_METHODS.map((m): [string, string] => [m, m])} placeholder="Sin especificar" />
            </select></div>
          <div className="field"><label className="field__label" htmlFor="sf-notary">Notaría</label>
            <input className="input" id="sf-notary" maxLength={120} placeholder="Por ejemplo: Notaría 30 de Cancún" value={f.notary} onChange={(e) => setF({ ...f, notary: e.target.value })} /></div>
          <div className="field span-all"><label className="field__label" htmlFor="sf-pdf">Contrato de compraventa o promesa firmado (PDF, opcional)</label>
            <input className="input" id="sf-pdf" type="file" accept="application/pdf" />
            <p className="field__hint">El comprador lo podrá descargar en su app. Puedes subirlo después.</p></div>
          <div className="field span-all"><label className="field__label" htmlFor="sf-notes">Notas internas</label>
            <input className="input" id="sf-notes" maxLength={500} placeholder="Solo las ve el personal" value={f.notes} onChange={(e) => setF({ ...f, notes: e.target.value })} /></div>
        </div>
        <div className={'notice ' + (overThreshold ? 'notice--warn' : 'notice--info')} style={{ marginTop: '1rem' }}>
          <Icon id="alert" />
          <span>
            {overThreshold
              ? <>Ley Antilavado: la venta es de {money(threshold)} o más (8,025 UMA). Hay que <strong>presentar aviso al SAT</strong> a más tardar el día 17 del mes siguiente y conservar copia de la identificación del comprador. Hazlo con tu contador o en el portal del SAT.</>
              : <>Ley Antilavado: la compraventa de casas es actividad vulnerable. Pide y guarda copia de la identificación oficial del comprador aunque no llegue al umbral de aviso ({money(threshold)}).</>}
          </span>
        </div>
        <label className="check" style={{ marginTop: '.75rem', display: 'flex', gap: '.5rem', alignItems: 'center' }}>
          <input type="checkbox" checked={f.ine} onChange={(e) => setF({ ...f, ine: e.target.checked })} />
          <span>Revisé su identificación oficial (INE o pasaporte){overThreshold ? ' *' : ''}</span>
        </label>
        <div className="dialog__actions">
          <button className="btn btn--secondary" type="button" onClick={close}>Cancelar</button>
          <button className="btn" type="submit" disabled={!!busy}>{busy || 'Registrar venta'}</button>
        </div>
      </form>
    </>
  );
}

/** Anular una venta registrada por error: la casa vuelve a estar disponible (pausada). */
function VoidForm({ s, close, onDone }: { s: Sale; close: () => void; onDone: (m: string) => void }) {
  const [reason, setReason] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const submit = (e: FormEvent) => {
    e.preventDefault();
    if (reason.trim().length < 3) return setError('Escribe el motivo (mínimo 3 letras).');
    setBusy(true);
    Sales.void(s.id, reason.trim()).then(() => { close(); onDone(`Venta ${s.folio} anulada. ${s.property.name} vuelve a estar disponible (pausada hasta que la publiques).`); load().then(rerender, () => {}); },
      (er) => { setError(failMsg(er)); setBusy(false); });
  };
  return (
    <>
      <h2 id="dialog-title">Anular la venta {s.folio}</h2>
      <p className="lead">{s.property.name} · {s.client.name}. Úsalo solo si se registró por error o la operación se cayó. El comprobante quedará marcado como ANULADO y la casa vuelve a estar disponible.</p>
      <form noValidate onSubmit={submit}>
        {error && <div className="notice notice--error" role="alert"><Icon id="alert" /><span>{error}</span></div>}
        <div className="field"><label className="field__label" htmlFor="vf-reason">Motivo *</label>
          <input className="input" id="vf-reason" maxLength={300} value={reason} onChange={(e) => setReason(e.target.value)} placeholder="Por ejemplo: el crédito no se aprobó" /></div>
        <div className="dialog__actions">
          <button className="btn btn--secondary" type="button" onClick={close}>Cancelar</button>
          <button className="btn link--danger" type="submit" disabled={busy}>{busy ? 'Anulando…' : 'Anular venta'}</button>
        </div>
      </form>
    </>
  );
}

function SaleDetail({ s, onChanged }: { s: Sale; onChanged: () => void }) {
  const { open, toast } = useOverlay();
  const [uploading, setUploading] = useState(false);
  const upload = (file?: File) => {
    if (!file) return;
    if (file.type !== 'application/pdf') return toast('El contrato debe ser un PDF.');
    setUploading(true);
    Sales.attachPdf(s, file).then(() => { toast('Contrato subido. El comprador ya lo puede descargar en su app.'); onChanged(); }, (e) => toast(failMsg(e))).finally(() => setUploading(false));
  };
  return (
    <section aria-labelledby="sl-title" style={{ marginTop: '1.5rem' }}>
      <div className="card__head" style={{ marginBottom: '.75rem' }}>
        <h2 className="card__title" id="sl-title">{s.folio} · {s.property.name}</h2>
        <Badge label={s.status === 'closed' ? 'Vendida' : 'Anulada'} tone={s.status === 'closed' ? 'ok' : 'gris'} />
      </div>
      <div className="grid-2">
        <section className="card card--pad" aria-labelledby="sl-data">
          <h3 className="card__title card__title--sm" id="sl-data" style={{ marginBottom: '.75rem' }}>Venta</h3>
          <dl className="facts-list" style={{ marginTop: 0 }}>
            <div><dt>Fecha de cierre</dt><dd>{dateShort(s.saleDate)} {s.saleDate.slice(0, 4)}</dd></div>
            <div><dt>Precio</dt><dd>{money(s.price)}</dd></div>
            <div><dt>Forma de pago</dt><dd>{s.paymentMethod ?? 'Sin especificar'}</dd></div>
            <div><dt>Notaría</dt><dd>{s.notary ?? 'Sin especificar'}</dd></div>
            <div><dt>Identificación revisada</dt><dd>{s.identityChecked ? 'Sí' : 'No'}</dd></div>
            <div><dt>Broker</dt><dd>{s.broker?.name ?? 'Sin broker'}</dd></div>
            <div><dt>Registró</dt><dd>{s.createdBy ?? '—'}</dd></div>
            {s.notes && <div><dt>Notas</dt><dd>{s.notes}</dd></div>}
            {s.status === 'voided' && <div><dt>Anulada</dt><dd>{s.voidReason}</dd></div>}
          </dl>
          {s.antiMoneyLaundering.requiresNotice && s.status === 'closed' && (
            <div className="notice notice--warn" style={{ marginTop: '1rem' }}><Icon id="alert" /><span>Supera {money(s.antiMoneyLaundering.threshold)} (8,025 UMA): presenta el aviso de la Ley Antilavado al SAT a más tardar el día 17 del mes siguiente al cierre.</span></div>
          )}
          <div className="choice-row" style={{ marginTop: '1rem' }}>
            <button className="btn btn--sm btn--secondary" type="button" onClick={() => Sales.openReceipt(s.id).catch((e) => toast(failMsg(e)))}><Icon id="file-edit" />Ver comprobante (PDF)</button>
            {s.hasDocument && <button className="btn btn--sm btn--secondary" type="button" onClick={() => Sales.openContract(s.id).catch((e) => toast(failMsg(e)))}><Icon id="file-edit" />Ver contrato firmado</button>}
            {s.status === 'closed' && can('contracts.manage') && (
              <label className="btn btn--sm btn--secondary" style={{ cursor: 'pointer' }}>
                {uploading ? 'Subiendo…' : s.hasDocument ? 'Reemplazar contrato (PDF)' : 'Subir contrato (PDF)'}
                <input type="file" accept="application/pdf" hidden disabled={uploading} onChange={(e) => upload(e.target.files?.[0])} />
              </label>
            )}
            {s.status === 'closed' && can('contracts.manage') && (
              <button className="btn btn--sm btn--secondary link--danger" type="button" onClick={() => open((close) => <VoidForm s={s} close={close} onDone={(m) => { toast(m); onChanged(); }} />)}>Anular venta</button>
            )}
          </div>
        </section>
        <section className="card card--pad" aria-labelledby="sl-buyer">
          <h3 className="card__title card__title--sm" id="sl-buyer" style={{ marginBottom: '.75rem' }}>Comprador</h3>
          <p className="strong" style={{ color: 'var(--marino)' }}><Link to={'/personas?persona=' + s.client.id} style={{ color: 'inherit' }}>{s.client.code ? s.client.code + ' · ' : ''}{s.client.name}</Link></p>
          <div className="contact-lines" style={{ marginTop: '.5rem' }}>
            {s.client.email && <a href={'mailto:' + s.client.email}>{s.client.email}</a>}
            {s.client.phone && <a href={'tel:' + s.client.phone.replace(/\s/g, '')}>{s.client.phone}</a>}
          </div>
          <p className="small muted" style={{ marginTop: '.75rem' }}>En su app ve «Mis compras» con el comprobante{s.hasDocument ? ' y el contrato' : ''}. Puede seguir pidiendo visitas a otras casas.</p>
          <p className="small muted" style={{ marginTop: '.5rem' }}>El comprobante no sustituye la escritura pública ante notario ni es factura.</p>
          <Link className="link" to={'/propiedades/' + s.property.code}>Ver la ficha de {s.property.name} <Icon id="arrow" className="icon--sm" /></Link>
        </section>
      </div>
    </section>
  );
}

/** Ventas dentro de la sección «Rentas y ventas» */
export function SalesPanel({ reloadKey }: { reloadKey: number }) {
  const [tab, setTab] = useState(S.tab);
  const [selected, setSelected] = useState(S.selected);
  const list = useApiData(() => Sales.list(tab === 'all' ? '' : tab), [tab, reloadKey]);
  const rows = list.data ?? [];
  const closed = rows.filter((s) => s.status === 'closed');
  const sel = rows.find((s) => s.id === selected) ?? rows[0];
  const choose = (id: string) => { S.selected = id; setSelected(id); setTimeout(() => document.getElementById('sl-detail')?.scrollIntoView({ behavior: 'smooth', block: 'start' }), 50); };
  const thisYear = closed.filter((s) => s.saleDate.startsWith(Z.TODAY.slice(0, 4)));
  return (
    <>
      <div className="metrics">
        <Metric label="Casas vendidas" value={closed.length} note={tab === 'closed' ? 'Ventas registradas' : 'En esta lista'} />
        <Metric label={`Ventas ${Z.TODAY.slice(0, 4)}`} value={money(thisYear.reduce((n, s) => n + s.price, 0))} note={`${thisYear.length} ${plural(thisYear.length, 'venta', 'ventas')} este año`} />
        <Metric label="Con aviso antilavado" value={closed.filter((s) => s.antiMoneyLaundering.requiresNotice).length} note="Superan 8,025 UMA" />
        <Metric label="Sin contrato en PDF" value={closed.filter((s) => !s.hasDocument).length} note="Súbelo cuando lo tengas" />
      </div>
      <Tabs name="sl" label="Filtrar ventas" selected={tab} onSelect={(v) => { S.tab = v; setTab(v); }} items={[['closed', 'Vendidas'], ['voided', 'Anuladas'], ['all', 'Todas']]} />
      {list.error ? <div className="notice notice--error" role="alert"><Icon id="alert" /><span>{list.error}</span></div>
        : list.loading && !list.data ? <p className="muted" role="status" style={{ marginTop: '1rem' }}>Cargando ventas…</p>
        : !rows.length ? <p className="muted" style={{ marginTop: '1rem' }}>No hay ventas {tab === 'closed' ? 'registradas' : tab === 'voided' ? 'anuladas' : ''}. Con «Registrar venta» dejas el comprobante de cierre para el comprador.</p>
        : (
          <ul style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: '1rem', marginTop: '1rem', listStyle: 'none', padding: 0 }}>
            {rows.map((s) => (
              <li key={s.id}>
                <button type="button" className={'card card--pad' + (s.id === sel?.id ? ' is-selected' : '')} aria-pressed={s.id === sel?.id} onClick={() => choose(s.id)}
                  style={{ width: '100%', textAlign: 'left', cursor: 'pointer', borderColor: s.id === sel?.id ? 'var(--marino)' : undefined }}>
                  <strong style={{ color: 'var(--marino)', display: 'block' }}>{s.property.name}</strong>
                  <span className="small">{s.client.name}</span>
                  <span className="small muted" style={{ display: 'block', marginTop: '.375rem' }}>{s.folio} · {money(s.price)}</span>
                  <span className="small muted" style={{ display: 'block' }}>Cierre {dateShort(s.saleDate)} {s.saleDate.slice(0, 4)}{s.hasDocument ? ' · con contrato' : ''}</span>
                  <span style={{ display: 'block', marginTop: '.5rem' }}><Badge label={s.status === 'closed' ? 'Vendida' : 'Anulada'} tone={s.status === 'closed' ? 'ok' : 'gris'} /></span>
                </button>
              </li>
            ))}
          </ul>
        )}
      <div id="sl-detail" aria-live="polite">{sel && <SaleDetail key={sel.id + sel.status + sel.hasDocument} s={sel} onChanged={() => list.reload()} />}</div>
    </>
  );
}
