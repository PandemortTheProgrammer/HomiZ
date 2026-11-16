import type { RequestHandler } from 'express';
import { z } from 'zod';
import { pool, withTransaction, type Db } from '../config/database.js';
import { insertActivity } from '../models/activity.model.js';
import { currentUser, type AuthUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { dateField, dateTimeField, pagination, paged, positiveMoney, queryArray } from '../middlewares/validate.js';
import { assertPropertyAccess, propertyScope } from '../services/access.service.js';
import { notify, userOfClient } from '../services/notification.service.js';
import { hideReceipts, tryIssueReceipt } from '../services/payment-receipt.service.js';

export const listQueryDto = pagination.extend({
  contractId: z.uuid().optional(),
  propertyId: z.uuid().optional(),
  status: queryArray,
  from: dateField.optional(),
  to: dateField.optional(),
  limit: z.coerce.number().int().min(1).max(100).default(50),
});
/** Pagaré adicional de un contrato (por ejemplo, un cargo extra o un mes más). */
export const createNoteDto = z.object({
  contractId: z.uuid({ error: 'Indica el contrato.' }),
  amount: positiveMoney,
  dueDate: dateField,
});
export const cancelNoteDto = z.object({ reason: z.string().trim().min(5, 'Explica por qué se cancela el pagaré.').max(300) });
export const updateNoteDto = z
  .object({ amount: positiveMoney.optional(), dueDate: dateField.optional() })
  .refine((v) => v.amount !== undefined || v.dueDate !== undefined, 'Indica el monto o la fecha.');
export const paymentDto = z.object({
  amount: positiveMoney,
  paidAt: dateTimeField,
  // El folio se genera solo (REC-<casa>-<pagaré>); se acepta uno escrito por compatibilidad con versiones anteriores.
  receiptFolio: z.string().trim().min(1).max(40).optional(),
  notes: z.string().trim().max(500).optional(),
});
export const correctDto = z
  .object({ amount: positiveMoney.optional(), paidAt: dateTimeField.optional(), receiptFolio: z.string().trim().min(1).max(40).optional(), notes: z.string().trim().max(500).optional() })
  .refine((v) => Object.keys(v).length > 0, 'Indica qué dato corregir.');
export const voidDto = z.object({ reason: z.string().trim().min(5, 'Explica por qué se anula el pago.').max(300) });
export const paymentParams = z.object({ id: z.uuid(), paymentId: z.uuid() });

interface NoteRow {
  id: string;
  contract_id: string;
  number: number;
  amount: number;
  due_date: string;
  paid_at: Date | null;
  status: 'pending' | 'paid' | 'overdue' | 'cancelled';
  property_id: string;
  property_code: string;
  property_name: string;
  client_id: string;
  client_name: string;
  payment_id: string | null;
  payment_amount: number | null;
  payment_paid_at: Date | null;
  receipt_folio: string | null;
  payment_notes: string | null;
  registered_by_name: string | null;
  proof_document_id: string | null;
  note_document_id: string | null;
  note_document_visible: boolean | null;
  stamps: { id: string; name: string; createdAt: string; visible: boolean }[] | null;
}

const SELECT = `
  SELECT n.id, n.contract_id, n.number, n.amount, to_char(n.due_date, 'YYYY-MM-DD') AS due_date, n.paid_at, n.status,
         ct.property_id, p.code AS property_code, p.name AS property_name, ct.client_id, c.name AS client_name,
         pay.id AS payment_id, pay.amount AS payment_amount, pay.paid_at AS payment_paid_at, pay.receipt_folio,
         pay.notes AS payment_notes, rb.name AS registered_by_name,
         (SELECT d.id FROM documents d WHERE d.promissory_note_id = n.id AND d.visible_to_client AND d.type NOT IN ('promissory_note', 'stamp')
           ORDER BY d.created_at DESC LIMIT 1) AS proof_document_id,
         (SELECT d.id FROM documents d WHERE d.promissory_note_id = n.id AND d.type = 'promissory_note'
           ORDER BY d.created_at DESC LIMIT 1) AS note_document_id,
         (SELECT d.visible_to_client FROM documents d WHERE d.promissory_note_id = n.id AND d.type = 'promissory_note'
           ORDER BY d.created_at DESC LIMIT 1) AS note_document_visible,
         -- Fotos de los sellos (entrega en físico y digital), de la más antigua a la más reciente
         (SELECT json_agg(json_build_object('id', d.id, 'name', d.name, 'createdAt', d.created_at, 'visible', d.visible_to_client) ORDER BY d.created_at)
            FROM documents d WHERE d.promissory_note_id = n.id AND d.type = 'stamp') AS stamps
    FROM promissory_notes n
    JOIN contracts ct ON ct.id = n.contract_id
    JOIN properties p ON p.id = ct.property_id
    JOIN clients c ON c.id = ct.client_id
    LEFT JOIN payments pay ON pay.promissory_note_id = n.id AND NOT pay.voided
    LEFT JOIN users rb ON rb.id = pay.registered_by`;

function present(n: NoteRow, user: AuthUser) {
  const payment = n.payment_id
    ? {
        id: n.payment_id, amount: n.payment_amount, paidAt: n.payment_paid_at, receiptFolio: n.receipt_folio, notes: n.payment_notes,
        ...(user.type === 'staff' ? { registeredBy: n.registered_by_name } : {}),
      }
    : null;
  return {
    id: n.id, contractId: n.contract_id, number: n.number, label: `Pagaré ${String(n.number).padStart(2, '0')}`, amount: n.amount,
    dueDate: n.due_date, status: n.status, paidAt: n.paid_at, payment, proofDocumentId: n.proof_document_id,
    // PDF del pagaré firmado (el cliente solo lo ve si es visible para él)
    documentId: user.type === 'staff' || n.note_document_visible ? n.note_document_id : null,
    // Fotos de los sellos: el cliente ve las que son visibles para él
    stamps: (n.stamps ?? []).filter((s) => user.type === 'staff' || s.visible).map(({ id, name, createdAt }) => ({ id, name, createdAt })),
    property: { id: n.property_id, name: n.property_name },
    ...(user.type === 'staff' ? { client: { id: n.client_id, name: n.client_name } } : {}),
  };
}

/** Resumen «Estado de pagos»: pagados X de N, faltan Y por $Z, próximo pagaré. */
async function summary(contractId: string) {
  const { rows } = await pool.query<{ total: number; paid: number; remaining: number; remaining_amount: number | null; next_number: number | null; next_due: string | null; next_amount: number | null }>(
    `SELECT count(*) FILTER (WHERE status <> 'cancelled')::int AS total,
            count(*) FILTER (WHERE status = 'paid')::int AS paid,
            count(*) FILTER (WHERE status IN ('pending', 'overdue'))::int AS remaining,
            sum(amount) FILTER (WHERE status IN ('pending', 'overdue')) AS remaining_amount,
            (array_agg(number ORDER BY due_date) FILTER (WHERE status IN ('pending', 'overdue')))[1] AS next_number,
            to_char((array_agg(due_date ORDER BY due_date) FILTER (WHERE status IN ('pending', 'overdue')))[1], 'YYYY-MM-DD') AS next_due,
            (array_agg(amount ORDER BY due_date) FILTER (WHERE status IN ('pending', 'overdue')))[1] AS next_amount
       FROM promissory_notes WHERE contract_id = $1`,
    [contractId],
  );
  const s = rows[0];
  return {
    contractId, total: s.total, paid: s.paid, remaining: s.remaining, remainingAmount: s.remaining_amount ?? 0,
    next: s.next_number ? { number: s.next_number, dueDate: s.next_due, amount: s.next_amount } : null,
  };
}

async function loadNote(user: AuthUser, id: string): Promise<NoteRow> {
  const { rows } = await pool.query<NoteRow>(`${SELECT} WHERE n.id = $1`, [id]);
  const n = rows[0];
  if (!n || (user.type === 'client' && n.client_id !== user.clientId)) throw new AppError(404, 'NOT_FOUND', 'El pagaré no existe.');
  if (user.type === 'staff') await assertPropertyAccess(user, n.property_id);
  return n;
}

export const list: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const params: unknown[] = [];
  const where: string[] = [];
  if (user.type === 'client') where.push(`ct.client_id = $${params.push(user.clientId ?? '00000000-0000-0000-0000-000000000000')}`);
  else {
    const scope = await propertyScope(user);
    if (scope) where.push(`ct.property_id = ANY($${params.push(scope)}::uuid[])`);
  }
  if (q.contractId) where.push(`n.contract_id = $${params.push(q.contractId)}`);
  if (q.propertyId) where.push(`ct.property_id = $${params.push(q.propertyId)}`);
  if (q.status?.length) where.push(`n.status::text = ANY($${params.push(q.status)}::text[])`);
  if (q.from) where.push(`n.due_date >= $${params.push(q.from)}::date`);
  if (q.to) where.push(`n.due_date <= $${params.push(q.to)}::date`);
  const w = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const base = `FROM promissory_notes n JOIN contracts ct ON ct.id = n.contract_id`;
  const total = await pool.query<{ n: string }>(`SELECT count(*) AS n ${base} ${w}`, params);
  // El cliente ve primero el más próximo por pagar, luego los pagados más recientes (como en la app).
  const order = user.type === 'client' ? `ORDER BY (n.status IN ('pending','overdue')) DESC, CASE WHEN n.status IN ('pending','overdue') THEN n.due_date END ASC, n.due_date DESC` : 'ORDER BY n.due_date';
  const { rows } = await pool.query<NoteRow>(`${SELECT} ${w} ${order} LIMIT $${params.length + 1} OFFSET $${params.length + 2}`, [...params, q.limit, (q.page - 1) * q.limit]);

  let contractForSummary = q.contractId;
  if (!contractForSummary && user.type === 'client' && user.clientId) {
    const c = await pool.query<{ id: string }>(`SELECT id FROM contracts WHERE client_id = $1 AND status = 'active' ORDER BY start_date DESC LIMIT 1`, [user.clientId]);
    contractForSummary = c.rows[0]?.id;
  }
  res.json({ ...paged(rows.map((n) => present(n, user)), Number(total.rows[0].n), q), summary: contractForSummary ? await summary(contractForSummary) : null });
};

