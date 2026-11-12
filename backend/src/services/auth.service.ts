import { randomInt } from 'node:crypto';
import { env } from '../config/env.js';
import { PRIVACY_VERSION } from '../config/legal.js';
import { withTransaction, type Db } from '../config/database.js';
import { AppError } from '../middlewares/error-handler.js';
import * as Users from '../models/user.model.js';
import * as Clients from '../models/client.model.js';
import * as Tokens from '../models/token.model.js';
import { insertActivity } from '../models/activity.model.js';
import { hashPassword, needsRehash, verifyAgainstDummy, verifyPassword } from './password.service.js';
import {
  accessTokenSeconds,
  createOpaqueToken,
  hashOpaqueToken,
  refreshExpiry,
  signAccessToken,
} from './token.service.js';
import { sendMail } from './mail.service.js';

export const MSG_INVALID_LOGIN = 'El correo o la contraseña son inválidos, intente de nuevo.';
export const MSG_INACTIVE = 'Su cuenta no está activa, comuníquese con la inmobiliaria.';
export const MSG_FORGOT = 'Si el correo está registrado, te enviamos una contraseña temporal. Entra con ella y crea la tuya.';

export interface PublicUser {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  birthDate: string | null;
  type: 'client' | 'staff';
  initials: string | null;
  roles: string[];
  permissions: string[];
  /** Entró con una contraseña temporal: el panel y la app le piden crear la suya */
  mustChangePassword: boolean;
}

export interface Session {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  user: PublicUser;
}

export async function toPublicUser(u: Users.UserRow): Promise<PublicUser> {
  const access = u.type === 'staff' ? await Users.loadAccess(u.id) : { roles: [], permissions: [] };
  return {
    id: u.id,
    name: u.name,
    email: u.email,
    phone: u.phone,
    birthDate: u.birth_date,
    type: u.type,
    initials: u.initials,
    roles: access.roles,
    permissions: access.permissions,
    mustChangePassword: u.must_change_password,
  };
}

async function issueSession(u: Users.UserRow): Promise<Session> {
  const { token, hash } = createOpaqueToken();
  await Tokens.insertRefreshToken(u.id, hash, refreshExpiry());
  return {
    accessToken: signAccessToken({ sub: u.id, type: u.type }),
    refreshToken: token,
    expiresIn: accessTokenSeconds(),
    user: await toPublicUser(u),
  };
}

function lockedError(until: Date): AppError {
  // El fin del bloqueo lo calcula la base (now()); si su reloj va unos milisegundos adelante del de Node,
  // el redondeo daría un minuto de más. Nunca se informa más que la duración configurada.
  const minutes = Math.min(env.LOGIN_LOCK_MINUTES, Math.max(1, Math.ceil((until.getTime() - Date.now()) / 60000)));
  return new AppError(423, 'ACCOUNT_LOCKED', `Por seguridad tu cuenta está bloqueada. Intenta de nuevo en ${minutes} minuto${minutes === 1 ? '' : 's'}.`, {
    retryAfterMinutes: minutes,
  });
}

