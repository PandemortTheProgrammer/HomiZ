import type { RequestHandler } from 'express';
import { z } from 'zod';
import { pool } from '../config/database.js';
import { env } from '../config/env.js';
import * as Leads from '../models/lead.model.js';
import * as Users from '../models/user.model.js';
import { insertActivity } from '../models/activity.model.js';
import { currentUser, type AuthUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { dateTimeField, pagination, paged } from '../middlewares/validate.js';
import { withTransaction, type Db } from '../config/database.js';
import { isAdmin, isBroker, isOwner } from '../services/access.service.js';
import * as Appointments from '../services/appointment.service.js';
import { assertMayAct, hiddenFromAdmin, leadWindow, warnOwnerOfUnattended } from '../services/lead-window.service.js';
import { clientForLead, createLead } from '../services/lead.service.js';
import { notify, staffWithPermission, userOfClient } from '../services/notification.service.js';
import { photoUrl } from '../services/property.service.js';

/*
 * Solicitudes (Contáctanos, visitas del sitio y «Busco casa» de la app).
 * El personal (leads.manage) les da seguimiento, contesta y propone casas; el cliente lo ve en la app.
 */
export const listQueryDto = pagination.extend({
  status: z.enum(['nuevo', 'en_seguimiento', 'cerrado']).optional(),
  reason: z.enum(['visita', 'rentar', 'comprar', 'publicar', 'otro']).optional(),
  // Administración: solo las que aún no tienen broker
  unassigned: z.enum(['true', 'false']).transform((v) => v === 'true').optional(),
});
/** Administración asigna el broker de la solicitud (y de su cita) */
export const brokerDto = z.object({ brokerId: z.uuid({ error: 'Elige un broker.' }) });
const REASONS = ['visita', 'rentar', 'comprar', 'publicar', 'otro'] as const;
export const updateDto = z
  .object({
    status: z.enum(['nuevo', 'en_seguimiento', 'cerrado'], { error: 'Estado no válido.' }).optional(),
    response: z.string().trim().min(2, 'Escribe la respuesta para el cliente.').max(2000).optional(),
    // Corregir los datos de la solicitud
    name: z.string().trim().min(2, 'Escribe el nombre.').max(120).optional(),
    phone: z.string().trim().max(30).nullable().optional(),
    message: z.string().trim().max(2000).nullable().optional(),
    reason: z.enum(REASONS, { error: 'Motivo no válido.' }).optional(),
  })
  .refine((v) => Object.values(v).some((x) => x !== undefined), 'Indica qué cambiar.');
/** Solicitud capturada por el personal (llamada, WhatsApp, oficina). */
export const createDto = z.object({
  reason: z.enum(REASONS, { error: 'Indica el motivo.' }),
  name: z.string().trim().min(2, 'Escribe el nombre.').max(120),
  email: z.email({ error: 'Escribe un correo válido.' }).max(160),
  phone: z.string().trim().max(30).optional().nullable(),
  message: z.string().trim().max(2000).optional().nullable(),
  propertyCode: z.string().trim().max(20).optional().nullable(),
  payload: z.record(z.string().max(40), z.union([z.string().max(500), z.number(), z.boolean()])).optional(),
});
/** Agendar la visita desde la solicitud */
export const appointmentDto = z.object({
  propertyId: z.uuid({ error: 'Elige la casa.' }),
  scheduledAt: dateTimeField,
  note: z.string().trim().max(500).optional().nullable(),
  /** El personal está de acuerdo con la fecha y hora que pidió la persona: la cita queda confirmada */
  agreed: z.boolean().optional(),
});
export const proposalDto = z.object({ propertyId: z.uuid({ error: 'Elige una casa.' }), note: z.string().trim().max(300).optional().nullable() });
export const proposalParams = z.object({ id: z.uuid(), proposalId: z.uuid() });
/** «Busco casa» desde la app: los datos de contacto salen de la cuenta. */
export const myRequestDto = z
  .object({
    reason: z.enum(['rentar', 'comprar', 'publicar', 'otro'], { error: 'Indica qué buscas.' }),
    message: z.string().trim().max(2000).optional().nullable(),
    payload: z.record(z.string().max(40), z.union([z.string().max(500), z.number(), z.boolean()])).optional(),
    // «¿Qué quieres hacer?» después de entrar por el QR de una casa: la casa y, si quiere, su cita
    propertySlug: z.string().regex(/^[a-z0-9-]{2,80}$/).optional(),
    // «Solicitar visita» desde el catálogo de la app (la casa por su clave, con el mismo formulario del sitio)
    // Claves como ZUG-007 o ZUG-HUA-024 (las mismas que acepta el sitio)
    propertyCode: z.string().trim().regex(/^[A-Z]{2,5}-[A-Z0-9-]{1,15}$/, 'No reconocemos la casa elegida. Vuelve a abrirla desde el catálogo.').optional(),
    preferredDate: z.iso.date({ error: 'Usa el formato AAAA-MM-DD.' }).optional(),
    preferredTime: z.string().regex(/^([01]\d|2[0-3]):(00|15|30|45)$/, 'Elige una hora en bloques de 15 minutos.').optional(),
  })
  .refine((v) => !v.preferredDate || !!v.propertySlug || !!v.propertyCode, { message: 'Indica la casa de la cita.', path: ['propertySlug'] })
  .refine((v) => !v.preferredDate === !v.preferredTime, { message: 'Elige el día y la hora de la cita.', path: ['preferredTime'] });

/** Editar lo que mandó en el formulario. La casa, el motivo y la cita no cambian aquí. */
export const editRequestDto = z.object({
  message: z.string().trim().max(2000).optional().nullable(),
  payload: z.record(z.string().max(40), z.union([z.string().max(500), z.number(), z.boolean()])),
});
/** Datos del sistema dentro del formulario: el cliente no los cambia al editar */
const SYSTEM_FIELDS = ['origen', 'quiere', 'aviso_privacidad', 'fecha_preferida', 'horario'];

const STATUS_TEXT = { nuevo: 'Recibida', en_seguimiento: 'En seguimiento', cerrado: 'Cerrada' } as const;

async function presentProposals(rows: Leads.ProposalRow[]) {
  return Promise.all(rows.map(async (p) => ({
    id: p.id, leadId: p.lead_id, note: p.note, createdAt: p.created_at,
    property: {
      id: p.property_id, code: p.code, slug: p.slug, name: p.name, zone: p.zone, city: p.city, operation: p.operation,
      price: p.price, rec: p.rec, banos: p.banos, m2: p.m2, petsAllowed: p.pets_allowed, photo: p.photo ? await photoUrl(p.photo) : null,
    },
  })));
}

/** Personal: todo. Cliente: sin teléfono ni correo del asesor ni datos internos. */
const presentAppointments = (rows: Leads.LeadAppointmentRow[]) =>
  rows.map((a) => ({ id: a.id, code: a.code, scheduledAt: a.scheduled_at, status: a.status, awaiting: a.status === 'por-confirmar' ? a.awaiting : null, property: { id: a.property_id, code: a.property_code, name: a.property_name }, broker: a.broker_name }));

/** Lo que el personal necesita para mostrar la prioridad o el aviso de «sin atender». */
const windowView = (l: Leads.LeadRow) => {
  const { priority, overdue } = leadWindow(l);
  return { priority: priority ? { brokerId: priority.brokerId, brokerName: priority.brokerName, until: priority.until.toISOString() } : null, overdue };
};

/** Una casa rentada o vendida ya no se ofrece: la solicitud abierta sigue, pero sin esa casa. */
const houseGone = (l: Leads.LeadRow) => l.status !== 'cerrado' && (l.property_status === 'rentada' || l.property_status === 'vendida');

const present = (l: Leads.LeadRow, proposals?: Awaited<ReturnType<typeof presentProposals>>, appointments?: ReturnType<typeof presentAppointments>) => ({
  id: l.id,
  folio: l.folio,
  reason: l.reason,
  name: l.name,
  email: l.email,
  phone: l.phone,
  message: l.message,
  ...windowView(l),
  property: l.property_id && !houseGone(l) ? { id: l.property_id, code: l.property_code, name: l.property_name } : null,
  preferredDate: l.preferred_date,
  preferredTime: l.preferred_time,
  payload: l.payload,
  status: l.status,
  statusLabel: STATUS_TEXT[l.status],
  clientId: l.client_id,
  broker: l.broker_id ? { id: l.broker_id, name: l.broker_name } : null,
  response: l.response,
  respondedAt: l.responded_at,
  respondedBy: l.responded_by_name,
  proposalCount: l.proposals,
  appointmentCount: l.appointments,
  ...(proposals ? { proposals } : {}),
  ...(appointments ? { appointments } : {}),
  createdAt: l.created_at,
});

/** Solicitud completa para el personal: propuestas, citas agendadas y las otras solicitudes de la persona. */
async function full(id: string) {
  const lead = (await Leads.findById(id))!;
  const others = (await Leads.othersOf(lead.email, id)).map((o) => ({
    id: o.id, folio: o.folio, reason: o.reason, status: o.status, statusLabel: STATUS_TEXT[o.status], property: houseGone(o) ? null : o.property_name, payload: o.payload, message: o.message, createdAt: o.created_at,
  }));
  return { ...present(lead, await presentProposals(await Leads.proposalsFor([id])), presentAppointments(await Leads.appointmentsFor(id))), others };
}

/** El broker solo atiende las solicitudes que administración le asignó. */
async function loadForStaff(user: AuthUser, id: string): Promise<Leads.LeadRow> {
  const lead = await Leads.findById(id);
  if (!lead) throw new AppError(404, 'NOT_FOUND', 'La solicitud no existe.');
  // Sin broker: la ven los brokers; administración, cuando le toca
  if (hiddenFromAdmin(user, lead)) throw new AppError(403, 'LEAD_ADMIN_WAIT', 'Esta solicitud aún no está disponible para administración.');
  if (!isAdmin(user) && lead.broker_id && lead.broker_id !== user.id) throw new AppError(403, 'NOT_OWNER', `Esta solicitud la atiende ${lead.broker_name ?? 'otro broker'}.`);
  return lead;
}

/** La solicitud, sus citas vigentes y el expediente de la persona pasan a ese broker. */
async function moveToBroker(db: Db, lead: Leads.LeadRow, brokerId: string, brokerName: string): Promise<void> {
  await db.query('UPDATE leads SET broker_id = $2 WHERE id = $1', [lead.id, brokerId]);
  await db.query(`UPDATE appointments SET broker_id = $2 WHERE lead_id = $1 AND status IN ('por-confirmar', 'confirmada')`, [lead.id, brokerId]).catch((err) => {
    if ((err as { code?: string }).code === '23505') throw new AppError(409, 'BROKER_BUSY', `${brokerName} ya tiene otra cita a esa hora. Cambia primero la hora de la cita.`);
    throw err;
  });
  if (lead.client_id) await db.query('UPDATE clients SET broker_id = $2 WHERE id = $1', [lead.client_id, brokerId]);
}

/** El primer broker que atiende una solicitud sin broker se queda con su seguimiento. Dos a la vez: gana el primero. */
async function takeIfFree(user: AuthUser, lead: Leads.LeadRow): Promise<Leads.LeadRow> {
  assertMayAct(user, lead); // La prioridad de otro broker no se salta agendando, proponiendo o escribiendo
  if (lead.broker_id || !isBroker(user)) return lead;
  await withTransaction(async (db) => {
    const { rowCount } = await db.query('UPDATE leads SET broker_id = $2 WHERE id = $1 AND broker_id IS NULL', [lead.id, user.id]);
    if (!rowCount) {
      const now = await Leads.findById(lead.id);
      throw new AppError(409, 'ALREADY_TAKEN', `Esta solicitud ya la atiende ${now?.broker_name ?? 'otro broker'}.`);
    }
    await moveToBroker(db, lead, user.id, user.name);
    await insertActivity({ userId: user.id, propertyId: lead.property_id, entity: 'lead', entityId: lead.id, action: 'take', description: `${user.name} tomó la solicitud ${lead.folio} de ${lead.name}.` }, db);
  });
  return { ...lead, broker_id: user.id };
}

/** POST /leads/:id/take — el broker toma la solicitud («Atender esta solicitud»). */
export const take: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  if (!isBroker(user)) throw new AppError(403, 'FORBIDDEN', 'Solo un broker puede atender una solicitud.');
  const lead = await loadForStaff(user, (res.locals.params as { id: string }).id);
  await takeIfFree(user, lead);
  res.json(await full(lead.id));
};

