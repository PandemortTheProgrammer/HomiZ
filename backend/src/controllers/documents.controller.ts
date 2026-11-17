import { createReadStream } from 'node:fs';
import type { RequestHandler } from 'express';
import { z } from 'zod';
import { pool, withTransaction } from '../config/database.js';
import {
  buildKey, createDownloadUrl, createUploadUrl, decodeLocalToken, deleteFile, FILE_RULES, fileSize, keyBelongsTo, localPath, putObject, type FilePurpose,
} from '../config/storage.js';
import { logger } from '../config/logger.js';
import { env } from '../config/env.js';
import { insertActivity } from '../models/activity.model.js';
import { currentUser, type AuthUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { pagination, paged } from '../middlewares/validate.js';
import { assertPropertyAccess, propertyScope } from '../services/access.service.js';
import { activeContractOf, clientDocumentFilter } from '../models/property-access.model.js';

// stamp: foto del sello de un pagaré (constancia de entrega en físico y digital), siempre ligada a ese pagaré
const DOC_TYPES = ['contract', 'deposit', 'delivery_sheet', 'rules', 'annex', 'receipt', 'proof', 'photo', 'other', 'promissory_note', 'stamp'] as const;

export const uploadUrlDto = z.object({
  propertyId: z.uuid({ error: 'Indica la propiedad.' }),
  purpose: z.enum(['document', 'property_photo', 'maintenance_photo']),
  mime: z.string().max(80),
  size: z.coerce.number().int().positive('El archivo está vacío.'),
});
export const confirmDto = z.object({
  propertyId: z.uuid(),
  storageKey: z.string().min(10).max(300),
  type: z.enum(DOC_TYPES, { error: 'Tipo de documento no válido.' }),
  name: z.string().trim().min(2, 'Escribe el nombre del documento.').max(120),
  description: z.string().trim().max(200).nullable().optional(),
  mime: z.string().max(80),
  visibleToClient: z.boolean().default(false),
  contractId: z.uuid().nullable().optional(),
  promissoryNoteId: z.uuid().nullable().optional(),
  receiptId: z.uuid().nullable().optional(),
  reportId: z.uuid().nullable().optional(),
  expenseId: z.uuid().nullable().optional(),
});
export const listQueryDto = pagination.extend({ propertyId: z.uuid().optional(), type: z.enum(DOC_TYPES).optional() });
export const updateDto = z
  .object({ name: z.string().trim().min(2).max(120).optional(), description: z.string().trim().max(200).nullable().optional(), visibleToClient: z.boolean().optional() })
  .refine((v) => Object.keys(v).length > 0, 'Indica qué cambiar.');

/** Quién puede subir qué: el cliente solo fotos de mantenimiento de su casa. */
function canUpload(user: AuthUser, purpose: FilePurpose): boolean {
  if (user.type === 'client') return purpose === 'maintenance_photo';
  const needed = { document: 'documents.manage', property_photo: 'properties.update', maintenance_photo: 'maintenance.manage' }[purpose];
  return user.permissions.has(needed);
}

/** POST /documents/upload-url — valida tipo y tamaño y devuelve una URL firmada de subida (PUT). */
export const uploadUrl: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = res.locals.body as z.infer<typeof uploadUrlDto>;
  if (!canUpload(user, d.purpose)) throw new AppError(403, 'FORBIDDEN', 'No tienes permiso para subir este tipo de archivo.');
  await assertPropertyAccess(user, d.propertyId);
  const rule = FILE_RULES[d.purpose];
  if (!rule.mimes.includes(d.mime)) {
    throw new AppError(400, 'INVALID_FILE_TYPE', `Tipo de archivo no permitido. Usa: ${rule.mimes.map((m) => m.split('/')[1].toUpperCase()).join(', ')}.`);
  }
  if (d.size > rule.maxBytes) throw new AppError(400, 'FILE_TOO_LARGE', `El archivo pesa más de ${rule.maxBytes / 1024 / 1024} MB.`);
  const { rows } = await pool.query<{ code: string }>('SELECT code FROM properties WHERE id = $1', [d.propertyId]);
  const storageKey = buildKey(rows[0].code, d.purpose, d.mime);
  // La subida va a esta misma API por la dirección que usa quien sube (panel, red local o túnel público)
  res.status(201).json({ storageKey, maxBytes: rule.maxBytes, upload: await createUploadUrl(storageKey, d.mime, rule.maxBytes, `${_req.protocol}://${_req.get('host')}`) });
};

