import { useEffect, useRef, useState, type FormEvent } from 'react';
import { Link } from 'react-router';
import { apiActive, errorText, load, request, ZApi } from '../api';
import { can } from '../auth';
import { suggestHouse, TenantForm } from './Appointments';
import { openRental } from './Rentals';
import { useApiData } from './Payments';
import { useOverlay } from '../components/Overlay';
import { ApptBadge, Badge, brokerOptions, Crumbs, err, FieldError, FollowBadge, Icon, Metric, Options, PageHead, Pager, Tabs, useErrors, useUrlParams } from '../components/ui';
import { broker, D as Data, dateShort, downloadCSV, money, norm, plural, prop, rerender, upcoming, useStore, viewState, Z, type Person, t12 } from '../store';

const typeLabel = (p: Person) => (p.type === 'cliente' ? 'Cliente' : p.label || 'Inquilino');
const nextFor = (p: Person) => upcoming((a) => a.person === p.id)[0];

/** Alta o edición de un expediente (diálogo) */
function PersonForm({ person, close }: { person: Person | null; close: () => void }) {
  const D = useStore();
  const { toast } = useOverlay();
  const { errors, check, live, clear } = useErrors();
  const p = person || { name: '', email: '', phone: '', type: 'cliente', property: '', broker: '', follow: 'Nuevo contacto', op: 'Renta', budget: '', needs: '', job: '' };
  const [brokerId, setBrokerId] = useState(p.broker);
  const [busy, setBusy] = useState(false);
  const [saveError, setSaveError] = useState('');

  // Se guarda en la API (POST o PATCH /clients) y el aviso de éxito sale solo cuando el servidor responde 2xx
  const onSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (busy || !check(e.currentTarget)) return;
    const v = (id: string) => (document.getElementById(id) as HTMLInputElement).value.trim();
    const data = { name: v('pf-name'), email: v('pf-email'), phone: v('pf-phone'), type: v('pf-type') as Person['type'], follow: v('pf-follow'), property: v('pf-prop'), broker: v('pf-broker'), op: v('pf-op'), budget: v('pf-budget'), needs: v('pf-needs'), job: v('pf-job') };
    setBusy(true);
    setSaveError('');
    try {
      await ZApi.personSave({ ...(person ?? { id: '' }), ...data }, !person);
      toast(person ? 'Se guardó el expediente de ' + data.name + '.' : data.name + ' se agregó al directorio.');
      close();
    } catch (err) {
      setSaveError(errorText(err)); // el diálogo sigue abierto con lo que escribió
      setBusy(false);
    }
  };
  const input = (id: string, label: string, props: Record<string, unknown>, span = false) => (
    <div className={'field' + (span ? ' span-all' : '')}>
      <label className="field__label" htmlFor={id}>{label}</label>
      <input className="input" id={id} onInput={() => clear(id)} {...props} {...err(errors, id)} />
      <FieldError errors={errors} id={id} />
    </div>
  );
  const select = (id: string, label: string, children: React.ReactNode, props: Record<string, unknown>) => (
    <div className="field">
      <label className="field__label" htmlFor={id}>{label}</label>
      <select className="select" id={id} onChange={() => clear(id)} {...props} {...err(errors, id)}>{children}</select>
      <FieldError errors={errors} id={id} />
    </div>
  );
  return (
    <>
      <h2 id="dialog-title">{person ? 'Editar expediente' : 'Agregar persona'}</h2>
      <p className="lead">{person ? `Actualiza los datos de ${p.name}.` : 'Registra a un cliente o inquilino y asígnale una casa y un broker.'} Los campos con * son obligatorios.</p>
      <form id="person-form" noValidate {...live} onSubmit={onSubmit}>
        <div className="form-grid">
          {input('pf-name', 'Nombre completo *', { required: true, minLength: 3, maxLength: 120, defaultValue: p.name, autoComplete: 'off' }, true)}
          {input('pf-email', 'Correo electrónico *', { type: 'email', required: true, defaultValue: p.email })}
          {input('pf-phone', 'Teléfono *', { type: 'tel', required: true, defaultValue: p.phone, placeholder: '998 000 0000' })}
          {/* Inquilino solo con contrato: se hace con «Rentarle esta casa» (genera pagarés y pausa la casa) */}
          {select('pf-type', 'Tipo *', <Options list={[['cliente', 'Cliente'], ['inquilino', p.type === 'inquilino' ? 'Inquilino o inquilina' : 'Inquilino (con «Rentarle esta casa»)', p.type !== 'inquilino']]} />, { required: true, defaultValue: p.type })}
          {select('pf-follow', 'Seguimiento *', <Options list={Object.keys(Z.FOLLOW).map((f): [string, string, boolean] => [f, f, f === 'Contrato vigente' && p.follow !== f])} />, { required: true, defaultValue: p.follow })}
          {select('pf-prop', 'Propiedad de interés *', <Options list={D.properties.map((x): [string, string] => [x.id, x.name + ' · ' + x.id])} placeholder="Elige una casa" />, {
            required: true, defaultValue: p.property,
            // La casa elegida trae a su broker
            onChange: (e: React.ChangeEvent<HTMLSelectElement>) => { clear('pf-prop'); const pr = prop(e.target.value); if (pr) setBrokerId(pr.broker); },
          })}
          {select('pf-broker', 'Broker *', <Options list={brokerOptions(D.brokers, brokerId)} placeholder="Elige un broker" />, { required: true, value: brokerId, onChange: (e: React.ChangeEvent<HTMLSelectElement>) => { clear('pf-broker'); setBrokerId(e.target.value); } })}
          {select('pf-op', 'Operación', <Options list={['Renta', 'Compra']} />, { defaultValue: p.op })}
          {input('pf-budget', 'Presupuesto', { defaultValue: p.budget, placeholder: '$30,000 MXN / mes' })}
          {input('pf-needs', 'Lo que busca', { defaultValue: p.needs, placeholder: '3 recámaras · 2 personas · 1 perro pequeño' }, true)}
          {input('pf-job', 'Ocupación y nacionalidad', { defaultValue: p.job, placeholder: 'Diseño de interiores · Nacionalidad mexicana' }, true)}
        </div>
        {saveError && <div className="callout callout--error" role="alert" style={{ marginTop: '1rem' }}><strong>No se guardó</strong>{saveError}</div>}
        <div className="dialog__actions">
          <button className="btn btn--secondary" type="button" onClick={close}>Cancelar</button>
          <button className="btn" type="submit" disabled={busy} aria-busy={busy}>{busy ? 'Guardando…' : person ? 'Guardar expediente' : 'Agregar persona'}</button>
        </div>
      </form>
    </>
  );
}

