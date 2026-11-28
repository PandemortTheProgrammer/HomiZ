import { useEffect, useRef, useState, type FormEvent } from 'react';
import { Link, useSearchParams } from 'react-router';
import { apiActive, Finance, load, Rentals, type ApiFailure, type MaintDetail, type Rental } from '../api';
import { can, isAdminSession } from '../auth';
import { useOverlay } from '../components/Overlay';
import { Badge, Crumbs, Icon, Metric, Options, PageHead, Tabs } from '../components/ui';
import { dateShort, money, plural, rerender, Z } from '../store';
import { TenantForm } from './Appointments';
import { PropertyDossier } from './Dossier';
import { SaleForm, SalesPanel } from './Sales';
import { NeedsServer, PropertyPayments, useApiData } from './Payments';

/* ==========================================================================
   Rentas: cada casa rentada con su inquilino en una tarjeta (al día o con adeudo, pagarés, reportes).
   Al abrirla, todo en pestañas: Contrato · Pagarés y pagos · Mantenimiento · Expediente · Agua y luz.
   ========================================================================== */
const S = { tab: 'active', selected: '' as string, detail: 'contrato' };
const DETAIL: [string, string][] = [['contrato', 'Contrato'], ['pagos', 'Pagarés y pagos'], ['mantenimiento', 'Reportes'], ['expediente', 'Expediente'], ['servicios', 'Agua, luz y mantenimiento']];
const MONTHS = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];

/**
 * Calendario del mes: en cada día, lo que toca en las casas rentadas (renta, cuota de mantenimiento,
 * revisar agua y luz). Los mismos días en que la tarea diaria manda los avisos.
 */
