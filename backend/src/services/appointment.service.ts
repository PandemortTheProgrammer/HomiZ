import { pool, withTransaction, type Db } from '../config/database.js';
import { env } from '../config/env.js';
import { AppError } from '../middlewares/error-handler.js';
import type { AuthUser } from '../middlewares/authenticate.js';
import { insertActivity } from '../models/activity.model.js';
import * as Leads from '../models/lead.model.js';
import { assertPropertyAccess, checkPropertyAccess, isAdmin, isBroker } from './access.service.js';
import { assertMayAct } from './lead-window.service.js';
import { nextCode } from './codes.service.js';
import { notify, staffWithPermission, userOfClient } from './notification.service.js';

export type ApptStatus = 'por-confirmar' | 'confirmada' | 'rechazada' | 'cancelada' | 'realizada';

export interface ApptRow {
  id: string;
  code: string;
  property_id: string;
  property_code: string;
  property_name: string;
  property_zone: string;
  property_address: string;
  property_lat: string | null;
  property_lng: string | null;
  photo_key: string | null;
  client_id: string;
  client_code: string;
  client_kind: string;
  client_name: string;
  client_email: string | null;
  client_phone: string | null;
  client_user_id: string | null;
  broker_id: string | null;
  broker_name: string | null;
  broker_phone: string | null;
  broker_email: string | null;
  scheduled_at: Date;
  duration_min: number;
  kind: string;
  status: ApptStatus;
  /** De quién se espera la confirmación de la fecha: el personal o el cliente (la otra parte de quien la propuso) */
  awaiting: 'staff' | 'client';
  note: string | null;
  reason: string | null;
  proposed_at: Date | null;
  confirmed_by: string | null;
  created_at: Date;
  lead_id: string | null;
  /** Solicitud de la que salió la cita o, si no salió de una, la más reciente de la persona */
  form_id: string | null;
  lead_folio: string | null;
  lead_payload: Record<string, unknown> | null;
  lead_message: string | null;
  lead_reason: string | null;
  lead_status: string | null;
  lead_name: string | null;
  lead_email: string | null;
  lead_phone: string | null;
  lead_property_code: string | null;
  lead_property_name: string | null;
  lead_preferred_date: string | null;
  lead_preferred_time: string | null;
  lead_created_at: Date | null;
  lead_broker_id: string | null;
  client_broker_id: string | null;
}

const SELECT = `
  SELECT a.id, a.code, a.property_id, p.code AS property_code, p.name AS property_name, p.zone AS property_zone,
         p.address AS property_address, p.lat AS property_lat, p.lng AS property_lng,
         (SELECT storage_key FROM property_photos ph WHERE ph.property_id = p.id ORDER BY position LIMIT 1) AS photo_key,
         a.client_id, c.code AS client_code, c.kind AS client_kind, c.name AS client_name, COALESCE(c.email, cu.email) AS client_email, COALESCE(c.phone, cu.phone) AS client_phone, c.user_id AS client_user_id,
         a.broker_id, b.name AS broker_name, b.phone AS broker_phone, b.email AS broker_email,
         a.scheduled_at, a.duration_min, a.kind, a.status, a.awaiting, a.note, a.reason, a.proposed_at, a.confirmed_by, a.created_at,
         a.lead_id, l.id AS form_id, l.folio AS lead_folio, l.payload AS lead_payload, l.message AS lead_message,
         l.reason AS lead_reason, l.status AS lead_status, l.name AS lead_name, l.email AS lead_email, l.phone AS lead_phone,
         lp.code AS lead_property_code, lp.name AS lead_property_name, to_char(l.preferred_date, 'YYYY-MM-DD') AS lead_preferred_date,
         l.preferred_time AS lead_preferred_time, l.created_at AS lead_created_at, l.broker_id AS lead_broker_id, c.broker_id AS client_broker_id
    FROM appointments a
    JOIN properties p ON p.id = a.property_id
    JOIN clients c ON c.id = a.client_id
    LEFT JOIN users cu ON cu.id = c.user_id
    LEFT JOIN users b ON b.id = a.broker_id
    -- El formulario que llenó: el de la solicitud de la cita o, si la pidió desde la app, su solicitud más reciente
    LEFT JOIN LATERAL (
      SELECT * FROM leads x
       WHERE x.id = a.lead_id OR (a.lead_id IS NULL AND (x.client_id = a.client_id OR lower(x.email) = lower(c.email)))
       ORDER BY (x.id = a.lead_id) DESC NULLS LAST, x.created_at DESC LIMIT 1
    ) l ON TRUE
    LEFT JOIN properties lp ON lp.id = l.property_id`;