/** POST /documents — confirma un documento ya subido y lo registra en el expediente. */
export const confirm: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = res.locals.body as z.infer<typeof confirmDto>;
  await assertPropertyAccess(user, d.propertyId);
  const { rows: p } = await pool.query<{ code: string }>('SELECT code FROM properties WHERE id = $1', [d.propertyId]);
  if (!keyBelongsTo(d.storageKey, p[0].code, 'document')) throw new AppError(400, 'INVALID_FILE', 'El archivo no corresponde a esta propiedad.');
  // El tipo guardado (con el que se entrega al descargar) es el de la extensión que generó el servidor, no el que se declara
  if (d.mime !== mimeOfKey(d.storageKey)) throw new AppError(400, 'INVALID_FILE_TYPE', 'El tipo de archivo no coincide con el archivo subido.');
  if (d.type === 'promissory_note' && !d.promissoryNoteId) throw new AppError(400, 'VALIDATION_ERROR', 'Indica a qué pagaré corresponde el PDF.');
  if (d.type === 'stamp') {
    if (!d.promissoryNoteId) throw new AppError(400, 'VALIDATION_ERROR', 'Indica a qué pagaré corresponde la foto del sello.');
    if (!d.mime.startsWith('image/')) throw new AppError(400, 'INVALID_FILE_TYPE', 'La foto del sello debe ser una imagen (JPG, PNG o WEBP).');
  }
  if (d.promissoryNoteId) {
    const note = await pool.query(
      'SELECT 1 FROM promissory_notes n JOIN contracts ct ON ct.id = n.contract_id WHERE n.id = $1 AND ct.property_id = $2',
      [d.promissoryNoteId, d.propertyId],
    );
    if (!note.rowCount) throw new AppError(400, 'INVALID_NOTE', 'El pagaré no corresponde a esta propiedad.');
  }
  const size = await fileSize(d.storageKey);
  if (size === null) throw new AppError(400, 'UPLOAD_NOT_FOUND', 'No encontramos el archivo. Termina de subirlo e inténtalo de nuevo.');
  // Los documentos personales (contrato, depósito, entrega, recibos…) se ligan al contrato vigente de la casa:
  // así solo los ve ese inquilino, no el anterior ni el siguiente. Reglamento, anexos y fotos son de la casa.
  if (!d.contractId && !d.promissoryNoteId && !['rules', 'annex', 'photo'].includes(d.type)) d.contractId = await activeContractOf(d.propertyId);
  const { rows } = await pool.query<{ id: string }>(
    `INSERT INTO documents (property_id, type, name, description, storage_key, mime, size, visible_to_client, uploaded_by,
                            contract_id, promissory_note_id, receipt_id, report_id, expense_id)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) RETURNING id`,
    [d.propertyId, d.type, d.name, d.description ?? null, d.storageKey, d.mime, size, d.visibleToClient, user.id,
      d.contractId ?? null, d.promissoryNoteId ?? null, d.receiptId ?? null, d.reportId ?? null, d.expenseId ?? null],
  );
  await pool.query('INSERT INTO dossiers (property_id) VALUES ($1) ON CONFLICT (property_id) DO NOTHING', [d.propertyId]);
  await insertActivity({ userId: user.id, propertyId: d.propertyId, entity: 'document', entityId: rows[0].id, action: 'upload', description: `${user.name} subió «${d.name}» al expediente${d.visibleToClient ? ' (visible para el cliente)' : ''}.` });
  res.status(201).json(present(await load(user, rows[0].id), user));
};

