import { pool } from '../config/database.js';
import { env } from '../config/env.js';

/* ==========================================================================
   Repositorio del dashboard: todo el SQL de GET /dashboard.
   El controlador decide qué perfil pide los datos; aquí solo se consulta la base (consultas parametrizadas).
   ========================================================================== */

/** Alcance del personal: null = administración (todas las casas); lista de ids = casas del broker */
export interface StaffScope {
  propertyIds: string[] | null;
  userId: string;
  /** Administración (sin ser propietario) no cuenta las solicitudes que aún esperan su turno */
  adminWaits: boolean;
}

const NO_CLIENT = '00000000-0000-0000-0000-000000000000';

/* ---------- Cliente ---------- */

export async function clientNextPayment(clientId: string | null) {
  const { rows } = await pool.query(
    `SELECT n.id, n.number, n.amount, to_char(n.due_date, 'YYYY-MM-DD') AS "dueDate", n.status
       FROM promissory_notes n JOIN contracts ct ON ct.id = n.contract_id
      WHERE ct.client_id = $1 AND n.status IN ('pending', 'overdue') ORDER BY n.due_date LIMIT 1`,
    [clientId ?? NO_CLIENT],
  );
  return rows[0] ?? null;
}

export async function clientNextAppointment(clientId: string | null) {
  const { rows } = await pool.query(
    `SELECT a.id, a.code, p.name AS "propertyName", a.scheduled_at AS "scheduledAt", a.status
       FROM appointments a JOIN properties p ON p.id = a.property_id
      WHERE a.client_id = $1 AND a.status IN ('por-confirmar', 'confirmada') AND a.scheduled_at > now() ORDER BY a.scheduled_at LIMIT 1`,
    [clientId ?? NO_CLIENT],
  );
  return rows[0] ?? null;
}

export async function clientLatestOpenReport(clientId: string | null) {
  const { rows } = await pool.query(
    `SELECT r.id, r.title, r.status, r.created_at AS "createdAt", count(*) OVER () AS total
       FROM maintenance_reports r
      WHERE r.property_id IN (SELECT property_id FROM contracts WHERE client_id = $1 AND status = 'active')
        AND r.status NOT IN ('resolved', 'cancelled')
      ORDER BY r.created_at DESC LIMIT 1`,
    [clientId ?? NO_CLIENT],
  );
  return rows[0] as { id: string; title: string; status: string; createdAt: Date; total: string } | undefined;
}

export async function clientRentedProperty(clientId: string | null) {
  const { rows } = await pool.query(
    `SELECT p.id, p.name, p.zone FROM contracts ct JOIN properties p ON p.id = ct.property_id WHERE ct.client_id = $1 AND ct.status = 'active' LIMIT 1`,
    [clientId ?? NO_CLIENT],
  );
  return rows[0] ?? null;
}

export async function unreadNotifications(userId: string) {
  const { rows } = await pool.query<{ n: string }>('SELECT count(*) AS n FROM notifications WHERE user_id = $1 AND NOT read', [userId]);
  return Number(rows[0].n);
}

/* ---------- Personal ---------- */