const LEAD_STATUS: Record<string, string> = { nuevo: 'Recibida', en_seguimiento: 'En seguimiento', cerrado: 'Cerrada' };

/** El formulario que llenó la persona (lo ven el personal y la propia persona en su cita). */
function form(a: ApptRow) {
  if (!a.form_id) return null;
  return {
    id: a.form_id, folio: a.lead_folio, reason: a.lead_reason, status: a.lead_status, statusLabel: LEAD_STATUS[a.lead_status ?? ''] ?? '',
    name: a.lead_name, email: a.lead_email, phone: a.lead_phone, payload: a.lead_payload ?? {}, message: a.lead_message,
    property: a.lead_property_code ? { code: a.lead_property_code, name: a.lead_property_name } : null,
    preferredDate: a.lead_preferred_date, preferredTime: a.lead_preferred_time, createdAt: a.lead_created_at,
    // false = no salió de esa solicitud: es la más reciente de la persona
    linked: a.lead_id === a.form_id,
  };
}

/** La dirección y el punto exactos se comparten con el cliente cuando la cita está confirmada (o la visita ya se hizo). */
const exactFor = (a: ApptRow, user: AuthUser) => user.type === 'staff' || a.status === 'confirmada' || a.status === 'realizada';

export function present(a: ApptRow, user: AuthUser) {
  const exact = exactFor(a, user);
  const base = {
    id: a.id,
    code: a.code,
    property: {
      id: a.property_id, code: a.property_code, name: a.property_name, zone: a.property_zone, photo: a.photo_key,
      address: exact ? a.property_address : '',
      lat: exact && a.property_lat != null ? Number(a.property_lat) : null,
      lng: exact && a.property_lng != null ? Number(a.property_lng) : null,
      exactLocation: exact,
    },
    scheduledAt: a.scheduled_at,
    durationMin: a.duration_min,
    kind: a.kind,
    status: a.status,
    // Acuerdo de la fecha: quien la propuso espera a que la otra parte la acepte
    awaiting: a.status === 'por-confirmar' ? a.awaiting : null,
    canAccept: a.status === 'por-confirmar' && a.awaiting === (user.type === 'staff' ? 'staff' : 'client'),
    note: a.note,
    reason: a.reason,
    createdAt: a.created_at,
    // Lo que la persona llenó en su formulario (el de la cita o su solicitud más reciente)
    lead: form(a),
    // Contacto mutuo: el cliente ve a su asesor (nombre, teléfono y correo) y el asesor ve al cliente
    broker: a.broker_id ? { id: a.broker_id, name: a.broker_name, phone: a.broker_phone, email: a.broker_email } : null,
  };
  if (user.type !== 'staff') return base;
  return {
    ...base,
    client: { id: a.client_id, code: a.client_code, kind: a.client_kind, name: a.client_name, email: a.client_email, phone: a.client_phone },
    confirmedBy: a.confirmed_by,
  };
}

