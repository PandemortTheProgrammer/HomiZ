import type { RequestHandler } from 'express';
import { z } from 'zod';
import { withTransaction } from '../config/database.js';
import * as Users from '../models/user.model.js';
import * as Tokens from '../models/token.model.js';
import { insertActivity } from '../models/activity.model.js';
import { currentUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { emailField, nameField, pagination, paged } from '../middlewares/validate.js';
import * as Repo from '../repositories/staff.repository.js';
import { hashPassword, passwordSchema } from '../services/password.service.js';

/* Controlador de /users (personal). El SQL vive en repositories/staff.repository.ts.
   Roles que el propietario asigna: broker, administrador o ambos. El rol «owner» (propietario) no se asigna por la API. */
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

type StaffRow = Repo.StaffRow;

const present = (s: StaffRow) => ({
  id: s.id, name: s.name, email: s.email, phone: s.phone, initials: s.initials, zones: s.zones, specialty: s.specialty,
  active: s.active, roles: s.roles, properties: s.properties, locked: !!s.locked_until && s.locked_until.getTime() > Date.now(), createdAt: s.created_at,
});

const findStaff = Repo.findStaff;
const setRoles = Repo.setRoles;

export const list: RequestHandler = async (_req, res) => {
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const rows = await Repo.list({ role: q.role, active: q.active, q: q.q });
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
    await Repo.setZones(db, u.id, d.zones ?? null, d.specialty ?? null);
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
    await Repo.update(db, id, d);
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
  res.json(await Repo.rolesWithPermissions());
};

/** Permisos configurables de broker y administrador. Gestionar al personal (users.manage) es solo del propietario. */
export const setRolePermissions: RequestHandler = async (_req, res) => {
  const admin = currentUser(res);
  const { code } = res.locals.params as { code: string };
  const { permissions } = res.locals.body as z.infer<typeof rolePermissionsDto>;
  const wanted = new Set(permissions);
  wanted.delete('users.manage');
  const known = await Repo.existingPermissions([...wanted]);
  const unknown = [...wanted].filter((p) => !known.includes(p));
  if (unknown.length) throw new AppError(400, 'VALIDATION_ERROR', 'Hay permisos que no existen.', { permissions: unknown });
  await withTransaction(async (db) => {
    await Repo.replaceRolePermissions(db, code, [...wanted]);
    await insertActivity({ userId: admin.id, entity: 'role', action: 'permissions', description: `${admin.name} actualizó los permisos del rol ${code}.`, newValues: [...wanted] }, db);
  });
  res.json({ code, permissions: [...wanted].sort() });
};
