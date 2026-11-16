import type { RequestHandler } from 'express';
import { z } from 'zod';
import { pool } from '../config/database.js';
import { currentUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { dateField, money, pagination, paged, positiveMoney } from '../middlewares/validate.js';
import { assertPropertyAccess, propertyScope } from '../services/access.service.js';
import { createContract, finishContract } from '../services/contract.service.js';
import { attachContractPdf } from '../services/contract-docs.service.js';

export const listQueryDto = pagination.extend({
  propertyId: z.uuid().optional(),
  clientId: z.uuid().optional(),
  status: z.enum(['active', 'finished', 'cancelled']).optional(),
});
export const createDto = z
  .object({
    propertyId: z.uuid({ error: 'Elige la propiedad.' }),
    clientId: z.uuid({ error: 'Elige al cliente.' }),
    startDate: dateField,
    endDate: dateField,
    monthlyRent: positiveMoney,
    paymentDay: z.coerce.number().int().min(1, 'El día de pago va del 1 al 28.').max(28, 'El día de pago va del 1 al 28.'),
    deposit: money.nullable().optional(),
    documentId: z.uuid().nullable().optional(),
  })
  .refine((v) => v.endDate > v.startDate, { message: 'La fecha de fin debe ser posterior al inicio.', path: ['endDate'] });
export const finishDto = z.object({ endDate: dateField.optional(), reason: z.string().trim().max(300).optional() });

const SELECT = `
  SELECT ct.id, ct.property_id, p.code AS property_code, p.name AS property_name, ct.client_id, c.name AS client_name,
         to_char(ct.start_date, 'YYYY-MM-DD') AS start_date, to_char(ct.end_date, 'YYYY-MM-DD') AS end_date,
         ct.monthly_rent, ct.payment_day, ct.deposit, ct.status, ct.document_id, ct.created_at,
         (SELECT count(*)::int FROM promissory_notes n WHERE n.contract_id = ct.id AND n.status <> 'cancelled') AS notes_total,
         (SELECT count(*)::int FROM promissory_notes n WHERE n.contract_id = ct.id AND n.status = 'paid') AS notes_paid,
         (SELECT count(*)::int FROM promissory_notes n WHERE n.contract_id = ct.id AND n.status = 'overdue') AS notes_overdue,
         -- Sección «Rentas»: adeudo, próximo pago, reportes abiertos, broker y agua y luz
         (SELECT COALESCE(sum(n.amount), 0) FROM promissory_notes n WHERE n.contract_id = ct.id AND n.status = 'overdue') AS owed,
         (SELECT to_char(min(n.due_date), 'YYYY-MM-DD') FROM promissory_notes n WHERE n.contract_id = ct.id AND n.status IN ('pending', 'overdue')) AS next_due,
         (SELECT count(*)::int FROM maintenance_reports m WHERE m.property_id = ct.property_id AND m.status NOT IN ('resolved', 'cancelled')) AS open_reports,
         c.code AS client_code, c.phone AS client_phone, c.email AS client_email, p.broker_id, b.name AS broker_name,
         p.electricity_service_number, p.water_service_number, p.utility_reminder_day, p.maintenance_fee, p.maintenance_fee_day
    FROM contracts ct JOIN properties p ON p.id = ct.property_id JOIN clients c ON c.id = ct.client_id LEFT JOIN users b ON b.id = p.broker_id`;

type Row = Record<string, unknown> & { id: string; property_id: string };
const present = (r: Row) => ({
  id: r.id, property: { id: r.property_id, code: r.property_code, name: r.property_name },
  client: { id: r.client_id, code: r.client_code, name: r.client_name, phone: r.client_phone, email: r.client_email },
  broker: r.broker_id ? { id: r.broker_id, name: r.broker_name } : null,
  startDate: r.start_date, endDate: r.end_date, monthlyRent: Number(r.monthly_rent), paymentDay: r.payment_day, deposit: r.deposit == null ? null : Number(r.deposit),
  status: r.status, documentId: r.document_id,
  notes: { total: r.notes_total, paid: r.notes_paid, overdue: r.notes_overdue, owed: Number(r.owed), nextDue: r.next_due },
  openReports: r.open_reports,
  utilities: { electricity: r.electricity_service_number ?? null, water: r.water_service_number ?? null, reminderDay: r.utility_reminder_day ?? null },
  maintenanceFee: r.maintenance_fee == null ? null : { amount: Number(r.maintenance_fee), day: r.maintenance_fee_day },
  createdAt: r.created_at,
});

export const list: RequestHandler = async (_req, res) => {
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const scope = await propertyScope(currentUser(res));
  const params: unknown[] = [];
  const where: string[] = [];
  if (scope) where.push(`ct.property_id = ANY($${params.push(scope)}::uuid[])`);
  if (q.propertyId) where.push(`ct.property_id = $${params.push(q.propertyId)}`);
  if (q.clientId) where.push(`ct.client_id = $${params.push(q.clientId)}`);
  if (q.status) where.push(`ct.status = $${params.push(q.status)}`);
  const w = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const total = await pool.query<{ n: string }>(`SELECT count(*) AS n FROM contracts ct ${w}`, params);
  const { rows } = await pool.query<Row>(`${SELECT} ${w} ORDER BY ct.start_date DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`, [...params, q.limit, (q.page - 1) * q.limit]);
  res.json(paged(rows.map(present), Number(total.rows[0].n), q));
};

async function findOne(id: string): Promise<Row> {
  const { rows } = await pool.query<Row>(`${SELECT} WHERE ct.id = $1`, [id]);
  if (!rows[0]) throw new AppError(404, 'NOT_FOUND', 'El contrato no existe.');
  return rows[0];
}

export const getOne: RequestHandler = async (_req, res) => {
  const row = await findOne((res.locals.params as { id: string }).id);
  await assertPropertyAccess(currentUser(res), row.property_id);
  res.json(present(row));
};

export const create: RequestHandler = async (_req, res) => {
  const id = await createContract(currentUser(res), res.locals.body as z.infer<typeof createDto>);
  res.status(201).json(present(await findOne(id)));
};

/** PDF ya subido con POST /documents/upload-url (propósito «document») */
export const pdfDto = z.object({ storageKey: z.string().trim().min(10).max(200) });

/** POST /contracts/:id/document — contrato firmado en PDF */
export const attachDocument: RequestHandler = async (_req, res) => {
  const { id } = res.locals.params as { id: string };
  const documentId = await attachContractPdf(currentUser(res), id, (res.locals.body as z.infer<typeof pdfDto>).storageKey);
  res.status(201).json({ documentId, contract: present(await findOne(id)) });
};

export const finish: RequestHandler = async (_req, res) => {
  const { id } = res.locals.params as { id: string };
  await finishContract(currentUser(res), id, res.locals.body as z.infer<typeof finishDto>);
  res.json(present(await findOne(id)));
};
