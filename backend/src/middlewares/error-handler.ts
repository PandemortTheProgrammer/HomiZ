import type { ErrorRequestHandler, RequestHandler } from 'express';
import { logger } from '../config/logger.js';

/** Error controlado de la API. Se responde como { error: { code, message, details } }. */
export class AppError extends Error {
  constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
    public readonly details?: unknown,
  ) {
    super(message);
  }
}

export const notFound: RequestHandler = (req, _res, next) => {
  next(new AppError(404, 'NOT_FOUND', 'El recurso solicitado no existe.'));
};

export const errorHandler: ErrorRequestHandler = (err, req, res, _next) => {
  if (err instanceof AppError) {
    res.status(err.status).json({ error: { code: err.code, message: err.message, details: err.details ?? null } });
    return;
  }
  if (err?.type === 'entity.parse.failed') {
    res.status(400).json({ error: { code: 'INVALID_JSON', message: 'El cuerpo de la petición no es JSON válido.', details: null } });
    return;
  }
  logger.error({ requestId: res.locals.requestId, err: err?.message }, 'Error no controlado');
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'Ocurrió un error inesperado. Intenta de nuevo.', details: null } });
};