/** Usuario de la app de la persona que hizo la solicitud (para avisarle). */
async function clientUser(lead: Leads.LeadRow): Promise<string | null> {
  const byClient = await userOfClient(lead.client_id);
  if (byClient) return byClient;
  const u = await Users.findByEmail(lead.email);
  return u && u.type === 'client' ? u.id : null;
}

/** GET /leads — administrador: todas (o solo las sin asignar); broker: las suyas o las que nadie atiende. */
export const list: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  // Broker: las suyas; con unassigned, las que aún nadie atiende
  await warnOwnerOfUnattended();
  const { rows, total } = await Leads.list({
    ...q,
    brokerId: isAdmin(user) || q.unassigned ? undefined : user.id,
    hidePoolNewerThan: isAdmin(user) && !isOwner(user) ? env.LEAD_ADMIN_WAIT_MINUTES : undefined,
  });
  res.json(paged(rows.map((l) => present(l)), total, q));
};

/** GET /leads/:id — con las casas propuestas y las citas agendadas. */
export const getOne: RequestHandler = async (_req, res) => {
  const lead = await loadForStaff(currentUser(res), (res.locals.params as { id: string }).id);
  res.json(await full(lead.id));
};

/** POST /leads — el personal registra una solicitud que llegó por teléfono, WhatsApp u oficina. */
export const create: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = res.locals.body as z.infer<typeof createDto>;
  if (d.reason === 'visita' && !d.propertyCode) throw new AppError(400, 'VALIDATION_ERROR', 'Indica la casa que quiere visitar.', { propertyCode: ['Indica la casa que quiere visitar.'] });
  const { folio } = await createLead({
    reason: d.reason, name: d.name, email: d.email, phone: d.phone ?? null, message: d.message ?? null,
    propertyCode: d.propertyCode || undefined, payload: { ...(d.payload ?? {}), origen: 'panel' },
    brokerId: isBroker(user) ? user.id : null,
  });
  const { rows } = await pool.query<{ id: string }>('SELECT id FROM leads WHERE folio = $1', [folio]);
  await insertActivity({ userId: user.id, entity: 'lead', entityId: rows[0].id, action: 'create', description: `${user.name} registró la solicitud ${folio} de ${d.name}.` });
  res.status(201).json(await full(rows[0].id));
};