/** Inicio de sesión con bloqueo tras varios intentos y registro en el historial. */
export async function login(email: string, password: string): Promise<Session> {
  const user = await Users.findByEmail(email);
  if (!user) {
    await verifyAgainstDummy(password);
    await insertActivity({ entity: 'auth', action: 'login_failed', description: 'Intento de acceso con un correo no registrado.' });
    throw new AppError(401, 'INVALID_CREDENTIALS', MSG_INVALID_LOGIN);
  }
  if (user.locked_until && user.locked_until.getTime() > Date.now()) {
    await insertActivity({ userId: user.id, entity: 'auth', action: 'login_blocked', description: 'Intento de acceso con la cuenta bloqueada.' });
    throw lockedError(user.locked_until);
  }
  let ok = await verifyPassword(user.password_hash, password);
  if (!ok && (await Tokens.consumeTemporaryPassword(user.id, temporaryHash(user.id, password)))) {
    // Entró con la contraseña temporal del correo: queda como su contraseña hasta que cree la suya
    await Users.updatePassword(user.id, await hashPassword(password), undefined, true);
    user.must_change_password = true;
    ok = true;
  }
  if (!ok) {
    const lockedUntil = await Users.registerFailedAttempt(user.id, env.LOGIN_MAX_ATTEMPTS, env.LOGIN_LOCK_MINUTES);
    const nowLocked = !!lockedUntil && lockedUntil.getTime() > Date.now();
    await insertActivity({
      userId: user.id,
      entity: 'auth',
      action: nowLocked ? 'account_locked' : 'login_failed',
      description: nowLocked ? 'Cuenta bloqueada por intentos fallidos.' : 'Contraseña incorrecta.',
    });
    if (nowLocked) throw lockedError(lockedUntil);
    throw new AppError(401, 'INVALID_CREDENTIALS', MSG_INVALID_LOGIN);
  }
  if (!user.active) {
    await insertActivity({ userId: user.id, entity: 'auth', action: 'login_inactive', description: 'Intento de acceso con cuenta inactiva.' });
    throw new AppError(403, 'ACCOUNT_INACTIVE', MSG_INACTIVE);
  }
  await Users.resetAttempts(user.id);
  // Guardada con los parámetros anteriores (64 MiB): se vuelve a guardar con los de menos memoria
  if (needsRehash(user.password_hash)) {
    await Users.updatePassword(user.id, await hashPassword(password), undefined, user.must_change_password).catch(() => {});
  }
  await insertActivity({ userId: user.id, entity: 'auth', action: 'login_success', description: 'Inicio de sesión.' });
  return issueSession(user);
}

/** Registro de clientes desde la app: crea el usuario y su expediente (o vincula el existente). */
export async function register(data: { name: string; email: string; phone: string | null; password: string }): Promise<Session> {
  if (await Users.findByEmail(data.email)) {
    throw new AppError(409, 'EMAIL_TAKEN', 'Ya existe una cuenta con ese correo. Inicia sesión o recupera tu contraseña.');
  }
  const passwordHash = await hashPassword(data.password);
  const user = await withTransaction(async (db) => {
    const u = await Users.createUser({ ...data, passwordHash, type: 'client' }, db);
    const clientId = await Clients.linkOrCreateForUser(u, db);
    await insertActivity({ userId: u.id, entity: 'client', entityId: clientId, action: 'register', description: `Cuenta de cliente creada desde la app. Aceptó el aviso de privacidad (versión ${PRIVACY_VERSION}).` }, db);
    return u;
  }).catch((err) => {
    if (err?.code === '23505') throw new AppError(409, 'EMAIL_TAKEN', 'Ya existe una cuenta con ese correo. Inicia sesión o recupera tu contraseña.');
    throw err;
  });
  await sendMail({
    to: user.email,
    subject: 'Bienvenido a Homiz · Inmobiliaria Zugar',
    text:
      `Hola, ${user.name.split(' ')[0]}:\n\n` +
      'Tu cuenta de la app Homiz ya está lista. Entra con tu correo y la contraseña que elegiste para enviar tus solicitudes y agendar tus visitas.\n\n' +
      'Si no creaste esta cuenta, escríbenos para darla de baja.\n\nInmobiliaria Zugar',
    action: { label: 'Abrir la app Homiz', url: await loginLink(user) },
  });
  return issueSession(user);
}

/**
 * Rotación del refresh token: cada uso entrega uno nuevo y revoca el anterior.
 * Si alguien presenta un token ya revocado (posible robo), se cierran todas las sesiones del usuario.
 */
export async function refresh(refreshToken: string): Promise<Session> {
  const invalid = new AppError(401, 'INVALID_REFRESH_TOKEN', 'Tu sesión expiró. Inicia sesión de nuevo.');
  const row = await Tokens.findRefreshToken(hashOpaqueToken(refreshToken));
  if (!row) throw invalid;
  if (row.revoked_at) {
    await Tokens.revokeAllForUser(row.user_id);
    await insertActivity({ userId: row.user_id, entity: 'auth', action: 'refresh_reuse', description: 'Se reutilizó un token revocado; se cerraron todas las sesiones.' });
    throw invalid;
  }
  if (row.expires_at.getTime() <= Date.now()) throw invalid;
  if (!(await Tokens.revokeRefreshToken(row.id))) throw invalid;
  const user = await Users.findById(row.user_id);
  if (!user) throw invalid;
  if (!user.active) throw new AppError(403, 'ACCOUNT_INACTIVE', MSG_INACTIVE);
  return issueSession(user);
}

