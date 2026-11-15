import { pool, withTransaction, type Db } from '../config/database.js';
import { env } from '../config/env.js';
import * as Leads from '../models/lead.model.js';
import * as Properties from '../models/property.model.js';
import { insertActivity } from '../models/activity.model.js';
import { AppError } from '../middlewares/error-handler.js';
import { ensureClientAccount } from './auth.service.js';
import { nextFolio } from './codes.service.js';
import { assertVisitable, placeVisit, VISIT_HOURS_TEXT, visitTimeOk } from './appointment.service.js';
import { correctionToken } from './lead-correction.service.js';
import { notify, plainBrokers } from './notification.service.js';

export interface LeadInput {
  reason: Leads.LeadRow['reason'];
  name: string;
  email: string;
  phone?: string | null;
  message?: string | null;
  propertySlug?: string;
  propertyCode?: string;
  preferredDate?: string;
  preferredTime?: string;
  payload?: Record<string, unknown>;
  /** Solicitud hecha desde la app: queda ligada al expediente del cliente con sesión. */
  clientId?: string | null;
  /** La registró un broker en el panel: queda con él (si no, administración la asigna). */
  brokerId?: string | null;
}

const REASON_TEXT: Record<Leads.LeadRow['reason'], string> = {
  visita: 'quiere visitar',
  rentar: 'quiere rentar',
  comprar: 'quiere comprar',
  publicar: 'quiere publicar su casa',
  otro: 'escribió por otro motivo',
};

/** Busca el expediente por correo o crea uno nuevo (sin cuenta de app). */
async function findOrCreateClient(db: Db, l: LeadInput, propertyId: string | null, brokerId: string | null): Promise<string> {
  const found = await db.query<{ id: string }>(`SELECT id FROM clients WHERE lower(email) = lower($1) AND active ORDER BY created_at LIMIT 1`, [l.email]);
  if (found.rows[0]) return found.rows[0].id;
  const p = l.payload ?? {};
  const str = (k: string) => (typeof p[k] === 'string' && p[k] ? String(p[k]) : null);
  const { rows } = await db.query<{ id: string }>(
    `INSERT INTO clients (kind, name, email, phone, nationality, occupation, operation, budget, has_pets, occupants, follow_status, property_id, broker_id)
     VALUES ('cliente', $1, $2, $3, $4, $5, $6, $7, $8, $9, 'Nuevo contacto', $10, $11) RETURNING id`,
    [
      l.name, l.email, l.phone ?? null, str('nacionalidad'), str('ocupacion'),
      l.reason === 'comprar' ? 'Compra' : 'Renta', str('presupuesto'), p.mascotas === 'si',
      Number(p.personas) || null, propertyId, brokerId,
    ],
  );
  return rows[0].id;
}

/** Expediente de la persona de la solicitud (para agendarle cita): el ligado, uno con su correo o uno nuevo. */
export async function clientForLead(lead: Leads.LeadRow): Promise<string> {
  if (lead.client_id) return lead.client_id;
  return withTransaction(async (db) => {
    const clientId = await findOrCreateClient(
      db,
      { reason: lead.reason, name: lead.name, email: lead.email, phone: lead.phone, payload: lead.payload },
      lead.property_id,
      null,
    );
    await db.query('UPDATE leads SET client_id = $2 WHERE id = $1', [lead.id, clientId]);
    return clientId;
  });
}

/**
 * Registra una solicitud del sitio (Contáctanos, «¿Te imaginas viviendo aquí?», bloque de contacto del inicio).
 * Una solicitud de visita con fecha y hora crea además la cita «por confirmar», sin broker hasta que administración lo asigne.
 */