const SELECT = `SELECT d.*, u.name AS uploaded_by_name FROM documents d LEFT JOIN users u ON u.id = d.uploaded_by`;

function present(d: Record<string, unknown>, user: AuthUser) {
  return {
    id: d.id, propertyId: d.property_id, type: d.type, name: d.name, description: d.description, mime: d.mime, size: d.size,
    createdAt: d.created_at,
    ...(user.type === 'staff' ? { visibleToClient: d.visible_to_client, uploadedBy: d.uploaded_by_name } : {}),
    links: { contractId: d.contract_id, promissoryNoteId: d.promissory_note_id, receiptId: d.receipt_id, reportId: d.report_id, expenseId: d.expense_id },
  };
}

async function load(user: AuthUser, id: string) {
  const { rows } = await pool.query(`${SELECT} WHERE d.id = $1`, [id]);
  const d = rows[0];
  if (!d || (user.type === 'client' && !d.visible_to_client)) throw new AppError(404, 'NOT_FOUND', 'El documento no existe.');
  await assertPropertyAccess(user, d.property_id);
  // El cliente solo ve lo de su contrato (no los documentos de otro inquilino de la misma casa)
  if (user.type === 'client') {
    const own = await pool.query(`SELECT 1 FROM documents d WHERE d.id = $1 AND ${clientDocumentFilter('$2')}`, [id, user.clientId]);
    if (!own.rowCount) throw new AppError(404, 'NOT_FOUND', 'El documento no existe.');
  }
  return d;
}

export const list: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const scope = await propertyScope(user);
  const params: unknown[] = [];
  const where: string[] = [];
  if (scope) where.push(`d.property_id = ANY($${params.push(scope)}::uuid[])`);
  if (user.type === 'client') where.push('d.visible_to_client', clientDocumentFilter(`$${params.push(user.clientId)}`));
  if (q.propertyId) where.push(`d.property_id = $${params.push(q.propertyId)}`);
  if (q.type) where.push(`d.type = $${params.push(q.type)}`);
  const w = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const total = await pool.query<{ n: string }>(`SELECT count(*) AS n FROM documents d ${w}`, params);
  const { rows } = await pool.query(`${SELECT} ${w} ORDER BY d.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`, [...params, q.limit, (q.page - 1) * q.limit]);
  res.json(paged(rows.map((d) => present(d, user)), Number(total.rows[0].n), q));
};

/** GET /documents/:id/download-url — URL firmada de corta duración para ver el archivo. */
export const downloadUrl: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = await load(user, (res.locals.params as { id: string }).id);
  const ext = String(d.storage_key).split('.').pop();
  res.json(await createDownloadUrl(d.storage_key, d.mime, `${String(d.name).replace(/[^\w\s.-]/g, '')}.${ext}`));
};

export const update: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const before = await load(user, id);
  const d = res.locals.body as z.infer<typeof updateDto>;
  await pool.query(
    `UPDATE documents SET name = COALESCE($2, name), description = CASE WHEN $3::boolean THEN $4 ELSE description END,
            visible_to_client = COALESCE($5, visible_to_client) WHERE id = $1`,
    [id, d.name ?? null, d.description !== undefined, d.description ?? null, d.visibleToClient ?? null],
  );
  await insertActivity({ userId: user.id, propertyId: before.property_id, entity: 'document', entityId: id, action: 'update', description: `${user.name} actualizó «${before.name}».`, newValues: d });
  res.json(present(await load(user, id), user));
};

/**
 * DELETE /documents/:id — elimina el documento del expediente (permiso documents.delete: administración y propietario).
 * Se quita de los contratos y recibos que lo usaban; el historial conserva quién lo eliminó.
 */