export const getOne: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const n = await loadNote(user, (res.locals.params as { id: string }).id);
  const body: Record<string, unknown> = present(n, user);
  if (user.type === 'staff') {
    const voided = await pool.query(
      `SELECT p.id, p.amount, p.paid_at AS "paidAt", p.receipt_folio AS "receiptFolio", p.void_reason AS "voidReason", u.name AS "registeredBy"
         FROM payments p JOIN users u ON u.id = p.registered_by WHERE p.promissory_note_id = $1 AND p.voided ORDER BY p.created_at`,
      [n.id],
    );
    body.voidedPayments = voided.rows;
  }
  res.json(body);
};

export const updateNote: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const n = await loadNote(user, (res.locals.params as { id: string }).id);
  if (n.status === 'paid' || n.status === 'cancelled') throw new AppError(409, 'INVALID_STATUS', 'Solo se editan pagarés pendientes o vencidos.');
  const d = res.locals.body as z.infer<typeof updateNoteDto>;
  await pool.query(
    `UPDATE promissory_notes SET amount = COALESCE($2, amount), due_date = COALESCE($3::date, due_date),
            status = CASE WHEN COALESCE($3::date, due_date) < CURRENT_DATE THEN 'overdue'::note_status ELSE 'pending'::note_status END
      WHERE id = $1`,
    [n.id, d.amount ?? null, d.dueDate ?? null],
  );
  await insertActivity({ userId: user.id, propertyId: n.property_id, entity: 'promissory_note', entityId: n.id, action: 'update', description: `${user.name} modificó el pagaré ${n.number} de ${n.client_name}.`, oldValues: { amount: n.amount, dueDate: n.due_date }, newValues: d });
  res.json(present(await loadNote(user, n.id), user));
};