function RentCalendar({ rows, onOpen }: { rows: Rental[]; onOpen: (id: string) => void }) {
  const [ym, setYm] = useState(Z.TODAY.slice(0, 7));
  const [y, m] = ym.split('-').map(Number);
  const first = new Date(y, m - 1, 1);
  const days = new Date(y, m, 0).getDate();
  const offset = (first.getDay() + 6) % 7; // lunes primero
  const shift = (n: number) => { const d = new Date(y, m - 1 + n, 1); setYm(`${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`); };
  const inPeriod = (r: Rental, day: number) => { const iso = `${ym}-${String(day).padStart(2, '0')}`; return iso >= r.startDate && iso <= r.endDate; };
  const events = (day: number) => rows.filter((r) => r.status === 'active' && inPeriod(r, day)).flatMap((r) => [
    ...(r.paymentDay === day ? [{ r, kind: 'renta', text: `Renta ${money(r.monthlyRent)}`, tone: r.notes.overdue ? 'error' : 'info' }] : []),
    ...(r.maintenanceFee?.amount && r.maintenanceFee.day === day ? [{ r, kind: 'mant', text: `Mantenimiento ${money(r.maintenanceFee.amount)}`, tone: 'warn' }] : []),
    ...((r.utilities.electricity || r.utilities.water) && r.utilities.reminderDay === day ? [{ r, kind: 'serv', text: 'Agua y luz', tone: 'gris' }] : []),
  ]);
  const today = Z.TODAY.startsWith(ym) ? Number(Z.TODAY.slice(8)) : 0;
  return (
    <section className="card card--pad" aria-labelledby="cal-title" style={{ marginTop: '1rem' }}>
      <div className="card__head">
        <h2 className="card__title" id="cal-title">{MONTHS[m - 1][0].toUpperCase() + MONTHS[m - 1].slice(1)} {y}</h2>
        <div className="choice-row">
          <button className="icon-btn" type="button" aria-label="Mes anterior" onClick={() => shift(-1)}><Icon id="left" /></button>
          <button className="btn btn--sm btn--secondary" type="button" onClick={() => setYm(Z.TODAY.slice(0, 7))}>Hoy</button>
          <button className="icon-btn" type="button" aria-label="Mes siguiente" onClick={() => shift(1)}><Icon id="right" /></button>
        </div>
      </div>
      <p className="small muted" style={{ marginBottom: '.75rem' }}>Renta (rojo si tiene pagarés vencidos), cuota de mantenimiento y revisión de agua y luz. Ese día les llega el aviso a administración, al broker y al inquilino.</p>
      <div className="rent-cal" role="grid" aria-labelledby="cal-title">
        {['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'].map((d) => <div key={d} className="rent-cal__dow" role="columnheader">{d}</div>)}
        {Array.from({ length: offset }, (_, i) => <div key={'x' + i} className="rent-cal__day is-empty" aria-hidden="true" />)}
        {Array.from({ length: days }, (_, i) => i + 1).map((day) => {
          const ev = events(day);
          return (
            <div key={day} className={'rent-cal__day' + (day === today ? ' is-today' : '')} role="gridcell" aria-label={`${day} de ${MONTHS[m - 1]}${ev.length ? ': ' + ev.map((e) => `${e.text}, ${e.r.property.name}`).join('; ') : ''}`}>
              <span className="rent-cal__num">{day}</span>
              {ev.map((e, i) => (
                <button key={i} type="button" className={'rent-cal__ev badge badge--' + e.tone} title={`${e.text} · ${e.r.property.name} · ${e.r.client.name}`} onClick={() => onOpen(e.r.id)}>
                  {e.r.property.name}: {e.kind === 'renta' ? 'renta' : e.kind === 'mant' ? 'mant.' : 'agua y luz'}
                </button>
              ))}
            </div>
          );
        })}
      </div>
    </section>
  );
}
const REPORT_TONE: Record<string, string> = { reported: 'warn', in_review: 'info', in_repair: 'warn', resolved: 'ok', cancelled: 'gris' };
const REPORT_STATUS: [string, string][] = [['reported', 'Reportado'], ['in_review', 'En revisión'], ['in_repair', 'En reparación'], ['resolved', 'Resuelto'], ['cancelled', 'Cancelado']];
const PRIORITY: Record<string, string> = { low: 'Baja', medium: 'Media', high: 'Alta' };
const failMsg = (e: unknown) => (e as ApiFailure)?.mensaje || 'No se pudo guardar. Inténtalo de nuevo.';
const year = (iso: string) => iso.slice(0, 4);

/** Al día / con adeudo, para la tarjeta y el encabezado */
function PayBadge({ r }: { r: Rental }) {
  if (r.status !== 'active') return <Badge label={r.status === 'finished' ? 'Finalizado' : 'Cancelado'} tone="gris" />;
  return r.notes.overdue ? <Badge label={`${r.notes.overdue} ${plural(r.notes.overdue, 'vencido', 'vencidos')} · ${money(r.notes.owed)}`} tone="error" /> : <Badge label="Al día" tone="ok" />;
}

/**
 * «Rentar una casa» / «Hacer inquilino»: elige la casa en renta y a la persona (lo que ya se sabe viene elegido);
 * después, el mismo formulario de contrato. Se abre desde Rentas, desde la persona y desde la casa.
 */
export function openRental(open: ReturnType<typeof useOverlay>['open'], onDone: (m: string) => void, pre: { property?: string; person?: string } = {}) {
  // Un solo formulario: cliente, casa (ya sugerida) y contrato
  open((close) => <TenantForm a={pre} close={close} onDone={onDone} />, { wide: true });
}