/** Cierra la sesión: revoca el refresh token presentado (o todas si allDevices). */
export async function logout(userId: string, refreshToken: string | undefined, allDevices: boolean): Promise<void> {
  if (allDevices) {
    await Tokens.revokeAllForUser(userId);
  } else if (refreshToken) {
    const row = await Tokens.findRefreshToken(hashOpaqueToken(refreshToken));
    if (row && row.user_id === userId) await Tokens.revokeRefreshToken(row.id);
  }
  await insertActivity({ userId, entity: 'auth', action: 'logout', description: allDevices ? 'Cerró sesión en todos los dispositivos.' : 'Cerró sesión.' });
}

/**
 * Cambia la contraseña (también la que pide crear tras entrar con la temporal). Cierra las demás sesiones
 * y devuelve una sesión nueva para que quien la cambió siga dentro.
 */
export async function changePassword(userId: string, current: string, next: string): Promise<Session> {
  const user = await Users.findById(userId);
  if (!user || !(await verifyPassword(user.password_hash, current))) {
    throw new AppError(400, 'INVALID_CURRENT_PASSWORD', 'La contraseña actual no es correcta.');
  }
  if (current === next) throw new AppError(400, 'SAME_PASSWORD', 'La nueva contraseña debe ser distinta de la actual.');
  await Users.updatePassword(userId, await hashPassword(next));
  await Tokens.revokeAllForUser(userId);
  await insertActivity({ userId, entity: 'auth', action: 'password_changed', description: user.must_change_password ? 'Creó su contraseña (después de la temporal).' : 'Cambió su contraseña.' });
  return issueSession({ ...user, must_change_password: false });
}

/** Sin letras ni números que se confundan (0/O, 1/I/l) */
const TEMP_CHARS = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
/** Contraseña temporal fácil de copiar: Zug-xxxx-xxxx (con mayúscula, minúscula y número) */
export function temporaryPassword(): string {
  const part = () => Array.from({ length: 4 }, () => TEMP_CHARS[randomInt(TEMP_CHARS.length)]).join('');
  return `Zug-${part()}-${randomInt(10, 100)}${part()}`;
}
/** Hash de la contraseña temporal ligado al usuario (en password_resets.code_hash) */
const temporaryHash = (userId: string, password: string) => hashOpaqueToken(`${userId}:${password}`);

/** Solo el propietario entra al panel; brokers y administradores usan la app. */
const entersPanel = async (user: { id: string; type: string }) => user.type === 'staff' && (await Users.loadAccess(user.id)).roles.includes('owner');

/** Enlace del correo: al panel (propietario) o al inicio de sesión de la app, con el correo escrito (los demás). */
async function loginLink(user: { id: string; type: string; email: string }): Promise<string> {
  if (await entersPanel(user)) return env.APP_RESET_URL;
  const base = env.APP_CLIENT_URL;
  return `${base}${base.includes('?') ? '&' : '?'}email=${encodeURIComponent(user.email)}`;
}

/**
 * «Olvidé mi contraseña»: envía una contraseña temporal (vale PASSWORD_RESET_MINUTES). La anterior sigue
 * sirviendo hasta que se use la temporal; al entrar con ella se le pide crear la suya.
 * Siempre responde igual, exista o no el correo, para no revelar qué cuentas existen.
 */
