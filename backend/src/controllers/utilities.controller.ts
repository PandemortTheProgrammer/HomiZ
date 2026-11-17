import type { RequestHandler } from 'express';
import { z } from 'zod';
import { pool } from '../config/database.js';
import { insertActivity } from '../models/activity.model.js';
import { currentUser, type AuthUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { dateField, dateTimeField, money, pagination, paged, queryArray } from '../middlewares/validate.js';
import { assertPropertyAccess, propertyScope } from '../services/access.service.js';
import { clientReceiptFilter } from '../models/property-access.model.js';
import { notify, tenantUserOf } from '../services/notification.service.js';

/* ---------- Servicios (cuentas de CFE / Aguakan) ---------- */
export const serviceQueryDto = z.object({ propertyId: z.uuid({ error: 'Indica la propiedad.' }) });
export const serviceCreateDto = z.object({
  propertyId: z.uuid(),
  type: z.enum(['electricity', 'water'], { error: 'El servicio debe ser luz (electricity) o agua (water).' }),
  providerName: z.string().trim().min(2).max(60).default('CFE'),
  accountNumber: z.string().trim().min(4, 'Escribe el número de cuenta o servicio.').max(40),
});
export const serviceUpdateDto = z
  .object({ providerName: z.string().trim().min(2).max(60).optional(), accountNumber: z.string().trim().min(4).max(40).optional(), active: z.boolean().optional() })
  .refine((v) => Object.keys(v).length > 0, 'Indica qué cambiar.');

const presentService = (s: Record<string, unknown>) => ({ id: s.id, propertyId: s.property_id, type: s.type, providerName: s.provider_name, accountNumber: s.account_number, active: s.active });

export const listServices: RequestHandler = async (_req, res) => {
  const { propertyId } = res.locals.query as z.infer<typeof serviceQueryDto>;
  await assertPropertyAccess(currentUser(res), propertyId);
  const { rows } = await pool.query('SELECT * FROM utility_services WHERE property_id = $1 ORDER BY type', [propertyId]);
  res.json({ data: rows.map(presentService) });
};

export const createService: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = res.locals.body as z.infer<typeof serviceCreateDto>;
  await assertPropertyAccess(user, d.propertyId);
  const { rows } = await pool.query(
    'INSERT INTO utility_services (property_id, type, provider_name, account_number) VALUES ($1, $2, $3, $4) RETURNING *',
    [d.propertyId, d.type, d.providerName, d.accountNumber],
  );
  await insertActivity({ userId: user.id, propertyId: d.propertyId, entity: 'utility_service', entityId: rows[0].id, action: 'create', description: `${user.name} registró la cuenta de ${d.type === 'water' ? 'agua' : 'luz'} ${d.accountNumber}.` });
  res.status(201).json(presentService(rows[0]));
};

export const updateService: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const found = await pool.query('SELECT * FROM utility_services WHERE id = $1', [id]);
  if (!found.rows[0]) throw new AppError(404, 'NOT_FOUND', 'El servicio no existe.');
  await assertPropertyAccess(user, found.rows[0].property_id);
  const d = res.locals.body as z.infer<typeof serviceUpdateDto>;
  const { rows } = await pool.query(
    `UPDATE utility_services SET provider_name = COALESCE($2, provider_name), account_number = COALESCE($3, account_number), active = COALESCE($4, active) WHERE id = $1 RETURNING *`,
    [id, d.providerName ?? null, d.accountNumber ?? null, d.active ?? null],
  );
  res.json(presentService(rows[0]));
};

/* ---------- Recibos y fichas de cobro ---------- */
export const receiptQueryDto = pagination.extend({
  propertyId: z.uuid().optional(),
  status: queryArray,
  kind: z.enum(['bill', 'charge_slip']).optional(),
  type: z.enum(['electricity', 'water']).optional(),
  /** App: además de agua y luz, los recibos de los pagarés pagados y las fichas de cobro de lo que toca pagar */
  pagares: z.enum(['1']).optional(),
});
export const receiptCreateDto = z.object({
  propertyId: z.uuid(),
  utilityServiceId: z.uuid().nullable().optional(),
  kind: z.enum(['bill', 'charge_slip']).default('bill'),
  concept: z.string().trim().min(2, 'Escribe el concepto (p. ej. Recibo de luz).').max(80),
  periodStart: dateField.nullable().optional(),
  periodEnd: dateField.nullable().optional(),
  amount: money,
  dueDate: dateField.nullable().optional(),
  documentId: z.uuid().nullable().optional(),
});
export const receiptUpdateDto = z
  .object({
    amount: money.optional(),
    dueDate: dateField.nullable().optional(),
    status: z.enum(['pending', 'paid', 'overdue']).optional(),
    paidAt: dateTimeField.nullable().optional(),
    documentId: z.uuid().nullable().optional(),
  })
  .refine((v) => Object.keys(v).length > 0, 'Indica qué cambiar.');