/** Finalizar el contrato: los pagarés futuros sin pagar se cancelan (no se borran) y la casa vuelve a estar disponible. */
function FinishForm({ r, close, onDone }: { r: Rental; close: () => void; onDone: (m: string) => void }) {
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const submit = (e: FormEvent) => {
    e.preventDefault();
    const endDate = (document.getElementById('ff-date') as HTMLInputElement).value || undefined;
    const reason = (document.getElementById('ff-reason') as HTMLInputElement).value.trim() || undefined;
    setBusy(true);
    Rentals.finish(r.id, { endDate, reason }).then(() => { close(); onDone(`Contrato de ${r.client.name} en ${r.property.name} finalizado. La casa vuelve a estar disponible (sigue pausada hasta que la publiques).`); },
      (er) => { setError(failMsg(er)); setBusy(false); });
  };
  return (
    <>
      <h2 id="dialog-title">Finalizar el contrato de {r.client.name}</h2>
      <p className="lead">{r.property.name}. Los pagarés sin pagar posteriores a la fecha de término se cancelan (quedan en el historial) y la casa vuelve a estar disponible.</p>
      <form noValidate onSubmit={submit}>
        {error && <div className="notice notice--error" role="alert"><Icon id="alert" /><span>{error}</span></div>}
        <div className="form-grid">
          <div className="field"><label className="field__label" htmlFor="ff-date">Fecha de término</label><input className="input" id="ff-date" type="date" defaultValue={Z.TODAY} max={r.endDate} /></div>
          <div className="field"><label className="field__label" htmlFor="ff-reason">Motivo</label><input className="input" id="ff-reason" maxLength={300} placeholder="Por ejemplo: terminó el periodo" /></div>
        </div>
        <div className="dialog__actions">
          <button className="btn btn--secondary" type="button" onClick={close}>Cancelar</button>
          <button className="btn link--danger" type="submit" disabled={busy}>{busy ? 'Guardando…' : 'Finalizar contrato'}</button>
        </div>
      </form>
    </>
  );
}

