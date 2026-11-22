import type { RequestHandler } from 'express';
import { z } from 'zod';
import { pool } from '../config/database.js';
import { createDownloadUrl, putObject } from '../config/storage.js';
import { currentUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { dateField, pagination, paged, positiveMoney } from '../middlewares/validate.js';
import { propertyScope } from '../services/access.service.js';
import { attachSalePdf, createSale, noticeThreshold, NOTICE_UMA, saleReceiptPdf, UMA_DAILY, voidSale } from '../services/sale.service.js';

export const listQueryDto = pagination.extend({
  propertyId: z.uuid().optional(),
  clientId: z.uuid().optional(),
  status: z.enum(['closed', 'voided']).optional(),
});
const optionalText = (max: number) => z.string().trim().max(max, `Máximo ${max} caracteres.`).nullable().optional();
export const createDto = z.object({
  propertyId: z.uuid({ error: 'Elige la casa que se vendió.' }),
  clientId: z.uuid({ error: 'Elige al comprador.' }),
  saleDate: dateField,
  price: positiveMoney,
  paymentMethod: optionalText(80),
  notary: optionalText(120),
  identityChecked: z.boolean().default(false),
  notes: optionalText(500),
});
export const voidDto = z.object({ reason: z.string().trim().min(3, 'Escribe el motivo (mínimo 3 letras).').max(300) });
export const pdfDto = z.object({ storageKey: z.string().trim().min(10).max(200) });

const SELECT = `
  SELECT s.id, s.folio, s.status, to_char(s.sale_date, 'YYYY-MM-DD') AS sale_date, s.price, s.payment_method, s.notary,
         s.identity_checked, s.notes, s.document_id, s.void_reason, s.created_at, s.voided_at,
         s.property_id, p.code AS property_code, p.name AS property_name, p.address AS property_address, p.zone AS property_zone,
         s.client_id, c.code AS client_code, c.name AS client_name, c.phone AS client_phone, c.email AS client_email,
         p.broker_id, b.name AS broker_name, u.name AS created_by_name
    FROM sales s JOIN properties p ON p.id = s.property_id JOIN clients c ON c.id = s.client_id
    LEFT JOIN users b ON b.id = p.broker_id LEFT JOIN users u ON u.id = s.created_by`;

type Row = Record<string, unknown> & { id: string; property_id: string; client_id: string; status: string; price: string };

const present = (r: Row, staff: boolean) => {
  const price = Number(r.price);
  const base = {
    id: r.id, folio: r.folio, status: r.status, saleDate: r.sale_date, price,
    paymentMethod: r.payment_method ?? null, notary: r.notary ?? null, hasDocument: Boolean(r.document_id),
    property: { id: r.property_id, code: r.property_code, name: r.property_name, address: r.property_address ?? null, zone: r.property_zone ?? null },
    voidReason: r.void_reason ?? null, createdAt: r.created_at,
  };
  if (!staff) return base;
  return {
    ...base,
    client: { id: r.client_id, code: r.client_code, name: r.client_name, phone: r.client_phone, email: r.client_email },
    broker: r.broker_id ? { id: r.broker_id, name: r.broker_name } : null,
    identityChecked: r.identity_checked, notes: r.notes ?? null, documentId: r.document_id ?? null,
    createdBy: r.created_by_name ?? null, voidedAt: r.voided_at ?? null,
    // Ley Antilavado: arriba del umbral se presenta aviso al SAT (a más tardar el día 17 del mes siguiente)
    antiMoneyLaundering: { threshold: noticeThreshold(), uma: UMA_DAILY, umaCount: NOTICE_UMA, requiresNotice: price >= noticeThreshold() },
  };
};

/** GET /sales — personal: las de sus casas (administración, todas); cliente: solo sus compras. */
export const list: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const params: unknown[] = [];
  const where: string[] = [];
  if (user.type === 'client') where.push(`s.client_id = $${params.push(user.clientId ?? null)}`);
  else {
    const scope = await propertyScope(user);
    if (scope) where.push(`s.property_id = ANY($${params.push(scope)}::uuid[])`);
    if (q.clientId) where.push(`s.client_id = $${params.push(q.clientId)}`);
  }
  if (q.propertyId) where.push(`s.property_id = $${params.push(q.propertyId)}`);
  if (q.status) where.push(`s.status = $${params.push(q.status)}`);
  const w = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const total = await pool.query<{ n: string }>(`SELECT count(*) AS n FROM sales s ${w}`, params);
  const { rows } = await pool.query<Row>(`${SELECT} ${w} ORDER BY s.sale_date DESC, s.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`, [...params, q.limit, (q.page - 1) * q.limit]);
  res.json(paged(rows.map((r) => present(r, user.type === 'staff')), Number(total.rows[0].n), q));
};