const SELECT = `
  SELECT r.id, r.property_id, p.name AS property_name, r.kind, r.concept, to_char(r.period_start, 'YYYY-MM-DD') AS period_start,
         to_char(r.period_end, 'YYYY-MM-DD') AS period_end, r.amount, to_char(r.due_date, 'YYYY-MM-DD') AS due_date, r.paid_at,
         r.status, r.document_id, s.type AS utility_type, s.provider_name, s.account_number
    FROM receipts r JOIN properties p ON p.id = r.property_id LEFT JOIN utility_services s ON s.id = r.utility_service_id`;

const MONTHS = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
function periodLabel(start: string | null, end: string | null): string | null {
  if (!start || !end) return null;
  const a = MONTHS[Number(start.slice(5, 7)) - 1], b = MONTHS[Number(end.slice(5, 7)) - 1];
  return a === b ? a : `${a}-${b}`;
}

const presentReceipt = (r: Record<string, unknown>) => ({
  id: r.id, property: { id: r.property_id, name: r.property_name }, kind: r.kind, concept: r.concept,
  utility: r.utility_type ? { type: r.utility_type, provider: r.provider_name, accountNumber: r.account_number } : null,
  periodStart: r.period_start, periodEnd: r.period_end, periodLabel: periodLabel(r.period_start as string | null, r.period_end as string | null),
  amount: r.amount, dueDate: r.due_date, paidAt: r.paid_at, status: r.status, documentId: r.document_id,
});

async function loadReceipt(user: AuthUser, id: string) {
  const { rows } = await pool.query(`${SELECT} WHERE r.id = $1`, [id]);
  if (!rows[0]) throw new AppError(404, 'NOT_FOUND', 'El recibo no existe.');
  await assertPropertyAccess(user, rows[0].property_id);
  if (user.type === 'client') {
    const own = await pool.query(`SELECT 1 FROM receipts r WHERE r.id = $1 AND ${clientReceiptFilter('$2')}`, [id, user.clientId]);
    if (!own.rowCount) throw new AppError(404, 'NOT_FOUND', 'El recibo no existe.');
  }
  return rows[0];
}

