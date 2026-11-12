import { randomUUID } from 'node:crypto';
import type { RequestHandler } from 'express';

/* Cada petición lleva un id para rastrearla en los logs (se devuelve en X-Request-Id). */
export const requestId: RequestHandler = (req, res, next) => {
  const incoming = req.header('x-request-id');
  const id = incoming && /^[\w-]{8,64}$/.test(incoming) ? incoming : randomUUID();
  res.locals.requestId = id;
  res.setHeader('X-Request-Id', id);
  next();
};