/** Mantenimiento de la casa: reportes del inquilino, su historial, fotos y el cambio de estado (con proveedor). */
function Maintenance({ propertyId }: { propertyId: string }) {
  const { toast } = useOverlay();
  const list = useApiData(() => Rentals.reports(propertyId), [propertyId]);
  const [sel, setSel] = useState('');
  const detail = useApiData(() => (sel ? Rentals.report(sel) : Promise.resolve(null as MaintDetail | null)), [sel]);
  const providers = useApiData(() => (can('maintenance.manage') ? Rentals.providers() : Promise.resolve([])), []);
  const [status, setStatus] = useState('');
  const [provider, setProvider] = useState('');
  const [comment, setComment] = useState('');
  const [busy, setBusy] = useState(false);
  useEffect(() => { setStatus(detail.data?.status ?? ''); setProvider(detail.data?.provider?.id ?? ''); setComment(''); }, [detail.data]);
  const reports = list.data ?? [];
  useEffect(() => { if (!sel && reports[0]) setSel(reports[0].id); }, [reports, sel]);
  if (list.loading && !list.data) return <p className="muted" role="status">Cargando reportes…</p>;
  if (list.error) return <div className="notice notice--error" role="alert"><Icon id="alert" /><span>{list.error}</span></div>;
  if (!reports.length) return <p className="muted">El inquilino no ha reportado nada en esta casa. Los reportes que haga en su app aparecen aquí.</p>;
  const d = detail.data;
  const save = (e: FormEvent) => {
    e.preventDefault();
    if (!d) return;
    setBusy(true);
    Rentals.updateReport(d.id, { status, comment: comment.trim() || undefined, providerId: provider || null })
      .then(() => { toast('Reporte actualizado. Le avisamos al inquilino en su app.'); detail.reload(); list.reload(); }, (er) => toast(failMsg(er)))
      .finally(() => setBusy(false));
  };
  return (
    <div className="grid-2 grid-2--wide-side">
      <section className="card card--pad" aria-labelledby="mt-list">
        <h3 className="card__title card__title--sm" id="mt-list" style={{ marginBottom: '.75rem' }}>Reportes · {reports.length}</h3>
        <ul className="ov-list">
          {reports.map((m) => (
            <li key={m.id}>
              <button className="link strong" type="button" aria-pressed={m.id === sel} style={{ color: 'var(--marino)', textAlign: 'left' }} onClick={() => setSel(m.id)}>{m.title}</button>
              <span>{m.category} · prioridad {PRIORITY[m.priority] ?? m.priority} · {dateShort(m.createdAt.slice(0, 10))}{m.provider ? ' · ' + m.provider.name : ''}</span>
              <Badge label={m.statusLabel} tone={REPORT_TONE[m.status] ?? 'gris'} />
            </li>
          ))}
        </ul>
      </section>
      <section className="card card--pad" aria-labelledby="mt-detail" aria-live="polite">
        {!d ? <p className="muted" role="status">Cargando reporte…</p> : (
          <>
            <div className="card__head"><h3 className="card__title card__title--sm" id="mt-detail">{d.title}</h3><Badge label={d.statusLabel} tone={REPORT_TONE[d.status] ?? 'gris'} /></div>
            <p>{d.description}</p>
            {[...d.photos.before, ...d.photos.after].length > 0 && (
              <div className="choice-row" style={{ marginTop: '.75rem' }}>
                {[...d.photos.before.map((p) => ['Antes', p] as const), ...d.photos.after.map((p) => ['Después', p] as const)].map(([stage, p]) => (
                  <a key={p.id} href={p.url} target="_blank" rel="noreferrer" title={stage}><img src={p.url} alt={`Foto ${stage.toLowerCase()} del reporte`} style={{ width: 88, height: 88, objectFit: 'cover', borderRadius: 8 }} /></a>
                ))}
              </div>
            )}
            <h4 className="label-xs" style={{ marginTop: '1rem' }}>Historial</h4>
            <ul className="ov-list">
              {d.timeline.map((t) => <li key={t.id}><strong>{t.statusLabel}</strong><span>{dateShort(t.createdAt.slice(0, 10))}{t.author ? ' · ' + t.author : ''}{t.comment ? ' · «' + t.comment + '»' : ''}</span></li>)}
            </ul>
            {can('maintenance.manage') && (
              <form onSubmit={save} style={{ marginTop: '1rem' }}>
                <div className="form-grid">
                  <div className="field"><label className="field__label" htmlFor="mt-status">Estado</label>
                    <select className="select" id="mt-status" value={status} onChange={(e) => setStatus(e.target.value)}><Options list={REPORT_STATUS} /></select></div>
                  <div className="field"><label className="field__label" htmlFor="mt-prov">Proveedor</label>
                    <select className="select" id="mt-prov" value={provider} onChange={(e) => setProvider(e.target.value)}>
                      <Options list={(providers.data ?? []).map((p): [string, string] => [p.id, p.name + (p.specialty ? ' · ' + p.specialty : '')])} placeholder="Sin asignar" />
                    </select></div>
                  <div className="field span-all"><label className="field__label" htmlFor="mt-comment">Comentario para el inquilino</label>
                    <input className="input" id="mt-comment" maxLength={1000} value={comment} onChange={(e) => setComment(e.target.value)} placeholder="Por ejemplo: el plomero va el jueves a las 10 a.m." /></div>
                </div>
                <button className="btn" type="submit" disabled={busy}>{busy ? 'Guardando…' : 'Guardar y avisar al inquilino'}</button>
              </form>
            )}
          </>
        )}
      </section>
    </div>
  );
}