export const listReceipts: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const q = res.locals.query as z.infer<typeof receiptQueryDto>;
  const scope = await propertyScope(user);
  const params: unknown[] = [];
  const where: string[] = [];
  if (scope) where.push(`r.property_id = ANY($${params.push(scope)}::uuid[])`);
  // El cliente solo ve los recibos de su contrato (no los del inquilino anterior)
  if (user.type === 'client') where.push(clientReceiptFilter(`$${params.push(user.clientId)}`));
  if (q.propertyId) where.push(`r.property_id = $${params.push(q.propertyId)}`);
  if (q.status?.length) where.push(`r.status::text = ANY($${params.push(q.status)}::text[])`);
  if (q.kind) where.push(`r.kind = $${params.push(q.kind)}`);
  if (q.type) where.push(`s.type = $${params.push(q.type)}`);
  const w = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const total = await pool.query<{ n: string }>(`SELECT count(*) AS n FROM receipts r LEFT JOIN utility_services s ON s.id = r.utility_service_id ${w}`, params);
  const { rows } = await pool.query(
    `${SELECT} ${w} ORDER BY (r.status <> 'paid') DESC, r.due_date DESC NULLS LAST LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, q.limit, (q.page - 1) * q.limit],
  );
  const notes = q.pagares ? await noteReceipts(user, scope, q.propertyId) : [];
  res.json(paged([...notes, ...rows.map(presentReceipt)], Number(total.rows[0].n) + notes.length, q));
};

/** Pagarés como recibos (pagados) y fichas de cobro (vencidos y el siguiente por pagar). */
async function noteReceipts(user: AuthUser, scope: string[] | null, propertyId?: string) {
  const params: unknown[] = [];
  const where = ["n.status <> 'cancelled'", "ct.status = 'active'"];
  if (user.type === 'client') where.push(`ct.client_id = $${params.push(user.clientId)}`);
  else if (scope) where.push(`ct.property_id = ANY($${params.push(scope)}::uuid[])`);
  if (propertyId) where.push(`ct.property_id = $${params.push(propertyId)}`);
  const { rows } = await pool.query<{ id: string; property_id: string; property_name: string; number: number; amount: string; due_date: string; paid_at: Date | null; status: string; document_id: string | null; next: boolean }>(
    `SELECT n.id, p.id AS property_id, p.name AS property_name, n.number, n.amount, to_char(n.due_date, 'YYYY-MM-DD') AS due_date, n.paid_at, n.status::text AS status,
            (SELECT d.id FROM documents d WHERE d.promissory_note_id = n.id AND d.type = 'receipt' AND d.visible_to_client ORDER BY d.created_at DESC LIMIT 1) AS document_id,
            n.status = 'pending' AND n.due_date = (SELECT min(x.due_date) FROM promissory_notes x WHERE x.contract_id = n.contract_id AND x.status = 'pending') AS next
       FROM promissory_notes n JOIN contracts ct ON ct.id = n.contract_id JOIN properties p ON p.id = ct.property_id
      WHERE ${where.join(' AND ')} ORDER BY (n.status = 'paid'), n.due_date DESC`,
    params,
  );
  return rows.filter((n) => n.status !== 'pending' || n.next).map((n) => {
    const paid = n.status === 'paid';
    return {
      id: n.id, property: { id: n.property_id, name: n.property_name }, kind: paid ? 'bill' : 'charge_slip',
      concept: `${paid ? 'Recibo' : 'Ficha de cobro'} · Pagaré ${String(n.number).padStart(2, '0')}`, utility: null, periodStart: null, periodEnd: null, periodLabel: null,
      amount: Number(n.amount), dueDate: n.due_date, paidAt: n.paid_at, status: n.status, documentId: n.document_id,
    };
  });
}

export const getReceipt: RequestHandler = async (_req, res) => {
  res.json(presentReceipt(await loadReceipt(currentUser(res), (res.locals.params as { id: string }).id)));
};

export const createReceipt: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = res.locals.body as z.infer<typeof receiptCreateDto>;
  await assertPropertyAccess(user, d.propertyId);
  if (d.utilityServiceId) {
    const s = await pool.query('SELECT 1 FROM utility_services WHERE id = $1 AND property_id = $2', [d.utilityServiceId, d.propertyId]);
    if (!s.rowCount) throw new AppError(400, 'VALIDATION_ERROR', 'El servicio no pertenece a esta propiedad.');
  }
  const status = d.dueDate && d.dueDate < new Date().toISOString().slice(0, 10) ? 'overdue' : 'pending';
  const { rows } = await pool.query<{ id: string }>(
    `INSERT INTO receipts (utility_service_id, property_id, kind, concept, period_start, period_end, amount, due_date, status, document_id)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id`,
    [d.utilityServiceId ?? null, d.propertyId, d.kind, d.concept, d.periodStart ?? null, d.periodEnd ?? null, d.amount, d.dueDate ?? null, status, d.documentId ?? null],
  );
  await insertActivity({ userId: user.id, propertyId: d.propertyId, entity: 'receipt', entityId: rows[0].id, action: 'create', description: `${user.name} registró ${d.concept} por $${d.amount.toLocaleString('en-US')}.` });
  await notify([await tenantUserOf(d.propertyId)], {
    type: 'receipt_created', title: d.concept, message: `Tienes un nuevo ${d.concept.toLowerCase()} por $${d.amount.toLocaleString('en-US')}${d.dueDate ? `, vence el ${d.dueDate.split('-').reverse().join('/')}` : ''}.`,
    entity: 'receipt', entityId: rows[0].id,
  });
  res.status(201).json(presentReceipt(await loadReceipt(user, rows[0].id)));
};

export const updateReceipt: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const before = await loadReceipt(user, id);
  const d = res.locals.body as z.infer<typeof receiptUpdateDto>;
  const paidAt = d.status === 'paid' ? d.paidAt ?? new Date().toISOString() : d.status ? null : undefined;
  await pool.query(
    `UPDATE receipts SET amount = COALESCE($2, amount),
            due_date = CASE WHEN $3::boolean THEN $4::date ELSE due_date END,
            status = COALESCE($5::receipt_status, status),
            paid_at = CASE WHEN $6::boolean THEN $7::timestamptz ELSE paid_at END,
            document_id = CASE WHEN $8::boolean THEN $9::uuid ELSE document_id END
      WHERE id = $1`,
    [id, d.amount ?? null, d.dueDate !== undefined, d.dueDate ?? null, d.status ?? null, paidAt !== undefined, paidAt ?? null, d.documentId !== undefined, d.documentId ?? null],
  );
  await insertActivity({ userId: user.id, propertyId: before.property_id, entity: 'receipt', entityId: id, action: 'update', description: `${user.name} actualizó ${before.concept}.`, oldValues: { status: before.status, amount: before.amount }, newValues: d });
  res.json(presentReceipt(await loadReceipt(user, id)));
};
