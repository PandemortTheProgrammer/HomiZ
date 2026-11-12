import type { RequestHandler } from 'express';
import { z } from 'zod';
import { pool, withTransaction, type Db } from '../config/database.js';
import * as Users from '../models/user.model.js';
import * as Tokens from '../models/token.model.js';
import { insertActivity } from '../models/activity.model.js';
import { currentUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { emailField, nameField, pagination, paged } from '../middlewares/validate.js';
import { hashPassword, passwordSchema } from '../services/password.service.js';

/* Roles que el propietario asigna: broker, administrador o ambos. El rol «owner» (propietario) no se asigna por la API. */
const ROLE = z.enum(['broker', 'admin']);

export const listQueryDto = pagination.extend({
  role: z.enum(['broker', 'admin', 'owner']).optional(),
  active: z.enum(['true', 'false']).transform((v) => v === 'true').optional(),
  q: z.string().trim().max(80).optional(),
});
export const createDto = z.object({
  name: nameField,
  email: emailField,
  phone: z.string().trim().max(30).optional().nullable(),
  zones: z.string().trim().max(120).optional().nullable(),
  specialty: z.string().trim().max(120).optional().nullable(),
  roles: z.array(ROLE).min(1, 'Elige al menos un rol.'),
  password: passwordSchema,
});
export const updateDto = z
  .object({
    name: nameField.optional(),
    phone: z.string().trim().max(30).nullable().optional(),
    zones: z.string().trim().max(120).nullable().optional(),
    specialty: z.string().trim().max(120).nullable().optional(),
    roles: z.array(ROLE).min(1, 'Elige al menos un rol.').optional(),
    active: z.boolean().optional(),
  })
  .refine((v) => Object.keys(v).length > 0, 'Envía al menos un dato para actualizar.');
export const rolePermissionsDto = z.object({ permissions: z.array(z.string().max(60)).max(50) });
export const roleParam = z.object({ code: ROLE });

interface StaffRow {
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

const present = (s: StaffRow) => ({
  id: s.id, name: s.name, email: s.email, phone: s.phone, initials: s.initials, zones: s.zones, specialty: s.specialty,
  active: s.active, roles: s.roles, properties: s.properties, locked: !!s.locked_until && s.locked_until.getTime() > Date.now(), createdAt: s.created_at,
});

async function findStaff(id: string): Promise<StaffRow | null> {
  const { rows } = await pool.query<StaffRow>(`${SELECT} WHERE u.id = $1 AND u.type = 'staff' GROUP BY u.id`, [id]);
  return rows[0] ?? null;
}

/** Cambia broker/administrador; el rol de propietario se conserva. */
async function setRoles(db: Db, userId: string, roles: string[]) {
  await db.query(`DELETE FROM user_roles WHERE user_id = $1 AND role_id IN (SELECT id FROM roles WHERE code IN ('broker', 'admin'))`, [userId]);
  await db.query('INSERT INTO user_roles (user_id, role_id) SELECT $1, id FROM roles WHERE code = ANY($2::text[])', [userId, roles]);
}

export const list: RequestHandler = async (_req, res) => {
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const where = [`u.type = 'staff'`];
  const params: unknown[] = [];
  if (q.active !== undefined) where.push(`u.active = $${params.push(q.active)}`);
  if (q.q) where.push(`(u.name ILIKE $${params.push(`%${q.q}%`)} OR u.email ILIKE $${params.length})`);
  const having = q.role ? `HAVING $${params.push(q.role)} = ANY(array_agg(r.code))` : '';
  const sql = `${SELECT} WHERE ${where.join(' AND ')} GROUP BY u.id ${having} ORDER BY u.name`;
  const { rows } = await pool.query<StaffRow>(sql, params);
  const start = (q.page - 1) * q.limit;
  res.json(paged(rows.slice(start, start + q.limit).map(present), rows.length, q));
};

export const create: RequestHandler = async (_req, res) => {
  const admin = currentUser(res);
  const d = res.locals.body as z.infer<typeof createDto>;
  if (await Users.findByEmail(d.email)) throw new AppError(409, 'EMAIL_TAKEN', 'Ya existe una cuenta con ese correo.');
  const passwordHash = await hashPassword(d.password);
  const id = await withTransaction(async (db) => {
    const u = await Users.createUser({ name: d.name, email: d.email, phone: d.phone ?? null, passwordHash, type: 'staff' }, db);
    await db.query('UPDATE users SET zones = $2, specialty = $3 WHERE id = $1', [u.id, d.zones ?? null, d.specialty ?? null]);
    await setRoles(db, u.id, d.roles);
    await insertActivity({ userId: admin.id, entity: 'user', entityId: u.id, action: 'create', description: `${admin.name} dio de alta a ${d.name} (${d.roles.join(' y ')}).` }, db);
    return u.id;
  });
  res.status(201).json(present((await findStaff(id))!));
};

export const update: RequestHandler = async (_req, res) => {
  const admin = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const d = res.locals.body as z.infer<typeof updateDto>;
  const before = await findStaff(id);
  if (!before) throw new AppError(404, 'NOT_FOUND', 'El usuario no existe o no es del personal.');
  if (d.active === false && (id === admin.id || before.roles.includes('owner'))) {
    throw new AppError(409, 'SELF_LOCKOUT', 'No se puede desactivar la cuenta del propietario.');
  }
  if (d.roles && !d.roles.includes('broker') && !d.roles.includes('admin') && before.properties > 0) {
    throw new AppError(409, 'HAS_PROPERTIES', `Tiene ${before.properties} casas asignadas. Reasígnalas antes de quitarle el rol de broker.`);
  }
  await withTransaction(async (db) => {
    await db.query(
      `UPDATE users SET name = COALESCE($2, name),
              phone = CASE WHEN $3::boolean THEN $4 ELSE phone END,
              zones = CASE WHEN $5::boolean THEN $6 ELSE zones END,
              specialty = CASE WHEN $7::boolean THEN $8 ELSE specialty END,
              active = COALESCE($9, active)
        WHERE id = $1`,
      [id, d.name ?? null, d.phone !== undefined, d.phone ?? null, d.zones !== undefined, d.zones ?? null, d.specialty !== undefined, d.specialty ?? null, d.active ?? null],
    );
    if (d.roles) await setRoles(db, id, d.roles);
    if (d.active === false) await Tokens.revokeAllForUser(id, db);
    await insertActivity({
      userId: admin.id, entity: 'user', entityId: id, action: 'update', description: `${admin.name} actualizó la cuenta de ${before.name}.`,
      oldValues: { roles: before.roles, active: before.active }, newValues: d,
    }, db);
  });
  res.json(present((await findStaff(id))!));
};

export const listRoles: RequestHandler = async (_req, res) => {
  const { rows } = await pool.query<{ code: string; name: string; permissions: string[] }>(
    `SELECT r.code, r.name, COALESCE(array_agg(p.code ORDER BY p.code) FILTER (WHERE p.code IS NOT NULL), '{}') AS permissions
       FROM roles r LEFT JOIN role_permissions rp ON rp.role_id = r.id LEFT JOIN permissions p ON p.id = rp.permission_id
      GROUP BY r.id ORDER BY r.code`,
  );
  const perms = await pool.query<{ code: string; description: string }>('SELECT code, description FROM permissions ORDER BY code');
  res.json({ roles: rows, permissions: perms.rows });
};

/** Permisos configurables de broker y administrador. Gestionar al personal (users.manage) es solo del propietario. */
export const setRolePermissions: RequestHandler = async (_req, res) => {
  const admin = currentUser(res);
  const { code } = res.locals.params as { code: string };
  const { permissions } = res.locals.body as z.infer<typeof rolePermissionsDto>;
  const wanted = new Set(permissions);
  wanted.delete('users.manage');
  const known = await pool.query<{ code: string }>('SELECT code FROM permissions WHERE code = ANY($1::text[])', [[...wanted]]);
  const unknown = [...wanted].filter((p) => !known.rows.some((k) => k.code === p));
  if (unknown.length) throw new AppError(400, 'VALIDATION_ERROR', 'Hay permisos que no existen.', { permissions: unknown });
  await withTransaction(async (db) => {
    await db.query('DELETE FROM role_permissions WHERE role_id = (SELECT id FROM roles WHERE code = $1)', [code]);
    await db.query(
      `INSERT INTO role_permissions (role_id, permission_id)
       SELECT r.id, p.id FROM roles r, permissions p WHERE r.code = $1 AND p.code = ANY($2::text[])`,
      [code, [...wanted]],
    );
    await insertActivity({ userId: admin.id, entity: 'role', action: 'permissions', description: `${admin.name} actualizó los permisos del rol ${code}.`, newValues: [...wanted] }, db);
  });
  res.json({ code, permissions: [...wanted].sort() });
};