function Detail({ r, onChanged }: { r: Rental; onChanged: () => void }) {
  const { open, toast } = useOverlay();
  const [tab, setTab] = useState(S.detail);
  const titleRef = useRef<HTMLHeadingElement>(null);
  useEffect(() => { titleRef.current?.focus({ preventScroll: true }); }, [r.id]);
  const select = (v: string) => { S.detail = v; setTab(v); };
  const u = r.utilities;
  const panels: Record<string, React.ReactNode> = {
    contrato: (
      <div className="grid-2">
        <section className="card card--pad" aria-labelledby="rt-contract">
          <h3 className="card__title card__title--sm" id="rt-contract" style={{ marginBottom: '.75rem' }}>Contrato</h3>
          <dl className="facts-list" style={{ marginTop: 0 }}>
            <div><dt>Periodo</dt><dd>{dateShort(r.startDate)} {year(r.startDate)} – {dateShort(r.endDate)} {year(r.endDate)}</dd></div>
            <div><dt>Renta</dt><dd>{money(r.monthlyRent)} al mes</dd></div>
            <div><dt>Día de pago</dt><dd>Día {r.paymentDay} de cada mes</dd></div>
            <div><dt>Depósito</dt><dd>{r.deposit ? money(r.deposit) : 'Sin depósito'}</dd></div>
            <div><dt>Pagarés</dt><dd>{r.notes.paid} de {r.notes.total} pagados{r.notes.nextDue ? ` · próximo ${dateShort(r.notes.nextDue)}` : ''}</dd></div>
            <div><dt>Broker</dt><dd>{r.broker?.name ?? 'Sin broker'}</dd></div>
          </dl>
          <div className="choice-row" style={{ marginTop: '1rem' }}>
            {r.documentId && <button className="btn btn--sm btn--secondary" type="button" onClick={() => Finance.openDocument(r.documentId!).catch((e) => toast(failMsg(e)))}><Icon id="file-edit" />Ver contrato firmado (PDF)</button>}
            {r.status === 'active' && can('contracts.manage') && (
              <button className="btn btn--sm btn--secondary link--danger" type="button" onClick={() => open((close) => <FinishForm r={r} close={close} onDone={(m) => { toast(m); onChanged(); load().then(rerender, () => {}); }} />)}>Finalizar contrato</button>
            )}
          </div>
        </section>
        <section className="card card--pad" aria-labelledby="rt-tenant">
          <h3 className="card__title card__title--sm" id="rt-tenant" style={{ marginBottom: '.75rem' }}>Inquilino</h3>
          <p className="strong" style={{ color: 'var(--marino)' }}><Link to={'/personas?persona=' + r.client.id} style={{ color: 'inherit' }}>{r.client.code ? r.client.code + ' · ' : ''}{r.client.name}</Link></p>
          <div className="contact-lines" style={{ marginTop: '.5rem' }}>
            {r.client.email && <a href={'mailto:' + r.client.email}>{r.client.email}</a>}
            {r.client.phone && <a href={'tel:' + r.client.phone.replace(/\s/g, '')}>{r.client.phone}</a>}
          </div>
          <p className="small muted" style={{ marginTop: '.75rem' }}>Ve sus pagarés, recibos, reportes y documentos en su app Homiz.</p>
          <Link className="link" to={'/propiedades/' + r.property.code}>Ver la ficha de {r.property.name} <Icon id="arrow" className="icon--sm" /></Link>
        </section>
      </div>
    ),
    pagos: <PropertyPayments propertyId={r.property.id} />,
    mantenimiento: <Maintenance propertyId={r.property.id} />,
    expediente: <PropertyDossier propertyId={r.property.id} />,
    servicios: (
      <section className="card card--pad" aria-labelledby="rt-util">
        <div className="card__head"><h3 className="card__title card__title--sm" id="rt-util">Agua y luz</h3>
          {isAdminSession() && <Link className="link" to={`/propiedades/${r.property.code}/editar?seccion=servicios`}>{u.electricity || u.water ? 'Editar números' : 'Capturar números'} <Icon id="arrow" className="icon--sm" /></Link>}</div>
        <dl className="facts-list">
          <div><dt>Luz · CFE (número de servicio)</dt><dd>{u.electricity || 'Sin capturar'}</dd></div>
          <div><dt>Agua · Aguakan (número de contrato)</dt><dd>{u.water || 'Sin capturar'}</dd></div>
          <div><dt>Recordatorio al inquilino</dt><dd>Día {u.reminderDay ?? 1} de cada mes</dd></div>
          <div><dt>Cuota de mantenimiento</dt><dd>{r.maintenanceFee?.amount ? `${money(r.maintenanceFee.amount)} · día ${r.maintenanceFee.day} de cada mes` : 'Sin cuota'}</dd></div>
        </dl>
        <p className="small muted" style={{ marginTop: '.75rem' }}>El inquilino ve estos números en su app y cada mes, ese día, le recordamos revisar sus recibos en la app de CFE y de Aguakan.</p>
      </section>
    ),
  };
  return (
    <section aria-labelledby="rt-title" style={{ marginTop: '1.5rem' }}>
      <div className="card__head" style={{ marginBottom: '.75rem' }}>
        <h2 className="card__title" id="rt-title" tabIndex={-1} ref={titleRef}>{r.property.name} · {r.client.name}</h2>
        <PayBadge r={r} />
      </div>
      <Tabs name="rt" label="Secciones de la renta" selected={tab} onSelect={select} items={DETAIL.map(([v, l]): [string, string] => [v, v === 'mantenimiento' && r.openReports ? `${l} · ${r.openReports}` : l])} />
      <div style={{ marginTop: '1rem' }}>{panels[tab]}</div>
    </section>
  );
}

