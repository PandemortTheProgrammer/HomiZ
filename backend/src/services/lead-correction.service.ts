import { timingSafeEqual } from 'node:crypto';
import { withTransaction } from '../config/database.js';
import { AppError } from '../middlewares/error-handler.js';
import { insertActivity } from '../models/activity.model.js';
import * as Users from '../models/user.model.js';
import { ensureClientAccount, sendAccountReady } from './auth.service.js';
import { hashOpaqueToken } from './token.service.js';

/* ==========================================================================
   «Cambiar mis datos» después de enviar un formulario del sitio (decisión 108).
   Al enviar, el sitio recibe un permiso firmado que vale 2 horas para corregir nombre, correo y teléfono.
   Si cambia el correo:
   - la cuenta que se creó con el correo equivocado (y nunca se usó) pasa al correo correcto con una
     contraseña temporal nueva: la del correo equivocado deja de servir;
   - si el correo correcto ya tiene cuenta, la solicitud y su cita pasan a esa cuenta y la equivocada se da de baja;
   - si la cuenta anterior ya existía o ya se usó, no se toca: se crea (o usa) la del correo correcto.
   ========================================================================== */
const TTL_MINUTES = 120;

export function correctionToken(leadId: string, created: boolean, userId: string | null): string {
  const exp = Math.floor(Date.now() / 1000) + TTL_MINUTES * 60;
  const body = `${leadId}.${created ? 1 : 0}.${userId ?? ''}.${exp}`;
  return `${Buffer.from(body).toString('base64url')}.${hashOpaqueToken('lead-fix:' + body)}`;
}

function readToken(token: string): { leadId: string; created: boolean; userId: string | null } | null {
  const [b64, sig] = token.split('.');
  if (!b64 || !sig) return null;
  const body = Buffer.from(b64, 'base64url').toString();
  const expected = hashOpaqueToken('lead-fix:' + body);
  if (expected.length !== sig.length || !timingSafeEqual(Buffer.from(expected), Buffer.from(sig))) return null;
  const [leadId, created, userId, exp] = body.split('.');
  if (!leadId || Number(exp) * 1000 < Date.now()) return null;
  return { leadId, created: created === '1', userId: userId || null };
}

export interface Correction { name?: string; email?: string; phone?: string | null }

export async function correctLead(folio: string, token: string, d: Correction) {
  const t = readToken(token);
  const expired = new AppError(403, 'CORRECTION_EXPIRED', 'Ya no se pueden cambiar los datos desde aquí (pasaron más de 2 horas). Escríbenos o corrígelos en la app.');
  if (!t) throw expired;

  return withTransaction(async (db) => {
    const { rows: [lead] } = await db.query<{ id: string; folio: string; name: string; email: string; phone: string | null; client_id: string | null }>(
      'SELECT id, folio, name, email, phone, client_id FROM leads WHERE folio = $1 FOR UPDATE',
      [folio],
    );
    if (!lead || lead.id !== t.leadId) throw expired;

    const name = d.name?.trim() || lead.name;
    const phone = d.phone === undefined ? lead.phone : d.phone?.trim() || null;
    const email = d.email?.trim().toLowerCase() || lead.email;
    const emailChanged = email !== lead.email.toLowerCase();
    await db.query('UPDATE leads SET name = $2, email = $3, phone = $4 WHERE id = $1', [lead.id, name, email, phone]);

    let clientId = lead.client_id;
    let userId = t.userId;
    let created = t.created;
    let account: 'created' | 'existing' = t.created ? 'created' : 'existing';

    if (emailChanged) {
      // ¿La cuenta del correo equivocado se creó con este formulario y nunca se usó?
      const old = t.userId ? (await db.query<{ id: string; must_change_password: boolean; used: boolean }>(
        `SELECT u.id, u.must_change_password, EXISTS (SELECT 1 FROM refresh_tokens r WHERE r.user_id = u.id) AS used FROM users u WHERE u.id = $1`,
        [t.userId],
      )).rows[0] : undefined;
      const removable = !!old && t.created && old.must_change_password && !old.used;
      const taken = await Users.findByEmail(email, db);

      if (taken && taken.id !== t.userId) {
        // El correo correcto ya tiene cuenta: la solicitud y su cita pasan a esa cuenta
        const acc = await ensureClientAccount({ name, email, phone }, db);
        await moveTo(acc.clientId);
        if (removable) {
          await db.query(`UPDATE users SET active = FALSE, email = 'baja-' || id || '@invalido.zugar' WHERE id = $1`, [old!.id]);
          await db.query('UPDATE clients SET active = FALSE WHERE user_id = $1', [old!.id]);
        }
        userId = acc.userId; created = false; account = 'existing';
      } else if (removable) {
        // La misma cuenta pasa al correo correcto; la contraseña temporal anterior deja de servir
        await db.query('UPDATE users SET email = $2, name = $3, phone = COALESCE($4, phone) WHERE id = $1', [old!.id, email, name, phone]);
        await db.query('UPDATE clients SET email = $2, name = $3, phone = COALESCE($4, phone) WHERE user_id = $1', [old!.id, email, name, phone]);
        await db.query('DELETE FROM password_resets WHERE user_id = $1', [old!.id]);
        await sendAccountReady({ id: old!.id, name, email, type: 'client' }, db);
        account = 'created';
      } else {
        // La cuenta anterior ya existía o ya se usó: no se toca; se crea la del correo correcto
        const acc = await ensureClientAccount({ name, email, phone }, db);
        await moveTo(acc.clientId);
        userId = acc.userId; created = acc.created; account = acc.created ? 'created' : 'existing';
      }
    } else if (clientId) {
      await db.query('UPDATE clients SET name = $2, phone = COALESCE($3, phone) WHERE id = $1', [clientId, name, phone]);
    }

    async function moveTo(newClient: string) {
      await db.query('UPDATE leads SET client_id = $2 WHERE id = $1', [lead.id, newClient]);
      await db.query('UPDATE appointments SET client_id = $2 WHERE lead_id = $1', [lead.id, newClient]);
      clientId = newClient;
    }

    await insertActivity({
      userId, entity: 'lead', entityId: lead.id, action: 'correct',
      description: `La persona corrigió sus datos de la solicitud ${lead.folio}${emailChanged ? ` (correo: ${lead.email} → ${email})` : ''}.`,
      oldValues: { name: lead.name, email: lead.email, phone: lead.phone }, newValues: { name, email, phone },
    }, db);

    return { folio: lead.folio, name, email, phone, account, editToken: correctionToken(lead.id, created, userId) };
  });
}
