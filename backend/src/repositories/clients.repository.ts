import { pool } from '../config/database.js';

/* ==========================================================================
   Repositorio de clientes: todo el SQL del módulo /clients (consultas parametrizadas).
   El controlador valida, aplica las reglas de negocio y decide qué responder.
   ========================================================================== */

/** Campos de la API → columnas de la tabla clients */
export const CLIENT_COLUMNS = {
  name: 'name', email: 'email', phone: 'phone', address: 'address', kind: 'kind', label: 'label', nationality: 'nationality',
  occupation: 'occupation', operation: 'operation', budget: 'budget', budgetAmount: 'budget_amount', needs: 'needs',
  hasPets: 'has_pets', petsCount: 'pets_count', occupants: 'occupants', followStatus: 'follow_status', propertyId: 'property_id', brokerId: 'broker_id',
} as const;
export type ClientField = keyof typeof CLIENT_COLUMNS;

export type ClientRow = Record<string, unknown> & { id: string; user_id: string | null; broker_id: string | null; property_id: string | null; name: string; kind: string; follow_status: string; email: string | null };

/** Quién consulta: administración ve todo; un broker, sus clientes o los ligados a sus casas */
export interface ClientScope { userId: string; admin: boolean }

const SELECT = `
  SELECT c.*, p.code AS property_code, p.name AS property_name, b.name AS broker_name, (c.user_id IS NOT NULL) AS has_account
    FROM clients c
    LEFT JOIN properties p ON p.id = c.property_id
    LEFT JOIN users b ON b.id = c.broker_id`;

function scopeSql(s: ClientScope, params: unknown[]): string {
  if (s.admin) return '';
  params.push(s.userId);
  return `AND (c.broker_id = $${params.length} OR c.property_id IN (SELECT id FROM properties WHERE broker_id = $${params.length}))`;
}

/** Un cliente activo dentro del alcance, o undefined */
export async function findScoped(s: ClientScope, id: string): Promise<ClientRow | undefined> {
  const params: unknown[] = [id];
  const { rows } = await pool.query<ClientRow>(`${SELECT} WHERE c.id = $1 AND c.active ${scopeSql(s, params)}`, params);
  return rows[0];
}

export interface ClientFilters { q?: string; kind?: string; followStatus?: string; propertyId?: string; page: number; limit: number }

