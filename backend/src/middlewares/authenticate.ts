import type { RequestHandler, Response } from 'express';
import { AppError } from './error-handler.js';
import { verifyAccessToken } from '../services/token.service.js';
import * as Users from '../models/user.model.js';
import * as Clients from '../models/client.model.js';

/** Usuario autenticado disponible en res.locals.user. */
export interface AuthUser {
  id: string;
  name: string;
  email: string;
  type: 'client' | 'staff';
  roles: string[];
  permissions: Set<string>;
  /** Expediente del cliente vinculado a la cuenta (solo perfiles cliente). */
  clientId: string | null;
}

/**
 * Exige un access token válido (Authorization: Bearer ...). Roles y permisos se leen de la base en cada
 * petición, así un cambio de permisos o una baja aplican de inmediato sin esperar a que expire el token.
 */
export const authenticate: RequestHandler = async (req, res, next) => {
  const header = req.header('authorization') ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7).trim() : '';
  const payload = token ? verifyAccessToken(token) : null;
  if (!payload) throw new AppError(401, 'UNAUTHENTICATED', 'Tu sesión no es válida o expiró. Inicia sesión de nuevo.');

  const user = await Users.findById(payload.sub);
  if (!user) throw new AppError(401, 'UNAUTHENTICATED', 'Tu sesión no es válida o expiró. Inicia sesión de nuevo.');
  if (!user.active) throw new AppError(403, 'ACCOUNT_INACTIVE', 'Su cuenta no está activa, comuníquese con la inmobiliaria.');

  const access = user.type === 'staff' ? await Users.loadAccess(user.id) : { roles: [], permissions: [] };
  const client = user.type === 'client' ? await Clients.findByUserId(user.id) : null;
  const authUser: AuthUser = {
    id: user.id,
    name: user.name,
    email: user.email,
    type: user.type,
    roles: access.roles,
    permissions: new Set(access.permissions),
    clientId: client?.id ?? null,
  };
  res.locals.user = authUser;
  next();
};

/** Usuario de la petición (después de authenticate). */
export function currentUser(res: Response): AuthUser {
  const user = res.locals.user as AuthUser | undefined;
  if (!user) throw new AppError(401, 'UNAUTHENTICATED', 'Inicia sesión para continuar.');
  return user;
}