/** Sección «Rentas y ventas» del menú: arriba se cambia entre Rentas y Ventas (?modo=ventas) */
export function RentalsPage() {
  const { open, toast } = useOverlay();
  const [params, setParams] = useSearchParams();
  const sales = params.get('modo') === 'ventas';
  const [salesKey, setSalesKey] = useState(0);
  const mode = (v: string) => setParams(v === 'ventas' ? { modo: 'ventas' } : {}, { replace: true });
  const switcher = <Tabs name="rv" label="Rentas o ventas" selected={sales ? 'ventas' : 'rentas'} onSelect={mode} items={[['rentas', 'Rentas'], ['ventas', 'Ventas']]} />;
  if (sales) {
    const register = () => open((close) => <SaleForm close={close} onDone={(m) => { toast(m); setSalesKey((k) => k + 1); }} />, { wide: true });
    return (
      <>
        <Crumbs items={[['Administración', '/resumen'], ['Rentas y ventas', '/rentas'], ['Ventas']]} />
        <PageHead title="Cada venta, con su comprobante." sub="Registro del cierre con el comprador: folio, comprobante en PDF y contrato firmado. Después de vender no administramos la casa."
          actions={apiActive() && can('contracts.manage') ? <button className="btn" type="button" onClick={register}><Icon id="user-key" />Registrar venta</button> : undefined} />
        {switcher}
        <div style={{ marginTop: '1rem' }}>{!apiActive() ? <NeedsServer what="Las ventas" /> : <SalesPanel reloadKey={salesKey} />}</div>
      </>
    );
  }
  return <RentalsList switcher={switcher} />;
}

