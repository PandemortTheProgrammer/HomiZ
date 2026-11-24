import { API_URL } from '../lib/api';
import { load, request } from './api';
import { currentSession } from './auth';
import { noticesRefresh } from './components/Notifications';
import { rerender } from './store';

/* ==========================================================================
   Tiempo real: el servidor avisa por WebSocket (/api/v1/ws) cada vez que alguien cambia algo
   (en el panel, en la app o en el sitio). El panel vuelve a leer los avisos, los datos
   (citas, casas, personas) y las listas abiertas, sin recargar la página.
   Respaldo si el WebSocket no conecta: se pregunta el número de cambios cada 5 s.
   ========================================================================== */

/** Evento de ventana al que se suscriben las listas que leen directo de la API (useApiData) */
export const LIVE_EVENT = 'zugar:changed';
/** Evento de ventana cuando cambia el estado de la conexión o llega una actualización */
export const LIVE_STATUS_EVENT = 'zugar:live-status';
/** Hora de la última actualización recibida */
export let lastUpdate: Date | null = null;
const status = () => window.dispatchEvent(new Event(LIVE_STATUS_EVENT));

let socket: WebSocket | null = null;
let retry: ReturnType<typeof setTimeout> | null = null;
let pending: ReturnType<typeof setTimeout> | null = null;
let poll: ReturnType<typeof setInterval> | null = null;
let lastSeq = -1;
let stopped = true;
let attempts = 0;
let ticks = 0;
let loading = false;
let dirty = false;

/** Vuelve a leer los datos. Si ya hay una lectura en curso, repite al terminar: la más lenta nunca pisa a la más nueva. */
function refresh() {
  if (loading) { dirty = true; return; }
  loading = true;
  load().then(() => { lastUpdate = new Date(); rerender(); status(); }, () => {}).finally(() => {
    loading = false;
    if (dirty) { dirty = false; refresh(); }
  });
}

/** Número de cambios del servidor: si avanzó desde el último que vimos, se recarga */
function seen(seq: number) {
  if (lastSeq >= 0 && seq !== lastSeq) changed();
  lastSeq = seq;
}

function changed() {
  // Varios cambios seguidos (guardar + aviso) se juntan en una sola recarga
  if (pending) clearTimeout(pending);
  pending = setTimeout(() => {
    pending = null;
    noticesRefresh.now();
    refresh();
    window.dispatchEvent(new Event(LIVE_EVENT));
  }, 250);
}

/** http(s)://host/api/v1 → ws(s)://host/api/v1/ws (relativo al sitio si la API es del mismo dominio) */
function socketUrl(token: string): string {
  const api = new URL(API_URL, location.href);
  api.protocol = api.protocol === 'https:' ? 'wss:' : 'ws:';
  return `${api.origin.replace(/^http/, 'ws')}${api.pathname.replace(/\/$/, '')}/ws?token=${encodeURIComponent(token)}`;
}

function connect() {
  const s = currentSession();
  if (stopped || !API_URL || !s?.api || !s.token) return;
  const ws = (socket = new WebSocket(socketUrl(s.token)));
  ws.onopen = () => { attempts = 0; status(); };
  ws.onmessage = (e) => {
    try { seen((JSON.parse(e.data) as { seq: number }).seq); } catch { /* mensaje desconocido */ }
  };
  ws.onclose = () => {
    if (socket === ws) socket = null;
    status();
    if (stopped) return;
    // El token dura 15 minutos: se renueva con cualquier petición y se vuelve a conectar (espera creciente hasta 30 s)
    attempts += 1;
    if (retry) clearTimeout(retry);
    retry = setTimeout(() => request<{ seq: number }>('GET', '/events/seq').then((r) => { seen(r.seq); connect(); }, connect), Math.min(30_000, 1000 * 2 ** Math.min(attempts, 5)));
  };
}

/** ¿Está llegando el tiempo real por WebSocket? (si no, la consulta periódica lo cubre) */
export const liveConnected = () => socket?.readyState === WebSocket.OPEN;

/** Empieza a escuchar (al abrir el panel). Devuelve cómo dejar de escuchar. */
export function startLive(): () => void {
  stopped = false;
  if (!socket) connect();
  // Respaldo: sin WebSocket (red que lo bloquea), cada 5 s se pregunta el número de cambios.
  // Con WebSocket se revisa cada 15 s: un túnel puede dejarlo «abierto» sin que llegue nada.
  const ask = () => request<{ seq: number }>('GET', '/events/seq').then((r) => seen(r.seq), () => {});
  if (!poll) {
    ask();
    poll = setInterval(() => { ticks += 1; if (document.visibilityState === 'visible' && (!liveConnected() || ticks % 3 === 0)) ask(); }, 5_000);
  }
  // Al volver a la pestaña, se revisa enseguida por si algo cambió mientras estaba oculta
  const onVisible = () => document.visibilityState === 'visible' && ask();
  document.addEventListener('visibilitychange', onVisible);
  return () => {
    stopped = true;
    document.removeEventListener('visibilitychange', onVisible);
    socket?.close();
    socket = null;
    if (retry) clearTimeout(retry);
    if (pending) clearTimeout(pending);
    if (poll) clearInterval(poll);
    poll = null;
    lastSeq = -1;
  };
}
