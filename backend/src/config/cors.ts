import { env } from './env.js';

/** Origen permitido: igual a uno de CORS_ORIGINS o a un patrón con «*» (p. ej. https://*.trycloudflare.com). */
export function corsAllowed(origin: string, allowed: string[] = env.corsOrigins): boolean {
  return allowed.some((o) =>
    o.includes('*')
      ? new RegExp('^' + o.split('*').map((s) => s.replace(/[.+?^${}()|[\]\\/]/g, '\\$&')).join('[a-z0-9-]+') + '$', 'i').test(origin)
      : o === origin,
  );
}

/**
 * Conexión de un navegador permitida: sin encabezado Origin (app del teléfono), un origen de CORS_ORIGINS
 * o el mismo sitio que la sirve (sitio, panel y app web publicados detrás del mismo dominio).
 */
export function originAllowed(origin: string | undefined, host: string | undefined): boolean {
  if (!origin) return true;
  if (corsAllowed(origin)) return true;
  try {
    return !!host && new URL(origin).host === host;
  } catch {
    return false;
  }
}
