import argon2 from 'argon2';
import { z } from 'zod';
import { env } from '../config/env.js';
import { AppError } from '../middlewares/error-handler.js';

/** Política: mínimo 8 caracteres, con mayúscula, minúscula y número. */
export const passwordSchema = z
  .string({ error: 'Escribe una contraseña.' })
  .min(8, 'La contraseña debe tener al menos 8 caracteres.')
  .max(128, 'La contraseña no puede tener más de 128 caracteres.')
  .regex(/[A-ZÁÉÍÓÚÑ]/, 'La contraseña debe incluir al menos una mayúscula.')
  .regex(/[a-záéíóúñ]/, 'La contraseña debe incluir al menos una minúscula.')
  .regex(/\d/, 'La contraseña debe incluir al menos un número.');

/*
 * Memoria controlada. Revisar una contraseña con Argon2 usa memoria a propósito (para que no se puedan adivinar
 * por fuerza bruta). Para que muchos inicios de sesión al mismo tiempo no agoten la memoria del servidor:
 * - Parámetros mínimos recomendados por OWASP para Argon2id: 19 MiB, 2 pasadas, 1 hilo (antes 64 MiB y 3 pasadas).
 *   Las contraseñas guardadas con los parámetros anteriores siguen funcionando y se actualizan solas al entrar.
 * - Solo PASSWORD_HASH_CONCURRENCY revisiones a la vez (por omisión 2 → máximo ~38 MiB); las demás esperan en fila
 *   unos milisegundos. Si la fila pasa de PASSWORD_QUEUE_MAX o alguien espera más de 20 s, se le pide reintentar (503).
 */
export const HASH_OPTIONS = { type: argon2.argon2id, memoryCost: 19 * 1024, timeCost: 2, parallelism: 1 } as const;

const limit = Math.max(1, env.PASSWORD_HASH_CONCURRENCY);
let running = 0;
const queue: (() => void)[] = [];

async function withSlot<T>(work: () => Promise<T>): Promise<T> {
  if (running >= limit) {
    if (queue.length >= env.PASSWORD_QUEUE_MAX) throw busy();
    await new Promise<void>((resolve, reject) => {
      const timer = setTimeout(() => {
        const i = queue.indexOf(go);
        if (i >= 0) queue.splice(i, 1);
        reject(busy());
      }, 20_000);
      function go() {
        clearTimeout(timer);
        resolve();
      }
      queue.push(go);
    });
  } else running++;
  try {
    return await work();
  } finally {
    const next = queue.shift();
    if (next) next(); // el lugar pasa directo al siguiente de la fila
    else running--;
  }
}

const busy = () =>
  new AppError(503, 'SERVER_BUSY', 'Muchas personas están entrando en este momento. Espera unos segundos e inténtalo de nuevo.', { retryAfterSeconds: 5 });

export function hashPassword(password: string): Promise<string> {
  return withSlot(() => argon2.hash(password, HASH_OPTIONS));
}

export async function verifyPassword(hash: string, password: string): Promise<boolean> {
  return withSlot(async () => {
    try {
      return await argon2.verify(hash, password);
    } catch {
      return false;
    }
  });
}

/** La contraseña se guardó con parámetros anteriores (más memoria): conviene volver a guardarla al entrar. */
export function needsRehash(hash: string): boolean {
  try {
    return argon2.needsRehash(hash, HASH_OPTIONS);
  } catch {
    return false;
  }
}

/** Ocupación actual (para /health y pruebas). */
export const passwordQueue = () => ({ running, waiting: queue.length, limit });

/* Hash ficticio para tardar lo mismo cuando el correo no existe (evita adivinar cuentas por tiempo de respuesta). */
let dummyHash: Promise<string> | null = null;
export async function verifyAgainstDummy(password: string): Promise<void> {
  dummyHash ??= hashPassword('Ficticia-0000');
  await verifyPassword(await dummyHash, password);
}
