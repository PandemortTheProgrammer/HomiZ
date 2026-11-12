import { pool, type Db } from '../config/database.js';

/* Consultas para verificar la pertenencia de un recurso a quien lo pide. */

export async function propertyBrokerId(propertyId: string, db: Db = pool): Promise<string | null | undefined> {
  const { rows } = await db.query<{ broker_id: string | null }>(
    'SELECT broker_id FROM properties WHERE id = $1 AND active',
    [propertyId],
  );
  return rows.length ? rows[0].broker_id : undefined; // undefined = la propiedad no existe
}

/** El cliente está vinculado a la propiedad si tiene contrato vigente en ella o es su propiedad registrada. */
/**
 * El cliente solo tiene acceso a una casa mientras tenga contrato VIGENTE en ella (privacidad entre inquilinos:
 * al terminar su contrato deja de ver la casa; marcarlo «inquilino» sin contrato no da acceso).
 */
export async function clientLinkedToProperty(clientId: string, propertyId: string, db: Db = pool): Promise<boolean> {
  const { rows } = await db.query(
    `SELECT 1 FROM contracts c JOIN clients cl ON cl.id = c.client_id
      WHERE c.client_id = $1 AND c.property_id = $2 AND c.status = 'active' AND cl.active LIMIT 1`,
    [clientId, propertyId],
  );
  return rows.length > 0;
}

/** Propiedades del cliente: solo las de sus contratos vigentes. */
export async function clientPropertyIds(clientId: string, db: Db = pool): Promise<string[]> {
  const { rows } = await db.query<{ id: string }>(
    `SELECT DISTINCT c.property_id AS id FROM contracts c JOIN clients cl ON cl.id = c.client_id
      WHERE c.client_id = $1 AND c.status = 'active' AND cl.active`,
    [clientId],
  );
  return rows.map((r) => r.id);
}

/**
 * Lo que un cliente ve de su casa es lo de SU contrato (no lo del inquilino anterior ni del siguiente).
 * Condiciones SQL para documentos (alias d), reportes (alias r) y recibos (alias r); $n = id del cliente.
 * - Documentos: ligados a su contrato o a sus pagarés; los generales de la casa (reglamento, anexos, fotos);
 *   y los sueltos subidos desde que empezó su contrato.
 * - Reportes de mantenimiento: los suyos y los que levantó el personal durante su contrato.
 * - Recibos (agua, luz…): los creados o del periodo de su contrato.
 */
const ACTIVE_CONTRACT = (p: string, alias: string) =>
  `(SELECT ct.id, ct.created_at, ct.start_date FROM contracts ct WHERE ct.client_id = ${p} AND ct.status = 'active' AND ct.property_id = ${alias}.property_id)`;

export const clientDocumentFilter = (p: string) => `(
  d.contract_id IN (SELECT id FROM ${ACTIVE_CONTRACT(p, 'd')} x)
  OR d.promissory_note_id IN (SELECT n.id FROM promissory_notes n JOIN contracts ct ON ct.id = n.contract_id WHERE ct.client_id = ${p} AND ct.status = 'active')
  OR (d.contract_id IS NULL AND d.promissory_note_id IS NULL AND (
        d.type IN ('rules', 'annex', 'photo')
        OR d.created_at >= (SELECT min(x.created_at) - interval '1 day' FROM ${ACTIVE_CONTRACT(p, 'd')} x)))
)`;

export const clientReportFilter = (p: string) => `(
  r.client_id = ${p}
  OR (r.client_id IS NULL AND r.created_at >= (SELECT min(x.created_at) - interval '1 day' FROM ${ACTIVE_CONTRACT(p, 'r')} x))
)`;

export const clientReceiptFilter = (p: string) => `(
  r.created_at >= (SELECT min(x.created_at) - interval '1 day' FROM ${ACTIVE_CONTRACT(p, 'r')} x)
  OR r.period_start >= (SELECT min(x.start_date) FROM ${ACTIVE_CONTRACT(p, 'r')} x)
)`;

/** Contrato vigente de la casa (para ligar ahí los documentos personales que sube el personal). */
export async function activeContractOf(propertyId: string, db: Db = pool): Promise<string | null> {
  const { rows } = await db.query<{ id: string }>(`SELECT id FROM contracts WHERE property_id = $1 AND status = 'active' LIMIT 1`, [propertyId]);
  return rows[0]?.id ?? null;
}

export async function brokerPropertyIds(brokerId: string, db: Db = pool): Promise<string[]> {
  const { rows } = await db.query<{ id: string }>('SELECT id FROM properties WHERE broker_id = $1', [brokerId]);
  return rows.map((r) => r.id);
}