/** POST /promissory-notes — agrega un pagaré al contrato vigente (contracts.manage). Número siguiente del contrato. */
export const createNote: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = res.locals.body as z.infer<typeof createNoteDto>;
  const { rows: ct } = await pool.query<{ property_id: string; status: string; client_name: string }>(
    'SELECT ct.property_id, ct.status, c.name AS client_name FROM contracts ct JOIN clients c ON c.id = ct.client_id WHERE ct.id = $1',
    [d.contractId],
  );
  if (!ct[0]) throw new AppError(404, 'NOT_FOUND', 'El contrato no existe.');
  await assertPropertyAccess(user, ct[0].property_id);
  if (ct[0].status !== 'active') throw new AppError(409, 'INVALID_STATUS', 'Solo se agregan pagarés a un contrato vigente.');
  const { rows } = await pool.query<{ id: string; number: number }>(
    `INSERT INTO promissory_notes (contract_id, number, amount, due_date, status)
     SELECT $1, COALESCE(max(number), 0) + 1, $2, $3::date, CASE WHEN $3::date < CURRENT_DATE THEN 'overdue'::note_status ELSE 'pending'::note_status END
       FROM promissory_notes WHERE contract_id = $1
     RETURNING id, number`,
    [d.contractId, d.amount, d.dueDate],
  );
  await insertActivity({ userId: user.id, propertyId: ct[0].property_id, entity: 'promissory_note', entityId: rows[0].id, action: 'create', description: `${user.name} agregó el pagaré ${rows[0].number} a ${ct[0].client_name}.`, newValues: d });
  res.status(201).json(present(await loadNote(user, rows[0].id), user));
};

