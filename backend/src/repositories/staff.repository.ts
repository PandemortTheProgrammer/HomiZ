import { pool, type Db } from '../config/database.js';

/* ==========================================================================
   Repositorio del personal (brokers, administración y propietario): SQL de /users y /users/roles.
   Las funciones que reciben `db` se usan dentro de una transacción del controlador.
   ========================================================================== */

export interface StaffRow {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  initials: string | null;
  zones: string | null;
  specialty: string | null;
  active: boolean;
  roles: string[];
  properties: number;
  locked_until: Date | null;
  created_at: Date;
}

const SELECT = `
  SELECT u.id, u.name, u.email, u.phone, u.initials, u.zones, u.specialty, u.active, u.locked_until, u.created_at,
         COALESCE(array_agg(DISTINCT r.code) FILTER (WHERE r.code IS NOT NULL), '{}') AS roles,
         (SELECT count(*)::int FROM properties p WHERE p.broker_id = u.id AND p.active) AS properties
    FROM users u
    LEFT JOIN user_roles ur ON ur.user_id = u.id
    LEFT JOIN roles r ON r.id = ur.role_id`;

/** Una persona del personal con sus roles y cuántas casas tiene, o null */
export async function findStaff(id: string): Promise<StaffRow | null> {
  const { rows } = await pool.query<StaffRow>(`${SELECT} WHERE u.id = $1 AND u.type = 'staff' GROUP BY u.id`, [id]);
  return rows[0] ?? null;
}

export interface StaffFilters { role?: string; active?: boolean; q?: string }

/** Todo el personal que cumple los filtros, ordenado por nombre */
export async function list(f: StaffFilters): Promise<StaffRow[]> {
  const where = [`u.type = 'staff'`];
  const params: unknown[] = [];
  if (f.active !== undefined) where.push(`u.active = $${params.push(f.active)}`);
  if (f.q) where.push(`(u.name ILIKE $${params.push(`%${f.q}%`)} OR u.email ILIKE $${params.length})`);
  const having = f.role ? `HAVING $${params.push(f.role)} = ANY(array_agg(r.code))` : '';
  const { rows } = await pool.query<StaffRow>(`${SELECT} WHERE ${where.join(' AND ')} GROUP BY u.id ${having} ORDER BY u.name`, params);
  return rows;
}

/** Cambia broker/administrador; el rol de propietario se conserva */
export async function setRoles(db: Db, userId: string, roles: string[]): Promise<void> {
  await db.query(`DELETE FROM user_roles WHERE user_id = $1 AND role_id IN (SELECT id FROM roles WHERE code IN ('broker', 'admin'))`, [userId]);
  await db.query('INSERT INTO user_roles (user_id, role_id) SELECT $1, id FROM roles WHERE code = ANY($2::text[])', [userId, roles]);
}

export async function setZones(db: Db, userId: string, zones: string | null, specialty: string | null): Promise<void> {
  await db.query('UPDATE users SET zones = $2, specialty = $3 WHERE id = $1', [userId, zones, specialty]);
}

export interface StaffChanges { name?: string; phone?: string | null; zones?: string | null; specialty?: string | null; active?: boolean }

/** Actualiza solo lo que viene (undefined = no cambia; null = borra el dato) */
export async function update(db: Db, id: string, d: StaffChanges): Promise<void> {
  await db.query(
    `UPDATE users SET name = COALESCE($2, name),
            phone = CASE WHEN $3::boolean THEN $4 ELSE phone END,
            zones = CASE WHEN $5::boolean THEN $6 ELSE zones END,
            specialty = CASE WHEN $7::boolean THEN $8 ELSE specialty END,
            active = COALESCE($9, active)
      WHERE id = $1`,
    [id, d.name ?? null, d.phone !== undefined, d.phone ?? null, d.zones !== undefined, d.zones ?? null, d.specialty !== undefined, d.specialty ?? null, d.active ?? null],
  );
}

/** Roles con sus permisos y el catálogo de permisos */
export async function rolesWithPermissions() {
  const { rows } = await pool.query<{ code: string; name: string; permissions: string[] }>(
    `SELECT r.code, r.name, COALESCE(array_agg(p.code ORDER BY p.code) FILTER (WHERE p.code IS NOT NULL), '{}') AS permissions
       FROM roles r LEFT JOIN role_permissions rp ON rp.role_id = r.id LEFT JOIN permissions p ON p.id = rp.permission_id
      GROUP BY r.id ORDER BY r.code`,
  );
  const perms = await pool.query<{ code: string; description: string }>('SELECT code, description FROM permissions ORDER BY code');
  return { roles: rows, permissions: perms.rows };
}

/** De una lista de códigos, los que sí existen */
export async function existingPermissions(codes: string[]): Promise<string[]> {
  const { rows } = await pool.query<{ code: string }>('SELECT code FROM permissions WHERE code = ANY($1::text[])', [codes]);
  return rows.map((r) => r.code);
}

/** Reemplaza los permisos de un rol */
export async function replaceRolePermissions(db: Db, roleCode: string, permissions: string[]): Promise<void> {
  await db.query('DELETE FROM role_permissions WHERE role_id = (SELECT id FROM roles WHERE code = $1)', [roleCode]);
  await db.query(
    `INSERT INTO role_permissions (role_id, permission_id)
     SELECT r.id, p.id FROM roles r, permissions p WHERE r.code = $1 AND p.code = ANY($2::text[])`,
    [roleCode, permissions],
  );
}
