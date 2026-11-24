import { useEffect, useRef, useState } from 'react';
import { Link, Navigate, Outlet, useLocation } from 'react-router';
import { apiActive, load, request, type ApiFailure } from '../api';
import { currentSession, loggedOut, logout } from '../auth';
import { lastUpdate, LIVE_STATUS_EVENT, liveConnected, startLive } from '../live';
import { pushSupported, registerBrowser } from '../push';
import { rerender } from '../store';
import { NotificationsBell, noticesRefresh } from './Notifications';
import { useOverlay } from './Overlay';
import { Icon } from './ui';

const NAV: [string, string, string][] = [
  ['resumen', 'grid', 'Resumen'],
  ['propiedades', 'home', 'Propiedades'],
  ['personas', 'users', 'Clientes e inquilinos'],
  ['brokers', 'user-key', 'Brokers'],
  ['citas', 'cal', 'Citas'],
  ['solicitudes', 'mail', 'Solicitudes'],
  ['rentas', 'folder', 'Rentas y ventas'],
  ['pagos', 'cash', 'Pagos'],
];

/** Dice si el panel está recibiendo los cambios al momento y cuándo fue la última actualización */
function LiveStatus({ offline }: { offline: boolean }) {
  const [, setTick] = useState(0);
  useEffect(() => {
    const on = () => setTick((n) => n + 1);
    window.addEventListener(LIVE_STATUS_EVENT, on);
    return () => window.removeEventListener(LIVE_STATUS_EVENT, on);
  }, []);
  const on = !offline && liveConnected();
  const at = lastUpdate?.toLocaleTimeString('es-MX', { hour: 'numeric', minute: '2-digit', hourCycle: 'h12' });
  return (
    <span className={'live-status' + (on ? ' is-on' : '')} role="status" title={on ? 'Los cambios llegan al momento' : 'Sin conexión en vivo: los cambios llegan cada pocos segundos'}>
      <span className="live-status__dot" aria-hidden="true" />{on ? 'En vivo' : offline ? 'Sin conexión' : 'Reconectando…'}{at ? ` · ${at}` : ''}
    </span>
  );
}

