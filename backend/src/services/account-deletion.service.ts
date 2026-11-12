import { randomUUID } from 'node:crypto';
import { withTransaction } from '../config/database.js';
import { AppError } from '../middlewares/error-handler.js';
import { insertActivity } from '../models/activity.model.js';
import { hashPassword } from './password.service.js';

/**
 * «Eliminar mi cuenta» (derecho de cancelación, LFPDPPP; requisito de Google Play).
 * - Con contrato vigente no se puede: los datos se necesitan para cumplir el contrato.
 * - Se borran o anonimizan los datos personales: cuenta, sesiones, dispositivos, avisos, solicitudes y su expediente
 *   de contacto. Las citas futuras se cancelan.
 * - Lo que la ley obliga a conservar (contratos y pagos terminados, para efectos fiscales) se queda, pero el
 *   expediente queda dado de baja y sin datos de contacto; el nombre solo se conserva si hubo contrato.
 * - Solo para cuentas de cliente: las del personal las da de baja administración.
 */
export async function deleteClientAccount(userId: string): Promise<void> {
  await withTransaction(async (db) => {
    const { rows: [u] } = await db.query<{ type: string }>('SELECT type FROM users WHERE id = $1 AND active FOR UPDATE', [userId]);
    if (!u) throw new AppError(404, 'NOT_FOUND', 'La cuenta no existe.');
    if (u.type !== 'client') throw new AppError(403, 'FORBIDDEN', 'Las cuentas del personal las da de baja administración.');
    const { rows: clients } = await db.query<{ id: string; has_contract: boolean }>(
      // Contrato de renta o compra registrada: el nombre se conserva (obligación fiscal y Ley Antilavado)
      `SELECT c.id, (EXISTS (SELECT 1 FROM contracts ct WHERE ct.client_id = c.id) OR EXISTS (SELECT 1 FROM sales s WHERE s.client_id = c.id)) AS has_contract
         FROM clients c WHERE c.user_id = $1`,
      [userId],
    );
    const ids = clients.map((c) => c.id);
    if (ids.length) {
      const active = await db.query(`SELECT 1 FROM contracts WHERE client_id = ANY($1::uuid[]) AND status = 'active' LIMIT 1`, [ids]);
      if (active.rowCount) {
        throw new AppError(409, 'HAS_ACTIVE_CONTRACT', 'Tienes un contrato de renta vigente: conservamos tus datos mientras dure. Al terminarlo podrás eliminar tu cuenta; si necesitas algo antes, escríbenos.');
      }
    }
    const gone = `eliminada-${randomUUID()}@homiz.invalid`;

    // Solicitudes y sus mensajes: sin datos de la persona
    await db.query(
      `UPDATE leads SET name = 'Persona eliminada', email = $2, phone = NULL, message = NULL, payload = '{}'::jsonb, response = NULL
        WHERE client_id = ANY($1::uuid[]) OR lower(email) = (SELECT lower(email) FROM users WHERE id = $3)`,
      [ids, gone, userId],
    );
    await db.query(`DELETE FROM lead_messages WHERE sender_id = $1`, [userId]);
    await db.query(`DELETE FROM appointment_messages WHERE sender_id = $1`, [userId]);
    // Citas por venir: se cancelan (las pasadas quedan como historial de la casa, sin datos de contacto)
    await db.query(
      `UPDATE appointments SET status = 'cancelada', reason = 'La persona eliminó su cuenta.'
        WHERE client_id = ANY($1::uuid[]) AND status IN ('por-confirmar', 'confirmada')`,
      [ids],
    );
    // Expediente: dado de baja y sin datos de contacto; el nombre solo se conserva si hubo contrato (obligación fiscal)
    for (const c of clients) {
      await db.query(
        `UPDATE clients SET ${c.has_contract ? '' : `name = 'Persona eliminada',`} email = NULL, phone = NULL, address = NULL, nationality = NULL,
                occupation = NULL, needs = NULL, budget = NULL, budget_amount = NULL, label = NULL, active = FALSE, user_id = NULL
          WHERE id = $1`,
        [c.id],
      );
    }
    // Cuenta: sin datos, sin forma de entrar y sin sesiones ni dispositivos
    await db.query(`DELETE FROM refresh_tokens WHERE user_id = $1`, [userId]);
    await db.query(`DELETE FROM password_resets WHERE user_id = $1`, [userId]);
    await db.query(`DELETE FROM devices WHERE user_id = $1`, [userId]);
    await db.query(`DELETE FROM notifications WHERE user_id = $1`, [userId]);
    await db.query(
      `UPDATE users SET name = 'Cuenta eliminada', email = $2, phone = NULL, birth_date = NULL, photo_key = NULL, initials = NULL,
              active = FALSE, must_change_password = FALSE, failed_attempts = 0, locked_until = NULL, password_hash = $3
        WHERE id = $1`,
      [userId, gone, await hashPassword(randomUUID() + randomUUID())],
    );
    await insertActivity({ userId, entity: 'auth', action: 'account_deleted', description: 'Una persona eliminó su cuenta (sus datos personales se anonimizaron).' }, db);
  });
}