/** Citas visibles: cliente = las suyas; broker = las que atiende; administrador = todas. */
export async function list(user: AuthUser, f: { status?: string[]; from?: string; to?: string; propertyId?: string; clientId?: string; page: number; limit: number }) {
  const params: unknown[] = [];
  const where: string[] = [];
  if (user.type === 'client') where.push(`a.client_id = $${params.push(user.clientId ?? '00000000-0000-0000-0000-000000000000')}`);
  else if (!isAdmin(user)) {
    // También las de las personas que le asignaron, aunque la casa sea de otro broker
    const me = params.push(user.id);
    where.push(`(a.broker_id = $${me} OR EXISTS (SELECT 1 FROM leads x WHERE x.client_id = a.client_id AND x.broker_id = $${me}))`);
  }
  if (f.status?.length) where.push(`a.status::text = ANY($${params.push(f.status)}::text[])`);
  if (f.from) where.push(`a.scheduled_at >= $${params.push(f.from)}::date`);
  if (f.to) where.push(`a.scheduled_at < ($${params.push(f.to)}::date + 1)`);
  if (f.propertyId) where.push(`a.property_id = $${params.push(f.propertyId)}`);
  if (f.clientId && user.type === 'staff') where.push(`a.client_id = $${params.push(f.clientId)}`);
  const w = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const total = await pool.query<{ n: string }>(`SELECT count(*) AS n FROM appointments a ${w}`, params);
  const { rows } = await pool.query<ApptRow>(`${SELECT} ${w} ORDER BY a.scheduled_at LIMIT $${params.length + 1} OFFSET $${params.length + 2}`, [...params, f.limit, (f.page - 1) * f.limit]);
  return { rows, total: Number(total.rows[0].n) };
}

export async function findById(id: string): Promise<ApptRow | null> {
  const { rows } = await pool.query<ApptRow>(`${SELECT} WHERE a.id = $1`, [id]);
  return rows[0] ?? null;
}

/** Carga la cita verificando que quien la pide puede verla. */
export async function loadFor(user: AuthUser, id: string): Promise<ApptRow> {
  const a = await findById(id);
  const notFound = new AppError(404, 'NOT_FOUND', 'La cita no existe.');
  if (!a) throw notFound;
  if (user.type === 'client') {
    if (a.client_id !== user.clientId) throw notFound;
  } else if (!isAdmin(user) && ![a.broker_id, a.lead_broker_id, a.client_broker_id].includes(user.id) && (await checkPropertyAccess(user, a.property_id)) !== 'ok') {
    throw new AppError(403, 'NOT_OWNER', 'Esta cita no está asignada a ti.');
  }
  return a;
}

/** «jueves, 29 de octubre, 16:30 h» (24 horas) */
const when = (d: Date) =>
  d.toLocaleString('es-MX', { timeZone: 'America/Cancun', weekday: 'long', day: 'numeric', month: 'long', hour: 'numeric', minute: '2-digit', hourCycle: 'h12' });

function conflict(err: unknown): never {
  if ((err as { code?: string }).code === '23505') throw new AppError(409, 'SCHEDULE_CONFLICT', 'Ese horario ya está ocupado. Elige otro.');
  throw err;
}

/** Horario de visitas de la inmobiliaria: de 7:00 a.m. a 11:00 p.m. (la última empieza a las 10:45 p.m. y dura 15 minutos). */
export const VISIT_HOURS_TEXT = 'Las visitas son de 7:00 a.m. a 11:00 p.m.';
export const visitTimeOk = (hhmm: string) => hhmm >= '07:00' && hhmm <= '22:45';

function assertVisitHour(at: string | Date): void {
  const hhmm = new Date(at).toLocaleTimeString('en-GB', { timeZone: env.TZ_APP, hour: '2-digit', minute: '2-digit', hourCycle: 'h23' });
  if (!visitTimeOk(hhmm)) throw new AppError(400, 'VALIDATION_ERROR', VISIT_HOURS_TEXT, { scheduledAt: [VISIT_HOURS_TEXT] });
}

