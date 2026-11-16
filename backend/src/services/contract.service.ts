import { pool, withTransaction } from '../config/database.js';
import { env } from '../config/env.js';
import { AppError } from '../middlewares/error-handler.js';
import type { AuthUser } from '../middlewares/authenticate.js';
import { insertActivity } from '../models/activity.model.js';
import { assertPropertyAccess, isOwner } from './access.service.js';
import { cancelVisitsOfHouse } from './appointment.service.js';
import { notify, staffWithPermission, userOfClient } from './notification.service.js';

export interface ContractInput {
  propertyId: string;
  clientId: string;
  startDate: string;
  endDate: string;
  monthlyRent: number;
  paymentDay: number;
  deposit?: number | null;
  documentId?: string | null;
}

/**
 * Registra el contrato y genera un pagaré por mes: el primero es el día de pago del mes de inicio
 * (o del siguiente si ese día ya pasó) y el último, el que cae antes del fin del contrato.
 */
export async function createContract(user: AuthUser, c: ContractInput): Promise<string> {
  // Rentar lo decide el dueño de la empresa; administración solo da seguimiento a la casa ya rentada
  if (!isOwner(user)) throw new AppError(403, 'OWNER_ONLY', 'Solo el dueño puede rentar una casa.');
  await assertPropertyAccess(user, c.propertyId);
  const prop = await pool.query<{ name: string; operation: string; broker_id: string | null }>('SELECT name, operation, broker_id FROM properties WHERE id = $1', [c.propertyId]);
  if (prop.rows[0].operation !== 'renta') throw new AppError(409, 'NOT_FOR_RENT', 'Solo se registran contratos de renta en casas en renta.');
  const client = await pool.query<{ name: string }>('SELECT name FROM clients WHERE id = $1 AND active', [c.clientId]);
  if (!client.rows[0]) throw new AppError(404, 'NOT_FOUND', 'El cliente no existe.');

  // La renta no empieza en una fecha que ya pasó, ni antes de la visita de esa persona a esa casa
  const today = new Date().toLocaleDateString('en-CA', { timeZone: env.TZ_APP });
  if (c.startDate < today) {
    const msg = 'La renta no puede empezar en una fecha que ya pasó.';
    throw new AppError(400, 'VALIDATION_ERROR', msg, { startDate: [msg] });
  }
  const { rows: [visit] } = await pool.query<{ day: string | null }>(
    `SELECT to_char(max(scheduled_at AT TIME ZONE $3), 'YYYY-MM-DD') AS day FROM appointments
      WHERE client_id = $1 AND property_id = $2 AND status IN ('realizada', 'confirmada', 'por-confirmar')`,
    [c.clientId, c.propertyId, env.TZ_APP],
  );
  if (visit?.day && c.startDate < visit.day) {
    const msg = `La renta no puede empezar antes de la visita a la casa (${visit.day.split('-').reverse().join('/')}).`;
    throw new AppError(400, 'VALIDATION_ERROR', msg, { startDate: [msg] });
  }

  try {
    return await withTransaction(async (db) => {
      const { rows } = await db.query<{ id: string }>(
        `INSERT INTO contracts (property_id, client_id, start_date, end_date, monthly_rent, payment_day, deposit, document_id)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`,
        [c.propertyId, c.clientId, c.startDate, c.endDate, c.monthlyRent, c.paymentDay, c.deposit ?? null, c.documentId ?? null],
      );
      const id = rows[0].id;
      const notes = await db.query(
        `WITH base AS (
           SELECT make_date(EXTRACT(YEAR FROM $2::date)::int, EXTRACT(MONTH FROM $2::date)::int, $4::int) AS d
         ), first AS (
           SELECT CASE WHEN d >= $2::date THEN d ELSE (d + INTERVAL '1 month')::date END AS d FROM base
         )
         INSERT INTO promissory_notes (contract_id, number, amount, due_date)
         SELECT $1, n + 1, $5, (first.d + make_interval(months => n))::date
           FROM first, generate_series(0, 599) AS n
          WHERE (first.d + make_interval(months => n))::date <= $3::date`,
        [id, c.startDate, c.endDate, c.paymentDay, c.monthlyRent],
      );
      if (!notes.rowCount) throw new AppError(400, 'VALIDATION_ERROR', 'Con esas fechas no cae ningún día de pago. Revisa el inicio, el fin y el día de pago.');
      await db.query(`UPDATE properties SET status = 'rentada', visibility = 'pausada', updated_at = now() WHERE id = $1`, [c.propertyId]);
      await cancelVisitsOfHouse(db, c.propertyId, 'La casa ya se rentó.');
      // Quien la rentó ya no busca esa casa: su solicitud termina aquí
      await db.query(`UPDATE leads SET status = 'cerrado' WHERE property_id = $1 AND client_id = $2 AND status <> 'cerrado'`, [c.propertyId, c.clientId]);
      await db.query(
        `UPDATE clients SET kind = 'inquilino', follow_status = 'Contrato vigente', property_id = $2, operation = 'Renta' WHERE id = $1`,
        [c.clientId, c.propertyId],
      );
      await db.query('INSERT INTO dossiers (property_id) VALUES ($1) ON CONFLICT (property_id) DO NOTHING', [c.propertyId]);
      await insertActivity({
        userId: user.id, propertyId: c.propertyId, entity: 'contract', entityId: id, action: 'create',
        description: `${user.name} registró el contrato de ${client.rows[0].name} en ${prop.rows[0].name} con ${notes.rowCount} pagarés.`,
        newValues: c,
      }, db);
      await notify([await userOfClient(c.clientId, db)], {
        type: 'contract_created', title: 'Tu contrato está listo', message: `Ya puedes consultar tu contrato y tus ${notes.rowCount} pagarés de ${prop.rows[0].name} en la app.`,
        entity: 'contract', entityId: id,
      }, db);
      // Nuevo inquilino: administración y el broker de la casa se enteran (la casa ya quedó rentada y pausada)
      const staff = [...(await staffWithPermission('properties.reassign', db)), prop.rows[0].broker_id].filter((u) => u && u !== user.id);
      await notify(staff, {
        type: 'tenant_created', title: 'Nuevo inquilino',
        message: `${client.rows[0].name} es inquilino de ${prop.rows[0].name}. La casa quedó rentada y se quitó del sitio (pausada).`,
        entity: 'contract', entityId: id,
      }, db);
      return id;
    });
  } catch (err) {
    if ((err as { code?: string }).code === '23505') throw new AppError(409, 'ACTIVE_CONTRACT_EXISTS', 'Esta casa ya tiene un contrato vigente.');
    throw err;
  }
}

