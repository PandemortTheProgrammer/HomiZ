import { createHmac, randomBytes } from 'node:crypto';
import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';

const ISSUER = 'homiz';
const AUDIENCE = 'homiz-api';

export interface AccessPayload {
  sub: string;
  type: 'client' | 'staff';
}

/** Access token JWT de vida corta (15 min por defecto). */
export function signAccessToken(payload: AccessPayload): string {
  return jwt.sign({ type: payload.type }, env.JWT_ACCESS_SECRET, {
    subject: payload.sub,
    issuer: ISSUER,
    audience: AUDIENCE,
    algorithm: 'HS256',
    expiresIn: env.JWT_ACCESS_TTL as jwt.SignOptions['expiresIn'],
  });
}

/** Devuelve el payload o null si el token es inválido o expiró. */
export function verifyAccessToken(token: string): AccessPayload | null {
  try {
    const decoded = jwt.verify(token, env.JWT_ACCESS_SECRET, { issuer: ISSUER, audience: AUDIENCE, algorithms: ['HS256'] });
    if (typeof decoded === 'string' || !decoded.sub) return null;
    const type = decoded.type === 'staff' ? 'staff' : decoded.type === 'client' ? 'client' : null;
    return type ? { sub: decoded.sub, type } : null;
  } catch {
    return null;
  }
}

/** Segundos de vida del access token (para responder expiresIn). */
export function accessTokenSeconds(): number {
  const m = /^(\d+)\s*([smhd])?$/.exec(env.JWT_ACCESS_TTL.trim());
  if (!m) return 900;
  const n = Number(m[1]);
  return n * ({ s: 1, m: 60, h: 3600, d: 86400 }[(m[2] ?? 's') as 's' | 'm' | 'h' | 'd']);
}

/** Token opaco aleatorio (refresh o recuperación). Al cliente se le da el token; en la base, su hash. */
export function createOpaqueToken(): { token: string; hash: string } {
  const token = randomBytes(48).toString('base64url');
  return { token, hash: hashOpaqueToken(token) };
}

export function hashOpaqueToken(token: string): string {
  return createHmac('sha256', env.JWT_REFRESH_SECRET).update(token).digest('hex');
}

export function refreshExpiry(): Date {
  return new Date(Date.now() + env.JWT_REFRESH_DAYS * 24 * 3600 * 1000);
}
