import type { RequestHandler } from 'express';
import { z } from 'zod';
import { AppError } from './error-handler.js';
import { logger } from '../config/logger.js';

interface Schemas {
  body?: z.ZodType;
  query?: z.ZodType;
  params?: z.ZodType;
}

/**
 * Valida y limpia body, query y params con zod (DTOs). Los valores validados quedan en res.locals.body,
 * res.locals.query y res.locals.params. Los errores se responden como VALIDATION_ERROR con el detalle
 * por campo: { campo: ["mensaje", ...] }.
 */
export function validate(schemas: Schemas): RequestHandler {
  return (req, res, next) => {
    const details: Record<string, string[]> = {};
    for (const part of ['params', 'query', 'body'] as const) {
      const schema = schemas[part];
      if (!schema) continue;
      const result = schema.safeParse(req[part] ?? {});
      if (result.success) {
        res.locals[part] = result.data;
      } else {
        for (const issue of result.error.issues) {
          const key = issue.path.length ? issue.path.join('.') : part;
          (details[key] ??= []).push(issue.message);
        }
      }
    }
    if (Object.keys(details).length) {
      // Quien no ve los campos marcados (una app vieja, un aviso suelto) igual sabe qué corregir: va el primer motivo
      const first = Object.values(details)[0][0];
      const technical = /^(Invalid|Expected|Required|Unrecognized|Too )/i.test(first);
      // Se registra la ruta y QUÉ campos fallaron (nunca los valores, que pueden ser datos personales)
      logger.warn({ path: req.originalUrl.split('?')[0], method: req.method, fields: Object.keys(details) }, 'Datos rechazados por validación');
      throw new AppError(400, 'VALIDATION_ERROR', technical ? 'Revisa los datos enviados.' : `Revisa los datos: ${first}`, details);
    }
    next();
  };
}

/* Piezas comunes para los DTOs. */
export const emailField = z.email({ error: 'Escribe un correo válido, por ejemplo nombre@correo.com.' }).max(160).transform((v) => v.trim().toLowerCase());
export const nameField = z.string({ error: 'Escribe tu nombre.' }).trim().min(2, 'Escribe tu nombre completo.').max(120);
export const phoneField = z
  .string()
  .trim()
  .refine((v) => v.replace(/\D/g, '').length >= 10, 'El teléfono debe tener al menos 10 dígitos.')
  .refine((v) => v.replace(/\D/g, '').length <= 15, 'El teléfono no puede tener más de 15 dígitos.')
  .max(30);
export const pagination = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});
export const idParam = z.object({ id: z.uuid({ error: 'El identificador no es válido.' }) });
export const money = z.coerce.number({ error: 'Escribe un monto válido.' }).nonnegative('El monto no puede ser negativo.').max(999_999_999.99);
export const positiveMoney = z.coerce.number({ error: 'Escribe un monto válido.' }).positive('El monto debe ser mayor a cero.').max(999_999_999.99);
export const dateField = z.iso.date({ error: 'Usa el formato AAAA-MM-DD.' });
export const dateTimeField = z.iso.datetime({ offset: true, error: 'Usa fecha y hora ISO, p. ej. 2026-10-24T10:00:00-05:00.' });
/** Arreglo en query: ?amenity=a&amenity=b o ?amenity=a */
export const queryArray = z.preprocess((v) => (v === undefined ? undefined : Array.isArray(v) ? v : [v]), z.array(z.string().max(60)).max(20).optional());

/** Respuesta paginada estándar. */
export function paged<T>(data: T[], total: number, q: { page: number; limit: number }) {
  return { data, pagination: { page: q.page, limit: q.limit, total, pages: Math.ceil(total / q.limit) } };
}