/** Marco del panel: encabezado, menú lateral y la sección activa. Sin sesión, manda al acceso. */
export function Shell() {
  const session = currentSession();
  const { pathname, search } = useLocation();
  const { toast, open, confirm } = useOverlay();
  const connected = apiActive();
  const [ready, setReady] = useState(false);
  // Error al cargar los datos del servidor: se muestra fijo con «Reintentar» (nunca datos inventados)
  const [loadError, setLoadError] = useState('');
  const [retrying, setRetrying] = useState(false);
  const loadData = () => {
    setRetrying(true);
    return load().then(
      () => { setLoadError(''); setReady(true); setRetrying(false); rerender(); },
      (e: ApiFailure) => { setLoadError(e?.mensaje || 'El servidor no respondió.'); setReady(true); setRetrying(false); },
    );
  };
  const [userOpen, setUserOpen] = useState(false);
  // Menú lateral en pantallas chicas (☰)
  const [menuOpen, setMenuOpen] = useState(false);
  const menuBtn = useRef<HTMLButtonElement>(null);
  const [permission, setPermission] = useState(() => ('Notification' in window ? Notification.permission : 'denied'));
  const userBtn = useRef<HTMLButtonElement>(null);
  const section = pathname.split('/')[1] || 'resumen';

  // Primero se cargan los datos del servidor (GET /properties, /clients, /appointments, /users…)
  useEffect(() => {
    if (!connected) return;
    loadData();
    // Avisos en el navegador: con permiso ya concedido se vuelve a registrar en silencio (Firebase puede renovar el token)
    if (pushSupported() && Notification.permission === 'granted') registerPush().catch((e) => console.warn('Avisos: no se registró este navegador', e));
    // Tiempo real: lo que cambie otra persona (o la app) aparece solo, sin recargar la página
    return startLive();
  }, []);

  // Al cambiar de sección: arriba y foco en el título
  const first = useRef(true);
  useEffect(() => {
    setMenuOpen(false); // al elegir una sección, el menú ☰ se cierra
    if (first.current) { first.current = false; return; }
    window.scrollTo(0, 0);
    document.querySelector<HTMLElement>('#view h1')?.focus({ preventScroll: true });
  }, [pathname]);
  useEffect(() => {
    const h1 = document.querySelector('#view h1');
    document.title = (h1 ? h1.textContent + ' · ' : '') + 'Panel administrativo | Zugar';
  });

  // Menú de usuario: se cierra con Escape o al hacer clic fuera
  useEffect(() => {
    const onClick = (e: MouseEvent) => !(e.target as HTMLElement).closest('.user') && setUserOpen(false);
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape' && userOpen) { setUserOpen(false); userBtn.current?.focus(); } };
    document.addEventListener('click', onClick);
    document.addEventListener('keydown', onKey);
    return () => { document.removeEventListener('click', onClick); document.removeEventListener('keydown', onKey); };
  }, [userOpen]);

  // Menú ☰: Escape lo cierra y regresa el foco al botón; con el menú abierto la página no se desplaza
  useEffect(() => {
    if (!menuOpen) return;
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') { setMenuOpen(false); menuBtn.current?.focus(); } };
    document.addEventListener('keydown', onKey);
    document.body.classList.add('menu-open');
    // El menú se vuelve visible en el siguiente cuadro: hasta entonces no puede recibir el foco
    const t = setTimeout(() => document.querySelector<HTMLElement>('#sidebar nav a')?.focus(), 30);
    return () => { clearTimeout(t); document.removeEventListener('keydown', onKey); document.body.classList.remove('menu-open'); };
  }, [menuOpen]);

  // Entró con la contraseña temporal y no ha creado la suya: vuelve al acceso a crearla
  if (session?.mustChange) return <Navigate to="/login" replace />;
  if (!session) {
    if (loggedOut.value) return <Navigate to="/login?salida=1" replace />; // el acceso la apaga al abrir
    return <Navigate to={'/login' + (pathname !== '/' ? '?volver=' + encodeURIComponent(pathname + search) : '')} replace />;
  }

  function registerPush() {
    return registerBrowser(
      (token) => request('POST', '/devices', { fcmToken: token, platform: 'web' }),
      (title, body) => { toast((title ? title + ': ' : '') + body); noticesRefresh.now(); load().then(rerender, () => {}); },
    );
  }
  const activatePush = async () => {
    const p = await Notification.requestPermission();
    setPermission(p);
    if (p !== 'granted') { toast('No se activaron los avisos. Puedes permitirlos en la configuración del navegador.'); return; }
    try {
      await registerPush();
      toast('Listo: recibirás los avisos del panel en este navegador.');
    } catch (e) {
      console.warn('Avisos: no se activaron', e);
      toast('No se pudieron activar los avisos. Intenta de nuevo.');
    }
  };

  const exp = new Date(session.exp);
  const askLogout = () =>
    confirm({
      icon: 'arrow-ur', safe: true,
      title: '¿Cerrar sesión?',
      lead: 'Tus cambios ya están guardados en el servidor de Zugar.',
      cancel: 'Seguir en el panel', confirm: 'Cerrar sesión',
      onConfirm: logout,
    });
  const help = () =>
    open((close) => (
      <>
        <span className="dialog__icon dialog__icon--info"><Icon id="info" className="icon--lg" /></span>
        <h2 id="dialog-title">¿Cómo usar el panel?</h2>
        <p className="lead">Todo lo que cambies aquí se refleja al momento en las demás secciones.</p>
        <ul className="activity">
          <li><strong>Propiedades.</strong> Da de alta casas, edita sus datos, fotos y amenidades, o pausa su publicación.</li>
          <li><strong>Clientes e inquilinos.</strong> Consulta el expediente de cada persona y su próxima visita.</li>
          <li><strong>Brokers.</strong> Asigna un responsable a cada casa; sus próximas citas se reasignan solas.</li>
          <li><strong>Citas.</strong> Confirma, reprograma o cancela visitas desde la agenda semanal.</li>
          <li><strong>Solicitudes.</strong> Lo que piden en el sitio y en la app. Contesta y propón casas: al cliente le llega a la app Homiz, en «Mis solicitudes», en lugar del correo.</li>
          <li><strong>Pagos y expediente.</strong> En cada casa, pestañas «Expediente» y «Pagos». Lo que puedes hacer depende de tu rol: el broker registra pagos y sube documentos de sus casas; administración además corrige o anula pagos y elimina documentos.</li>
        </ul>
        <p className="small muted" style={{ marginTop: '1rem' }}>Conectado al servidor: cada cambio se guarda al momento y solo se confirma cuando el servidor responde. Soporte: soporte@zugar.example</p>
        <div className="dialog__actions"><button className="btn" type="button" onClick={close}>Entendido</button></div>
      </>
    ));

  return (
    <>
      <a className="skip-link" href="#view">Saltar al contenido</a>
      <header className="topbar">
        <button ref={menuBtn} className="menu-btn" type="button" aria-expanded={menuOpen} aria-controls="sidebar"
          aria-label={menuOpen ? 'Cerrar el menú' : 'Abrir el menú'} onClick={() => setMenuOpen(!menuOpen)}>
          <Icon id={menuOpen ? 'x' : 'menu'} />
        </button>
        <Link className="brand" to="/resumen" aria-label="Zugar administración, ir al resumen">
          <img className="brand__logo" src="/assets/img/logo-zugar-blanco-1200.png" alt="Inmobiliaria Zugar" width="1200" height="492" />
          <span className="brand__tag">Administración · Cancún</span>
        </Link>
        <nav className="topnav" aria-label="Accesos generales">
          <Link className="topnav__extra" to="/resumen" aria-current="page">Panel administrativo</Link>
          <a className="topnav__extra" href="/" target="_blank" rel="noopener">Ver sitio público <Icon id="arrow-ur" className="icon--sm" /></a>
          <a className="topnav__extra" href="#" onClick={(e) => { e.preventDefault(); help(); }}>Ayuda</a>
          <LiveStatus offline={!!loadError} />
          <NotificationsBell />
          <div className="user">
            <button ref={userBtn} className="user__btn" type="button" aria-expanded={userOpen} aria-controls="user-menu" id="user-btn" onClick={(e) => { e.stopPropagation(); setUserOpen(!userOpen); }}>
              <span className="user__full">{session.name} · {session.role}</span>
              <span className="user__short" aria-hidden="true">{session.name.split(' ').map((w) => w[0]).slice(0, 2).join('').toUpperCase()}</span>
            </button>
            <div className="user__menu" id="user-menu" hidden={!userOpen}>
              <strong id="user-name">{session.name}</strong>
              <p id="user-meta">{session.role} · {session.email}</p>
              <hr />
              <p id="user-exp">Tu sesión vence a las {String(exp.getHours()).padStart(2, '0')}:{String(exp.getMinutes()).padStart(2, '0')} h.</p>
              {connected && pushSupported() && permission !== 'granted' && (
                <button className="btn btn--sm" id="push-btn" type="button" style={{ marginBottom: '.5rem' }} disabled={permission === 'denied'} onClick={activatePush}
                  title={permission === 'denied' ? 'Permite las notificaciones de este sitio en la configuración del navegador.' : 'Recibe nuevas solicitudes, citas y reportes aunque el panel esté cerrado.'}>
                  {permission === 'denied' ? 'Avisos bloqueados en este navegador' : 'Activar avisos en este navegador'}
                </button>
              )}
              <button className="btn btn--secondary btn--sm" type="button" onClick={askLogout}>Cerrar sesión</button>
            </div>
          </div>
        </nav>
      </header>
      <div className="shell">
        {menuOpen && <div className="sidebar-backdrop" aria-hidden="true" onClick={() => setMenuOpen(false)} />}
        <aside className={'sidebar' + (menuOpen ? ' is-open' : '')} id="sidebar">
          <p className="sidebar__label" id="menu-label">Gestión inmobiliaria</p>
          <nav aria-labelledby="menu-label">
            <ul>
              {NAV.map(([id, icon, label]) => (
                <li key={id}><Link to={'/' + id} aria-current={section === id ? 'page' : undefined}><Icon id={icon} />{label}</Link></li>
              ))}
            </ul>
          </nav>
          {/* En celular, los accesos de la barra superior pasan al menú */}
          <ul className="sidebar__extra">
            <li><a href="/" target="_blank" rel="noopener"><Icon id="arrow-ur" />Ver sitio público</a></li>
            <li><a href="#" onClick={(e) => { e.preventDefault(); setMenuOpen(false); help(); }}><Icon id="info" />Ayuda</a></li>
          </ul>
          <div className="sidebar__foot">
            <p>Casas para vivir Cancún.</p>
            <p>Equipo local</p>
            <p><span className="badge badge--gris">{loadError ? 'Sin conexión con el servidor' : 'Conectado al servidor'}</span></p>
          </div>
        </aside>
        <div className="main">
          <main className="view" id="view" tabIndex={-1}>
            {loadError && (
              <div className="callout callout--error" role="alert">
                <strong>No se pudieron cargar los datos del servidor</strong>
                {loadError} Revisa tu conexión o que la API esté encendida. Lo que ves puede estar incompleto y no se guardará nada hasta que vuelva la conexión.
                <div className="callout__actions"><button className="btn btn--sm" type="button" onClick={loadData} disabled={retrying}>{retrying ? 'Reintentando…' : 'Reintentar'}</button></div>
              </div>
            )}
            {ready ? <Outlet /> : <p className="muted" role="status">Cargando datos de Zugar…</p>}
          </main>
          <footer className="footer">
            <span>© 2026 Zugar · Administración</span>
            <span>{loadError ? 'Sin conexión' : 'Datos en vivo'}</span>
          </footer>
        </div>
      </div>
    </>
  );
}