/** DELETE /leads/:id — solo administración. Las citas que salieron de ella se conservan. */
export const remove: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  if (!isAdmin(user)) throw new AppError(403, 'FORBIDDEN', 'Solo administración puede eliminar solicitudes.');
  const { id } = res.locals.params as { id: string };
  const lead = await loadForStaff(user, id);
  assertMayAct(user, lead);
  await withTransaction(async (db) => {
    await Leads.remove(db, id);
    await insertActivity({ userId: user.id, propertyId: lead.property_id, entity: 'lead', entityId: id, action: 'delete', description: `${user.name} eliminó la solicitud ${lead.folio} de ${lead.name}.` }, db);
  });
  res.status(204).end();
};

/** «Hacer cita» solo vale para la casa, el día y la hora que pidió la persona. */
async function assertAgreedDate(lead: Leads.LeadRow, propertyId: string, scheduledAt: string): Promise<void> {
  const msg = 'Esa no es la fecha que pidió la persona. Usa «Agendar cita» para proponerle otra.';
  if (!lead.preferred_date || !lead.preferred_time || lead.property_id !== propertyId) throw new AppError(400, 'VALIDATION_ERROR', msg);
  const { rows: [t] } = await pool.query<{ at: Date }>(`SELECT ($1::date + $2::time) AT TIME ZONE 'America/Cancun' AS at`, [lead.preferred_date, lead.preferred_time]);
  if (t.at.getTime() !== new Date(scheduledAt).getTime()) throw new AppError(400, 'VALIDATION_ERROR', msg);
}

