import { initializeApp, getApps } from '@firebase/app';
import { getMessaging, getToken, isSupported, onMessage, type Messaging } from '@firebase/messaging';
import { API_URL } from '../lib/api';

/* ==========================================================================
   Avisos del panel en el navegador (Firebase Cloud Messaging, proyecto homiz-413ff).
   - Solo con sesión de la API y en una página segura (https o localhost).
   - El permiso se pide con un botón del menú de usuario.
   - El navegador queda registrado en POST /devices; al cerrar sesión se da de baja.
   - Con la pestaña cerrada, los avisos los muestra public/admin/firebase-messaging-sw.js.
   ========================================================================== */
const CONFIG = {
  apiKey: 'AIzaSyBx7pt0_zgMJBrK0MoFiM91-7tOmRLtX1E',
  authDomain: 'homiz-413ff.firebaseapp.com',
  projectId: 'homiz-413ff',
  storageBucket: 'homiz-413ff.firebasestorage.app',
  messagingSenderId: '781670117568',
  appId: '1:781670117568:web:ce01ba2a927343e7c57d25',
};
const VAPID_KEY = 'BEJw-k2x765RpmUta5eQpKFwF0Pfp5f8B7yRorKR792pTS0irlUE-dGdiGZj7sC9KDaZf3skbgCH8WpdhV25Elc';
const TOKEN_KEY = 'zugar_push_token';

export const pushSupported = () => window.isSecureContext && 'serviceWorker' in navigator && 'Notification' in window && 'PushManager' in window;

function stored(v?: string | null) {
  try {
    if (v === undefined) return localStorage.getItem(TOKEN_KEY);
    if (v) localStorage.setItem(TOKEN_KEY, v);
    else localStorage.removeItem(TOKEN_KEY);
  } catch {
    return null;
  }
  return null;
}

let messaging: Messaging | null = null;
async function getMessagingOnce(onForeground: (title: string, body: string) => void) {
  if (messaging) return messaging;
  if (!(await isSupported())) throw new Error('Este navegador no admite avisos push.');
  const app = getApps()[0] ?? initializeApp(CONFIG);
  messaging = getMessaging(app);
  onMessage(messaging, (m) => onForeground(m.notification?.title ?? '', m.notification?.body ?? 'Tienes un aviso nuevo.'));
  return messaging;
}

/** La primera vez el service worker tarda en activarse; sin esperar, Firebase no puede suscribirse. */
function active(reg: ServiceWorkerRegistration): Promise<ServiceWorkerRegistration> {
  if (reg.active) return Promise.resolve(reg);
  const sw = (reg.installing || reg.waiting)!;
  return new Promise((ok) => sw.addEventListener('statechange', () => sw.state === 'activated' && ok(reg)));
}

/** Pide el token a Firebase y registra este navegador en el servidor.
    Un solo registro a la vez: dos pedidos simultáneos crearían dos tokens y uno quedaría sin dar de baja. */
let registering: Promise<string> | null = null;
export function registerBrowser(send: (token: string) => Promise<unknown>, onForeground: (title: string, body: string) => void) {
  registering ??= (async () => {
    const [m, reg] = await Promise.all([getMessagingOnce(onForeground), navigator.serviceWorker.register('/admin/firebase-messaging-sw.js', { scope: '/admin/' }).then(active)]);
    const token = await getToken(m, { vapidKey: VAPID_KEY, serviceWorkerRegistration: reg });
    if (!token) throw new Error('Firebase no entregó el token.');
    await send(token);
    stored(token);
    return token;
  })().finally(() => (registering = null));
  return registering;
}

/** Al cerrar sesión: este navegador deja de recibir los avisos de esa cuenta. */
export function pushLogout(accessToken: string) {
  const t = stored();
  if (!t || !accessToken || !API_URL) return;
  fetch(API_URL + '/devices/' + encodeURIComponent(t), { method: 'DELETE', keepalive: true, headers: { Authorization: 'Bearer ' + accessToken } }).catch(() => {});
  stored(null);
}
