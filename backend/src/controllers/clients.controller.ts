import type { RequestHandler } from 'express';
import { z } from 'zod';
import { insertActivity } from '../models/activity.model.js';
import { currentUser, type AuthUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { emailField, money, nameField, pagination, paged } from '../middlewares/validate.js';
import * as Repo from '../repositories/clients.repository.js';
import { assertPropertyAccess, isAdmin } from '../services/access.service.js';

/* Controlador de /clients: valida la entrada, aplica las reglas de negocio y responde.
   El SQL vive en repositories/clients.repository.ts. */

const FOLLOW = ['Nuevo contacto', 'En seguimiento', 'Visita confirmada', 'Por confirmar', 'Reservada', 'Contrato vigente', 'Contrato finalizado'] as const;

export const listQueryDto = pagination.extend({
  q: z.string().trim().max(80).optional(),
  kind: z.enum(['cliente', 'inquilino']).optional(),
  followStatus: z.enum(FOLLOW).optional(),
  propertyId: z.uuid().optional(),
});

const fields = {
  name: nameField,
  email: emailField.nullable(),
  phone: z.string().trim().max(30).nullable(),
  address: z.string().trim().max(200).nullable(),
  kind: z.enum(['cliente', 'inquilino']),
  label: z.string().trim().max(40).nullable(),
  nationality: z.string().trim().max(60).nullable(),
  occupation: z.string().trim().max(80).nullable(),
  operation: z.enum(['Renta', 'Compra']).nullable(),
  budget: z.string().trim().max(60).nullable(),
  budgetAmount: money.nullable(),
  needs: z.string().trim().max(200).nullable(),
  hasPets: z.boolean(),
  petsCount: z.coerce.number().int().min(0).max(20),
  occupants: z.coerce.number().int().min(1).max(30).nullable(),
  followStatus: z.enum(FOLLOW),
  propertyId: z.uuid().nullable(),
  brokerId: z.uuid().nullable(),
};
export const createDto = z.object({
  ...Object.fromEntries(Object.entries(fields).map(([k, v]) => [k, v.optional()])),
  name: fields.name,
}) as z.ZodType<Partial<Record<keyof typeof fields, unknown>> & { name: string }>;
export const updateDto = z
  .object(Object.fromEntries(Object.entries(fields).map(([k, v]) => [k, v.optional()])))
  .refine((v) => Object.keys(v).length > 0, 'Envía al menos un dato para actualizar.');


type Row = Repo.ClientRow;

const present = (c: Row) => ({
  id: c.id, code: c.code, kind: c.kind, label: c.label, name: c.name, email: c.email, phone: c.phone, address: c.address,
  nationality: c.nationality, occupation: c.occupation, operation: c.operation, budget: c.budget, budgetAmount: c.budget_amount,
  needs: c.needs, hasPets: c.has_pets, petsCount: c.pets_count, occupants: c.occupants, followStatus: c.follow_status,
  property: c.property_id ? { id: c.property_id, code: c.property_code, name: c.property_name } : null,
  broker: c.broker_id ? { id: c.broker_id, name: c.broker_name } : null,
  hasAccount: c.has_account, createdAt: c.created_at,
});

/** El broker ve los clientes que tiene asignados o que están ligados a sus casas. */
const scopeOf = (user: AuthUser): Repo.ClientScope => ({ userId: user.id, admin: isAdmin(user) });

async function findScoped(user: AuthUser, id: string): Promise<Row> {
  const row = await Repo.findScoped(scopeOf(user), id);
  if (!row) throw new AppError(404, 'NOT_FOUND', 'El cliente no existe o no lo tienes asignado.');
  return row;
}

export const list: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const { rows, total } = await Repo.list(scopeOf(user), q);
  res.json(paged(rows.map(present), total, q));
};

export const getOne: RequestHandler = async (_req, res) => {
  res.json(present(await findScoped(currentUser(res), (res.locals.params as { id: string }).id)));
};

/**
 * GET /clients/:id/overview — todo lo de la persona en un lugar (decisión 113): sus solicitudes, citas,
 * contratos con el estado de sus pagarés y lo que ha hecho en la app y el sitio (bitácora).
 */
export const overview: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const c = await findScoped(user, (res.locals.params as { id: string }).id);
  res.json({ client: present(c), ...(await Repo.overview(c)) });
};

async function checkLinks(user: AuthUser, d: Record<string, unknown>) {
  if (d.propertyId) await assertPropertyAccess(user, d.propertyId as string);
  if (d.brokerId && !isAdmin(user) && d.brokerId !== user.id) throw new AppError(403, 'FORBIDDEN', 'Solo un administrador puede asignar el cliente a otro broker.');
}

export const create: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = res.locals.body as Record<string, unknown>;
  await checkLinks(user, d);
  // Una persona nueva no tiene contrato: entra como prospecto (inquilino solo con «Rentarle esta casa»)
  if (d.kind === 'inquilino' || d.followStatus === 'Contrato vigente') throw NEEDS_CONTRACT;
  if (!isAdmin(user)) d.brokerId = user.id;
  const id = await Repo.insert(d);
  await insertActivity({ userId: user.id, propertyId: (d.propertyId as string) ?? null, entity: 'client', entityId: id, action: 'create', description: `${user.name} registró a ${d.name as string}.` });
  res.status(201).json(present(await findScoped(user, id)));
};

/**
 * Inquilino = tiene contrato. Marcarlo a mano dejaría la casa publicada y sin pagarés:
 * se hace con «Rentarle esta casa» (POST /contracts), que genera los pagarés y pausa la casa.
 */
const NEEDS_CONTRACT = new AppError(409, 'NEEDS_CONTRACT', 'Para hacerla inquilina registra su contrato con «Rentarle esta casa»: así se generan sus pagarés y la casa sale del sitio.');

export const update: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const before = await findScoped(user, id);
  const d = res.locals.body as Record<string, unknown>;
  await checkLinks(user, d);
  if ((d.kind === 'inquilino' && before.kind !== 'inquilino') || (d.followStatus === 'Contrato vigente' && before.follow_status !== 'Contrato vigente')) {
    if (!(await Repo.hasActiveContract(id))) throw NEEDS_CONTRACT;
  }
  await Repo.update(id, d);
  await insertActivity({ userId: user.id, propertyId: before.property_id, entity: 'client', entityId: id, action: 'update', description: `${user.name} actualizó el expediente de ${before.name as string}.`, newValues: d });
  res.json(present(await findScoped(user, id)));
};

/** Baja lógica. No se permite si tiene un contrato vigente. */
export const remove: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const c = await findScoped(user, id);
  if (await Repo.hasActiveContract(id)) throw new AppError(409, 'HAS_ACTIVE_CONTRACT', 'El cliente tiene un contrato vigente. Finalízalo antes de darlo de baja.');
  const cancelled = await Repo.cancelUpcomingAppointments(id);
  await Repo.deactivate(id);
  await insertActivity({ userId: user.id, propertyId: c.property_id, entity: 'client', entityId: id, action: 'delete', description: `${user.name} dio de baja el expediente de ${c.name as string}.` });
  res.json({ message: 'El expediente se dio de baja. Su historial se conserva.', appointmentsCancelled: cancelled });
};