/**
 * POST /leads/:id/appointment — agenda la visita: crea (si falta) el expediente y la cita ligada a la solicitud.
 * Si la solicitud ya tiene una cita vigente de esa casa, la reprograma (no se crea otra: evitaba citas duplicadas).
 */
export const schedule: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const lead = await takeIfFree(user, await loadForStaff(user, id));
  const d = res.locals.body as z.infer<typeof appointmentDto>;
  if (d.agreed) await assertAgreedDate(lead, d.propertyId, d.scheduledAt);
  const { rows: open } = await pool.query<{ id: string; code: string; property_id: string }>(
    `SELECT id, code, property_id FROM appointments WHERE lead_id = $1 AND status IN ('por-confirmar', 'confirmada') ORDER BY scheduled_at DESC`,
    [id],
  );
  const same = open.find((a) => a.property_id === d.propertyId);
  if (same) {
    await Appointments.transition(user, same.id, 'reschedule', { scheduledAt: d.scheduledAt, reason: d.note ?? undefined });
    if (lead.status === 'nuevo') await pool.query(`UPDATE leads SET status = 'en_seguimiento' WHERE id = $1`, [id]);
    res.json({ appointment: { id: same.id, code: same.code }, rescheduled: true, lead: await full(id) });
    return;
  }
  const clientId = await clientForLead(lead);
  // Una cita vigente por persona: si ya tiene una (de otra casa), esa misma cita se cambia a esta
  // La cita queda con el broker asignado a la solicitud (o sin broker si administración aún no lo asigna)
  const placed = await Appointments.createOrMove(user, { propertyId: d.propertyId, clientId, scheduledAt: d.scheduledAt, note: d.note ?? lead.message, leadId: id, assigned: lead.broker_id });
  if (d.agreed) {
    // Ya la pidió la persona: al aceptarla el personal, la fecha queda acordada por ambos
    await pool.query(`UPDATE appointments SET awaiting = 'staff' WHERE id = $1`, [placed.id]);
    await Appointments.transition(user, placed.id, 'confirm');
  }
  if (lead.status === 'nuevo') await pool.query(`UPDATE leads SET status = 'en_seguimiento' WHERE id = $1`, [id]);
  await insertActivity({ userId: user.id, entity: 'lead', entityId: id, action: 'schedule', description: `${user.name} ${placed.moved ? 'cambió' : 'agendó'} la cita ${placed.code} desde la solicitud ${lead.folio}.` });
  res.status(placed.moved ? 200 : 201).json({ appointment: { id: placed.id, code: placed.code }, rescheduled: placed.moved, moved: placed.moved, lead: await full(id) });
};