/** Rentada, vendida o con contrato vigente: ya tiene inquilino o dueño y no recibe visitas (cliente, broker ni administración). */
export async function assertVisitable(db: Db, propertyId: string): Promise<void> {
  const { rows: [h] } = await db.query<{ status: string; rented: boolean }>(
    `SELECT p.status::text AS status, EXISTS (SELECT 1 FROM contracts c WHERE c.property_id = p.id AND c.status = 'active') AS rented
       FROM properties p WHERE p.id = $1`,
    [propertyId],
  );
  if (h?.status === 'vendida') throw new AppError(409, 'NOT_AVAILABLE', 'Esta casa ya se vendió: no se pueden agendar visitas.');
  if (h?.status === 'rentada' || h?.rented) throw new AppError(409, 'NOT_AVAILABLE', 'Esta casa está rentada y tiene inquilino: no se pueden agendar visitas.');
}

/** La casa se rentó o se vendió: sus citas por venir se cancelan y a cada persona le llega el aviso. */
export async function cancelVisitsOfHouse(db: Db, propertyId: string, reason: string): Promise<void> {
  const { rows } = await db.query<{ id: string; code: string; client_id: string }>(
    `UPDATE appointments SET status = 'cancelada', reason = $2
      WHERE property_id = $1 AND status IN ('por-confirmar', 'confirmada') AND scheduled_at > now()
      RETURNING id, code, client_id`,
    [propertyId, reason],
  );
  for (const a of rows) {
    await notify([await userOfClient(a.client_id, db)], { type: 'appointment_cancelled', title: 'Cita cancelada', message: `Cancelamos tu cita ${a.code}: ${reason}`, entity: 'appointment', entityId: a.id }, db);
  }
}

export interface PlacedVisit { id: string; code: string; moved: boolean; previous: { propertyId: string; propertyName: string; brokerId: string | null } | null }

/**
 * Una cita vigente por persona (por confirmar o confirmada, y aún por venir), sea prospecto o inquilino.
 * Si ya tiene una, se cambia esa misma cita a la nueva casa, fecha y hora (vuelve a «por confirmar»);
 * si no, se crea. Se bloquea por persona para que dos pedidos al mismo tiempo no creen dos citas.
 */
export async function placeVisit(
  db: Db,
  d: { clientId: string; propertyId: string; brokerId: string | null; scheduledAt: string | Date; note?: string | null; leadId?: string | null; awaiting?: 'staff' | 'client' },
): Promise<PlacedVisit> {
  // Quien propone la fecha espera a la otra parte: lo pide el cliente → confirma el personal, y al revés
  const awaiting = d.awaiting ?? 'staff';
  assertVisitHour(d.scheduledAt);
  await assertVisitable(db, d.propertyId);
  await db.query('SELECT pg_advisory_xact_lock(hashtext($1))', ['cita:' + d.clientId]);
  const { rows: [active] } = await db.query<{ id: string; code: string; property_id: string; property_name: string; broker_id: string | null }>(
    `SELECT a.id, a.code, a.property_id, p.name AS property_name, a.broker_id FROM appointments a JOIN properties p ON p.id = a.property_id
      WHERE a.client_id = $1 AND a.status IN ('por-confirmar', 'confirmada') AND a.scheduled_at > now()
      ORDER BY a.scheduled_at DESC LIMIT 1 FOR UPDATE OF a`,
    [d.clientId],
  );
  if (active) {
    await db.query(
      `UPDATE appointments SET property_id = $2, broker_id = $3, scheduled_at = $4, proposed_at = $4, status = 'por-confirmar',
              confirmed_by = NULL, note = COALESCE($5, note), lead_id = COALESCE($6, lead_id), duration_min = 15, awaiting = $7
        WHERE id = $1`,
      [active.id, d.propertyId, d.brokerId, d.scheduledAt, d.note ?? null, d.leadId ?? null, awaiting],
    );
    return { id: active.id, code: active.code, moved: true, previous: { propertyId: active.property_id, propertyName: active.property_name, brokerId: active.broker_id } };
  }
  const code = await nextCode(db, 'appointments', 'CIT');
  const { rows } = await db.query<{ id: string }>(
    `INSERT INTO appointments (code, property_id, client_id, broker_id, scheduled_at, status, note, lead_id, awaiting)
     VALUES ($1, $2, $3, $4, $5, 'por-confirmar', $6, $7, $8) RETURNING id`,
    [code, d.propertyId, d.clientId, d.brokerId, d.scheduledAt, d.note ?? null, d.leadId ?? null, awaiting],
  );
  return { id: rows[0].id, code, moved: false, previous: null };
}

