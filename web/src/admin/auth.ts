import { apiLogin, apiLogout, type ApiFailure } from './api';

/* ==========================================================================
   Sesión del panel. Inicia sesión con POST /auth/login y guarda los tokens.
   Sin servidor no hay acceso: se muestra el error (nunca datos de ejemplo).
   ========================================================================== */
const KEY = 'zugar-admin-sesion';
const LOCK_KEY = 'zugar-admin-intentos';
const HOURS = 8;
const MAX_TRIES = 5;
const LOCK_SECONDS = 30;

export interface Session {
  email: string;
  name: string;
  role: string;
  exp: number;
  api?: boolean;
  token?: string;
  refresh?: string;
  roles?: string[];
  permissions?: string[];
  /** Entró con la contraseña temporal del correo: antes de usar el panel crea la suya */
  mustChange?: boolean;
}

export type LoginResult =
  | { ok: true; user: Session }
  | { ok: false; error: 'locked'; lockedFor: number }
  | { ok: false; error: 'invalid'; left: number }
  | { ok: false; error: 'noaccess' }
  /** El servidor no respondió (apagado o sin internet) */
  | { ok: false; error: 'offline' }
  /** El servidor respondió con otro error (429, 500…): se muestra su mensaje */
  | { ok: false; error: 'server'; message: string };

const read = (s: Storage): Session | null => {
  try {
    return JSON.parse(s.getItem(KEY) || 'null');
  } catch {
    return null;
  }
};

export function currentSession(): Session | null {
  let s: Session | null = null;
  try {
    s = read(sessionStorage) || read(localStorage);
  } catch {
    return null;
  }
  // Sin token de la API (sesiones viejas del modo de diseño) no hay sesión válida
  if (!s || !s.exp || Date.now() > s.exp || !s.api || !s.token) {
    clearSession();
    return null;
  }
  return s;
}

export function clearSession() {
  try {
    sessionStorage.removeItem(KEY);
    localStorage.removeItem(KEY);
  } catch {
    /* almacenamiento bloqueado */
  }
}

/** Cambia datos de la sesión guardada (donde ya estaba) */
function updateSession(change: Partial<Session>) {
  for (const s of [sessionStorage, localStorage]) {
    const cur = read(s);
    if (!cur) continue;
    try {
      s.setItem(KEY, JSON.stringify({ ...cur, ...change }));
    } catch {
      /* sin almacenamiento */
    }
  }
}

/** La API renueva el token cada 15 minutos: se guarda donde ya estaba la sesión */
export function saveTokens(token: string, refresh: string) {
  updateSession({ token, refresh });
}

/** Ya creó su contraseña: tokens nuevos (las sesiones anteriores se cerraron) y entra al panel */
export function passwordChanged(token: string, refresh: string) {
  updateSession({ token, refresh, mustChange: false });
}

/* ---------- Roles y permisos ----------
   Cada persona del personal es broker, administración o ambos; el propietario decide quién es qué.
   El panel solo muestra las acciones permitidas; la API vuelve a validar cada una. */
export function roleLabel(roles: string[] = []) {
  if (roles.includes('owner')) return 'Propietario';
  if (roles.includes('admin') && roles.includes('broker')) return 'Broker y administración';
  return roles.includes('admin') ? 'Administración' : 'Broker';
}

/** Administración o propietario (lo que el broker no hace: hacer inquilino, números de servicio…) */
export function isAdminSession() {
  const r = currentSession()?.roles ?? [];
  return r.includes('admin') || r.includes('owner');
}

export function can(permission: string) {
  const s = currentSession();
  if (!s) return false;
  return !!s.api && !!s.permissions?.includes(permission);
}

/** Al abrir el panel se leen de nuevo roles y permisos (pudieron cambiar desde el último acceso) */
export function refreshAccess(roles: string[], permissions: string[]) {
  if (!roles.includes('owner')) {
    // Sesión abierta antes de la regla, o ya no es propietario: sale del panel
    clearSession();
    window.location.hash = '#/login?sinacceso=1';
    return;
  }
  updateSession({ roles, permissions, role: roleLabel(roles) });
}

export function lockState() {
  let l: { tries?: number; until?: number } | null = null;
  try {
    l = JSON.parse(sessionStorage.getItem(LOCK_KEY) || 'null');
  } catch {
    /* nada */
  }
  const left = Math.ceil(((l?.until ?? 0) - Date.now()) / 1000);
  return { tries: l?.tries ?? 0, lockedFor: left > 0 ? left : 0 };
}

function start(session: Omit<Session, 'exp'>, remember: boolean): LoginResult {
  const s: Session = { ...session, exp: Date.now() + HOURS * 3600 * 1000 };
  try {
    sessionStorage.removeItem(LOCK_KEY);
    clearSession();
    (remember ? localStorage : sessionStorage).setItem(KEY, JSON.stringify(s));
  } catch {
    /* sin almacenamiento: la sesión dura lo que dure la página */
  }
  return { ok: true, user: s };
}

function failed(): LoginResult {
  const tries = lockState().tries + 1;
  const until = tries >= MAX_TRIES ? Date.now() + LOCK_SECONDS * 1000 : 0;
  try {
    sessionStorage.setItem(LOCK_KEY, JSON.stringify({ tries: until ? 0 : tries, until }));
  } catch {
    /* sin almacenamiento */
  }
  return until ? { ok: false, error: 'locked', lockedFor: LOCK_SECONDS } : { ok: false, error: 'invalid', left: MAX_TRIES - tries };
}

export async function login(email: string, password: string, remember: boolean): Promise<LoginResult> {
  const lock = lockState();
  if (lock.lockedFor) return { ok: false, error: 'locked', lockedFor: lock.lockedFor };
  try {
    const r = await apiLogin(email, password);
    const u = r.user;
    if (!u.roles?.includes('owner')) return { ok: false, error: 'noaccess' }; // el panel es del propietario; todos los demás usan la app
    return start(
      { email: u.email, name: u.name, role: roleLabel(u.roles), api: true, token: r.accessToken, refresh: r.refreshToken, roles: u.roles, permissions: u.permissions, mustChange: !!u.mustChangePassword },
      remember,
    );
  } catch (err) {
    const e = err as ApiFailure;
    if (e?.sinConexion) return { ok: false, error: 'offline' }; // sin servidor no se entra
    if (e?.status === 423) {
      const min = (e.detalles as { retryAfterMinutes?: number } | undefined)?.retryAfterMinutes || 15;
      try {
        sessionStorage.setItem(LOCK_KEY, JSON.stringify({ tries: 0, until: Date.now() + min * 60000 }));
      } catch {
        /* sin almacenamiento */
      }
      return { ok: false, error: 'locked', lockedFor: min * 60 };
    }
    // Solo 400/401 son datos incorrectos; 429, 500… son del servidor y se dicen tal cual
    if (e?.status && e.status !== 400 && e.status !== 401) return { ok: false, error: 'server', message: e.mensaje || 'El servidor no pudo completar el acceso.' };
    return failed();
  }
}

/** true justo después de cerrar sesión: el panel manda al acceso con «Cerraste sesión correctamente» */
export const loggedOut = { value: false };

export function logout() {
  apiLogout();
  loggedOut.value = true;
  clearSession();
  location.replace('#/login?salida=1');
}