/**
 * PATCH /leads/:id/broker — administración asigna (o cambia) el broker de la solicitud. La persona y sus datos
 * no cambian; sus citas vigentes y su expediente pasan a ese broker, y al broker le llega el aviso.
 */
export const assignBroker: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  if (!isAdmin(user)) throw new AppError(403, 'FORBIDDEN', 'Solo administración asigna brokers a las solicitudes.');
  const { id } = res.locals.params as { id: string };
  const lead = await loadForStaff(user, id);
  assertMayAct(user, lead);
  const { brokerId } = res.locals.body as z.infer<typeof brokerDto>;
  const { rows: [b] } = await pool.query<{ name: string }>(
    `SELECT u.name FROM users u JOIN user_roles ur ON ur.user_id = u.id JOIN roles r ON r.id = ur.role_id WHERE u.id = $1 AND u.active AND r.code IN ('broker', 'admin')`,
    [brokerId],
  );
  if (!b) throw new AppError(400, 'INVALID_BROKER', 'Elige un broker activo.');
  await withTransaction(async (db) => {
    await moveToBroker(db, lead, brokerId, b.name);
    await insertActivity({ userId: user.id, propertyId: lead.property_id, entity: 'lead', entityId: id, action: 'assign', description: `${user.name} asignó la solicitud ${lead.folio} de ${lead.name} a ${b.name}.`, oldValues: { brokerId: lead.broker_id }, newValues: { brokerId } }, db);
    await notify([brokerId], { type: 'lead_assigned', title: 'Te asignaron una solicitud', message: `${lead.name} · folio ${lead.folio}${lead.property_name ? ` · ${lead.property_name}` : ''}.`, entity: 'lead', entityId: id }, db);
  });
  res.json(await full(id));
};

