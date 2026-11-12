import { pool, type Db } from '../config/database.js';
import { bump } from './live.service.js';
import { pushToUser } from './push.service.js';

/*
 * Notificaciones: se guarda el registro (para la bandeja de la app) y se envía push.
 * Destinatarios típicos: cliente vinculado, broker responsable y administradores con permiso.
 */
export interface NotificationInput {
  type: string;
  title: string;
  message: string;
  entity?: string;
  entityId?: string;
}

export async function notify(userIds: (string | null | undefined)[], n: NotificationInput, db: Db = pool): Promise<void> {
  const ids = [...new Set(userIds.filter((id): id is string => !!id))];
  for (const userId of ids) {
    await db.query(
      `INSERT INTO notifications (user_id, type, title, message, entity, entity_id) VALUES ($1, $2, $3, $4, $5, $6)`,
      [userId, n.type, n.title, n.message, n.entity ?? null, n.entityId ?? null],
    );
  }
  // Aviso en tiempo real (también para las tareas programadas, que no pasan por una petición).
  // Con un pequeño retraso: si se notificó dentro de una transacción, para entonces ya se guardó.
  if (ids.length) setTimeout(() => bump('notifications'), 500).unref();
  // El push sale después de guardar; si falla no afecta la operación.
  for (const userId of ids) {
    void pushToUser(userId, { title: n.title, body: n.message, data: { type: n.type, entity: n.entity ?? '', entityId: n.entityId ?? '' } });
  }
}

/** Broker responsable de una propiedad. */
export async function brokerOf(propertyId: string, db: Db = pool): Promise<string | null> {
  const { rows } = await db.query<{ broker_id: string | null }>('SELECT broker_id FROM properties WHERE id = $1', [propertyId]);
  return rows[0]?.broker_id ?? null;
}

/** Cuenta de usuario del cliente (si tiene app). */
export async function userOfClient(clientId: string | null | undefined, db: Db = pool): Promise<string | null> {
  if (!clientId) return null;
  const { rows } = await db.query<{ user_id: string | null }>('SELECT user_id FROM clients WHERE id = $1', [clientId]);
  return rows[0]?.user_id ?? null;
}

/** Cuenta del inquilino con contrato vigente en la propiedad. */
export async function tenantUserOf(propertyId: string, db: Db = pool): Promise<string | null> {
  const { rows } = await db.query<{ user_id: string | null }>(
    `SELECT c.user_id FROM contracts ct JOIN clients c ON c.id = ct.client_id
      WHERE ct.property_id = $1 AND ct.status = 'active' LIMIT 1`,
    [propertyId],
  );
  return rows[0]?.user_id ?? null;
}

/** Personal activo que tiene un permiso (p. ej. administradores con notifications.overdue). */
/** Brokers que no son administración: son los primeros en ver una solicitud del pool. */
export async function plainBrokers(db: Db = pool): Promise<string[]> {
  const { rows } = await db.query<{ id: string }>(
    `SELECT u.id FROM users u WHERE u.active AND u.type = 'staff'
        AND EXISTS (SELECT 1 FROM user_roles ur JOIN roles r ON r.id = ur.role_id WHERE ur.user_id = u.id AND r.code = 'broker')
        AND NOT EXISTS (SELECT 1 FROM user_roles ur JOIN roles r ON r.id = ur.role_id WHERE ur.user_id = u.id AND r.code IN ('admin', 'owner'))`,
  );
  return rows.map((r) => r.id);
}

export async function staffWithPermission(code: string, db: Db = pool): Promise<string[]> {
  const { rows } = await db.query<{ id: string }>(
    `SELECT DISTINCT u.id FROM users u
       JOIN user_roles ur ON ur.user_id = u.id
       JOIN role_permissions rp ON rp.role_id = ur.role_id
       JOIN permissions p ON p.id = rp.permission_id
      WHERE p.code = $1 AND u.active AND u.type = 'staff'`,
    [code],
  );
  return rows.map((r) => r.id);
}

/** Administradores (y propietario) activos. */
export async function admins(db: Db = pool): Promise<string[]> {
  const { rows } = await db.query<{ id: string }>(
    `SELECT DISTINCT u.id FROM users u JOIN user_roles ur ON ur.user_id = u.id JOIN roles r ON r.id = ur.role_id
      WHERE r.code IN ('admin', 'owner') AND u.active`,
  );
  return rows.map((r) => r.id);
}
