import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';
import { pool } from '../config/database.js';

/*
 * Notificaciones push. Interfaz única con dos implementaciones:
 * - mock (desarrollo y pruebas): no envía nada, solo registra cuántos dispositivos habría avisado.
 * - fcm: Firebase Cloud Messaging HTTP v1 con la cuenta de servicio de FCM_* (sin dependencias extra).
 */
export interface PushMessage {
  title: string;
  body: string;
  data?: Record<string, string>;
}

export const mockPushLog: { userId: string; message: PushMessage }[] = [];

let cachedToken: { value: string; exp: number } | null = null;

async function fcmAccessToken(): Promise<string> {
  if (cachedToken && cachedToken.exp > Date.now() + 60_000) return cachedToken.value;
  const now = Math.floor(Date.now() / 1000);
  const assertion = jwt.sign(
    { iss: env.FCM_CLIENT_EMAIL, scope: 'https://www.googleapis.com/auth/firebase.messaging', aud: 'https://oauth2.googleapis.com/token', iat: now, exp: now + 3600 },
    env.FCM_PRIVATE_KEY.replace(/\\n/g, '\n'),
    { algorithm: 'RS256' },
  );
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion }),
  });
  if (!res.ok) throw new Error(`FCM token ${res.status}`);
  const body = (await res.json()) as { access_token: string; expires_in: number };
  cachedToken = { value: body.access_token, exp: Date.now() + body.expires_in * 1000 };
  return body.access_token;
}

async function sendFcm(token: string, message: PushMessage): Promise<'ok' | 'invalid' | 'error'> {
  const res = await fetch(`https://fcm.googleapis.com/v1/projects/${env.FCM_PROJECT_ID}/messages:send`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${await fcmAccessToken()}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      message: {
        token,
        notification: { title: message.title, body: message.body },
        data: message.data ?? {},
        // Android: que aparezca aunque la app esté cerrada; iPhone: con sonido.
        android: { priority: 'high', notification: { sound: 'default' } },
        apns: { payload: { aps: { sound: 'default' } } },
      },
    }),
  });
  if (res.ok) return 'ok';
  return res.status === 404 || res.status === 400 ? 'invalid' : 'error';
}

/** Envía a todos los dispositivos del usuario. Nunca lanza: un fallo de push no debe romper la operación. */
export async function pushToUser(userId: string, message: PushMessage): Promise<void> {
  try {
    if (env.PUSH_DRIVER === 'mock') {
      mockPushLog.push({ userId, message });
      if (mockPushLog.length > 200) mockPushLog.shift();
      return;
    }
    const { rows } = await pool.query<{ fcm_token: string }>('SELECT fcm_token FROM devices WHERE user_id = $1', [userId]);
    for (const { fcm_token } of rows) {
      const result = await sendFcm(fcm_token, message);
      if (result === 'invalid') await pool.query('DELETE FROM devices WHERE fcm_token = $1', [fcm_token]);
    }
  } catch (err) {
    logger.warn({ err: (err as Error).message }, 'No se pudo enviar la notificación push');
  }
}