export async function forgotPassword(email: string): Promise<void> {
  const user = await Users.findByEmail(email);
  if (!user || !user.active) return;
  const temp = temporaryPassword();
  const expiresAt = new Date(Date.now() + env.PASSWORD_RESET_MINUTES * 60000);
  await Tokens.insertPasswordReset(user.id, createOpaqueToken().hash, expiresAt, undefined, temporaryHash(user.id, temp));
  await insertActivity({ userId: user.id, entity: 'auth', action: 'password_reset_requested', description: 'Solicitó recuperar su contraseña (contraseña temporal).' });
  await sendMail({
    to: user.email,
    subject: 'Tu contraseña temporal · Zugar',
    text:
      `Hola, ${user.name.split(' ')[0]}:\n\n` +
      `Recibimos una solicitud para recuperar tu contraseña. Entra con esta contraseña temporal (vale ${env.PASSWORD_RESET_MINUTES} minutos):\n\n` +
      `${temp}\n\nAl entrar te pediremos crear tu propia contraseña.\n\n` +
      'Si no fuiste tú, ignora este correo: tu contraseña de siempre sigue funcionando.\n\nInmobiliaria Zugar',
    action: { label: (await entersPanel(user)) ? 'Entrar al panel' : 'Abrir la app Homiz', url: await loginLink(user) },
  });
}

/**
 * Cuenta de la app creada sola al enviar un formulario del sitio: le llega una contraseña temporal por correo;
 * al entrar crea la suya y ve su solicitud. Si ya tenía cuenta, no se toca.
 * Devuelve el expediente (cliente) vinculado y si la cuenta es nueva.
 */
export async function ensureClientAccount(data: { name: string; email: string; phone: string | null }, db: Db): Promise<{ clientId: string; created: boolean; userId: string }> {
  const existing = await Users.findByEmail(data.email);
  if (existing) {
    const { rows } = await db.query<{ id: string }>('SELECT id FROM clients WHERE user_id = $1 ORDER BY created_at LIMIT 1', [existing.id]);
    const clientId = rows[0]?.id ?? (existing.type === 'client' ? await Clients.linkOrCreateForUser(existing, db) : '');
    return { clientId, created: false, userId: existing.id };
  }
  // Contraseña temporal por correo: al entrar con ella se le pide crear la suya.
  const user = await Users.createUser({ ...data, passwordHash: await hashPassword(temporaryPassword()), type: 'client' }, db);
  const clientId = await Clients.linkOrCreateForUser(user, db);
  await insertActivity({ userId: user.id, entity: 'client', entityId: clientId, action: 'register', description: 'Cuenta de la app creada al enviar un formulario del sitio.' }, db);
  await sendAccountReady(user, db);
  return { clientId, created: true, userId: user.id };
}

/** Pone una contraseña temporal nueva a la cuenta del cliente y le envía el correo «Tu cuenta de Homiz está lista». */
export async function sendAccountReady(user: { id: string; name: string; email: string; type: string }, db: Db): Promise<void> {
  const temp = temporaryPassword();
  await db.query('UPDATE users SET password_hash = $2, must_change_password = TRUE, failed_attempts = 0, locked_until = NULL WHERE id = $1', [user.id, await hashPassword(temp)]);
  await sendMail({
    to: user.email,
    subject: 'Tu cuenta de Homiz está lista · Inmobiliaria Zugar',
    text:
      `Hola, ${user.name.split(' ')[0]}:\n\n` +
      'Recibimos tu solicitud y te creamos una cuenta en la app Homiz para que la sigas: ahí tu asesor te contesta, te propone casas y agendas tus visitas.\n\n' +
      `Entra con tu correo (${user.email}) y esta contraseña temporal:\n\n${temp}\n\n` +
      'Al entrar te pediremos crear tu propia contraseña.\n\nInmobiliaria Zugar',
    action: { label: 'Abrir la app Homiz', url: await loginLink(user) },
  });
}

export async function resetPassword(token: string, password: string): Promise<void> {
  const passwordHash = await hashPassword(password);
  await withTransaction(async (db) => {
    const id = await Tokens.consumePasswordReset(hashOpaqueToken(token), db);
    if (!id) throw new AppError(400, 'INVALID_RESET_TOKEN', 'El enlace no es válido o ya expiró. Solicita uno nuevo.');
    await Users.updatePassword(id, passwordHash, db);
    await Tokens.revokeAllForUser(id, db);
    await insertActivity({ userId: id, entity: 'auth', action: 'password_reset', description: 'Creó una nueva contraseña con el enlace de recuperación.' }, db);
  });
}