function RentalsList({ switcher }: { switcher: React.ReactNode }) {
  const { open, toast } = useOverlay();
  const [tab, setTab] = useState(S.tab);
  const [selected, setSelected] = useState(S.selected);
  // El calendario usa las rentas vigentes
  const list = useApiData(() => Rentals.list(tab === 'all' ? '' : tab === 'calendario' ? 'active' : tab), [tab]);
  const rows = list.data ?? [];
  const active = rows.filter((r) => r.status === 'active');
  const choose = (id: string) => { S.selected = id; setSelected(id); setTimeout(() => document.getElementById('rt-detail')?.scrollIntoView({ behavior: 'smooth', block: 'start' }), 50); };
  const sel = rows.find((r) => r.id === selected) ?? rows[0];
  const start = () => openRental(open, (m) => { toast(m); list.reload(); });

  return (
    <>
      <Crumbs items={[['Administración', '/resumen'], ['Rentas y ventas', '/rentas'], ['Rentas']]} />
      <PageHead title="Cada renta, en un solo lugar." sub="Contrato, pagarés y pagos, mantenimiento, expediente y agua y luz de cada casa rentada."
        actions={apiActive() && can('contracts.manage') ? <button className="btn" type="button" onClick={start}><Icon id="user-key" />Rentar una casa</button> : undefined} />
      {switcher}
      {!apiActive() ? <NeedsServer what="Las rentas" /> : (
        <>
          <div style={{ marginTop: '1rem' }} />
          <div className="metrics">
            <Metric label="Casas rentadas" value={active.length} note={tab === 'active' ? 'Contratos vigentes' : 'En esta lista'} />
            <Metric label="Renta mensual" value={money(active.reduce((s, r) => s + r.monthlyRent, 0))} note="Suma de los contratos vigentes" />
            <Metric label="Adeudo vencido" value={money(rows.reduce((s, r) => s + r.notes.owed, 0))} note={`${rows.filter((r) => r.notes.overdue).length} ${plural(rows.filter((r) => r.notes.overdue).length, 'renta', 'rentas')} con pagarés vencidos`} />
            <Metric label="Reportes abiertos" value={rows.reduce((s, r) => s + r.openReports, 0)} note="Mantenimiento por atender" />
          </div>
          <Tabs name="rs" label="Filtrar rentas" selected={tab} onSelect={(v) => { S.tab = v; setTab(v); }} items={[['active', 'Vigentes'], ['calendario', 'Calendario'], ['finished', 'Finalizadas'], ['all', 'Todas']]} />
          {tab === 'calendario' && <RentCalendar rows={rows} onOpen={(id) => { S.tab = 'active'; setTab('active'); choose(id); }} />}
          {tab === 'calendario' ? null : list.error ? <div className="notice notice--error" role="alert"><Icon id="alert" /><span>{list.error}</span></div>
            : list.loading && !list.data ? <p className="muted" role="status" style={{ marginTop: '1rem' }}>Cargando rentas…</p>
            : !rows.length ? <p className="muted" style={{ marginTop: '1rem' }}>No hay rentas {tab === 'active' ? 'vigentes' : tab === 'finished' ? 'finalizadas' : ''}. Con «Rentar una casa» registras el contrato y se generan sus pagarés.</p>
            : (
              <ul className="rental-grid" style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: '1rem', marginTop: '1rem', listStyle: 'none', padding: 0 }}>
                {rows.map((r) => (
                  <li key={r.id}>
                    <button type="button" className={'card card--pad' + (r.id === sel?.id ? ' is-selected' : '')} aria-pressed={r.id === sel?.id} onClick={() => choose(r.id)}
                      style={{ width: '100%', textAlign: 'left', cursor: 'pointer', borderColor: r.id === sel?.id ? 'var(--marino)' : undefined }}>
                      <strong style={{ color: 'var(--marino)', display: 'block' }}>{r.property.name}</strong>
                      <span className="small">{r.client.name}</span>
                      <span className="small muted" style={{ display: 'block', marginTop: '.375rem' }}>{money(r.monthlyRent)} / mes · día {r.paymentDay}</span>
                      <span className="small muted" style={{ display: 'block' }}>Pagarés {r.notes.paid}/{r.notes.total}{r.openReports ? ` · ${r.openReports} ${plural(r.openReports, 'reporte abierto', 'reportes abiertos')}` : ''}</span>
                      <span style={{ display: 'block', marginTop: '.5rem' }}><PayBadge r={r} /></span>
                    </button>
                  </li>
                ))}
              </ul>
            )}
          <div id="rt-detail" aria-live="polite">{sel && tab !== 'calendario' && <Detail key={sel.id} r={sel} onChanged={() => list.reload()} />}</div>
        </>
      )}
    </>
  );
}