/** Módulo 3 · Clientes e inquilinos */
export function People() {
  const D = useStore();
  const S = viewState.people;
  const { toast, open, confirm } = useOverlay();
  const detailRef = useRef<HTMLDivElement>(null);
  const focusDetail = useRef(false);
  useUrlParams((p) => { const id = p.get('persona'); if (id) S.selected = id; });

  useEffect(() => {
    if (!focusDetail.current) return;
    focusDetail.current = false;
    detailRef.current?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    detailRef.current?.querySelector<HTMLElement>('h2')?.focus({ preventScroll: true });
  });

  const people = D.people;
  const clients = people.filter((p) => p.type === 'cliente').length;
  const tenants = people.filter((p) => p.type === 'inquilino');
  const byProp: Record<string, number> = {};
  tenants.forEach((p) => { if (p.follow === 'Contrato vigente') byProp[p.property] = (byProp[p.property] || 0) + 1; });
  const shared = Object.values(byProp).filter((n) => n > 1).length;
  const up = upcoming();
  const upConf = up.filter((a) => a.status === 'confirmada').length;

  const q = norm(S.q);
  const list = people.filter((p) =>
    (S.tab === 'todas' || p.type === S.tab) && (!S.follow || p.follow === S.follow) && (!S.broker || p.broker === S.broker) &&
    (!q || norm(p.name + ' ' + p.email + ' ' + p.phone).includes(q) || p.phone.replace(/\D/g, '').includes(S.q.replace(/\D/g, '') || '¬')));

  const personForm = (p: Person | null) => open((close) => <PersonForm person={p} close={close} />, { wide: true });
  const deletePerson = (p: Person) => {
    const linked = upcoming((a) => a.person === p.id);
    const pr = prop(p.property);
    confirm({
      title: `¿Eliminar a ${p.name}?`,
      lead: 'Su expediente dejará de aparecer en el directorio. Esta acción no se puede deshacer.',
      item: (
        <div className="dialog__item">
          <span className="avatar" aria-hidden="true">{p.name.split(' ').map((w) => w[0]).slice(0, 2).join('')}</span>
          <div><strong>{p.name}</strong><span>{p.code ? p.code + ' · ' : ''}{typeLabel(p)} ·{pr ? pr.name : 'Sin propiedad'}</span><span>{p.email}</span></div>
        </div>
      ),
      callout: linked.length ? (
        <div className="callout"><strong>Tiene {linked.length === 1 ? 'una visita próxima' : linked.length + ' visitas próximas'}</strong>{prop(linked[0].property)?.name ?? ''} · {dateShort(linked[0].date)}, {t12(linked[0].start)}. Se {plural(linked.length, 'cancelará', 'cancelarán')} y {plural(linked.length, 'quedará', 'quedarán')} en el historial.</div>
      ) : null,
      check: linked.length ? 'Entiendo que se eliminará el expediente y se cancelarán sus visitas.' : null,
      cancel: 'Conservar expediente', confirm: 'Sí, eliminar',
      // DELETE /clients/:id (baja lógica). El servidor cancela sus citas próximas; 409 si tiene contrato vigente.
      onConfirm: () =>
        ZApi.personDelete(p).then(
          () => {
            if (S.selected === p.id) S.selected = Data.people[0]?.id ?? null;
            toast('Se eliminó el expediente de ' + p.name + '.');
            rerender();
          },
          (err) => toast('No se eliminó a ' + p.name + ': ' + errorText(err)),
        ),
    });
  };
  const exportCsv = () => {
    const rows: string[][] = [['Nombre', 'Correo', 'Teléfono', 'Tipo', 'Propiedad', 'Broker', 'Seguimiento', 'Presupuesto']];
    D.people.forEach((p) => rows.push([p.name, p.email, p.phone, typeLabel(p), prop(p.property)?.name ?? '', broker(p.broker).name, p.follow, p.budget]));
    downloadCSV('zugar-clientes-e-inquilinos.csv', rows);
    toast('Se descargó zugar-clientes-e-inquilinos.csv.');
  };

  const sel = people.find((x) => x.id === S.selected);
  const a = sel ? nextFor(sel) : undefined;
  const pr = sel ? (a ? prop(a.property) : prop(sel.property)) : undefined;

  return (
    <>
      <Crumbs items={[['Administración', '/resumen'], ['Clientes e inquilinos']]} />
      <PageHead title="Personas, no expedientes." sub="Contactos, intereses y contratos en un mismo lugar."
        actions={<><button className="btn btn--secondary" type="button" onClick={exportCsv}><Icon id="download" />Exportar</button><button className="btn" type="button" onClick={() => personForm(null)}><Icon id="plus" />Agregar persona</button></>} />
      <div className="metrics">
        <Metric label="Total de personas" value={people.length} note="Directorio actualizado" />
        <Metric label="Clientes" value={clients} note="Buscan comprar o rentar" />
        <Metric label="Inquilinos" value={tenants.length} note={shared ? `${shared} ${plural(shared, 'contrato compartido vigente', 'contratos compartidos vigentes')}` : 'Contratos individuales'} />
        <Metric label="Visitas próximas" value={up.length} note={`${upConf} ${plural(upConf, 'confirmada', 'confirmadas')} · ${up.length - upConf} ${plural(up.length - upConf, 'pendiente', 'pendientes')}`} />
      </div>
      <div id="pp-tabs">
        <Tabs name="pp" label="Filtrar por tipo" selected={S.tab} onSelect={(v) => { S.tab = v; rerender(); }}
          items={[['todas', 'Todas las personas · ' + people.length], ['cliente', 'Clientes · ' + clients], ['inquilino', 'Inquilinos · ' + tenants.length]]} />
      </div>
      <div className="filters filters--3" role="search" aria-label="Filtrar personas">
        <div className="field"><label className="field__label" htmlFor="pp-q">Buscar contacto</label><input className="input input-search" id="pp-q" type="search" placeholder="Nombre, correo o teléfono" defaultValue={S.q} onChange={(e) => { S.q = e.target.value; rerender(); }} /></div>
        <div className="field"><label className="field__label" htmlFor="pp-follow">Estado de seguimiento</label>
          <select className="select" id="pp-follow" value={S.follow} onChange={(e) => { S.follow = e.target.value; rerender(); }}><Options list={Object.keys(Z.FOLLOW)} placeholder="Todos" /></select></div>
        <div className="field"><label className="field__label" htmlFor="pp-broker">Broker</label>
          <select className="select" id="pp-broker" value={S.broker} onChange={(e) => { S.broker = e.target.value; rerender(); }}><Options list={brokerOptions(D.brokers, S.broker)} placeholder="Todos los brokers" /></select></div>
      </div>
      <div className="table-wrap" style={{ marginTop: '1.25rem' }}>
        <table className="table">
          <caption className="sr-only">Directorio de clientes e inquilinos</caption>
          <thead><tr><th scope="col">Persona / Contacto</th><th scope="col">Tipo</th><th scope="col">Propiedad</th><th scope="col">Broker</th><th scope="col">Seguimiento</th><th scope="col">Acciones</th></tr></thead>
          <tbody id="pp-rows">
            {list.length ? list.map((p) => {
              const ppr = prop(p.property);
              const view = () => { S.selected = p.id; focusDetail.current = true; rerender(); };
              return (
                <tr key={p.id} className={p.id === S.selected ? 'is-selected' : ''}>
                  <td><button className="link strong" type="button" style={{ color: 'var(--marino)' }} onClick={view}>{p.name}</button><span className="sub">{p.code ? p.code + ' · ' : ''}{p.email} · {p.phone}</span></td>
                  <td><Badge label={typeLabel(p)} tone={p.type === 'cliente' ? 'info' : 'ok'} /></td>
                  <td>{ppr ? <Link to={'/propiedades/' + ppr.id}>{ppr.name}</Link> : <span className="muted">Propiedad eliminada</span>}</td>
                  <td>{broker(p.broker).name}</td>
                  <td><FollowBadge f={p.follow} /></td>
                  <td><div className="actions">
                    <button className="icon-btn" type="button" aria-label={'Ver expediente de ' + p.name} title="Ver" onClick={view}><Icon id="eye" /></button>
                    <button className="icon-btn" type="button" aria-label={'Editar expediente de ' + p.name} title="Editar" onClick={() => personForm(p)}><Icon id="pencil" /></button>
                    <button className="icon-btn icon-btn--danger" type="button" aria-label={'Eliminar a ' + p.name} title="Eliminar" onClick={() => deletePerson(p)}><Icon id="trash" /></button>
                  </div></td>
                </tr>
              );
            }) : <tr><td colSpan={6} className="table-empty">No encontramos personas con estos filtros.</td></tr>}
          </tbody>
        </table>
      </div>
      <div id="pp-pager"><Pager shown={list.length} total={list.length} noun="personas" /></div>

      <div id="pp-detail" ref={detailRef} style={{ marginTop: '1.5rem' }} aria-live="polite">
        {sel && (
          <div className="grid-2 grid-2--wide-side">
            <section className="card card--pad" aria-labelledby="pd-title">
              <div className="card__head"><h2 className="card__title" id="pd-title" tabIndex={-1}>{sel.name}</h2>
                <button className="link" type="button" onClick={() => personForm(sel)}>Editar expediente <Icon id="arrow" className="icon--sm" /></button></div>
              <div className="profile">
                <div>
                  <Badge label={typeLabel(sel) + ' · ' + sel.op} tone={sel.type === 'cliente' ? 'info' : 'ok'} />
                  <div className="profile__lines">
                    {sel.budget && <p>Presupuesto: {sel.budget}</p>}
                    {sel.needs && <p>{sel.needs}</p>}
                    {sel.job && <p className="muted small">{sel.job}</p>}
                  </div>
                </div>
                <div>
                  {sel.type === 'cliente' && can('contracts.manage') && apiActive() && (
                    // Cliente que ya decidió: un clic para hacerlo inquilino (casa elegida si la que tiene asignada está en renta)
                    <button className="btn btn--sm" type="button" style={{ marginBottom: '1rem' }} onClick={() => openRental(open, (m) => toast(m), { person: sel.id })}>
                      <Icon id="user-key" />Rentar casa{suggestHouse(sel.id) ? ` · ${prop(suggestHouse(sel.id)!.id)!.name}` : ''}
                    </button>
                  )}
                  {sel.type === 'inquilino' ? (
                    // Inquilino: lo que importa es su casa (expediente, pagos y pagarés, reportes); otra visita es opcional
                    <TenantLinks p={sel} />
                  ) : a ? (
                    <>
                      <p className="strong" style={{ fontWeight: 600, color: 'var(--marino)' }}>{pr ? pr.name : ''} · {dateShort(a.date)}, {t12(a.start)}</p>
                      <p className="small muted" style={{ marginTop: '.375rem' }}>{broker(a.broker).name} · Visita {a.kind.toLowerCase()} {Z.APPT_STATUS[a.status].label.toLowerCase()}</p>
                      {a.note && <p className="quote">“{a.note}”</p>}
                      <Link className="btn btn--secondary" to={'/citas?cita=' + a.id}>Ver cita</Link>
                    </>
                  ) : (
                    <>
                      <p className="strong" style={{ fontWeight: 600, color: 'var(--marino)' }}>{pr ? pr.name : 'Sin propiedad asignada'}</p>
                      <p className="small muted" style={{ marginBlock: '.375rem 1rem' }}>Sin visitas próximas.</p>
                      <Link className="btn btn--secondary" to={'/citas?nueva=' + sel.id}>Agendar visita</Link>
                    </>
                  )}
                </div>
              </div>
            </section>
            <section className="card card--pad" aria-label="Datos de contacto">
              <p className="field__label">Correo electrónico</p>
              <p className="input" style={{ marginTop: '.5rem', display: 'flex', alignItems: 'center' }}>{sel.email}</p>
              <p className="small muted" style={{ marginBlock: '.5rem 1rem' }}>Contacto preferido para seguimiento.</p>
              <p className="small">Teléfono · <a href={'tel:+52' + sel.phone.replace(/\D/g, '')}>{sel.phone}</a></p>
              <p style={{ marginTop: '1rem' }}><a className="link" href={'mailto:' + sel.email}>Enviar correo <Icon id="arrow-ur" className="icon--sm" /></a></p>
            </section>
          </div>
        )}
        {sel && apiActive() && <PersonOverview id={sel.id} />}
      </div>
    </>
  );
}

