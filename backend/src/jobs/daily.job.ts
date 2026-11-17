import cron from 'node-cron';
import { withTransaction, type Db } from '../config/database.js';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';
import { notify, staffWithPermission } from '../services/notification.service.js';

/*
 * Tareas diarias (07:00 hora de Cancún por defecto):
 * 1. Marcar como vencidos los pagarés y recibos cuya fecha ya pasó, y avisar.
 * 2. Recordar pagarés y recibos que vencen en los próximos 3 días.
 * 3. Avisar al personal de mantenimientos programados en los próximos 7 días y de gastos pendientes.
 * 4. Recordar al inquilino, el día elegido de cada mes, revisar sus recibos de agua y luz con su número de servicio.
 * Cada aviso se registra en reminder_log para no repetirlo el mismo día (o la misma semana, en gastos).
 */

const REMIND_DAYS = 3;
const MAINTENANCE_DAYS = 7;

const money = (n: number) => `$${Number(n).toLocaleString('en-US')}`;
const fmt = (iso: string) => iso.split('-').reverse().join('/');

/** Fecha de hoy en la zona horaria de la app (AAAA-MM-DD). */
export function todayInAppZone(now = new Date()): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone: env.TZ_APP }).format(now);
}

/** Registra el recordatorio; devuelve false si ya se había enviado ese día. */
async function firstTime(db: Db, kind: string, entityId: string, sentOn: string): Promise<boolean> {
  const { rowCount } = await db.query('INSERT INTO reminder_log (kind, entity_id, sent_on) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING', [kind, entityId, sentOn]);
  return (rowCount ?? 0) > 0;
}

interface DueNote {
  id: string;
  number: number;
  amount: number;
  due_date: string;
  property_name: string;
  broker_id: string | null;
  client_user_id: string | null;
  client_name: string;
}

const NOTE_SQL = `
  SELECT n.id, n.number, n.amount, to_char(n.due_date, 'YYYY-MM-DD') AS due_date, p.name AS property_name, p.broker_id,
         c.user_id AS client_user_id, c.name AS client_name
    FROM promissory_notes n JOIN contracts ct ON ct.id = n.contract_id
    JOIN properties p ON p.id = ct.property_id JOIN clients c ON c.id = ct.client_id`;

interface DueReceipt {
  id: string;
  concept: string;
  amount: number;
  due_date: string;
  property_name: string;
  broker_id: string | null;
  client_user_id: string | null;
}

const RECEIPT_SQL = `
  SELECT r.id, r.concept, r.amount, to_char(r.due_date, 'YYYY-MM-DD') AS due_date, p.name AS property_name, p.broker_id,
         (SELECT c.user_id FROM contracts ct JOIN clients c ON c.id = ct.client_id WHERE ct.property_id = r.property_id AND ct.status = 'active' LIMIT 1) AS client_user_id
    FROM receipts r JOIN properties p ON p.id = r.property_id`;

export interface DailyResult {
  overdueNotes: number;
  overdueReceipts: number;
  noteReminders: number;
  receiptReminders: number;
  maintenanceReminders: number;
  expenseReminders: number;
  utilityReminders: number;
  maintenanceFeeReminders: number;
  anonymizedLeads: number;
}