/** El cliente pide visita a una casa del catálogo; el personal puede agendar por un cliente. */
export async function create(user: AuthUser, d: { propertyId: string; clientId?: string; scheduledAt: string; note?: string | null; leadId?: string | null }): Promise<string> {
  return (await createOrMove(user, d)).id;
}

/** Igual que create, pero dice si se cambió la cita vigente de la persona (moved) en lugar de crear otra. */
/**
 * [assigned]: la solicitud de la que sale la cita ya tiene broker asignado por administración; la cita queda con ese broker
 * (aunque la casa sea de otro) y ese broker puede agendarla. undefined = el broker de la casa.
 */
export async function createOrMove(
  user: AuthUser,
  d: { propertyId: string; clientId?: string; scheduledAt: string; note?: string | null; leadId?: string | null; assigned?: string | null },
): Promise<PlacedVisit> {
  if (new Date(d.scheduledAt).getTime() <= Date.now()) throw new AppError(400, 'VALIDATION_ERROR', 'Elige una fecha y hora futuras.', { scheduledAt: ['Elige una fecha y hora futuras.'] });
  const prop = await pool.query<{ name: string; broker_id: string | null; status: string; visibility: string; active: boolean }>(
    'SELECT name, broker_id, status, visibility, active FROM properties WHERE id = $1',
    [d.propertyId],
  );
  const p = prop.rows[0];
  if (!p || !p.active) throw new AppError(404, 'NOT_FOUND', 'La propiedad no existe.');

  let clientId: string;
  if (user.type === 'client') {
    if (!user.clientId) throw new AppError(409, 'NO_CLIENT_PROFILE', 'Tu cuenta aún no tiene expediente. Comunícate con la inmobiliaria.');
    const inCatalog = p.visibility === 'publicada' && ['disponible', 'reservada'].includes(p.status);
    if (!inCatalog && (await checkPropertyAccess(user, d.propertyId)) !== 'ok') throw new AppError(409, 'NOT_AVAILABLE', 'Esta casa no está disponible para visitas.');
    clientId = user.clientId;
  } else {
    if (!(d.assigned && d.assigned === user.id)) await assertPropertyAccess(user, d.propertyId);
    if (!d.clientId) throw new AppError(400, 'VALIDATION_ERROR', 'Indica el cliente.', { clientId: ['Indica el cliente.'] });
    clientId = d.clientId;
  }

  try {
    return await withTransaction(async (db) => {
      // Si a la persona ya le asignaron un broker, la cita es con él aunque la casa sea de otro
      const assigned = user.type === 'client' ? (await db.query<{ broker_id: string | null }>('SELECT broker_id FROM clients WHERE id = $1', [clientId])).rows[0]?.broker_id : null;
      const brokerId = d.assigned === undefined ? (assigned ?? p.broker_id) : d.assigned;
      // La propone el cliente → la confirma el personal; la propone el personal → la acepta el cliente
      const awaiting = user.type === 'client' ? 'staff' : 'client';
      const placed = await placeVisit(db, { clientId, propertyId: d.propertyId, brokerId, scheduledAt: d.scheduledAt, note: d.note, leadId: d.leadId, awaiting });
      const id = placed.id;
      const whenText = when(new Date(d.scheduledAt));
      await insertActivity({
        userId: user.id, propertyId: d.propertyId, entity: 'appointment', entityId: id, action: placed.moved ? 'reschedule' : 'request',
        description: placed.moved
          ? `${user.name} cambió la cita ${placed.code} de ${placed.previous!.propertyName} a ${p.name} para el ${whenText}.`
          : `${user.name} solicitó una visita a ${p.name} para el ${whenText}.`,
      }, db);
      // Las citas que pide el cliente le llegan a su broker y a administración (que también las ve en el panel)
      const targets = user.type === 'client' ? [brokerId, ...(await staffWithPermission('properties.reassign', db))] : [await userOfClient(clientId, db)];
      await notify(targets, user.type === 'client'
        ? {
            type: placed.moved ? 'appointment_rescheduled' : 'appointment_requested',
            title: placed.moved ? 'Cita cambiada' : 'Cita solicitada',
            message: placed.moved
              ? `${user.name} cambió la cita ${placed.code} a ${p.name}, el ${whenText}. Confírmala o propón otra fecha.`
              : `${user.name} pide visitar ${p.name} el ${whenText}. Confírmala o propón otra fecha.`,
            entity: 'appointment', entityId: id,
          }
        : {
            type: placed.moved ? 'appointment_rescheduled' : 'appointment_requested',
            title: placed.moved ? 'Nueva fecha para tu visita' : 'Te proponemos una visita',
            message: `${placed.moved ? `Tu cita ${placed.code} ahora es para` : 'Visita a'} ${p.name} el ${whenText}. Acéptala en la app o propón otra fecha.`,
            entity: 'appointment', entityId: id,
          }, db);
      // Si la cita era de otra casa con otro broker, a ese broker se le avisa que ya no la atiende
      const old = placed.previous?.brokerId;
      if (old && old !== brokerId && old !== user.id) {
        await notify([old], { type: 'appointment_cancelled', title: 'Cita reasignada', message: `La cita ${placed.code} se cambió a ${p.name}; ya no es en ${placed.previous!.propertyName}.`, entity: 'appointment', entityId: id }, db);
      }
      return placed;
    });
  } catch (err) {
    conflict(err);
  }
}

