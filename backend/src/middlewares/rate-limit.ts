import type { Request } from 'express';
import rateLimit, { ipKeyGenerator } from 'express-rate-limit';
import { env } from '../config/env.js';
import { verifyAccessToken } from '../services/token.service.js';

/** Mensaje claro: qué pasó, por qué y cuánto esperar (no solo «demasiadas solicitudes»). */
const message = (text: string) => (_req: Request, res: { getHeader?: (n: string) => unknown }) => {
  const retry = Number(res.getHeader?.('Retry-After')) || 0;
  const wait = retry ? ` Vuelve a intentarlo en ${Math.max(1, Math.ceil(retry / 60))} minuto${retry > 60 ? 's' : ''}.` : ' Vuelve a intentarlo en unos minutos.';
  return { error: { code: 'RATE_LIMITED', message: text + wait, details: null } };
};

/** Quién hace la petición: la persona con sesión (por su cuenta) o, sin sesión, la conexión (IP). */
function who(req: Request): { key: string; signedIn: boolean } {
  const header = req.header('authorization') ?? '';
  const payload = header.startsWith('Bearer ') ? verifyAccessToken(header.slice(7).trim()) : null;
  return payload ? { key: `u:${payload.sub}`, signedIn: true } : { key: `ip:${ipKeyGenerator(req.ip ?? '')}`, signedIn: false };
}

/**
 * Límite general. Con sesión se cuenta por persona (la app recarga varias pantallas con cada aviso en tiempo real,
 * y una familia u oficina comparte la misma IP): 3,000 cada 15 min. Sin sesión, por IP: RATE_LIMIT_MAX (600).
 * No cuentan el canal en vivo, la salud del servidor ni las fotos con enlace firmado.
 */
export const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: (req) => (who(req).signedIn ? 3000 : env.RATE_LIMIT_MAX),
  keyGenerator: (req) => who(req).key,
  skip: (req) => /^\/api\/v1\/(events|health|ws)/.test(req.path) || (req.method === 'GET' && req.path.startsWith('/api/v1/files/')),
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  message: message('Se hicieron demasiadas solicitudes seguidas desde tu cuenta o conexión (protección contra abusos).'),
});

/**
 * Inicio de sesión, recuperación de contraseña, registro, formularios del sitio y eliminar cuenta: estricto, pero
 * por correo y conexión (así una persona que se equivoca no bloquea a las demás de la misma oficina).
 */
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: env.RATE_LIMIT_LOGIN_MAX,
  keyGenerator: (req) => `${ipKeyGenerator(req.ip ?? '')}:${String((req.body as { email?: unknown } | undefined)?.email ?? '').trim().toLowerCase()}`,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  message: message('Hubo muchos intentos seguidos con este correo desde esta conexión (protección de tu cuenta).'),
});
