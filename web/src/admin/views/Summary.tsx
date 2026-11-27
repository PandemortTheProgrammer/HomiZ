import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router';
import { errorText, request } from '../api';
import { currentSession } from '../auth';
import { useOverlay } from '../components/Overlay';
import { ApptBadge, Cover, Crumbs, Icon, Metric, PageHead } from '../components/ui';
import { broker, dateFull, dateLong, dateShort, downloadCSV, isoDate, opLabel, parseDate, person, plural, priceLabel, prop, upcoming, useStore, Z, t12 } from '../store';

/** Indicadores que calcula el servidor con SQL (GET /dashboard) */
interface DashboardCounts { appointmentsToConfirm: number; appointmentsToday: number; newLeads: number; overdueNotes: number; upcomingNotes: number; openReports: number }
type DashState = { status: 'loading' } | { status: 'ok'; counts: DashboardCounts; at: Date } | { status: 'error'; message: string };

/** Lunes a domingo de la semana de hoy (hora de Cancún) */
function thisWeek() {
  const today = parseDate(Z.TODAY);
  const monday = new Date(today);
  monday.setDate(today.getDate() - ((today.getDay() + 6) % 7));
  const sunday = new Date(monday);
  sunday.setDate(monday.getDate() + 6);
  return { from: isoDate(monday), to: isoDate(sunday) };
}