type Action = 'confirm' | 'reject' | 'cancel' | 'complete' | 'reschedule';

const RULES: Record<Action, { from: ApptStatus[]; to: ApptStatus; staffOnly: boolean; verb: string; type: string; title: string }> = {
  // Confirmar = aceptar la fecha: la parte a la que se espera (personal o cliente), ver `awaiting`
  confirm: { from: ['por-confirmar'], to: 'confirmada', staffOnly: false, verb: 'confirmó', type: 'appointment_confirmed', title: 'Cita confirmada' },
  reject: { from: ['por-confirmar'], to: 'rechazada', staffOnly: true, verb: 'rechazó', type: 'appointment_rejected', title: 'Cita rechazada' },
  cancel: { from: ['por-confirmar', 'confirmada'], to: 'cancelada', staffOnly: false, verb: 'canceló', type: 'appointment_cancelled', title: 'Cita cancelada' },
  complete: { from: ['confirmada'], to: 'realizada', staffOnly: true, verb: 'marcó como realizada', type: 'appointment_completed', title: 'Visita realizada' },
  reschedule: { from: ['por-confirmar', 'confirmada'], to: 'por-confirmar', staffOnly: false, verb: 'reprogramó', type: 'appointment_rescheduled', title: 'Cita reprogramada' },
};