/** Finaliza el contrato. Los pagarés sin pagar posteriores a la fecha de término quedan cancelados (no se borran). */
export async function finishContract(user: AuthUser, id: string, data: { endDate?: string; reason?: string }): Promise<void> {
  const { rows } = await pool.query<{ property_id: string; client_id: string; status: string; client_name: string; property_name: string; start_date: string }>(
    `SELECT ct.property_id, ct.client_id, ct.status, c.name AS client_name, p.name AS property_name, to_char(ct.start_date, 'YYYY-MM-DD') AS start_date
       FROM contracts ct JOIN clients c ON c.id = ct.client_id JOIN properties p ON p.id = ct.property_id WHERE ct.id = $1`,
    [id],
  );
  const ct = rows[0];
  if (!ct) throw new AppError(404, 'NOT_FOUND', 'El contrato no existe.');
  await assertPropertyAccess(user, ct.property_id);
  if (ct.status !== 'active') throw new AppError(409, 'CONTRACT_NOT_ACTIVE', 'El contrato ya no está vigente.');
  const endDate = data.endDate ?? new Date().toLocaleDateString('en-CA', { timeZone: env.TZ_APP });
  // Termina el mismo día que empezó (o antes): no llegó a correr, así que queda CANCELADO con todos sus pagarés
  // (la fecha de fin debe ser posterior al inicio y no se puede «finalizar» un contrato de cero días)
  const cancelledContract = endDate <= ct.start_date;

  await withTransaction(async (db) => {
    if (cancelledContract) await db.query(`UPDATE contracts SET status = 'cancelled' WHERE id = $1`, [id]);
    else await db.query(`UPDATE contracts SET status = 'finished', end_date = LEAST(end_date, $2::date) WHERE id = $1`, [id, endDate]);
    const cancelled = await db.query(
      `UPDATE promissory_notes SET status = 'cancelled' WHERE contract_id = $1 AND status IN ('pending', 'overdue') AND (due_date > $2::date OR $3)`,
      [id, endDate, cancelledContract],
    );
    await db.query(`UPDATE properties SET status = 'disponible', updated_at = now() WHERE id = $1`, [ct.property_id]);
    // Deja de ser inquilino: ya no ve la casa ni lo del siguiente inquilino (su historial se conserva)
    await db.query(`UPDATE clients SET kind = 'cliente', follow_status = 'Contrato finalizado' WHERE id = $1`, [ct.client_id]);
    await insertActivity({
      userId: user.id, propertyId: ct.property_id, entity: 'contract', entityId: id, action: 'finish',
      description: `${user.name} ${cancelledContract ? 'canceló (el mismo día que empezaba)' : 'finalizó'} el contrato de ${ct.client_name} en ${ct.property_name}${data.reason ? ` (${data.reason})` : ''}; ${cancelled.rowCount} pagarés quedaron cancelados.`,
    }, db);
  });
}
