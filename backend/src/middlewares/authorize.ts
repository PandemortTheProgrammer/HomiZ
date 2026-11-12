import type { RequestHandler } from 'express';
import { AppError } from './error-handler.js';
import { currentUser } from './authenticate.js';

const FORBIDDEN = 'No tienes permiso para realizar esta acción.';

/** Solo personal de la inmobiliaria (broker o administrador). */
export const requireStaff: RequestHandler = (_req, res, next) => {
  if (currentUser(res).type !== 'staff') throw new AppError(403, 'FORBIDDEN', FORBIDDEN);
  next();
};

/** Solo clientes (inquilinos o prospectos con cuenta). */
export const requireClient: RequestHandler = (_req, res, next) => {
  if (currentUser(res).type !== 'client') throw new AppError(403, 'FORBIDDEN', FORBIDDEN);
  next();
};

/** Exige TODOS los permisos indicados (códigos de la tabla permissions). */
export function requirePermission(...codes: string[]): RequestHandler {
  return (_req, res, next) => {
    const user = currentUser(res);
    const missing = codes.filter((c) => !user.permissions.has(c));
    if (user.type !== 'staff' || missing.length) {
      throw new AppError(403, 'FORBIDDEN', FORBIDDEN, { missingPermissions: missing });
    }
    next();
  };
}

/** Exige al menos uno de los roles indicados (broker, admin). */
export function requireRole(...roles: string[]): RequestHandler {
  return (_req, res, next) => {
    const user = currentUser(res);
    if (!roles.some((r) => user.roles.includes(r))) throw new AppError(403, 'FORBIDDEN', FORBIDDEN);
    next();
  };
}