/** PATCH /leads/:id — estado, respuesta para el cliente (se le avisa en la app) o corrección de datos. */
export const update: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const lead = await takeIfFree(user, await loadForStaff(user, id));
  const d = res.locals.body as z.infer<typeof updateDto>;
  if (d.name !== undefined || d.phone !== undefined || d.message !== undefined || d.reason !== undefined) {
    await Leads.updateDetails(id, d);
  }
  // Contestar pasa la solicitud a «en seguimiento» si seguía nueva.
  const status = d.status ?? (d.response && lead.status === 'nuevo' ? 'en_seguimiento' : lead.status);
  await pool.query(
    `UPDATE leads SET status = $2,
            response = CASE WHEN $3::text IS NULL THEN response ELSE $3 END,
            responded_at = CASE WHEN $3::text IS NULL THEN responded_at ELSE now() END,
            responded_by = CASE WHEN $3::text IS NULL THEN responded_by ELSE $4 END
      WHERE id = $1`,
    [id, status, d.response ?? null, user.id],
  );
  const edited = d.name !== undefined || d.phone !== undefined || d.message !== undefined || d.reason !== undefined;
  const parts = [edited && 'corrigió', d.response && 'respondió', status !== lead.status && `marcó como ${STATUS_TEXT[status].toLowerCase()}`].filter(Boolean).join(' y ');
  await insertActivity({ userId: user.id, propertyId: lead.property_id, entity: 'lead', entityId: id, action: 'update', description: `${user.name} ${parts} la solicitud ${lead.folio}.`, oldValues: { status: lead.status }, newValues: d });
  if (d.response) {
    await notify([await clientUser(lead)], { type: 'lead_update', title: 'Respuesta a tu solicitud', message: `Tu asesor respondió tu solicitud ${lead.folio}: ${d.response.slice(0, 120)}`, entity: 'lead', entityId: id });
  }
  res.json(await full(id));
};

/** POST /leads/:id/proposals — propone una casa del inventario (se le avisa al cliente). */
export const addProposal: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const lead = await takeIfFree(user, await loadForStaff(user, id));
  const d = res.locals.body as z.infer<typeof proposalDto>;
  const { rows: p } = await pool.query<{ name: string }>(`SELECT name FROM properties WHERE id = $1 AND active`, [d.propertyId]);
  if (!p[0]) throw new AppError(404, 'NOT_FOUND', 'La casa no existe.');
  await Appointments.assertVisitable(pool, d.propertyId);
  try {
    await pool.query('INSERT INTO lead_proposals (lead_id, property_id, note, proposed_by) VALUES ($1, $2, $3, $4)', [id, d.propertyId, d.note ?? null, user.id]);
  } catch (err) {
    if ((err as { code?: string }).code === '23505') throw new AppError(409, 'ALREADY_PROPOSED', 'Esa casa ya está propuesta en esta solicitud.');
    throw err;
  }
  if (lead.status === 'nuevo') await pool.query(`UPDATE leads SET status = 'en_seguimiento' WHERE id = $1`, [id]);
  await insertActivity({ userId: user.id, propertyId: d.propertyId, entity: 'lead', entityId: id, action: 'proposal', description: `${user.name} propuso ${p[0].name} en la solicitud ${lead.folio}.` });
  await notify([await clientUser(lead)], { type: 'lead_update', title: 'Te proponemos una casa', message: `Tu asesor te propone ${p[0].name}. Velo en «Mis solicitudes».`, entity: 'lead', entityId: id });
  res.status(201).json(present((await Leads.findById(id))!, await presentProposals(await Leads.proposalsFor([id]))));
};

/** DELETE /leads/:id/proposals/:proposalId */
export const removeProposal: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id, proposalId } = res.locals.params as z.infer<typeof proposalParams>;
  assertMayAct(user, await loadForStaff(user, id));
  const del = await pool.query('DELETE FROM lead_proposals WHERE id = $1 AND lead_id = $2', [proposalId, id]);
  if (!del.rowCount) throw new AppError(404, 'NOT_FOUND', 'La propuesta no existe.');
  res.json(present((await Leads.findById(id))!, await presentProposals(await Leads.proposalsFor([id]))));
};

