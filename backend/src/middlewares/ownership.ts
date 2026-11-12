import type { Request, RequestHandler } from 'express';
import { z } from 'zod';
import { AppError } from './error-handler.js';
import { currentUser } from './authenticate.js';
import { checkPropertyAccess } from '../services/access.service.js';

const uuid = z.uuid();

/**
 * Verifica que quien pide tenga relación con la propiedad: el broker responsable, el cliente vinculado
 * o un administrador. `getPropertyId` indica de dónde sale el id (params, query o body).
 * Si el id es opcional y no viene, se deja pasar (el controlador limita el alcance del listado).
 */
export function requirePropertyAccess(getPropertyId: (req: Request) => unknown, options: { optional?: boolean } = {}): RequestHandler {
  return async (req, res, next) => {
    const raw = getPropertyId(req);
    if (raw === undefined || raw === null || raw === '') {
      if (options.optional) return next();
      throw new AppError(400, 'VALIDATION_ERROR', 'Falta indicar la propiedad.');
    }
    const parsed = uuid.safeParse(raw);
    if (!parsed.success) throw new AppError(400, 'VALIDATION_ERROR', 'El identificador de la propiedad no es válido.');

    const result = await checkPropertyAccess(currentUser(res), parsed.data);
    if (result === 'not_found') throw new AppError(404, 'NOT_FOUND', 'La propiedad no existe.');
    if (result === 'forbidden') throw new AppError(403, 'NOT_OWNER', 'No tienes acceso a esta propiedad.');
    next();
  };
}