/** Conteos del personal. Broker: sus citas y sus casas; administración: todo. */
export async function staffCounts(s: StaffScope) {
  const p = s.propertyIds ? [s.propertyIds] : [];
  const mine = s.propertyIds ? [s.userId] : [];
  const inScope = (col: string) => (s.propertyIds ? `${col} = ANY($1::uuid[])` : 'TRUE');
  const myAppts = () => (s.propertyIds ? 'broker_id = $1' : 'TRUE');
  const oneMine = async (sql: string) => Number((await pool.query<{ n: string }>(sql, mine)).rows[0].n);
  const one = async (sql: string) => Number((await pool.query<{ n: string }>(sql, p)).rows[0].n);
  // LEAD_ADMIN_WAIT_MINUTES es un número validado en env.ts (no viene del usuario)
  const adminWaits = s.adminWaits
    ? ` AND NOT (broker_id IS NULL AND created_at > now() - make_interval(mins => ${env.LEAD_ADMIN_WAIT_MINUTES})
        AND NOT (reason IN ('visita', 'comprar') AND EXISTS (SELECT 1 FROM properties h WHERE h.id = leads.property_id AND h.broker_id IS NOT NULL AND h.status NOT IN ('rentada', 'vendida'))))`
    : '';
  return {
    appointmentsToConfirm: await oneMine(`SELECT count(*) AS n FROM appointments WHERE status = 'por-confirmar' AND scheduled_at > now() AND ${myAppts()}`),
    appointmentsToday: await oneMine(`SELECT count(*) AS n FROM appointments WHERE status = 'confirmada' AND (scheduled_at AT TIME ZONE 'America/Cancun')::date = (now() AT TIME ZONE 'America/Cancun')::date AND ${myAppts()}`),
    overdueNotes: await one(`SELECT count(*) AS n FROM promissory_notes n JOIN contracts ct ON ct.id = n.contract_id WHERE n.status = 'overdue' AND ${inScope('ct.property_id')}`),
    upcomingNotes: await one(`SELECT count(*) AS n FROM promissory_notes n JOIN contracts ct ON ct.id = n.contract_id WHERE n.status = 'pending' AND n.due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 7 AND ${inScope('ct.property_id')}`),
    newReports: await one(`SELECT count(*) AS n FROM maintenance_reports WHERE status = 'reported' AND ${inScope('property_id')}`),
    openReports: await one(`SELECT count(*) AS n FROM maintenance_reports WHERE status NOT IN ('resolved', 'cancelled') AND ${inScope('property_id')}`),
    overdueReceipts: await one(`SELECT count(*) AS n FROM receipts WHERE status = 'overdue' AND ${inScope('property_id')}`),
    pendingExpenses: await one(`SELECT count(*) AS n FROM expenses WHERE status = 'pending' AND ${inScope('property_id')}`),
    upcomingMaintenance: await one(`SELECT count(*) AS n FROM expenses WHERE next_maintenance_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 14 AND ${inScope('property_id')}`),
    newLeads: await one(`SELECT count(*) AS n FROM leads WHERE status = 'nuevo' AND (property_id IS NULL OR ${inScope('property_id')})${adminWaits}`),
  };
}

/** Las 5 citas por confirmar más próximas */
export async function staffPendingAppointments(s: StaffScope) {
  const { rows } = await pool.query(
    `SELECT a.id, a.code, c.name AS "clientName", p.name AS "propertyName", a.scheduled_at AS "scheduledAt"
       FROM appointments a JOIN clients c ON c.id = a.client_id JOIN properties p ON p.id = a.property_id
      WHERE a.status = 'por-confirmar' AND a.scheduled_at > now() AND ${s.propertyIds ? 'a.broker_id = $1' : 'TRUE'} ORDER BY a.scheduled_at LIMIT 5`,
    s.propertyIds ? [s.userId] : [],
  );
  return rows;
}

/** Los 5 pagarés vencidos más antiguos */
export async function staffOverdueNotes(s: StaffScope) {
  const { rows } = await pool.query(
    `SELECT n.id, n.number, n.amount, to_char(n.due_date, 'YYYY-MM-DD') AS "dueDate", c.name AS "clientName", pr.name AS "propertyName", pr.id AS "propertyId"
       FROM promissory_notes n JOIN contracts ct ON ct.id = n.contract_id JOIN clients c ON c.id = ct.client_id JOIN properties pr ON pr.id = ct.property_id
      WHERE n.status = 'overdue' AND ${s.propertyIds ? 'ct.property_id = ANY($1::uuid[])' : 'TRUE'} ORDER BY n.due_date LIMIT 5`,
    s.propertyIds ? [s.propertyIds] : [],
  );
  return rows;
}

/** Los 5 reportes de mantenimiento abiertos más recientes */
export async function staffOpenReports(s: StaffScope) {
  const { rows } = await pool.query(
    `SELECT r.id, r.title, r.priority, r.status, p.name AS "propertyName", p.id AS "propertyId", r.created_at AS "createdAt"
       FROM maintenance_reports r JOIN properties p ON p.id = r.property_id
      WHERE r.status NOT IN ('resolved', 'cancelled') AND ${s.propertyIds ? 'r.property_id = ANY($1::uuid[])' : 'TRUE'} ORDER BY r.created_at DESC LIMIT 5`,
    s.propertyIds ? [s.propertyIds] : [],
  );
  return rows;
}