/* ---------- Cliente de la app: «Mis solicitudes» ---------- */

const forClient = (l: ReturnType<typeof present>) => {
  const { clientId: _c, email: _e, phone: _p, name: _n, priority: _r, overdue: _v, ...rest } = l;
  return rest;
};

/* ---------- Mensajes de la solicitud (cliente ↔ asesor) ---------- */
export const messageDto = z.object({ body: z.string().trim().min(1, 'Escribe tu mensaje.').max(2000) });

async function messagesOf(leadId: string, viewer: AuthUser) {
  const { rows } = await pool.query<{ id: string; body: string; from_staff: boolean; sender_id: string | null; sender: string | null; created_at: Date }>(
    `SELECT m.id, m.body, m.from_staff, m.sender_id, u.name AS sender, m.created_at
       FROM lead_messages m LEFT JOIN users u ON u.id = m.sender_id WHERE m.lead_id = $1 ORDER BY m.created_at`,
    [leadId],
  );
  // Para el cliente, el personal aparece como «Zugar» (igual que en el chat de las citas)
  return rows.map((m) => ({
    id: m.id, body: m.body, fromStaff: m.from_staff, mine: m.sender_id === viewer.id,
    sender: m.from_staff && viewer.type === 'client' ? 'Zugar' : m.sender ?? 'Cliente', createdAt: m.created_at,
  }));
}

/** GET /leads/:id/messages */
export const staffMessages: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const lead = await loadForStaff(user, (res.locals.params as { id: string }).id);
  res.json({ data: await messagesOf(lead.id, user) });
};

/** POST /leads/:id/messages — el asesor escribe; al cliente le llega el aviso en la app. */
export const staffSend: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const lead = await takeIfFree(user, await loadForStaff(user, (res.locals.params as { id: string }).id));
  const { body } = res.locals.body as z.infer<typeof messageDto>;
  await pool.query('INSERT INTO lead_messages (lead_id, sender_id, from_staff, body) VALUES ($1, $2, TRUE, $3)', [lead.id, user.id, body]);
  if (lead.status === 'nuevo') await pool.query(`UPDATE leads SET status = 'en_seguimiento' WHERE id = $1`, [lead.id]);
  await notify([await clientUser(lead)], { type: 'lead_message', title: 'Nuevo mensaje de tu asesor', message: body.slice(0, 140), entity: 'lead', entityId: lead.id });
  res.status(201).json({ data: await messagesOf(lead.id, user) });
};

/** Mi solicitud (cliente) o 404 */
async function loadMine(user: AuthUser, id: string) {
  const lead = (await Leads.listOfClient(user.clientId, user.email)).find((l) => l.id === id);
  if (!lead) throw new AppError(404, 'NOT_FOUND', 'La solicitud no existe.');
  return lead;
}

/** GET /requests/:id/messages */
export const mineMessages: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  onlyClient(user);
  const lead = await loadMine(user, (res.locals.params as { id: string }).id);
  res.json({ data: await messagesOf(lead.id, user) });
};

/** POST /requests/:id/messages — el cliente escribe; se avisa al broker de la casa o a quien atiende solicitudes. */
export const mineSend: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  onlyClient(user);
  const lead = await loadMine(user, (res.locals.params as { id: string }).id);
  const { body } = res.locals.body as z.infer<typeof messageDto>;
  await pool.query('INSERT INTO lead_messages (lead_id, sender_id, from_staff, body) VALUES ($1, $2, FALSE, $3)', [lead.id, user.id, body]);
  const { rows } = await pool.query<{ broker_id: string | null; responded_by: string | null }>(
    'SELECT l.broker_id, l.responded_by FROM leads l WHERE l.id = $1',
    [lead.id],
  );
  const lastStaff = await pool.query<{ sender_id: string }>('SELECT sender_id FROM lead_messages WHERE lead_id = $1 AND from_staff ORDER BY created_at DESC LIMIT 1', [lead.id]);
  const to = rows[0]?.broker_id ?? lastStaff.rows[0]?.sender_id ?? rows[0]?.responded_by;
  // Sin broker asignado todavía: le llega a administración, que la asigna
  const recipients = to ? [to] : await staffWithPermission('properties.reassign');
  await notify(recipients, { type: 'lead_message', title: `Mensaje de ${user.name}`, message: `${lead.folio}: ${body.slice(0, 120)}`, entity: 'lead', entityId: lead.id });
  res.status(201).json({ data: await messagesOf(lead.id, user) });
};

