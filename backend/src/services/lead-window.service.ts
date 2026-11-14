import { pool } from '../config/database.js';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';
import { AppError } from '../middlewares/error-handler.js';
import type { AuthUser } from '../middlewares/authenticate.js';
import type { LeadRow } from '../models/lead.model.js';
import { isAdmin, isOwner } from './access.service.js';
import { notify } from './notification.service.js';

/*
 * Ventanas de una solicitud sin broker. No hay tarea programada: se calculan al consultar,
 * con la fecha de creación, para que funcionen aunque el servidor se haya dormido.
 *
 * - Visita o compra de una casa con broker: solo él atiende durante la prioridad; luego pasa al pool.
 * - Pool: al inicio solo los brokers; después también administración.
 * - Sin atender mucho tiempo: aviso a la dueña, que puede reasignar en cualquier momento.
 */

const MINUTE = 60_000;

export interface LeadWindow {
  priority: { brokerId: string; brokerName: string; until: Date } | null;
  adminFrom: Date;
  overdue: boolean;
}

export function leadWindow(l: LeadRow, now = new Date()): LeadWindow {
  const created = new Date(l.created_at).getTime();
  const adminFrom = new Date(created + env.LEAD_ADMIN_WAIT_MINUTES * MINUTE);
  if (l.broker_id || l.status === 'cerrado') return { priority: null, adminFrom, overdue: false };
  const until = new Date(created + env.LEAD_PRIORITY_MINUTES * MINUTE);
  const available = l.property_status !== 'rentada' && l.property_status !== 'vendida';
  const priority = (l.reason === 'visita' || l.reason === 'comprar') && l.house_broker_id && available && now < until
    ? { brokerId: l.house_broker_id, brokerName: l.house_broker_name ?? 'el asesor de la casa', until }
    : null;
  return { priority, adminFrom, overdue: now.getTime() >= created + env.LEAD_ESCALATE_MINUTES * MINUTE };
}

/** Administración espera su turno en el pool: durante ese tiempo no ve la solicitud. */
export function hiddenFromAdmin(user: AuthUser, l: LeadRow, now = new Date()): boolean {
  if (isOwner(user) || !isAdmin(user)) return false;
  const w = leadWindow(l, now);
  return !l.broker_id && l.status !== 'cerrado' && !w.priority && now < w.adminFrom;
}

const hour = (d: Date) => d.toLocaleTimeString('es-MX', { timeZone: env.TZ_APP, hour: 'numeric', minute: '2-digit', hourCycle: 'h12' });

/** «6:30 p.m.» ya termina en punto: no se agrega otro. */
const punto = (s: string) => (s.endsWith('.') ? s : s + '.');

/** Atender, agendar, proponer o escribir. La dueña siempre puede; con prioridad, solo el broker prioritario. */
export function assertMayAct(user: AuthUser, l: LeadRow, now = new Date()): void {
  if (l.broker_id || isOwner(user)) return;
  const w = leadWindow(l, now);
  if (w.priority) {
    if (w.priority.brokerId === user.id) return;
    throw new AppError(403, 'LEAD_PRIORITY', punto(`Prioridad de ${w.priority.brokerName} hasta las ${hour(w.priority.until)}`));
  }
  if (isAdmin(user) && now < w.adminFrom) throw new AppError(403, 'LEAD_ADMIN_WAIT', punto(`Administración puede tomarla desde las ${hour(w.adminFrom)}`));
}

/** Aviso único a la dueña por cada solicitud sin atender. Corre cuando alguien consulta solicitudes o el inicio. */
export async function warnOwnerOfUnattended(): Promise<void> {
  try {
    const { rows } = await pool.query<{ id: string; folio: string; name: string }>(
      `SELECT l.id, l.folio, l.name FROM leads l
        WHERE l.broker_id IS NULL AND l.status <> 'cerrado' AND l.created_at <= now() - make_interval(mins => $1::int)
          AND NOT EXISTS (SELECT 1 FROM reminder_log r WHERE r.kind = 'lead_unattended' AND r.entity_id = l.id)
        ORDER BY l.created_at LIMIT 20`,
      [env.LEAD_ESCALATE_MINUTES],
    );
    if (!rows.length) return;
    const { rows: owners } = await pool.query<{ id: string }>(
      `SELECT u.id FROM users u JOIN user_roles ur ON ur.user_id = u.id JOIN roles r ON r.id = ur.role_id WHERE r.code = 'owner' AND u.active`,
    );
    for (const l of rows) {
      const { rowCount } = await pool.query(
        `INSERT INTO reminder_log (kind, entity_id, sent_on) VALUES ('lead_unattended', $1, CURRENT_DATE) ON CONFLICT DO NOTHING`,
        [l.id],
      );
      if (rowCount) {
        await notify(owners.map((o) => o.id), { type: 'lead_unattended', title: 'Solicitud sin atender', message: `${l.name} · folio ${l.folio}. Nadie la ha tomado; asígnala a un broker.`, entity: 'lead', entityId: l.id });
      }
    }
  } catch (err) {
    // Un aviso que falla no debe impedir ver las solicitudes
    logger.error({ err: (err as Error).message }, 'No se pudo avisar de solicitudes sin atender');
  }
}