/** Módulo 1 · Resumen (dashboard) */
export function Summary() {
  const D = useStore();
  const navigate = useNavigate();
  const { toast } = useOverlay();
  const props = D.properties;
  const week = thisWeek();
  const appts = D.appointments.filter((a) => a.date >= week.from && a.date <= week.to);
  const firstName = (currentSession()?.name || '').split(' ')[0];

  // Indicadores del servidor: se piden al abrir y otra vez cada que cambian los datos del panel
  const [dash, setDash] = useState<DashState>({ status: 'loading' });
  const fetchDash = () => {
    setDash({ status: 'loading' });
    request<{ counts: DashboardCounts }>('GET', '/dashboard').then(
      (r) => setDash({ status: 'ok', counts: r.counts, at: new Date() }),
      (e) => setDash({ status: 'error', message: errorText(e) }),
    );
  };
  useEffect(fetchDash, [D.appointments, D.people]);
  const count = <T,>(list: T[], fn: (x: T) => boolean) => list.filter(fn).length;
  const rent = count(props, (p) => p.op === 'renta');
  const st = (s: string) => count(props, (p) => p.status === s);
  const clients = count(D.people, (p) => p.type === 'cliente');
  const aStatus = (s: string) => count(appts, (a) => a.status === s);
  const next = upcoming().slice(0, 3);
  // Disponibles pero sin publicar (antes «borradores»): falta completar o publicarlas
  const drafts = props.filter((p) => p.status === 'disponible' && p.visibility === 'pausada');
  const pending = upcoming((a) => a.status === 'por-confirmar');
  const featured = props.find((p) => p.status === 'disponible' && p.visibility === 'publicada') || props[0];
  const fb = featured ? broker(featured.broker) : null;
  const fNext = featured ? upcoming((a) => a.property === featured.id).length : 0;

  const exportCsv = () => {
    const rows: (string | number)[][] = [
      ['Indicador', 'Valor', 'Detalle'],
      ['Propiedades en cartera', props.length, `${rent} en renta · ${props.length - rent} en venta`],
      ['Casas disponibles', st('disponible'), `${st('reservada')} reservadas · ${st('rentada')} rentadas · ${drafts.length} sin publicar`],
      ['Clientes e inquilinos', D.people.length, `${clients} clientes · ${D.people.length - clients} inquilinos`],
      ['Citas esta semana', appts.length, `${aStatus('confirmada')} confirmadas · ${aStatus('por-confirmar')} por confirmar`],
      ...(dash.status === 'ok' ? [
        ['Citas por confirmar (servidor)', dash.counts.appointmentsToConfirm, ''],
        ['Citas de hoy (servidor)', dash.counts.appointmentsToday, ''],
        ['Solicitudes nuevas (servidor)', dash.counts.newLeads, ''],
        ['Pagarés vencidos (servidor)', dash.counts.overdueNotes, ''],
      ] : []),
      [], ['Fecha', 'Hora', 'Cliente', 'Propiedad', 'Broker', 'Estado'],
    ];
    upcoming().forEach((a) => rows.push([dateShort(a.date), a.start, person(a.person).name, prop(a.property)?.name ?? '', broker(a.broker).name, Z.APPT_STATUS[a.status].label]));
    const file = `zugar-resumen-${week.from}-al-${week.to}.csv`;
    downloadCSV(file, rows);
    toast('Se descargó ' + file + '.');
  };

  return (
    <>
      <Crumbs items={[['Administración', '/resumen'], ['Resumen']]} />
      <PageHead title="Todo en su lugar." sub={`Buen día${firstName ? ', ' + firstName : ''}. Así se mueve Zugar esta semana.`}
        actions={<><button className="btn btn--secondary" type="button" onClick={exportCsv}>Exportar resumen</button><Link className="btn" to="/propiedades/nueva">Nueva propiedad</Link></>} />
      <div className="meta-row"><strong>Semana del {dateShort(week.from)} al {dateFull(week.to)}</strong><span>{dateLong(Z.TODAY)}{dash.status === 'ok' ? ' · Actualizado a las ' + dash.at.toLocaleTimeString('es-MX', { hour: 'numeric', minute: '2-digit' }) : ''}</span></div>

      <div className="metrics">
        <Metric label="Propiedades en cartera" value={props.length} note={`${rent} en renta · ${props.length - rent} en venta`} />
        <Metric label="Casas disponibles" value={st('disponible')} note={`${st('reservada')} ${plural(st('reservada'), 'reservada', 'reservadas')} · ${st('rentada')} ${plural(st('rentada'), 'rentada', 'rentadas')} · ${drafts.length} sin publicar`} />
        <Metric label="Clientes e inquilinos" value={D.people.length} note={`${clients} clientes · ${D.people.length - clients} inquilinos`} />
        <Metric label="Citas esta semana" value={appts.length} note={`${aStatus('confirmada')} confirmadas · ${aStatus('por-confirmar')} por confirmar`} />
      </div>

      {/* GET /dashboard: conteos hechos en la base de datos (carga, error y datos) */}
      <section className="card card--pad" aria-labelledby="dash-title" aria-busy={dash.status === 'loading'} style={{ marginBottom: '1.5rem' }}>
        <div className="card__head">
          <h2 className="card__title" id="dash-title">Indicadores del servidor</h2>
          <button className="link" type="button" onClick={fetchDash} disabled={dash.status === 'loading'}>Actualizar <Icon id="arrow" className="icon--sm" /></button>
        </div>
        {dash.status === 'loading' && <p className="muted" role="status">Consultando indicadores…</p>}
        {dash.status === 'error' && (
          <div className="callout callout--error" role="alert"><strong>No se pudieron consultar los indicadores</strong>{dash.message}
            <div className="callout__actions"><button className="btn btn--sm" type="button" onClick={fetchDash}>Reintentar</button></div></div>
        )}
        {dash.status === 'ok' && (
          <div className="metrics" style={{ marginBottom: 0 }}>
            <Metric label="Citas por confirmar" value={dash.counts.appointmentsToConfirm} note="Próximas, esperando respuesta" />
            <Metric label="Citas de hoy" value={dash.counts.appointmentsToday} note="Confirmadas para hoy" />
            <Metric label="Solicitudes nuevas" value={dash.counts.newLeads} note="Del sitio, sin atender" />
            <Metric label="Pagarés vencidos" value={dash.counts.overdueNotes} note={`${dash.counts.upcomingNotes} vencen en 7 días`} />
          </div>
        )}
      </section>

      <div className="grid-2">
        <div className="stack">
          <section className="card card--pad" aria-labelledby="prox-title">
            <div className="card__head"><h2 className="card__title" id="prox-title">Próximas visitas</h2><Link className="link" to="/citas">Ver agenda <Icon id="arrow" className="icon--sm" /></Link></div>
            <div className="table-wrap">
              <table className="table">
                <thead><tr><th scope="col">Fecha</th><th scope="col">Cliente / Propiedad</th><th scope="col">Broker</th></tr></thead>
                <tbody>
                  {next.length ? next.map((a) => {
                    const p = prop(a.property);
                    const to = '/citas?cita=' + a.id;
                    return (
                      <tr key={a.id} data-row-select onClick={(e) => !(e.target as HTMLElement).closest('a') && navigate(to)}>
                        <td><span className="strong">{dateShort(a.date)}</span><span className="sub">{t12(a.start)}</span></td>
                        <td>
                          <Link className="strong" to={to}>{person(a.person).name}</Link>
                          <span className="sub">{p ? p.name + ' · ' + p.zone.replace('Residencial ', '').replace(' Residencial', '') : 'Propiedad eliminada'}</span>
                          <div style={{ marginTop: '.375rem' }}><ApptBadge s={a.status} /></div>
                        </td>
                        <td>{broker(a.broker).name}</td>
                      </tr>
                    );
                  }) : <tr><td colSpan={3} className="table-empty">No hay visitas próximas.</td></tr>}
                </tbody>
              </table>
            </div>
          </section>

          <section className="card card--pad" aria-labelledby="att-title">
            <h2 className="card__title" id="att-title" style={{ marginBottom: '.5rem' }}>Requieren tu atención</h2>
            {drafts.length || pending.length ? (
              <ul className="attention">
                {drafts.map((p) => (
                  <li key={p.id}><Icon id="file-edit" /><div><strong>{p.name} está disponible pero sin publicar</strong><p>{p.photos.length ? 'Revisa la información antes de publicar.' : 'Completa las fotografías antes de publicar.'}</p></div>
                    <Link className="link" to={`/propiedades/${p.id}/editar`}>Completar <Icon id="arrow" className="icon--sm" /></Link></li>
                ))}
                {pending.map((a) => (
                  <li key={a.id}><Icon id="cal-clock" /><div><strong>Una visita pendiente de confirmación</strong><p>{person(a.person).name} · {dateShort(a.date)}, {t12(a.start)}</p></div>
                    <Link className="link" to={'/citas?cita=' + a.id}>Revisar <Icon id="arrow" className="icon--sm" /></Link></li>
                ))}
              </ul>
            ) : <p className="muted">Nada pendiente por ahora. Todo en su lugar.</p>}
          </section>
        </div>

        <div className="stack">
          {featured && fb && (
            <section className="feature" aria-label="Propiedad destacada">
              <p className="feature__eyebrow">En tu cartera · {featured.id}</p>
              <div className="feature__card">
                <div className="feature__media"><Cover p={featured} /><span className="badge badge--dorado">En {opLabel(featured).toLowerCase()}</span></div>
                <div className="feature__body">
                  <p className="feature__price">{priceLabel(featured)}</p>
                  <p className="feature__name">{featured.name}</p>
                  <p className="feature__loc">{featured.zone}, Cancún</p>
                  <ul className="specs">
                    <li><Icon id="bed" />{featured.rec}<span className="sr-only"> recámaras</span></li>
                    <li><Icon id="bath" />{featured.banos}<span className="sr-only"> baños</span></li>
                    <li><Icon id="area" />{featured.m2} m²</li>
                  </ul>
                </div>
              </div>
              <div className="feature__foot">
                <span>{fb.name} · {fNext} {plural(fNext, 'próxima visita', 'próximas visitas')}</span>
                <Link to={'/propiedades/' + featured.id}>Administrar propiedad <Icon id="arrow-ur" className="icon--sm" /></Link>
              </div>
            </section>
          )}
          <section className="card card--pad" aria-labelledby="act-title">
            <h2 className="card__title" id="act-title" style={{ marginBottom: '.25rem' }}>Actividad reciente</h2>
            {D.activity.length ? <ul className="activity">{D.activity.slice(0, 4).map((e, i) => <li key={i}><time>{e.when}</time><p>{e.text}</p></li>)}</ul> : <p className="muted">Todavía no hay actividad registrada.</p>}
          </section>
        </div>
      </div>
    </>
  );
}