export async function runDailyJobs(today = todayInAppZone()): Promise<DailyResult> {
  const result: DailyResult = { overdueNotes: 0, overdueReceipts: 0, noteReminders: 0, receiptReminders: 0, maintenanceReminders: 0, expenseReminders: 0, utilityReminders: 0, maintenanceFeeReminders: 0, anonymizedLeads: 0 };
  const watchers = await staffWithPermission('notifications.overdue');

  await withTransaction(async (db) => {
    /* 1. Vencidos */
    const overdueIds = (await db.query<{ id: string }>(
      `UPDATE promissory_notes SET status = 'overdue' WHERE status = 'pending' AND due_date < $1::date RETURNING id`,
      [today],
    )).rows.map((r) => r.id);
    const overdueNotes = await db.query<DueNote>(`${NOTE_SQL} WHERE n.id = ANY($1::uuid[])`, [overdueIds]);
    for (const n of overdueNotes.rows) {
      result.overdueNotes++;
      await notify([n.client_user_id], { type: 'promissory_note_overdue', title: 'Pagaré vencido', message: `Tu pagaré ${String(n.number).padStart(2, '0')} de ${money(n.amount)} venció el ${fmt(n.due_date)}. Comunícate con tu asesora para pagarlo.`, entity: 'promissory_note', entityId: n.id }, db);
      await notify([n.broker_id, ...watchers], { type: 'promissory_note_overdue', title: 'Pagaré vencido', message: `${n.client_name} · ${n.property_name}: pagaré ${n.number} de ${money(n.amount)} venció el ${fmt(n.due_date)}.`, entity: 'promissory_note', entityId: n.id }, db);
    }

    const overdueReceipts = await db.query<{ id: string }>(`UPDATE receipts SET status = 'overdue' WHERE status = 'pending' AND due_date < $1::date RETURNING id`, [today]);
    if (overdueReceipts.rowCount) {
      const rows = (await db.query<DueReceipt>(`${RECEIPT_SQL} WHERE r.id = ANY($1::uuid[])`, [overdueReceipts.rows.map((r) => r.id)])).rows;
      for (const r of rows) {
        result.overdueReceipts++;
        await notify([r.client_user_id, r.broker_id, ...watchers], { type: 'receipt_overdue', title: `${r.concept} vencido`, message: `${r.property_name}: ${r.concept.toLowerCase()} de ${money(r.amount)} venció el ${fmt(r.due_date)}.`, entity: 'receipt', entityId: r.id }, db);
      }
    }

    /* 2. Próximos a vencer */
    const soonNotes = await db.query<DueNote>(`${NOTE_SQL} WHERE n.status = 'pending' AND n.due_date BETWEEN $1::date AND $1::date + $2::int`, [today, REMIND_DAYS]);
    for (const n of soonNotes.rows) {
      if (!(await firstTime(db, 'note_due', n.id, today))) continue;
      result.noteReminders++;
      await notify([n.client_user_id], { type: 'promissory_note_due', title: 'Pagaré próximo a vencer', message: `Tu pagaré ${String(n.number).padStart(2, '0')} de ${money(n.amount)} vence el ${fmt(n.due_date)}. Recuerda que se paga en persona en efectivo.`, entity: 'promissory_note', entityId: n.id }, db);
      await notify([n.broker_id, ...watchers], { type: 'promissory_note_due', title: 'Pagaré próximo a vencer', message: `${n.client_name} · ${n.property_name}: pagaré ${n.number} vence el ${fmt(n.due_date)}.`, entity: 'promissory_note', entityId: n.id }, db);
    }
    const soonReceipts = await db.query<DueReceipt>(`${RECEIPT_SQL} WHERE r.status = 'pending' AND r.due_date BETWEEN $1::date AND $1::date + $2::int`, [today, REMIND_DAYS]);
    for (const r of soonReceipts.rows) {
      if (!(await firstTime(db, 'receipt_due', r.id, today))) continue;
      result.receiptReminders++;
      await notify([r.client_user_id, r.broker_id, ...watchers], { type: 'receipt_due', title: `${r.concept} próximo a vencer`, message: `${r.property_name}: ${r.concept.toLowerCase()} de ${money(r.amount)} vence el ${fmt(r.due_date)}.`, entity: 'receipt', entityId: r.id }, db);
    }

    /* 3. Mantenimientos programados y gastos pendientes → broker y administración */
    const maint = await db.query<{ id: string; concept: string; date: string; property_name: string; broker_id: string | null }>(
      `SELECT e.id, e.concept, to_char(e.next_maintenance_date, 'YYYY-MM-DD') AS date, p.name AS property_name, p.broker_id
         FROM expenses e JOIN properties p ON p.id = e.property_id
        WHERE e.next_maintenance_date BETWEEN $1::date AND $1::date + $2::int`,
      [today, MAINTENANCE_DAYS],
    );
    for (const m of maint.rows) {
      if (!(await firstTime(db, 'maintenance_upcoming', m.id, today))) continue;
      result.maintenanceReminders++;
      await notify([m.broker_id, ...watchers], { type: 'maintenance_upcoming', title: 'Próximo mantenimiento', message: `${m.property_name}: ${m.concept} programado para el ${fmt(m.date)}.`, entity: 'expense', entityId: m.id }, db);
    }
    const pending = await db.query<{ id: string; concept: string; amount: number; property_name: string; broker_id: string | null }>(
      `SELECT e.id, e.concept, e.amount, p.name AS property_name, p.broker_id FROM expenses e JOIN properties p ON p.id = e.property_id
        WHERE e.status = 'pending' AND e.date <= $1::date
          AND NOT EXISTS (SELECT 1 FROM reminder_log l WHERE l.kind = 'expense_pending' AND l.entity_id = e.id AND l.sent_on > $1::date - 7)`,
      [today],
    );
    for (const e of pending.rows) {
      await firstTime(db, 'expense_pending', e.id, today);
      result.expenseReminders++;
      await notify([e.broker_id, ...watchers], { type: 'expense_pending', title: 'Gasto pendiente de pago', message: `${e.property_name}: ${e.concept} por ${money(e.amount)} sigue pendiente.`, entity: 'expense', entityId: e.id }, db);
    }

    /* 4. Servicios de agua y luz: el día elegido de cada mes, al inquilino se le recuerda revisar sus recibos
          en la app de CFE y de Aguakan con su número de servicio (no se le envía el recibo). */
    const day = Number(today.slice(8, 10));
    const utilities = await db.query<{ id: string; name: string; electricity: string | null; water: string | null; client_user_id: string | null }>(
      `SELECT p.id, p.name, p.electricity_service_number AS electricity, p.water_service_number AS water, c.user_id AS client_user_id
         FROM properties p JOIN contracts ct ON ct.property_id = p.id AND ct.status = 'active' JOIN clients c ON c.id = ct.client_id
        WHERE p.utility_reminder_day = $1 AND (p.electricity_service_number IS NOT NULL OR p.water_service_number IS NOT NULL)`,
      [day],
    );
    for (const u of utilities.rows) {
      if (!(await firstTime(db, 'utility_reminder', u.id, today))) continue;
      result.utilityReminders++;
      const parts = [u.electricity && `luz en la app CFE Contigo con tu número de servicio ${u.electricity}`, u.water && `agua en la app de Aguakan con tu número de contrato ${u.water}`].filter(Boolean);
      await notify([u.client_user_id], {
        type: 'utility_reminder', title: 'Revisa tus recibos de agua y luz',
        message: `${u.name}: consulta tu recibo de ${parts.join(' y de ')}.`, entity: 'property', entityId: u.id,
      }, db);
    }

    /* 6. Conservación (aviso de privacidad): las solicitudes de más de 2 años de personas que nunca rentaron ni compraron
          se anonimizan; las de quien tuvo contrato se conservan por obligación fiscal. */
    const purged = await db.query(
      `UPDATE leads l SET name = 'Persona eliminada', email = 'anonimizada-' || l.id || '@homiz.invalid', phone = NULL,
              message = NULL, payload = '{}'::jsonb, response = NULL
        WHERE l.created_at < $1::date - interval '2 years' AND l.name <> 'Persona eliminada'
          AND NOT EXISTS (SELECT 1 FROM contracts ct WHERE ct.client_id = l.client_id)`,
      [today],
    );
    result.anonymizedLeads = purged.rowCount ?? 0;

    /* 5. Cuota de mantenimiento: el día que capturó administración, se recuerda a administración, al broker de la casa
          y al inquilino (si la casa está rentada) que toca pagarla. */
    const fees = await db.query<{ id: string; name: string; fee: string; broker_id: string | null; client_user_id: string | null }>(
      `SELECT p.id, p.name, p.maintenance_fee AS fee, p.broker_id, c.user_id AS client_user_id
         FROM properties p
         LEFT JOIN contracts ct ON ct.property_id = p.id AND ct.status = 'active'
         LEFT JOIN clients c ON c.id = ct.client_id
        WHERE p.active AND p.maintenance_fee_day = $1 AND p.maintenance_fee > 0`,
      [day],
    );
    for (const f of fees.rows) {
      if (!(await firstTime(db, 'maintenance_fee', f.id, today))) continue;
      result.maintenanceFeeReminders++;
      const text = `${f.name}: hoy toca pagar la cuota de mantenimiento de ${money(Number(f.fee))}.`;
      await notify([f.broker_id, ...watchers], { type: 'maintenance_fee', title: 'Pago de mantenimiento', message: text, entity: 'property', entityId: f.id }, db);
      if (f.client_user_id) {
        await notify([f.client_user_id], { type: 'maintenance_fee', title: 'Pago de mantenimiento', message: text, entity: 'property', entityId: f.id }, db);
      }
    }
  });
  return result;
}

/** Programa la tarea diaria. No se usa en pruebas (ahí se llama runDailyJobs directamente). */
export function scheduleDailyJobs(): void {
  if (env.JOBS_ENABLED !== 'true' || env.isTest) return;
  cron.schedule(
    env.JOBS_CRON,
    () => {
      runDailyJobs()
        .then((r) => logger.info(r, 'Tareas diarias completadas'))
        .catch((err) => logger.error({ err: err.message }, 'Error en las tareas diarias'));
    },
    { timezone: env.TZ_APP },
  );
  logger.info(`Tareas diarias programadas (${env.JOBS_CRON}, ${env.TZ_APP})`);
}
