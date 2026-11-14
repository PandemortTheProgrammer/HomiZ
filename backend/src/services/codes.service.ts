import { randomInt } from 'node:crypto';
import type { Db } from '../config/database.js';

/**
 * Siguiente clave legible (ZUG-013, CIT-027...). Usa un candado de transacción para que dos altas
 * simultáneas no obtengan la misma clave: llamar dentro de withTransaction.
 */
export async function nextCode(db: Db, table: 'properties' | 'appointments' | 'sales', prefix: string): Promise<string> {
  await db.query('SELECT pg_advisory_xact_lock(hashtext($1))', [`code:${table}`]);
  const column = table === 'sales' ? 'folio' : 'code';
  const { rows } = await db.query<{ n: number | null }>(
    `SELECT max(substring(${column} FROM $1)::int) AS n FROM ${table} WHERE ${column} ~ $2`,
    [`^${prefix}-(\\d+)$`, `^${prefix}-\\d+$`],
  );
  return `${prefix}-${String((rows[0].n ?? 0) + 1).padStart(3, '0')}`;
}

/** Folio de solicitudes del sitio: Z-##### (único; se reintenta si ya existe). */
export async function nextFolio(db: Db): Promise<string> {
  for (let i = 0; i < 5; i++) {
    const folio = `Z-${randomInt(10000, 99999)}`;
    const { rowCount } = await db.query('SELECT 1 FROM leads WHERE folio = $1', [folio]);
    if (!rowCount) return folio;
  }
  return `Z-${Date.now().toString().slice(-7)}`;
}

/** "Casa del Patio" → "casa-del-patio" */
export function slugify(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 60);
}

/** slug único de propiedad a partir del nombre (con sufijo -2, -3… si ya existe). */
export async function uniqueSlug(db: Db, name: string, exceptId?: string): Promise<string> {
  const base = slugify(name) || 'propiedad';
  for (let i = 1; i < 100; i++) {
    const slug = i === 1 ? base : `${base}-${i}`;
    const { rowCount } = await db.query('SELECT 1 FROM properties WHERE slug = $1 AND id IS DISTINCT FROM $2', [slug, exceptId ?? null]);
    if (!rowCount) return slug;
  }
  return `${base}-${Date.now()}`;
}
