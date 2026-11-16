import { pool, withTransaction } from '../config/database.js';
import { fileSize, keyBelongsTo } from '../config/storage.js';
import { insertActivity } from '../models/activity.model.js';
import type { AuthUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { assertPropertyAccess } from './access.service.js';

/*
 * PDF del contrato firmado. Los pagarés se generan solos al registrar el contrato (12 mensuales);
 * ya no se separan de un PDF (decisión 111). Cada pagaré puede llevar las fotos de sus sellos.
 */

interface ContractRef { id: string; property_id: string; property_code: string; client_name: string }

async function contractFor(user: AuthUser, contractId: string): Promise<ContractRef> {
  const { rows } = await pool.query<ContractRef>(
    `SELECT ct.id, ct.property_id, p.code AS property_code, c.name AS client_name
       FROM contracts ct JOIN properties p ON p.id = ct.property_id JOIN clients c ON c.id = ct.client_id WHERE ct.id = $1`,
    [contractId],
  );
  if (!rows[0]) throw new AppError(404, 'NOT_FOUND', 'El contrato no existe.');
  await assertPropertyAccess(user, rows[0].property_id);
  return rows[0];
}

/** El archivo ya subido (POST /documents/upload-url + PUT) debe ser un PDF de esa casa. */
async function uploadedPdf(ct: ContractRef, storageKey: string): Promise<number> {
  if (!keyBelongsTo(storageKey, ct.property_code, 'document') || !storageKey.endsWith('.pdf')) {
    throw new AppError(400, 'INVALID_FILE', 'El archivo no es un PDF de esta casa.');
  }
  const size = await fileSize(storageKey);
  if (size === null) throw new AppError(400, 'UPLOAD_NOT_FOUND', 'No encontramos el archivo. Termina de subirlo e inténtalo de nuevo.');
  return size;
}

/** POST /contracts/:id/document — el contrato firmado (PDF): queda en el expediente, visible para el inquilino. */
export async function attachContractPdf(user: AuthUser, contractId: string, storageKey: string): Promise<string> {
  const ct = await contractFor(user, contractId);
  const size = await uploadedPdf(ct, storageKey);
  return withTransaction(async (db) => {
    const { rows } = await db.query<{ id: string }>(
      `INSERT INTO documents (property_id, type, name, storage_key, mime, size, visible_to_client, uploaded_by, contract_id)
       VALUES ($1, 'contract', $2, $3, 'application/pdf', $4, TRUE, $5, $6) RETURNING id`,
      [ct.property_id, `Contrato de arrendamiento · ${ct.client_name}`, storageKey, size, user.id, ct.id],
    );
    await db.query('UPDATE contracts SET document_id = $2 WHERE id = $1', [ct.id, rows[0].id]);
    await db.query('INSERT INTO dossiers (property_id) VALUES ($1) ON CONFLICT (property_id) DO NOTHING', [ct.property_id]);
    await insertActivity({ userId: user.id, propertyId: ct.property_id, entity: 'contract', entityId: ct.id, action: 'upload', description: `${user.name} subió el contrato firmado de ${ct.client_name}.` }, db);
    return rows[0].id;
  });
}
