import type { RequestHandler } from 'express';
import { z } from 'zod';
import { pool } from '../config/database.js';
import { insertActivity } from '../models/activity.model.js';
import { currentUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { pagination, paged } from '../middlewares/validate.js';

export const listQueryDto = pagination.extend({
  q: z.string().trim().max(80).optional(),
  specialty: z.string().trim().max(60).optional(),
  active: z.enum(['true', 'false']).transform((v) => v === 'true').default(true),
});
const fields = {
  name: z.string().trim().min(2, 'Escribe el nombre del proveedor.').max(120),
  specialty: z.string().trim().min(2, 'Escribe la especialidad (p. ej. Plomería).').max(60),
  phone: z.string().trim().max(30).nullable(),
  email: z.email({ error: 'Escribe un correo válido.' }).nullable(),
  zone: z.string().trim().max(120).nullable(),
  notes: z.string().trim().max(500).nullable(),
};
export const createDto = z.object({ ...fields, phone: fields.phone.optional(), email: fields.email.optional(), zone: fields.zone.optional(), notes: fields.notes.optional() });
export const updateDto = z
  .object({ ...Object.fromEntries(Object.entries(fields).map(([k, v]) => [k, v.optional()])), active: z.boolean().optional() })
  .refine((v) => Object.keys(v).length > 0, 'Indica qué cambiar.');

const present = (p: Record<string, unknown>) => ({ id: p.id, name: p.name, specialty: p.specialty, phone: p.phone, email: p.email, zone: p.zone, notes: p.notes, active: p.active });

export const list: RequestHandler = async (_req, res) => {
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const params: unknown[] = [q.active];
  let where = 'WHERE active = $1';
  if (q.q) where += ` AND (name ILIKE $${params.push(`%${q.q}%`)} OR specialty ILIKE $${params.length} OR zone ILIKE $${params.length})`;
  if (q.specialty) where += ` AND specialty ILIKE $${params.push(q.specialty)}`;
  const total = await pool.query<{ n: string }>(`SELECT count(*) AS n FROM providers ${where}`, params);
  const { rows } = await pool.query(`SELECT * FROM providers ${where} ORDER BY specialty, name LIMIT $${params.length + 1} OFFSET $${params.length + 2}`, [...params, q.limit, (q.page - 1) * q.limit]);
  res.json(paged(rows.map(present), Number(total.rows[0].n), q));
};

async function find(id: string) {
  const { rows } = await pool.query('SELECT * FROM providers WHERE id = $1', [id]);
  if (!rows[0]) throw new AppError(404, 'NOT_FOUND', 'El proveedor no existe.');
  return rows[0];
}

export const getOne: RequestHandler = async (_req, res) => {
  res.json(present(await find((res.locals.params as { id: string }).id)));
};

export const create: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = res.locals.body as z.infer<typeof createDto>;
  const { rows } = await pool.query(
    'INSERT INTO providers (name, specialty, phone, email, zone, notes) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
    [d.name, d.specialty, d.phone ?? null, d.email ?? null, d.zone ?? null, d.notes ?? null],
  );
  await insertActivity({ userId: user.id, entity: 'provider', entityId: rows[0].id, action: 'create', description: `${user.name} registró al proveedor ${d.name} (${d.specialty}).` });
  res.status(201).json(present(rows[0]));
};

export const update: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const before = await find(id);
  const d = res.locals.body as Record<string, unknown>;
  const cols = ['name', 'specialty', 'phone', 'email', 'zone', 'notes', 'active'].filter((k) => d[k] !== undefined);
  await pool.query(`UPDATE providers SET ${cols.map((c, i) => `${c} = $${i + 2}`).join(', ')} WHERE id = $1`, [id, ...cols.map((c) => d[c])]);
  await insertActivity({ userId: user.id, entity: 'provider', entityId: id, action: 'update', description: `${user.name} actualizó al proveedor ${before.name}.`, newValues: d });
  res.json(present(await find(id)));
};

/** Baja lógica: deja de aparecer en el directorio, pero se conserva en reportes y gastos anteriores. */
export const remove: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const p = await find(id);
  await pool.query('UPDATE providers SET active = FALSE WHERE id = $1', [id]);
  await insertActivity({ userId: user.id, entity: 'provider', entityId: id, action: 'delete', description: `${user.name} desactivó al proveedor ${p.name}.` });
  res.json({ message: 'El proveedor se desactivó.' });
};
