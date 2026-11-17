import type { RequestHandler } from 'express';
import { z } from 'zod';
import { pool } from '../config/database.js';
import { currentUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { pagination, paged } from '../middlewares/validate.js';

export const listQueryDto = pagination.extend({ unread: z.enum(['true', 'false']).transform((v) => v === 'true').optional() });
export const deviceDto = z.object({
  fcmToken: z.string().min(20, 'Token de dispositivo no válido.').max(4096),
  platform: z.enum(['android', 'ios', 'web']),
});

/** GET /notifications — bandeja propia, con el total sin leer (para el contador de la campana). */
export const list: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const filter = q.unread ? 'AND NOT read' : '';
  const total = await pool.query<{ n: string }>(`SELECT count(*) AS n FROM notifications WHERE user_id = $1 ${filter}`, [user.id]);
  const unread = await pool.query<{ n: string }>('SELECT count(*) AS n FROM notifications WHERE user_id = $1 AND NOT read', [user.id]);
  const { rows } = await pool.query(
    `SELECT id, type, title, message, entity, entity_id AS "entityId", read, sent_at AS "sentAt"
       FROM notifications WHERE user_id = $1 ${filter} ORDER BY sent_at DESC LIMIT $2 OFFSET $3`,
    [user.id, q.limit, (q.page - 1) * q.limit],
  );
  res.json({ ...paged(rows, Number(total.rows[0].n), q), unreadCount: Number(unread.rows[0].n) });
};

export const markRead: RequestHandler = async (_req, res) => {
  const { rowCount } = await pool.query('UPDATE notifications SET read = TRUE WHERE id = $1 AND user_id = $2', [(res.locals.params as { id: string }).id, currentUser(res).id]);
  if (!rowCount) throw new AppError(404, 'NOT_FOUND', 'La notificación no existe.');
  res.status(204).end();
};

export const markAllRead: RequestHandler = async (_req, res) => {
  const { rowCount } = await pool.query('UPDATE notifications SET read = TRUE WHERE user_id = $1 AND NOT read', [currentUser(res).id]);
  res.json({ updated: rowCount ?? 0 });
};

/** POST /devices — registra (o reasigna) el token FCM del dispositivo para recibir push. */
export const registerDevice: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = res.locals.body as z.infer<typeof deviceDto>;
  await pool.query(
    `INSERT INTO devices (user_id, fcm_token, platform) VALUES ($1, $2, $3)
     ON CONFLICT (fcm_token) DO UPDATE SET user_id = EXCLUDED.user_id, platform = EXCLUDED.platform`,
    [user.id, d.fcmToken, d.platform],
  );
  res.status(204).end();
};

export const unregisterDevice: RequestHandler = async (req, res) => {
  await pool.query('DELETE FROM devices WHERE fcm_token = $1 AND user_id = $2', [String(req.params.token), currentUser(res).id]);
  res.status(204).end();
};