/**
 * Inquilino: su casa con accesos directos al expediente (documentos, mantenimiento, agua y luz), a los pagos y pagarés.
 * Si quedó como inquilino sin contrato (la casa no está rentada), avisa y ofrece «Rentarle esta casa».
 */
function TenantLinks({ p }: { p: Person }) {
  const { open, toast } = useOverlay();
  const house = prop(p.property);
  if (!house) return <p className="muted">Sin casa asignada.</p>;
  const rented = house.status === 'rentada';
  const rent = () => open((close) => <TenantForm a={{ property: house.id, person: p.id }} close={close} onDone={(m) => { toast(m); load().then(rerender, () => {}); }} />, { wide: true });
  return (
    <>
      <p className="strong" style={{ fontWeight: 600, color: 'var(--marino)' }}><Link to={'/propiedades/' + house.id} style={{ color: 'inherit' }}>{house.name} · {house.id}</Link></p>
      {rented ? (
        <>
          <p className="small muted" style={{ marginBlock: '.375rem 1rem' }}>Inquilino con contrato vigente.</p>
          <div className="choice-row">
            <Link className="btn btn--sm" to={`/propiedades/${house.id}?seccion=expediente`}><Icon id="folder" />Expediente y reportes</Link>
            <Link className="btn btn--sm btn--secondary" to={`/propiedades/${house.id}?seccion=pagos`}><Icon id="cash" />Pagos y pagarés</Link>
          </div>
        </>
      ) : (
        <div className="callout" style={{ marginTop: '.5rem' }}>
          <strong>Falta registrar su contrato</strong>
          Sin contrato no hay pagarés y {house.name} sigue publicada en el sitio. Regístralo y la casa se pausa sola.
          {can('contracts.manage') && house.op === 'renta' && apiActive() && (
            <button className="btn btn--sm" type="button" style={{ marginTop: '.75rem' }} onClick={rent}><Icon id="user-key" />Rentarle {house.name}</button>
          )}
        </div>
      )}
    </>
  );
}