/** Lista paginada con filtros; devuelve las filas de la página y el total */
export async function list(s: ClientScope, f: ClientFilters): Promise<{ rows: ClientRow[]; total: number }> {
  const params: unknown[] = [];
  let where = `WHERE c.active ${scopeSql(s, params)}`;
  if (f.q) where += ` AND (c.name ILIKE $${params.push(`%${f.q}%`)} OR c.email ILIKE $${params.length} OR c.phone ILIKE $${params.length})`;
  if (f.kind) where += ` AND c.kind = $${params.push(f.kind)}`;
  if (f.followStatus) where += ` AND c.follow_status = $${params.push(f.followStatus)}`;
  if (f.propertyId) where += ` AND c.property_id = $${params.push(f.propertyId)}`;
  const total = await pool.query<{ n: string }>(`SELECT count(*) AS n FROM clients c ${where}`, params);
  const { rows } = await pool.query<ClientRow>(
    `${SELECT} ${where} ORDER BY c.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, f.limit, (f.page - 1) * f.limit],
  );
  return { rows, total: Number(total.rows[0].n) };
}

/** Todo lo de la persona: solicitudes, citas, contratos con sus pagarés y bitácora */
export async function overview(c: ClientRow) {
  const email = String(c.email ?? '');
  const [leads, appointments, contracts, activity] = await Promise.all([
    pool.query(
      `SELECT l.id, l.folio, l.reason, l.status, l.created_at AS "createdAt", p.code AS "propertyCode", p.name AS "propertyName",
              (SELECT count(*)::int FROM lead_proposals x WHERE x.lead_id = l.id) AS proposals
         FROM leads l LEFT JOIN properties p ON p.id = l.property_id
        WHERE l.client_id = $1 OR ($2 <> '' AND lower(l.email) = lower($2)) ORDER BY l.created_at DESC LIMIT 30`,
      [c.id, email],
    ),
    pool.query(
      `SELECT a.id, a.code, a.status, a.scheduled_at AS "scheduledAt", p.code AS "propertyCode", p.name AS "propertyName", b.name AS broker
         FROM appointments a JOIN properties p ON p.id = a.property_id LEFT JOIN users b ON b.id = a.broker_id
        WHERE a.client_id = $1 ORDER BY a.scheduled_at DESC LIMIT 30`,
      [c.id],
    ),
    pool.query(
      `SELECT ct.id, ct.status, to_char(ct.start_date, 'YYYY-MM-DD') AS "startDate", to_char(ct.end_date, 'YYYY-MM-DD') AS "endDate",
              ct.monthly_rent AS "monthlyRent", ct.payment_day AS "paymentDay", p.code AS "propertyCode", p.name AS "propertyName",
              count(n.*) FILTER (WHERE n.status <> 'cancelled')::int AS "notesTotal", count(n.*) FILTER (WHERE n.status = 'paid')::int AS "notesPaid",
              count(n.*) FILTER (WHERE n.status = 'overdue')::int AS "notesOverdue",
              to_char(min(n.due_date) FILTER (WHERE n.status IN ('pending', 'overdue')), 'YYYY-MM-DD') AS "nextDue",
              (SELECT count(*)::int FROM documents d JOIN promissory_notes x ON x.id = d.promissory_note_id WHERE x.contract_id = ct.id AND d.type = 'stamp') AS stamps
         FROM contracts ct JOIN properties p ON p.id = ct.property_id LEFT JOIN promissory_notes n ON n.contract_id = ct.id
        WHERE ct.client_id = $1 GROUP BY ct.id, p.code, p.name ORDER BY ct.start_date DESC`,
      [c.id],
    ),
    // Lo que hizo la persona (en la app o el sitio) y lo que se hizo con su expediente
    pool.query(
      `SELECT a.action, a.description, a.created_at AS "createdAt", u.name AS "user", (u.type = 'client') AS "byClient"
         FROM activity_log a LEFT JOIN users u ON u.id = a.user_id
        WHERE ($1::uuid IS NOT NULL AND a.user_id = $1) OR (a.entity = 'client' AND a.entity_id = $2)
           OR (a.entity = 'lead' AND a.entity_id IN (SELECT id FROM leads WHERE client_id = $2))
           OR (a.entity = 'appointment' AND a.entity_id IN (SELECT id FROM appointments WHERE client_id = $2))
        ORDER BY a.created_at DESC LIMIT 40`,
      [c.user_id ?? null, c.id],
    ),
  ]);
  return { leads: leads.rows, appointments: appointments.rows, contracts: contracts.rows, activity: activity.rows };
}

/** true si el cliente tiene un contrato vigente */
export async function hasActiveContract(clientId: string): Promise<boolean> {
  const { rowCount } = await pool.query(`SELECT 1 FROM contracts WHERE client_id = $1 AND status = 'active'`, [clientId]);
  return !!rowCount;
}

/** Inserta solo los campos recibidos; devuelve el id */
export async function insert(d: Partial<Record<ClientField, unknown>>): Promise<string> {
  const cols: string[] = [];
  const vals: unknown[] = [];
  for (const [k, col] of Object.entries(CLIENT_COLUMNS)) if (d[k as ClientField] !== undefined) { cols.push(col); vals.push(d[k as ClientField]); }
  const { rows } = await pool.query<{ id: string }>(`INSERT INTO clients (${cols.join(', ')}) VALUES (${cols.map((_, i) => `$${i + 1}`).join(', ')}) RETURNING id`, vals);
  return rows[0].id;
}

/** Actualiza solo los campos recibidos */
export async function update(id: string, d: Partial<Record<ClientField, unknown>>): Promise<void> {
  const sets: string[] = [];
  const vals: unknown[] = [];
  for (const [k, col] of Object.entries(CLIENT_COLUMNS)) if (d[k as ClientField] !== undefined) { vals.push(d[k as ClientField]); sets.push(`${col} = $${vals.length}`); }
  if (!sets.length) return;
  vals.push(id);
  await pool.query(`UPDATE clients SET ${sets.join(', ')} WHERE id = $${vals.length}`, vals);
}

/** Cancela las citas próximas de un cliente que se da de baja; devuelve cuántas */
export async function cancelUpcomingAppointments(clientId: string): Promise<number> {
  const r = await pool.query(
    `UPDATE appointments SET status = 'cancelada', reason = 'El cliente se dio de baja.'
      WHERE client_id = $1 AND status IN ('por-confirmar', 'confirmada') AND scheduled_at > now()`,
    [clientId],
  );
  return r.rowCount ?? 0;
}

/** Baja lógica: el historial se conserva */
export async function deactivate(clientId: string): Promise<void> {
  await pool.query('UPDATE clients SET active = FALSE WHERE id = $1', [clientId]);
}
