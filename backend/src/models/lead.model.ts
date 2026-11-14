import { pool, type Db } from '../config/database.js';

export interface LeadRow {
  id: string;
  folio: string;
  reason: 'visita' | 'rentar' | 'comprar' | 'publicar' | 'otro';
  name: string;
  email: string;
  phone: string | null;
  message: string | null;
  property_id: string | null;
  property_code: string | null;
  property_name: string | null;
  /** Estado de la casa: rentada o vendida ya no se muestra en una solicitud abierta */
  property_status: string | null;
  /** Asesor de la casa: tiene la prioridad en las visitas */
  house_broker_id: string | null;
  house_broker_name: string | null;
  preferred_date: string | null;
  preferred_time: string | null;
  payload: Record<string, unknown>;
  status: 'nuevo' | 'en_seguimiento' | 'cerrado';
  client_id: string | null;
  /** Broker asignado por administración (null = sin asignar) */
  broker_id: string | null;
  broker_name: string | null;
  response: string | null;
  responded_at: Date | null;
  responded_by_name: string | null;
  proposals: number;
  /** Citas vigentes (no canceladas ni rechazadas) agendadas desde la solicitud */
  appointments: number;
  created_at: Date;
}

export interface LeadAppointmentRow {
  id: string;
  code: string;
  scheduled_at: Date;
  status: string;
  /** Por confirmar: quién debe aceptar la fecha */
  awaiting: 'staff' | 'client';
  property_id: string;
  property_code: string;
  property_name: string;
  broker_name: string | null;
}

export interface ProposalRow {
  id: string;
  lead_id: string;
  note: string | null;
  created_at: Date;
  property_id: string;
  code: string;
  slug: string;
  name: string;
  zone: string;
  city: string | null;
  operation: 'renta' | 'venta';
  price: number;
  rec: number;
  banos: number;
  m2: number | null;
  pets_allowed: boolean;
  photo: string | null;
}

const SELECT = `
  SELECT l.id, l.folio, l.reason, l.name, l.email, l.phone, l.message, l.property_id, p.code AS property_code,
         p.name AS property_name, to_char(l.preferred_date, 'YYYY-MM-DD') AS preferred_date, l.preferred_time,
         l.payload, l.status, l.client_id, l.broker_id, ab.name AS broker_name, l.response, l.responded_at, rb.name AS responded_by_name,
         p.status::text AS property_status, p.broker_id AS house_broker_id, hb.name AS house_broker_name,
         (SELECT count(*)::int FROM lead_proposals lp JOIN properties h ON h.id = lp.property_id WHERE lp.lead_id = l.id AND h.status NOT IN ('rentada', 'vendida')) AS proposals,
         (SELECT count(*)::int FROM appointments a WHERE a.lead_id = l.id AND a.status NOT IN ('cancelada', 'rechazada')) AS appointments,
         l.created_at
    FROM leads l LEFT JOIN properties p ON p.id = l.property_id LEFT JOIN users rb ON rb.id = l.responded_by
    LEFT JOIN users ab ON ab.id = l.broker_id LEFT JOIN users hb ON hb.id = p.broker_id`;

export async function insert(
  db: Db,
  l: { folio: string; reason: LeadRow['reason']; name: string; email: string; phone: string | null; message: string | null; propertyId: string | null; preferredDate: string | null; preferredTime: string | null; payload: Record<string, unknown>; clientId: string | null; brokerId?: string | null },
): Promise<string> {
  const { rows } = await db.query<{ id: string }>(
    `INSERT INTO leads (folio, reason, name, email, phone, message, property_id, preferred_date, preferred_time, payload, client_id, broker_id)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING id`,
    [l.folio, l.reason, l.name, l.email, l.phone, l.message, l.propertyId, l.preferredDate, l.preferredTime, JSON.stringify(l.payload), l.clientId, l.brokerId ?? null],
  );
  return rows[0].id;
}

