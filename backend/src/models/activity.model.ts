import { pool, type Db } from '../config/database.js';

/* Historial: solo inserción (la base rechaza UPDATE y DELETE con un trigger). */

export interface ActivityInput {
  userId?: string | null;
  propertyId?: string | null;
  entity: string;
  entityId?: string | null;
  action: string;
  description?: string | null;
  oldValues?: unknown;
  newValues?: unknown;
}

export async function insertActivity(a: ActivityInput, db: Db = pool): Promise<void> {
  await db.query(
    `INSERT INTO activity_log (user_id, property_id, entity, entity_id, action, description, old_values, new_values)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
    [
      a.userId ?? null,
      a.propertyId ?? null,
      a.entity,
      a.entityId ?? null,
      a.action,
      a.description ?? null,
      a.oldValues === undefined ? null : JSON.stringify(a.oldValues),
      a.newValues === undefined ? null : JSON.stringify(a.newValues),
    ],
  );
}

export interface ActivityFilters {
  propertyId?: string;
  /** Si se indica, solo se devuelven registros de estas propiedades (alcance de un broker). */
  propertyIds?: string[];
  entity?: string;
  action?: string;
  from?: string;
  to?: string;
  page: number;
  limit: number;
}

export interface ActivityRow {
  id: string;
  user_id: string | null;
  user_name: string | null;
  property_id: string | null;
  property_code: string | null;
  property_name: string | null;
  entity: string;
  entity_id: string | null;
  action: string;
  description: string | null;
  old_values: unknown;
  new_values: unknown;
  created_at: Date;
}

export async function listActivity(f: ActivityFilters): Promise<{ rows: ActivityRow[]; total: number }> {
  const where: string[] = [];
  const params: unknown[] = [];
  const add = (sql: string, value: unknown) => {
    params.push(value);
    where.push(sql.replace('?', `$${params.length}`));
  };
  if (f.propertyIds) add('a.property_id = ANY(?::uuid[])', f.propertyIds);
  if (f.propertyId) add('a.property_id = ?', f.propertyId);
  if (f.entity) add('a.entity = ?', f.entity);
  if (f.action) add('a.action = ?', f.action);
  if (f.from) add('a.created_at >= ?::timestamptz', f.from);
  if (f.to) add('a.created_at < ?::timestamptz', f.to);
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';

  const total = await pool.query<{ count: string }>(`SELECT count(*) FROM activity_log a ${whereSql}`, params);
  params.push(f.limit, (f.page - 1) * f.limit);
  const { rows } = await pool.query<ActivityRow>(
    `SELECT a.id, a.user_id, u.name AS user_name, a.property_id, p.code AS property_code, p.name AS property_name,
            a.entity, a.entity_id, a.action, a.description, a.old_values, a.new_values, a.created_at
       FROM activity_log a
       LEFT JOIN users u ON u.id = a.user_id
       LEFT JOIN properties p ON p.id = a.property_id
       ${whereSql}
      ORDER BY a.created_at DESC
      LIMIT $${params.length - 1} OFFSET $${params.length}`,
    params,
  );
  return { rows, total: Number(total.rows[0].count) };
}