function onlyClient(user: AuthUser) {
  if (user.type !== 'client') throw new AppError(403, 'FORBIDDEN', 'Solo los clientes tienen solicitudes.');
}

/** GET /requests — mis solicitudes con las casas propuestas. */
export const mine: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  onlyClient(user);
  const rows = await Leads.listOfClient(user.clientId, user.email);
  const proposals = await presentProposals(await Leads.proposalsFor(rows.map((r) => r.id)));
  res.json({ data: rows.map((l) => forClient(present(l, proposals.filter((p) => p.leadId === l.id)))) });
};

/** GET /requests/:id — una de mis solicitudes. */
export const mineOne: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  onlyClient(user);
  const { id } = res.locals.params as { id: string };
  const lead = (await Leads.listOfClient(user.clientId, user.email)).find((l) => l.id === id);
  if (!lead) throw new AppError(404, 'NOT_FOUND', 'La solicitud no existe.');
  res.json(forClient(present(lead, await presentProposals(await Leads.proposalsFor([id])))));
};

/** PATCH /requests/:id — el cliente corrige lo que mandó; su asesor (o administración) recibe el aviso. */
export const updateMine: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  onlyClient(user);
  const { id } = res.locals.params as { id: string };
  const lead = await loadMine(user, id);
  if (lead.status === 'cerrado') throw new AppError(409, 'REQUEST_CLOSED', 'Esta solicitud ya está cerrada. Si necesitas algo más, envía una nueva.');
  const d = res.locals.body as z.infer<typeof editRequestDto>;
  const old = (lead.payload ?? {}) as Record<string, unknown>;
  const kept = Object.fromEntries(SYSTEM_FIELDS.filter((k) => k in old).map((k) => [k, old[k]]));
  const sent = Object.fromEntries(Object.entries(d.payload).filter(([k]) => !SYSTEM_FIELDS.includes(k)));
  await pool.query('UPDATE leads SET message = $2, payload = $3 WHERE id = $1', [id, d.message || null, { ...sent, ...kept }]);
  await insertActivity({ userId: user.id, entity: 'lead', entityId: id, action: 'update', description: `${user.name} corrigió los datos de su solicitud ${lead.folio}.` });
  await notify(lead.broker_id ? [lead.broker_id] : await staffWithPermission('properties.reassign'), {
    type: 'lead_received', title: 'Solicitud actualizada', message: `${user.name} corrigió los datos de su solicitud ${lead.folio}.`, entity: 'lead', entityId: id,
  });
  res.json(forClient(present((await Leads.findById(id))!, await presentProposals(await Leads.proposalsFor([id])))));
};

/** POST /requests — «Busco casa» desde la app: nombre, correo y teléfono salen de la cuenta. */
export const createMine: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  onlyClient(user);
  const d = res.locals.body as z.infer<typeof myRequestDto>;
  const me = await Users.findById(user.id);
  // Con casa, día y hora se agenda la cita (una vigente por persona: si ya tenía una, se cambia a esta)
  const visit = !!((d.propertySlug || d.propertyCode) && d.preferredDate && d.preferredTime);
  const { folio } = await createLead({
    reason: visit ? 'visita' : d.reason, name: user.name, email: user.email, phone: me?.phone ?? null, message: d.message ?? null,
    payload: { ...(d.payload ?? {}), ...(visit ? { quiere: d.reason } : {}), origen: 'app' }, clientId: user.clientId,
    propertySlug: d.propertySlug, propertyCode: d.propertyCode, preferredDate: d.preferredDate, preferredTime: d.preferredTime,
  });
  const { rows } = await pool.query<{ id: string }>('SELECT id FROM leads WHERE folio = $1', [folio]);
  const lead = (await Leads.findById(rows[0].id))!;
  res.status(201).json(forClient(present(lead, [])));
};