/** brokerId: solo las solicitudes que administración le asignó. unassigned: solo las que aún no tienen broker. */
export async function list(f: { brokerId?: string; unassigned?: boolean; status?: string; reason?: string; hidePoolNewerThan?: number; page: number; limit: number }): Promise<{ rows: LeadRow[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  if (f.brokerId) {
    params.push(f.brokerId);
    where.push(`l.broker_id = $${params.length}`);
  }
  if (f.unassigned) where.push('l.broker_id IS NULL');
  if (f.hidePoolNewerThan !== undefined) {
    // Administración espera su turno en el pool. Las visitas con prioridad sí se ven, en solo lectura
    params.push(f.hidePoolNewerThan);
    where.push(`NOT (l.broker_id IS NULL AND l.status <> 'cerrado' AND l.created_at > now() - make_interval(mins => $${params.length}::int)
      AND NOT (l.reason IN ('visita', 'comprar') AND p.broker_id IS NOT NULL AND p.status NOT IN ('rentada', 'vendida')))`);
  }
  if (f.status) {
    params.push(f.status);
    where.push(`l.status = $${params.length}`);
  }
  if (f.reason) {
    params.push(f.reason);
    where.push(`l.reason = $${params.length}`);
  }
  const w = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const total = await pool.query<{ n: string }>(`SELECT count(*) AS n FROM leads l LEFT JOIN properties p ON p.id = l.property_id ${w}`, params);
  const { rows } = await pool.query<LeadRow>(`${SELECT} ${w} ORDER BY l.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`, [
    ...params,
    f.limit,
    (f.page - 1) * f.limit,
  ]);
  return { rows, total: Number(total.rows[0].n) };
}

export async function findById(id: string): Promise<LeadRow | null> {
  const { rows } = await pool.query<LeadRow>(`${SELECT} WHERE l.id = $1`, [id]);
  return rows[0] ?? null;
}

/** Solicitudes de un cliente de la app: las ligadas a su expediente o hechas con su correo. */
export async function listOfClient(clientId: string | null, email: string): Promise<LeadRow[]> {
  const { rows } = await pool.query<LeadRow>(`${SELECT} WHERE (l.client_id = $1 OR lower(l.email) = lower($2)) ORDER BY l.created_at DESC LIMIT 50`, [clientId, email]);
  return rows;
}

/** Otras solicitudes de la misma persona (mismo correo), de la más reciente a la más antigua. */
export async function othersOf(email: string, exceptId: string): Promise<LeadRow[]> {
  const { rows } = await pool.query<LeadRow>(`${SELECT} WHERE lower(l.email) = lower($1) AND l.id <> $2 ORDER BY l.created_at DESC LIMIT 20`, [email, exceptId]);
  return rows;
}

/** Citas agendadas desde una solicitud (todas, también las canceladas, como historial). */
export async function appointmentsFor(leadId: string): Promise<LeadAppointmentRow[]> {
  const { rows } = await pool.query<LeadAppointmentRow>(
    `SELECT a.id, a.code, a.scheduled_at, a.status, a.awaiting, a.property_id, p.code AS property_code, p.name AS property_name, b.name AS broker_name
       FROM appointments a JOIN properties p ON p.id = a.property_id LEFT JOIN users b ON b.id = a.broker_id
      WHERE a.lead_id = $1 ORDER BY a.scheduled_at`,
    [leadId],
  );
  return rows;
}

/** Datos de contacto y motivo (el personal corrige lo que llegó mal escrito). */
export async function updateDetails(id: string, d: { name?: string; phone?: string | null; message?: string | null; reason?: LeadRow['reason'] }): Promise<void> {
  await pool.query(
    `UPDATE leads SET name = COALESCE($2, name),
            phone = CASE WHEN $3::boolean THEN $4 ELSE phone END,
            message = CASE WHEN $5::boolean THEN $6 ELSE message END,
            reason = COALESCE($7, reason)
      WHERE id = $1`,
    [id, d.name ?? null, d.phone !== undefined, d.phone ?? null, d.message !== undefined, d.message ?? null, d.reason ?? null],
  );
}

/** Borra la solicitud con sus propuestas y mensajes; las citas se conservan sin el vínculo. */
export async function remove(db: Db, id: string): Promise<void> {
  await db.query('UPDATE appointments SET lead_id = NULL WHERE lead_id = $1', [id]);
  await db.query('DELETE FROM leads WHERE id = $1', [id]);
}

/** Casas propuestas para una o varias solicitudes. */
export async function proposalsFor(leadIds: string[]): Promise<ProposalRow[]> {
  if (!leadIds.length) return [];
  const { rows } = await pool.query<ProposalRow>(
    `SELECT lp.id, lp.lead_id, lp.note, lp.created_at, p.id AS property_id, p.code, p.slug, p.name, p.zone, p.city, p.operation,
            p.price, p.rec, p.banos, p.m2, p.pets_allowed,
            (SELECT storage_key FROM property_photos ph WHERE ph.property_id = p.id ORDER BY position LIMIT 1) AS photo
       FROM lead_proposals lp JOIN properties p ON p.id = lp.property_id
      WHERE lp.lead_id = ANY($1::uuid[]) AND p.status NOT IN ('rentada', 'vendida') ORDER BY lp.created_at`,
    [leadIds],
  );
  return rows;
}