/** Cambios de estado. Avisa a la otra parte: si actúa el cliente, al broker; si actúa el personal, al cliente. */
export async function transition(user: AuthUser, id: string, action: Action, d: { reason?: string; scheduledAt?: string } = {}): Promise<void> {
  const rule = RULES[action];
  const a = await loadFor(user, id);
  if (rule.staffOnly && user.type !== 'staff') throw new AppError(403, 'FORBIDDEN', 'No tienes permiso para realizar esta acción.');
  if (user.type === 'staff' && !user.permissions.has('appointments.manage')) throw new AppError(403, 'FORBIDDEN', 'No tienes permiso para realizar esta acción.', { missingPermissions: ['appointments.manage'] });
  // Una cita de una solicitud con prioridad la atiende solo quien tiene la prioridad
  const lead = user.type === 'staff' && a.lead_id ? await Leads.findById(a.lead_id) : null;
  if (lead) assertMayAct(user, lead);
  if (!rule.from.includes(a.status)) {
    throw new AppError(409, 'INVALID_STATUS', `No se puede ${action === 'complete' ? 'marcar como realizada' : rule.verb.replace(/ó$/, 'ar')} una cita ${a.status.replace('-', ' ')}.`);
  }
  if (action === 'confirm') {
    // La fecha la acuerdan ambos: quien la propuso no la confirma; la acepta la otra parte
    if (user.type === 'client' && a.awaiting !== 'client') throw new AppError(409, 'WAITING_STAFF', 'Tu asesor aún no confirma esta fecha. Te avisaremos en cuanto la confirme.');
    if (user.type === 'staff' && a.awaiting === 'client') throw new AppError(409, 'WAITING_CLIENT', `Esperamos que ${a.client_name} acepte esta fecha. Si necesitas otra, reprográmala.`);
  }
  if (action === 'reject' && !d.reason) throw new AppError(400, 'VALIDATION_ERROR', 'Indica el motivo del rechazo.', { reason: ['Indica el motivo del rechazo.'] });
  if (action === 'confirm' || action === 'reschedule') await assertVisitable(pool, a.property_id);
  if (action === 'reschedule') {
    if (!d.scheduledAt || new Date(d.scheduledAt).getTime() <= Date.now()) throw new AppError(400, 'VALIDATION_ERROR', 'Elige una fecha y hora futuras.', { scheduledAt: ['Elige una fecha y hora futuras.'] });
    assertVisitHour(d.scheduledAt);
  }

  try {
    await withTransaction(async (db) => {
      const confirmedBy = action === 'confirm'
        ? `Confirmada por ${user.name.split(' ')[0]} · ${new Date().toLocaleString('es-MX', { timeZone: 'America/Cancun', day: 'numeric', month: 'short', hour: 'numeric', minute: '2-digit', hourCycle: 'h12' })}.`
        : null;
      await db.query(
        `UPDATE appointments
            SET status = $2::appointment_status, reason = COALESCE($3::text, reason),
                scheduled_at = COALESCE($4::timestamptz, scheduled_at),
                proposed_at = CASE WHEN $4::timestamptz IS NOT NULL THEN $4::timestamptz ELSE proposed_at END,
                confirmed_by = CASE WHEN $2::text = 'confirmada' THEN $5::text WHEN $2::text = 'por-confirmar' THEN NULL ELSE confirmed_by END,
                awaiting = COALESCE($6, awaiting)
          WHERE id = $1`,
        // Al reprogramar, quien propone la nueva fecha espera a que la otra parte la acepte
        [id, rule.to, d.reason ?? null, action === 'reschedule' ? d.scheduledAt : null, confirmedBy, action === 'reschedule' ? (user.type === 'client' ? 'staff' : 'client') : null],
      );
      // Atender la cita es atender la solicitud: se queda con su seguimiento
      if (lead && !lead.broker_id && isBroker(user) && (action === 'confirm' || action === 'reschedule')) {
        const { rowCount } = await db.query('UPDATE leads SET broker_id = $2 WHERE id = $1 AND broker_id IS NULL', [lead.id, user.id]);
        if (rowCount && lead.client_id) await db.query('UPDATE clients SET broker_id = $2 WHERE id = $1 AND broker_id IS NULL', [lead.client_id, user.id]);
      }
      const newWhen = when(action === 'reschedule' ? new Date(d.scheduledAt!) : a.scheduled_at);
      await insertActivity({
        userId: user.id, propertyId: a.property_id, entity: 'appointment', entityId: id, action,
        description: `${user.name} ${rule.verb} la visita de ${a.client_name} a ${a.property_name} (${newWhen})${d.reason ? `: ${d.reason}` : ''}.`,
        oldValues: { status: a.status, scheduledAt: a.scheduled_at }, newValues: { status: rule.to, scheduledAt: d.scheduledAt ?? a.scheduled_at },
      }, db);
      // La otra parte: si actúa el cliente, su broker (o administración si aún no tiene); si actúa el personal, el cliente
      const targets = user.type === 'client'
        ? (a.broker_id ? [a.broker_id] : await staffWithPermission('properties.reassign', db))
        : [a.client_user_id];
      const byClient = user.type === 'client';
      const msg = {
        confirm: byClient ? `${a.client_name} aceptó la visita a ${a.property_name} el ${newWhen}.` : `Tu visita a ${a.property_name} es el ${newWhen}.`,
        reject: `No pudimos confirmar tu visita a ${a.property_name}${d.reason ? `: ${d.reason}` : '.'}`,
        cancel: byClient ? `${a.client_name} canceló la visita a ${a.property_name} del ${newWhen}${d.reason ? `: ${d.reason}` : '.'}` : `La visita a ${a.property_name} del ${newWhen} se canceló${d.reason ? `: ${d.reason}` : '.'}`,
        complete: `Gracias por visitar ${a.property_name}.`,
        reschedule: byClient
          ? `${a.client_name} propone cambiar la visita a ${a.property_name} al ${newWhen}. Confírmala o propón otra fecha.`
          : `Tu asesor propone cambiar tu visita a ${a.property_name} al ${newWhen}. Acéptala en la app o propón otra fecha.`,
      }[action];
      const title = action === 'reschedule' ? (byClient ? 'Nueva fecha propuesta' : 'Nueva fecha para tu visita') : rule.title;
      await notify(targets, { type: rule.type, title, message: msg, entity: 'appointment', entityId: id }, db);
    });
  } catch (err) {
    conflict(err);
  }
}