/** POST /promissory-notes/:id/cancel — cancela un pagaré que no se cobrará (sin pago); queda en el historial. */
export const cancelNote: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const n = await loadNote(user, (res.locals.params as { id: string }).id);
  const { reason } = res.locals.body as z.infer<typeof cancelNoteDto>;
  if (n.status === 'paid') throw new AppError(409, 'ALREADY_PAID', 'Este pagaré tiene un pago registrado: primero anula el pago.');
  if (n.status === 'cancelled') throw new AppError(409, 'INVALID_STATUS', 'Este pagaré ya está cancelado.');
  await pool.query(`UPDATE promissory_notes SET status = 'cancelled' WHERE id = $1`, [n.id]);
  await insertActivity({ userId: user.id, propertyId: n.property_id, entity: 'promissory_note', entityId: n.id, action: 'cancel', description: `${user.name} canceló el pagaré ${n.number} de ${n.client_name}: ${reason}` });
  res.json(present(await loadNote(user, n.id), user));
};

/**
 * Folio automático: REC-<clave de la casa>-<número de pagaré>, p. ej. REC-ZUG-012-05.
 * Si ese pagaré ya tuvo un pago (anulado), se agrega una letra: REC-ZUG-012-05-B, -C…
 */
async function nextFolio(db: Db, n: NoteRow): Promise<string> {
  const base = `REC-${n.property_code}-${String(n.number).padStart(2, '0')}`;
  const { rows } = await db.query<{ receipt_folio: string }>('SELECT receipt_folio FROM payments WHERE promissory_note_id = $1', [n.id]);
  const used = new Set(rows.map((r) => r.receipt_folio));
  if (!used.has(base)) return base;
  for (let i = 1; i < 26; i++) {
    const folio = `${base}-${String.fromCharCode(65 + i)}`;
    if (!used.has(folio)) return folio;
  }
  return `${base}-${Date.now().toString(36).toUpperCase()}`;
}

/** Registro de pago en efectivo. El pago debe cubrir el pagaré completo. */
export const registerPayment: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const n = await loadNote(user, (res.locals.params as { id: string }).id);
  const d = res.locals.body as z.infer<typeof paymentDto>;
  if (n.status === 'paid') throw new AppError(409, 'ALREADY_PAID', 'Este pagaré ya tiene un pago registrado.');
  if (n.status === 'cancelled') throw new AppError(409, 'INVALID_STATUS', 'Este pagaré está cancelado.');
  if (d.amount !== n.amount) {
    throw new AppError(400, 'AMOUNT_MISMATCH', `El pago debe cubrir el pagaré completo ($${n.amount.toLocaleString('en-US')}).`, { amount: [`Monto esperado: ${n.amount}`] });
  }
  try {
    await withTransaction(async (db) => {
      const folio = d.receiptFolio ?? (await nextFolio(db, n));
      await db.query(
        `INSERT INTO payments (promissory_note_id, amount, paid_at, receipt_folio, notes, registered_by) VALUES ($1, $2, $3, $4, $5, $6)`,
        [n.id, d.amount, d.paidAt, folio, d.notes ?? null, user.id],
      );
      await db.query(`UPDATE promissory_notes SET status = 'paid', paid_at = $2 WHERE id = $1`, [n.id, d.paidAt]);
      await insertActivity({ userId: user.id, propertyId: n.property_id, entity: 'promissory_note', entityId: n.id, action: 'payment', description: `${user.name} registró el pago del pagaré ${n.number} de ${n.client_name} (folio ${folio}).`, newValues: { ...d, receiptFolio: folio } }, db);
      await notify([await userOfClient(n.client_id, db)], {
        type: 'payment_registered', title: 'Pago registrado',
        message: `Registramos tu pago del pagaré ${String(n.number).padStart(2, '0')} por $${n.amount.toLocaleString('en-US')}. Folio ${folio} (comprobante interno de pago; no es factura CFDI).`,
        entity: 'promissory_note', entityId: n.id,
      }, db);
    });
  } catch (err) {
    if ((err as { code?: string }).code === '23505') throw new AppError(409, 'ALREADY_PAID', 'Este pagaré ya tiene un pago registrado.');
    throw err;
  }
  await tryIssueReceipt(n.id, user.id);
  res.status(201).json(present(await loadNote(user, n.id), user));
};