/* ---------- Todo de la persona (solicitudes, citas, contrato y pagarés, bitácora) ---------- */
interface Overview {
  leads: { id: string; folio: string; reason: string; status: string; createdAt: string; propertyName: string | null; proposals: number }[];
  appointments: { id: string; code: string; status: string; scheduledAt: string; propertyCode: string; propertyName: string; broker: string | null }[];
  contracts: { id: string; status: string; startDate: string; endDate: string; monthlyRent: number; paymentDay: number; propertyCode: string; propertyName: string;
    notesTotal: number; notesPaid: number; notesOverdue: number; nextDue: string | null; stamps: number }[];
  activity: { action: string; description: string; createdAt: string; user: string | null; byClient: boolean }[];
}
const REASON: Record<string, string> = { visita: 'Visita', rentar: 'Rentar', comprar: 'Comprar', publicar: 'Publicar', otro: 'Otro' };
const LEAD_STATUS: Record<string, string> = { nuevo: 'Nueva', en_seguimiento: 'En seguimiento', cerrado: 'Cerrada' };
const when = (iso: string) => new Date(iso).toLocaleString('es-MX', { timeZone: 'America/Cancun', day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hourCycle: 'h12' });

function PersonOverview({ id }: { id: string }) {
  const data = useApiData(() => request<Overview>('GET', `/clients/${id}/overview`), [id]);
  if (data.error) return <div className="notice notice--error" role="alert" style={{ marginTop: '1rem' }}><Icon id="alert" /><span>{data.error}</span></div>;
  if (!data.data) return <p className="muted" role="status" style={{ marginTop: '1rem' }}>Cargando su historial…</p>;
  const o = data.data;
  return (
    <div className="stack" style={{ marginTop: '1.5rem' }}>
      {o.contracts.map((c) => (
        <section key={c.id} className="card card--pad" aria-label={'Contrato de ' + c.propertyName}>
          <div className="card__head"><h3 className="card__title card__title--sm">Contrato · {c.propertyName}</h3><Badge label={c.status === 'active' ? 'Vigente' : 'Finalizado'} tone={c.status === 'active' ? 'ok' : 'gris'} /></div>
          <div className="metrics" style={{ marginBottom: '1rem' }}>
            <dl className="card metric"><dt>Pagarés pagados</dt><dd>{c.notesPaid} de {c.notesTotal}</dd><p>{c.notesOverdue ? `${c.notesOverdue} vencido${c.notesOverdue === 1 ? '' : 's'}` : 'Sin vencidos'}</p></dl>
            <dl className="card metric"><dt>Renta</dt><dd>{money(Number(c.monthlyRent))}</dd><p>Día {c.paymentDay} de cada mes</p></dl>
            <dl className="card metric"><dt>Próximo pago</dt><dd>{c.nextDue ? dateShort(c.nextDue) : '—'}</dd><p>{c.stamps} {c.stamps === 1 ? 'foto de sello' : 'fotos de sellos'}</p></dl>
          </div>
          <p className="small muted">Del {dateShort(c.startDate)} {c.startDate.slice(0, 4)} al {dateShort(c.endDate)} {c.endDate.slice(0, 4)} · <Link to={`/propiedades/${c.propertyCode}?seccion=expediente`}>Ver expediente y estado de la propiedad</Link> · <Link to={`/propiedades/${c.propertyCode}?seccion=pagos`}>Ver pagarés</Link></p>
        </section>
      ))}
      <div className="grid-2">
        <section className="card card--pad" aria-labelledby="ov-ap">
          <h3 className="card__title card__title--sm" id="ov-ap" style={{ marginBottom: '.75rem' }}>Citas · {o.appointments.length}</h3>
          {o.appointments.length ? (
            <ul className="ov-list">{o.appointments.map((a) => (
              <li key={a.id}><Link className="strong" to={'/citas?cita=' + a.code}>{a.code}</Link><span>{a.propertyName} · {when(a.scheduledAt)}{a.broker ? ' · ' + a.broker : ''}</span><ApptBadge s={a.status} /></li>
            ))}</ul>
          ) : <p className="muted">Sin citas.</p>}
          <h3 className="card__title card__title--sm" style={{ margin: '1.25rem 0 .75rem' }}>Solicitudes · {o.leads.length}</h3>
          {o.leads.length ? (
            <ul className="ov-list">{o.leads.map((l) => (
              <li key={l.id}><Link className="strong" to={'/solicitudes?id=' + l.id}>{l.folio}</Link><span>{REASON[l.reason] ?? l.reason}{l.propertyName ? ' · ' + l.propertyName : ''} · {when(l.createdAt)}{l.proposals ? ` · ${l.proposals} propuesta${l.proposals === 1 ? '' : 's'}` : ''}</span><Badge label={LEAD_STATUS[l.status] ?? l.status} tone={l.status === 'nuevo' ? 'info' : l.status === 'cerrado' ? 'gris' : 'warn'} /></li>
            ))}</ul>
          ) : <p className="muted">Sin solicitudes.</p>}
        </section>
        <section className="card card--pad" aria-labelledby="ov-act">
          <h3 className="card__title card__title--sm" id="ov-act" style={{ marginBottom: '.75rem' }}>Movimientos</h3>
          {o.activity.length ? (
            <ul className="activity">{o.activity.map((a, i) => (
              <li key={i}><strong>{a.byClient ? 'En la app' : a.user ?? 'Sistema'}</strong> {a.description}<br /><span className="small muted">{when(a.createdAt)}</span></li>
            ))}</ul>
          ) : <p className="muted">Sin movimientos.</p>}
        </section>
      </div>
    </div>
  );
}
