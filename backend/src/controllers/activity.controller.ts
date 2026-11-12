import type { RequestHandler } from 'express';
import { z } from 'zod';
import { listActivity } from '../models/activity.model.js';
import { currentUser } from '../middlewares/authenticate.js';
import { pagination } from '../middlewares/validate.js';
import { propertyScope } from '../services/access.service.js';

export const activityQueryDto = pagination.extend({
  propertyId: z.uuid({ error: 'El identificador de la propiedad no es válido.' }).optional(),
  entity: z.string().max(40).optional(),
  action: z.string().max(40).optional(),
  from: z.iso.date({ error: 'Usa el formato AAAA-MM-DD.' }).optional(),
  to: z.iso.date({ error: 'Usa el formato AAAA-MM-DD.' }).optional(),
});

/**
 * GET /activity-log — historial con filtros. El administrador ve todo; un broker solo los registros
 * de sus propiedades (la pertenencia de propertyId se valida antes con requirePropertyAccess).
 */
export const listActivityLog: RequestHandler = async (_req, res) => {
  const q = res.locals.query as z.infer<typeof activityQueryDto>;
  const scope = await propertyScope(currentUser(res));
  const { rows, total } = await listActivity({ ...q, propertyIds: scope ?? undefined });
  res.json({
    data: rows.map((r) => ({
      id: r.id,
      user: r.user_id ? { id: r.user_id, name: r.user_name } : null,
      property: r.property_id ? { id: r.property_id, code: r.property_code, name: r.property_name } : null,
      entity: r.entity,
      entityId: r.entity_id,
      action: r.action,
      description: r.description,
      oldValues: r.old_values,
      newValues: r.new_values,
      createdAt: r.created_at,
    })),
    pagination: { page: q.page, limit: q.limit, total, pages: Math.ceil(total / q.limit) },
  });
};
