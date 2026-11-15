import type { RequestHandler } from 'express';
import { z } from 'zod';
import * as Svc from '../services/appointment.service.js';
import { currentUser } from '../middlewares/authenticate.js';
import { dateField, dateTimeField, pagination, paged, queryArray } from '../middlewares/validate.js';

export const listQueryDto = pagination.extend({
  status: queryArray,
  from: dateField.optional(),
  to: dateField.optional(),
  propertyId: z.uuid().optional(),
  clientId: z.uuid().optional(),
});
export const createDto = z.object({
  propertyId: z.uuid({ error: 'Elige la propiedad.' }),
  clientId: z.uuid().optional(),
  scheduledAt: dateTimeField,
  note: z.string().trim().max(1000).nullable().optional(),
});
export const reasonDto = z.object({ reason: z.string().trim().min(3, 'Escribe el motivo.').max(300).optional() });
export const rescheduleDto = z.object({ scheduledAt: dateTimeField, reason: z.string().trim().max(300).optional() });
export const messageDto = z.object({ body: z.string().trim().min(1, 'Escribe un mensaje.').max(2000) });

export const list: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const { rows, total } = await Svc.list(user, q);
  res.json(paged(rows.map((a) => Svc.present(a, user)), total, q));
};

export const getOne: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  res.json(Svc.present(await Svc.loadFor(user, (res.locals.params as { id: string }).id), user));
};

export const create: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  // Si la persona ya tenía una cita vigente, se cambia esa (moved: true) en lugar de crear otra
  const placed = await Svc.createOrMove(user, res.locals.body as z.infer<typeof createDto>);
  res.status(placed.moved ? 200 : 201).json({ ...Svc.present((await Svc.findById(placed.id))!, user), moved: placed.moved });
};

/** GET /appointments/active — la cita vigente del cliente (para que la app ofrezca «Cambiar mi cita» en lugar de pedir otra). */
export const active: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  if (user.type !== 'client') return void res.json({ appointment: null }); // es del cliente, no de quien atiende
  const { rows } = await Svc.list(user, { status: ['por-confirmar', 'confirmada'], page: 1, limit: 50 });
  const next = rows.filter((a) => a.scheduled_at.getTime() > Date.now()).at(-1) ?? null;
  res.json({ appointment: next ? Svc.present(next, user) : null });
};

const act =
  (action: 'confirm' | 'reject' | 'cancel' | 'complete' | 'reschedule'): RequestHandler =>
  async (_req, res) => {
    const user = currentUser(res);
    const { id } = res.locals.params as { id: string };
    await Svc.transition(user, id, action, (res.locals.body ?? {}) as { reason?: string; scheduledAt?: string });
    res.json(Svc.present((await Svc.findById(id))!, user));
  };
export const confirm = act('confirm');
export const reject = act('reject');
export const cancel = act('cancel');
export const complete = act('complete');
export const reschedule = act('reschedule');

export const listMessages: RequestHandler = async (_req, res) => {
  res.json({ data: await Svc.messages(currentUser(res), (res.locals.params as { id: string }).id) });
};

export const postMessage: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  await Svc.sendMessage(user, id, (res.locals.body as z.infer<typeof messageDto>).body);
  res.status(201).json({ data: await Svc.messages(user, id) });
};