export async function createLead(l: LeadInput): Promise<{ folio: string; appointmentCode: string | null; account: 'created' | 'existing' | null; editToken: string | null }> {
  const property = l.propertySlug ? await Properties.findBySlug(l.propertySlug) : l.propertyCode ? await Properties.findByCode(l.propertyCode) : null;
  if ((l.propertySlug || l.propertyCode) && !property) throw new AppError(404, 'NOT_FOUND', 'La casa indicada no existe.');
  if (l.reason === 'visita' && !property) throw new AppError(400, 'VALIDATION_ERROR', 'Indica la casa que quieres visitar.', { propertySlug: ['Indica la casa que quieres visitar.'] });

  // Antes de crear la cuenta: si la visita no procede, no debe salir ningún correo
  if (l.reason === 'visita' && property) await assertVisitable(pool, property.id);
  if (l.preferredTime && !visitTimeOk(l.preferredTime.slice(0, 5))) throw new AppError(400, 'VALIDATION_ERROR', VISIT_HOURS_TEXT, { preferredTime: [VISIT_HOURS_TEXT] });
  // Se pueden enviar varias solicitudes, pero no una segunda cita de la misma casa desde el sitio (se cambia en la app)
  if (l.reason === 'visita' && property && l.preferredDate && !l.clientId) {
    const { rowCount } = await pool.query(
      `SELECT 1 FROM appointments a JOIN clients c ON c.id = a.client_id LEFT JOIN users u ON u.id = c.user_id
        WHERE a.property_id = $1 AND a.status IN ('por-confirmar', 'confirmada') AND a.scheduled_at > now()
          AND (lower(c.email) = lower($2) OR lower(u.email) = lower($2)) LIMIT 1`,
      [property.id, l.email],
    );
    if (rowCount) throw new AppError(409, 'ALREADY_SCHEDULED', 'Este correo ya tiene una cita para esta casa. Si quieres cambiar el día o la hora, hazlo en la app Homiz.');
  }

  return withTransaction(async (db) => {
    const folio = await nextFolio(db);
    let clientId = l.clientId ?? (l.reason === 'publicar' || l.reason === 'otro' ? null : await findOrCreateClient(db, l, property?.id ?? null, l.brokerId ?? null));
    // Formularios del sitio: se crea sola la cuenta de la app (la persona solo crea su contraseña con el correo).
    let account: 'created' | 'existing' | null = null;
    let accountUser: string | null = null;
    if (!l.clientId) {
      const acc = await ensureClientAccount({ name: l.name, email: l.email, phone: l.phone ?? null }, db);
      account = acc.created ? 'created' : 'existing';
      accountUser = acc.userId;
      clientId ??= acc.clientId || null;
    }
    // Quien ya tiene broker sigue con él; si no, la toma el primero que la atienda
    const { rows: [own] } = clientId ? await db.query<{ broker_id: string | null }>('SELECT broker_id FROM clients WHERE id = $1', [clientId]) : { rows: [] as { broker_id: string | null }[] };
    const brokerId = l.brokerId ?? own?.broker_id ?? null;
    // Sin broker propio, una visita o una compra tiene la prioridad del asesor de la casa
    const houseBroker = !brokerId && (l.reason === 'visita' || l.reason === 'comprar') ? property?.broker_id ?? null : null;
    const leadId = await Leads.insert(db, {
      folio, reason: l.reason, name: l.name, email: l.email, phone: l.phone ?? null, message: l.message ?? null,
      propertyId: property?.id ?? null, preferredDate: l.preferredDate ?? null, preferredTime: l.preferredTime ?? null,
      payload: l.payload ?? {}, clientId, brokerId,
    });

    let appointmentCode: string | null = null;
    if (l.reason === 'visita' && property && clientId && l.preferredDate && l.preferredTime) {
      await db.query('SAVEPOINT cita');
      try {
        const { rows: [t] } = await db.query<{ at: Date }>(`SELECT ($1::date + $2::time) AT TIME ZONE $3 AS at`, [l.preferredDate, l.preferredTime, env.TZ_APP]);
        // Una cita vigente por persona: si ya tenía una, se cambia a esta casa, fecha y hora
        const placed = await placeVisit(db, { clientId, propertyId: property.id, brokerId: brokerId ?? houseBroker, scheduledAt: t.at, note: l.message ?? null, leadId });
        appointmentCode = placed.code;
      } catch (err) {
        // Si el broker ya tiene una cita a esa hora, la solicitud se guarda igual y él propondrá otro horario.
        if ((err as { code?: string }).code !== '23505') throw err;
        await db.query('ROLLBACK TO SAVEPOINT cita');
      }
    }

    await insertActivity({
      propertyId: property?.id ?? null, entity: 'lead', entityId: leadId, action: 'create',
      description: `${l.name} ${REASON_TEXT[l.reason]}${property ? ` ${property.name}` : ''} (folio ${folio}).`,
    }, db);

    // Con broker le llega a él (si la registró él mismo, no hace falta); con prioridad, al asesor de la casa;
    // en el pool, primero a los brokers: administración entra después de su espera
    const recipients = l.brokerId ? [] : brokerId ? [brokerId] : houseBroker ? [houseBroker] : await plainBrokers(db);
    await notify(recipients, {
      type: l.reason === 'visita' ? 'appointment_requested' : 'lead_received',
      title: l.reason === 'visita' ? 'Nueva solicitud de visita' : 'Nueva solicitud del sitio',
      message: `${l.name} ${REASON_TEXT[l.reason]}${property ? ` ${property.name}` : ''}. Folio ${folio}.`,
      entity: 'lead',
      entityId: leadId,
    }, db);
    // Permiso de 2 horas para «Cambiar mis datos» desde el sitio (solo formularios del sitio)
    const editToken = l.clientId ? null : correctionToken(leadId, account === 'created', accountUser);
    return { folio, appointmentCode, account, editToken };
  });
}