async function loadPayment(user: AuthUser, noteId: string, paymentId: string) {
  const n = await loadNote(user, noteId);
  const { rows } = await pool.query(`SELECT * FROM payments WHERE id = $1 AND promissory_note_id = $2`, [paymentId, noteId]);
  if (!rows[0]) throw new AppError(404, 'NOT_FOUND', 'El pago no existe.');
  if (rows[0].voided) throw new AppError(409, 'INVALID_STATUS', 'Este pago ya está anulado.');
  return { n, p: rows[0] as { amount: number; paid_at: Date; receipt_folio: string; notes: string | null } };
}

/** Corrección de un pago registrado (solo administración, permiso payments.correct). */
export const correctPayment: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id, paymentId } = res.locals.params as z.infer<typeof paymentParams>;
  const { n, p } = await loadPayment(user, id, paymentId);
  const d = res.locals.body as z.infer<typeof correctDto>;
  await withTransaction(async (db) => {
    await db.query(
      `UPDATE payments SET amount = COALESCE($2, amount), paid_at = COALESCE($3, paid_at), receipt_folio = COALESCE($4, receipt_folio), notes = COALESCE($5, notes) WHERE id = $1`,
      [paymentId, d.amount ?? null, d.paidAt ?? null, d.receiptFolio ?? null, d.notes ?? null],
    );
    if (d.paidAt) await db.query('UPDATE promissory_notes SET paid_at = $2 WHERE id = $1', [id, d.paidAt]);
    await insertActivity({ userId: user.id, propertyId: n.property_id, entity: 'payment', entityId: paymentId, action: 'correct', description: `${user.name} corrigió el pago del pagaré ${n.number} de ${n.client_name}.`, oldValues: { amount: p.amount, paidAt: p.paid_at, receiptFolio: p.receipt_folio, notes: p.notes }, newValues: d }, db);
  });
  await tryIssueReceipt(id, user.id); // el recibo debe decir lo mismo que el pago corregido
  res.json(present(await loadNote(user, id), user));
};

/** Anulación: el pagaré vuelve a pendiente (o vencido) y el pago anulado queda en el historial. */
export const voidPayment: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id, paymentId } = res.locals.params as z.infer<typeof paymentParams>;
  const { n } = await loadPayment(user, id, paymentId);
  const { reason } = res.locals.body as z.infer<typeof voidDto>;
  await withTransaction(async (db) => {
    await db.query('UPDATE payments SET voided = TRUE, void_reason = $2 WHERE id = $1', [paymentId, reason]);
    await db.query(
      `UPDATE promissory_notes SET paid_at = NULL, status = CASE WHEN due_date < CURRENT_DATE THEN 'overdue'::note_status ELSE 'pending'::note_status END WHERE id = $1`,
      [id],
    );
    await insertActivity({ userId: user.id, propertyId: n.property_id, entity: 'payment', entityId: paymentId, action: 'void', description: `${user.name} anuló el pago del pagaré ${n.number} de ${n.client_name}: ${reason}` }, db);
  });
  await hideReceipts(id);
  res.json(present(await loadNote(user, id), user));
};