export const remove: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const d = await load(user, id);
  await withTransaction(async (db) => {
    await db.query('UPDATE contracts SET document_id = NULL WHERE document_id = $1', [id]);
    await db.query('UPDATE receipts SET document_id = NULL WHERE document_id = $1', [id]);
    await db.query('DELETE FROM documents WHERE id = $1', [id]);
    await insertActivity({ userId: user.id, propertyId: d.property_id, entity: 'document', entityId: id, action: 'delete', description: `${user.name} eliminó «${d.name}» del expediente.`, oldValues: { name: d.name, type: d.type, storageKey: d.storage_key } }, db);
  });
  // El registro ya no existe; si el archivo no se puede borrar, solo queda huérfano en el almacenamiento.
  await deleteFile(d.storage_key).catch((err) => logger.warn({ err, key: d.storage_key }, 'No se pudo borrar el archivo del documento'));
  res.status(204).end();
};

/* ---------- Destino de las URL firmadas: subidas (local o R2) y descargas (solo local) ---------- */

/** Firma de los primeros bytes de cada tipo permitido (evita subir HTML o scripts disfrazados) */
export function contentMatches(mime: string, b: Buffer): boolean {
  const starts = (sig: number[], at = 0) => sig.every((x, i) => b[at + i] === x);
  switch (mime) {
    case 'application/pdf': return starts([0x25, 0x50, 0x44, 0x46, 0x2d]); // %PDF-
    case 'image/jpeg': return starts([0xff, 0xd8, 0xff]);
    case 'image/png': return starts([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
    case 'image/webp': return starts([0x52, 0x49, 0x46, 0x46]) && starts([0x57, 0x45, 0x42, 0x50], 8); // RIFF....WEBP
    default: return false;
  }
}

/** Tipo que corresponde a la extensión de la clave (la generó el servidor) */
const MIME_BY_EXT: Record<string, string> = { pdf: 'application/pdf', jpg: 'image/jpeg', png: 'image/png', webp: 'image/webp' };
const mimeOfKey = (key: string) => MIME_BY_EXT[key.split('.').pop() ?? ''] ?? null;

/** PUT /files/:token — recibe el archivo crudo y lo guarda (carpeta local o R2). Valida firma, vigencia, tipo y tamaño. */
export const putFile: RequestHandler = async (req, res) => {
  const t = decodeLocalToken(String(req.params.token));
  if (!t || t.op !== 'put') throw new AppError(403, 'INVALID_SIGNATURE', 'El enlace de subida no es válido o ya expiró.');
  if ((req.header('content-type') ?? '').split(';')[0] !== t.mime) throw new AppError(400, 'INVALID_FILE_TYPE', 'El tipo de archivo no coincide con el solicitado.');
  const body = req.body as Buffer;
  if (!Buffer.isBuffer(body) || !body.length) throw new AppError(400, 'EMPTY_FILE', 'El archivo está vacío.');
  if (t.max && body.length > t.max) throw new AppError(413, 'FILE_TOO_LARGE', 'El archivo supera el tamaño permitido.');
  // El contenido debe ser de verdad lo que dice ser (no basta el encabezado): PDF, JPG, PNG o WEBP
  if (!contentMatches(t.mime, body)) throw new AppError(400, 'INVALID_FILE_CONTENT', 'El archivo no es un PDF o imagen válido.');
  await putObject(t.key, t.mime, body);
  res.status(201).json({ storageKey: t.key, size: body.length });
};

/** GET /files/:token — entrega el archivo si la firma es válida y vigente. */
export const getFile: RequestHandler = async (req, res) => {
  const t = decodeLocalToken(String(req.params.token));
  if (env.STORAGE_DRIVER !== 'local' || !t || t.op !== 'get') throw new AppError(403, 'INVALID_SIGNATURE', 'El enlace no es válido o ya expiró.');
  if ((await fileSize(t.key)) === null) throw new AppError(404, 'NOT_FOUND', 'El archivo no existe.');
  res.setHeader('Content-Type', t.mime);
  res.setHeader('Content-Disposition', `inline; filename="${encodeURIComponent(t.name ?? 'archivo')}"`);
  res.setHeader('Cache-Control', 'private, max-age=300');
  res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin'); // el sitio y el panel muestran fotos desde otro origen
  createReadStream(localPath(t.key)).pipe(res);
};