/* ---------- Chat de la cita ---------- */
export async function messages(user: AuthUser, id: string) {
  await loadFor(user, id);
  const { rows } = await pool.query<{ id: string; sender_id: string; sender_name: string; sender_type: string; body: string; created_at: Date }>(
    `SELECT m.id, m.sender_id, u.name AS sender_name, u.type AS sender_type, m.body, m.created_at
       FROM appointment_messages m JOIN users u ON u.id = m.sender_id
      WHERE m.appointment_id = $1 ORDER BY m.created_at`,
    [id],
  );
  // Al cliente el personal se le presenta como «Zugar» (no ve quién es el broker).
  return rows.map((m) => ({
    id: m.id,
    mine: m.sender_id === user.id,
    sender: m.sender_name, // contacto mutuo: el cliente ve el nombre de su asesor
    fromStaff: m.sender_type === 'staff',
    body: m.body,
    createdAt: m.created_at,
  }));
}

export async function sendMessage(user: AuthUser, id: string, body: string): Promise<void> {
  const a = await loadFor(user, id);
  if (a.status === 'cancelada' || a.status === 'rechazada') throw new AppError(409, 'INVALID_STATUS', 'Esta cita ya no admite mensajes.');
  await pool.query('INSERT INTO appointment_messages (appointment_id, sender_id, body) VALUES ($1, $2, $3)', [id, user.id, body]);
  const targets = user.type === 'client' ? (a.broker_id ? [a.broker_id] : await staffWithPermission('properties.reassign')) : [a.client_user_id];
  await notify(targets, {
    type: 'appointment_message', title: user.type === 'client' ? `Mensaje de ${a.client_name}` : `Mensaje de ${user.name.split(' ')[0]} (Zugar)`,
    message: body.length > 120 ? `${body.slice(0, 117)}…` : body, entity: 'appointment', entityId: id,
  });
}
