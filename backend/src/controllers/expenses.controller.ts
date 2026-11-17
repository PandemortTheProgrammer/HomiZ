import type { RequestHandler } from 'express';
import { z } from 'zod';
import { pool } from '../config/database.js';
import { insertActivity } from '../models/activity.model.js';
import { currentUser, type AuthUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { dateField, money, pagination, paged } from '../middlewares/validate.js';
import { assertPropertyAccess, propertyScope } from '../services/access.service.js';

export const listQueryDto = pagination.extend({
  propertyId: z.uuid().optional(),
  providerId: z.uuid().optional(),
  status: z.enum(['pending', 'paid']).optional(),
  from: dateField.optional(),
  to: dateField.optional(),
});
const fields = {
  propertyId: z.uuid({ error: 'Indica la propiedad.' }),
  providerId: z.uuid().nullable(),
  reportId: z.uuid().nullable(),
  concept: z.string().trim().min(2, 'Escribe el concepto.').max(120),
  amount: money,
  date: dateField,
  status: z.enum(['pending', 'paid']),
  nextMaintenanceDate: dateField.nullable(),
  notes: z.string().trim().max(500).nullable(),
};
export const createDto = z.object({
  ...fields,
  providerId: fields.providerId.optional(), reportId: fields.reportId.optional(), status: fields.status.default('pending'),
  nextMaintenanceDate: fields.nextMaintenanceDate.optional(), notes: fields.notes.optional(),
});
export const updateDto = z
  .object(Object.fromEntries(Object.entries(fields).filter(([k]) => k !== 'propertyId').map(([k, v]) => [k, v.optional()])))
  .refine((v) => Object.keys(v).length > 0, 'Indica qué cambiar.');

const SELECT = `
  SELECT e.id, e.property_id, p.name AS property_name, e.provider_id, pv.name AS provider_name, e.report_id, r.title AS report_title,
         e.concept, e.amount, to_char(e.date, 'YYYY-MM-DD') AS date, e.status,
         to_char(e.next_maintenance_date, 'YYYY-MM-DD') AS next_maintenance_date, e.notes, e.created_at
    FROM expenses e JOIN properties p ON p.id = e.property_id
    LEFT JOIN providers pv ON pv.id = e.provider_id LEFT JOIN maintenance_reports r ON r.id = e.report_id`;

const present = (e: Record<string, unknown>) => ({
  id: e.id, property: { id: e.property_id, name: e.property_name }, provider: e.provider_id ? { id: e.provider_id, name: e.provider_name } : null,
  report: e.report_id ? { id: e.report_id, title: e.report_title } : null, concept: e.concept, amount: e.amount, date: e.date,
  status: e.status, nextMaintenanceDate: e.next_maintenance_date, notes: e.notes, createdAt: e.created_at,
});

async function load(user: AuthUser, id: string) {
  const { rows } = await pool.query(`${SELECT} WHERE e.id = $1`, [id]);
  if (!rows[0]) throw new AppError(404, 'NOT_FOUND', 'El gasto no existe.');
  await assertPropertyAccess(user, rows[0].property_id);
  return rows[0];
}

async function checkLinks(propertyId: string, d: { reportId?: string | null }) {
  if (d.reportId) {
    const r = await pool.query('SELECT 1 FROM maintenance_reports WHERE id = $1 AND property_id = $2', [d.reportId, propertyId]);
    if (!r.rowCount) throw new AppError(400, 'VALIDATION_ERROR', 'El reporte no pertenece a esta propiedad.');
  }
}

/** Listado con totales (total, pagado y pendiente) del mismo filtro. */
export const list: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const scope = await propertyScope(user);
  const params: unknown[] = [];
  const where: string[] = [];
  if (scope) where.push(`e.property_id = ANY($${params.push(scope)}::uuid[])`);
  if (q.propertyId) where.push(`e.property_id = $${params.push(q.propertyId)}`);
  if (q.providerId) where.push(`e.provider_id = $${params.push(q.providerId)}`);
  if (q.status) where.push(`e.status = $${params.push(q.status)}`);
  if (q.from) where.push(`e.date >= $${params.push(q.from)}::date`);
  if (q.to) where.push(`e.date <= $${params.push(q.to)}::date`);
  const w = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const totals = await pool.query<{ n: string; total: number | null; paid: number | null; pending: number | null }>(
    `SELECT count(*) AS n, sum(amount) AS total, sum(amount) FILTER (WHERE status = 'paid') AS paid, sum(amount) FILTER (WHERE status = 'pending') AS pending
       FROM expenses e ${w}`,
    params,
  );
  const { rows } = await pool.query(`${SELECT} ${w} ORDER BY e.date DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`, [...params, q.limit, (q.page - 1) * q.limit]);
  const t = totals.rows[0];
  res.json({ ...paged(rows.map(present), Number(t.n), q), totals: { total: t.total ?? 0, paid: t.paid ?? 0, pending: t.pending ?? 0 } });
};

export const getOne: RequestHandler = async (_req, res) => {
  res.json(present(await load(currentUser(res), (res.locals.params as { id: string }).id)));
};

export const create: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = res.locals.body as z.infer<typeof createDto>;
  await assertPropertyAccess(user, d.propertyId);
  await checkLinks(d.propertyId, d);
  const { rows } = await pool.query<{ id: string }>(
    `INSERT INTO expenses (property_id, provider_id, report_id, concept, amount, date, status, next_maintenance_date, notes)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
    [d.propertyId, d.providerId ?? null, d.reportId ?? null, d.concept, d.amount, d.date, d.status, d.nextMaintenanceDate ?? null, d.notes ?? null],
  );
  await insertActivity({ userId: user.id, propertyId: d.propertyId, entity: 'expense', entityId: rows[0].id, action: 'create', description: `${user.name} registró el gasto «${d.concept}» por $${d.amount.toLocaleString('en-US')}.` });
  res.status(201).json(present(await load(user, rows[0].id)));
};

export const update: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const before = await load(user, id);
  const d = res.locals.body as Record<string, unknown>;
  await checkLinks(before.property_id, d as { reportId?: string | null });
  const map: Record<string, string> = { providerId: 'provider_id', reportId: 'report_id', concept: 'concept', amount: 'amount', date: 'date', status: 'status', nextMaintenanceDate: 'next_maintenance_date', notes: 'notes' };
  const keys = Object.keys(map).filter((k) => d[k] !== undefined);
  await pool.query(`UPDATE expenses SET ${keys.map((k, i) => `${map[k]} = $${i + 2}`).join(', ')} WHERE id = $1`, [id, ...keys.map((k) => d[k])]);
  await insertActivity({ userId: user.id, propertyId: before.property_id, entity: 'expense', entityId: id, action: 'update', description: `${user.name} actualizó el gasto «${before.concept}».`, newValues: d });
  res.json(present(await load(user, id)));
};