/** La venta, si quien la pide puede verla: el comprador, o el personal de esa casa. */
async function visibleSale(res: Parameters<RequestHandler>[1], id: string): Promise<Row> {
  const user = currentUser(res);
  const { rows } = await pool.query<Row>(`${SELECT} WHERE s.id = $1`, [id]);
  const row = rows[0];
  if (!row) throw new AppError(404, 'NOT_FOUND', 'La venta no existe.');
  if (user.type === 'client') {
    if (row.client_id !== user.clientId) throw new AppError(404, 'NOT_FOUND', 'La venta no existe.');
  } else {
    const scope = await propertyScope(user);
    if (scope && !scope.includes(row.property_id)) throw new AppError(403, 'NOT_OWNER', 'No tienes acceso a esta venta.');
  }
  return row;
}

export const getOne: RequestHandler = async (_req, res) => {
  const row = await visibleSale(res, (res.locals.params as { id: string }).id);
  res.json(present(row, currentUser(res).type === 'staff'));
};

export const create: RequestHandler = async (_req, res) => {
  const id = await createSale(currentUser(res), res.locals.body as z.infer<typeof createDto>);
  res.status(201).json(present(await visibleSale(res, id), true));
};

export const voidOne: RequestHandler = async (_req, res) => {
  const { id } = res.locals.params as { id: string };
  await voidSale(currentUser(res), id, (res.locals.body as z.infer<typeof voidDto>).reason);
  res.json(present(await visibleSale(res, id), true));
};

export const attachDocument: RequestHandler = async (_req, res) => {
  const { id } = res.locals.params as { id: string };
  const documentId = await attachSalePdf(currentUser(res), id, (res.locals.body as z.infer<typeof pdfDto>).storageKey);
  res.status(201).json({ documentId, sale: present(await visibleSale(res, id), true) });
};

/** GET /sales/:id/receipt-url — comprobante en PDF (se genera al momento con los datos vigentes). */
export const receiptUrl: RequestHandler = async (_req, res) => {
  const r = await visibleSale(res, (res.locals.params as { id: string }).id);
  const pdf = await saleReceiptPdf({
    folio: String(r.folio), status: r.status, saleDate: String(r.sale_date), price: Number(r.price),
    paymentMethod: (r.payment_method as string | null) ?? null, notary: (r.notary as string | null) ?? null,
    property: { code: String(r.property_code), name: String(r.property_name), address: (r.property_address as string | null) ?? null },
    client: { code: (r.client_code as string | null) ?? null, name: String(r.client_name) },
    voidReason: (r.void_reason as string | null) ?? null, issuedAt: new Date(),
  });
  const key = `properties/${r.property_code}/documents/${r.id}.pdf`;
  await putObject(key, 'application/pdf', pdf);
  res.json(await createDownloadUrl(key, 'application/pdf', `Comprobante ${r.folio}.pdf`));
};

/** GET /sales/:id/document-url — contrato firmado (si se subió). */
export const documentUrl: RequestHandler = async (_req, res) => {
  const r = await visibleSale(res, (res.locals.params as { id: string }).id);
  if (!r.document_id) throw new AppError(404, 'NOT_FOUND', 'Esta venta no tiene contrato en PDF.');
  const { rows: [d] } = await pool.query<{ storage_key: string; mime: string }>('SELECT storage_key, mime FROM documents WHERE id = $1', [r.document_id]);
  if (!d) throw new AppError(404, 'NOT_FOUND', 'El contrato ya no está disponible.');
  res.json(await createDownloadUrl(d.storage_key, d.mime, `Contrato ${r.folio}.pdf`));
};

/** GET /sales/anti-money-laundering — umbral vigente para avisar en el formulario. */
export const thresholds: RequestHandler = (_req, res) => {
  res.json({ threshold: noticeThreshold(), uma: UMA_DAILY, umaCount: NOTICE_UMA });
};
