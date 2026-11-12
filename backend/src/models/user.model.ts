import { pool, type Db } from '../config/database.js';

export interface UserRow {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  birth_date: string | null;
  password_hash: string;
  type: 'client' | 'staff';
  initials: string | null;
  active: boolean;
  failed_attempts: number;
  locked_until: Date | null;
  /** Entró con una contraseña temporal: debe crear una propia */
  must_change_password: boolean;
}

const COLUMNS = `id, name, email, phone, to_char(birth_date, 'YYYY-MM-DD') AS birth_date, password_hash, type, initials,
  active, failed_attempts, locked_until, must_change_password`;

export async function findByEmail(email: string, db: Db = pool): Promise<UserRow | null> {
  const { rows } = await db.query<UserRow>(`SELECT ${COLUMNS} FROM users WHERE lower(email) = lower($1)`, [email.trim()]);
  return rows[0] ?? null;
}

export async function findById(id: string, db: Db = pool): Promise<UserRow | null> {
  const { rows } = await db.query<UserRow>(`SELECT ${COLUMNS} FROM users WHERE id = $1`, [id]);
  return rows[0] ?? null;
}

/** Roles y permisos efectivos (la suma de todos sus roles). */
export async function loadAccess(userId: string, db: Db = pool): Promise<{ roles: string[]; permissions: string[] }> {
  const { rows } = await db.query<{ role: string; permission: string | null }>(
    `SELECT r.code AS role, p.code AS permission
       FROM user_roles ur
       JOIN roles r ON r.id = ur.role_id
       LEFT JOIN role_permissions rp ON rp.role_id = r.id
       LEFT JOIN permissions p ON p.id = rp.permission_id
      WHERE ur.user_id = $1`,
    [userId],
  );
  return {
    roles: [...new Set(rows.map((r) => r.role))],
    permissions: [...new Set(rows.map((r) => r.permission).filter((p): p is string => !!p))],
  };
}

/** Suma un intento fallido; al llegar al máximo bloquea la cuenta y reinicia el contador. */
export async function registerFailedAttempt(id: string, maxAttempts: number, lockMinutes: number): Promise<Date | null> {
  const { rows } = await pool.query<{ locked_until: Date | null }>(
    `UPDATE users
        SET locked_until = CASE WHEN failed_attempts + 1 >= $2 THEN now() + make_interval(mins => $3) ELSE locked_until END,
            failed_attempts = CASE WHEN failed_attempts + 1 >= $2 THEN 0 ELSE failed_attempts + 1 END
      WHERE id = $1
      RETURNING locked_until`,
    [id, maxAttempts, lockMinutes],
  );
  return rows[0]?.locked_until ?? null;
}

export async function resetAttempts(id: string, db: Db = pool): Promise<void> {
  await db.query('UPDATE users SET failed_attempts = 0, locked_until = NULL WHERE id = $1', [id]);
}

export async function createUser(
  data: { name: string; email: string; phone: string | null; passwordHash: string; type: 'client' | 'staff' },
  db: Db = pool,
): Promise<UserRow> {
  const initials = data.name.split(/\s+/).filter(Boolean).map((w) => w[0]).slice(0, 2).join('').toUpperCase();
  const { rows } = await db.query<UserRow>(
    `INSERT INTO users (name, email, phone, password_hash, type, initials)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING ${COLUMNS}`,
    [data.name.trim(), data.email.trim().toLowerCase(), data.phone, data.passwordHash, data.type, initials],
  );
  return rows[0];
}

/** [temporary]: contraseña temporal del correo; al entrar con ella se le pide crear una propia. */
export async function updatePassword(id: string, passwordHash: string, db: Db = pool, temporary = false): Promise<void> {
  await db.query('UPDATE users SET password_hash = $2, failed_attempts = 0, locked_until = NULL, must_change_password = $3 WHERE id = $1', [id, passwordHash, temporary]);
}

export async function updateProfile(
  id: string,
  data: { name?: string; phone?: string | null; birthDate?: string | null },
  db: Db = pool,
): Promise<UserRow | null> {
  const { rows } = await db.query<UserRow>(
    `UPDATE users
        SET name = COALESCE($2, name),
            phone = CASE WHEN $3::boolean THEN $4 ELSE phone END,
            birth_date = CASE WHEN $5::boolean THEN $6::date ELSE birth_date END
      WHERE id = $1
      RETURNING ${COLUMNS}`,
    [id, data.name ?? null, data.phone !== undefined, data.phone ?? null, data.birthDate !== undefined, data.birthDate ?? null],
  );
  return rows[0] ?? null;
}
