import type { RequestHandler } from 'express';
import { z } from 'zod';
import { pool, withTransaction } from '../config/database.js';
import { createDownloadUrl, fileSize, keyBelongsTo } from '../config/storage.js';
import { insertActivity } from '../models/activity.model.js';
import { currentUser, type AuthUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { pagination, paged, queryArray } from '../middlewares/validate.js';
import { assertPropertyAccess, propertyScope } from '../services/access.service.js';
import { clientReportFilter } from '../models/property-access.model.js';
import { admins, brokerOf, notify } from '../services/notification.service.js';

export const CATEGORIES = ['Plomería', 'Electricidad', 'Climatización', 'Cerrajería', 'Jardinería', 'Albercas', 'Pintura', 'Electrodomésticos', 'Otro'] as const;
const STATUS = ['reported', 'in_review', 'in_repair', 'resolved', 'cancelled'] as const;
const STATUS_ES: Record<(typeof STATUS)[number], string> = {
  reported: 'Reportado', in_review: 'En revisión', in_repair: 'En reparación', resolved: 'Resuelto', cancelled: 'Cancelado',
};
const PRIORITY_ES = { low: 'baja', medium: 'media', high: 'alta' } as const;

const photoKeys = z.array(z.string().min(10).max(300)).max(5, 'Máximo 5 fotos por reporte.');

export const listQueryDto = pagination.extend({
  propertyId: z.uuid().optional(),
  status: queryArray,
  priority: z.enum(['low', 'medium', 'high']).optional(),
  category: z.enum(CATEGORIES).optional(),
  open: z.enum(['true', 'false']).transform((v) => v === 'true').optional(),
});
export const createDto = z.object({
  propertyId: z.uuid({ error: 'Indica la propiedad.' }),
  title: z.string().trim().min(3, 'Escribe un título breve.').max(80),
  description: z.string().trim().min(5, 'Describe qué pasa.').max(2000),
  category: z.enum(CATEGORIES, { error: 'Elige una categoría.' }),
  priority: z.enum(['low', 'medium', 'high']).default('medium'),
  photos: photoKeys.default([]),
});
export const updateDto = z.object({
  status: z.enum(STATUS, { error: 'Estado no válido.' }),
  comment: z.string().trim().max(1000).optional(),
  providerId: z.uuid().nullable().optional(),
  photosAfter: photoKeys.optional(),
});

interface ReportRow {
  id: string;
  property_id: string;
  property_code: string;
  property_name: string;
  client_id: string | null;
  client_user_id: string | null;
  title: string;
  description: string;
  category: string;
  priority: 'low' | 'medium' | 'high';
  status: (typeof STATUS)[number];
  provider_id: string | null;
  provider_name: string | null;
  provider_specialty: string | null;
  provider_phone: string | null;
  closed_at: Date | null;
  created_at: Date;
}

const SELECT = `
  SELECT r.id, r.property_id, p.code AS property_code, p.name AS property_name, r.client_id, c.user_id AS client_user_id,
         r.title, r.description, r.category, r.priority, r.status, r.provider_id, pv.name AS provider_name,
         pv.specialty AS provider_specialty, pv.phone AS provider_phone, r.closed_at, r.created_at
    FROM maintenance_reports r
    JOIN properties p ON p.id = r.property_id
    LEFT JOIN clients c ON c.id = r.client_id
    LEFT JOIN providers pv ON pv.id = r.provider_id`;

function present(r: ReportRow, user: AuthUser) {
  return {
    id: r.id,
    property: { id: r.property_id, code: r.property_code, name: r.property_name },
    title: r.title,
    description: r.description,
    category: r.category,
    priority: r.priority,
    subtitle: `${r.category} - prioridad ${PRIORITY_ES[r.priority]}`,
    status: r.status,
    statusLabel: STATUS_ES[r.status],
    provider: r.provider_id ? { id: r.provider_id, name: r.provider_name, specialty: r.provider_specialty, ...(user.type === 'staff' ? { phone: r.provider_phone } : {}) } : null,
    closedAt: r.closed_at,
    createdAt: r.created_at,
  };
}

async function load(user: AuthUser, id: string): Promise<ReportRow> {
  const { rows } = await pool.query<ReportRow>(`${SELECT} WHERE r.id = $1`, [id]);
  if (!rows[0]) throw new AppError(404, 'NOT_FOUND', 'El reporte no existe.');
  await assertPropertyAccess(user, rows[0].property_id);
  // El cliente solo ve sus reportes (no los del inquilino anterior)
  if (user.type === 'client') {
    const own = await pool.query(`SELECT 1 FROM maintenance_reports r WHERE r.id = $1 AND ${clientReportFilter('$2')}`, [id, user.clientId]);
    if (!own.rowCount) throw new AppError(404, 'NOT_FOUND', 'El reporte no existe.');
  }
  return rows[0];
}

async function checkPhotos(code: string, keys: string[]) {
  for (const k of keys) {
    if (!keyBelongsTo(k, code, 'maintenance_photo') || (await fileSize(k)) === null) {
      throw new AppError(400, 'INVALID_FILE', 'Una de las fotos no se subió correctamente. Vuelve a subirla.', { storageKey: k });
    }
  }
}

export const list: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const scope = await propertyScope(user);
  const params: unknown[] = [];
  const where: string[] = [];
  if (scope) where.push(`r.property_id = ANY($${params.push(scope)}::uuid[])`);
  if (user.type === 'client') where.push(clientReportFilter(`$${params.push(user.clientId)}`));
  if (q.propertyId) where.push(`r.property_id = $${params.push(q.propertyId)}`);
  if (q.status?.length) where.push(`r.status::text = ANY($${params.push(q.status)}::text[])`);
  if (q.priority) where.push(`r.priority = $${params.push(q.priority)}`);
  if (q.category) where.push(`r.category = $${params.push(q.category)}`);
  if (q.open !== undefined) where.push(q.open ? `r.status NOT IN ('resolved', 'cancelled')` : `r.status IN ('resolved', 'cancelled')`);
  const w = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const total = await pool.query<{ n: string }>(`SELECT count(*) AS n FROM maintenance_reports r ${w}`, params);
  const { rows } = await pool.query<ReportRow>(
    `${SELECT} ${w} ORDER BY (r.status IN ('resolved', 'cancelled')), CASE r.priority WHEN 'high' THEN 0 WHEN 'medium' THEN 1 ELSE 2 END, r.created_at DESC
     LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, q.limit, (q.page - 1) * q.limit],
  );
  res.json(paged(rows.map((r) => present(r, user)), Number(total.rows[0].n), q));
};

async function detail(user: AuthUser, id: string) {
  const r = await load(user, id);
  const updates = await pool.query(
    `SELECT u.id, u.status, u.comment, u.created_at AS "createdAt", us.name AS author, us.type AS author_type
       FROM maintenance_updates u LEFT JOIN users us ON us.id = u.user_id WHERE u.report_id = $1 ORDER BY u.created_at`,
    [id],
  );
  const photos = await pool.query<{ id: string; stage: 'before' | 'after'; storage_key: string }>(
    'SELECT id, stage, storage_key FROM maintenance_photos WHERE report_id = $1 ORDER BY created_at',
    [id],
  );
  const signed = await Promise.all(photos.rows.map(async (p) => ({ id: p.id, stage: p.stage, url: (await createDownloadUrl(p.storage_key, p.storage_key.endsWith('.png') ? 'image/png' : p.storage_key.endsWith('.webp') ? 'image/webp' : 'image/jpeg', `foto-${p.stage}`)).url })));
  return {
    ...present(r, user),
    timeline: updates.rows.map((u) => ({
      id: u.id, status: u.status, statusLabel: STATUS_ES[u.status as keyof typeof STATUS_ES], comment: u.comment, createdAt: u.createdAt,
      // Al cliente el personal se le muestra como «Zugar».
      author: u.author_type === 'staff' && user.type === 'client' ? 'Zugar' : u.author,
    })),
    photos: { before: signed.filter((p) => p.stage === 'before'), after: signed.filter((p) => p.stage === 'after') },
  };
}

export const getOne: RequestHandler = async (_req, res) => {
  res.json(await detail(currentUser(res), (res.locals.params as { id: string }).id));
};

export const getUpdates: RequestHandler = async (_req, res) => {
  const d = await detail(currentUser(res), (res.locals.params as { id: string }).id);
  res.json({ data: d.timeline });
};

/** Alta: el cliente solo en su propiedad; el personal con maintenance.manage en las suyas. Avisa a broker y administración. */
export const create: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const d = res.locals.body as z.infer<typeof createDto>;
  if (user.type === 'staff' && !user.permissions.has('maintenance.manage')) throw new AppError(403, 'FORBIDDEN', 'No tienes permiso para registrar reportes.');
  await assertPropertyAccess(user, d.propertyId);
  const prop = await pool.query<{ code: string; name: string }>('SELECT code, name FROM properties WHERE id = $1', [d.propertyId]);
  await checkPhotos(prop.rows[0].code, d.photos);

  const id = await withTransaction(async (db) => {
    const clientId = user.type === 'client' ? user.clientId : null;
    const { rows } = await db.query<{ id: string }>(
      `INSERT INTO maintenance_reports (property_id, client_id, title, description, category, priority) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
      [d.propertyId, clientId, d.title, d.description, d.category, d.priority],
    );
    const reportId = rows[0].id;
    await db.query(`INSERT INTO maintenance_updates (report_id, status, comment, user_id) VALUES ($1, 'reported', $2, $3)`, [reportId, user.type === 'client' ? 'Reporte creado desde la app.' : 'Reporte registrado por la inmobiliaria.', user.id]);
    for (const k of d.photos) await db.query(`INSERT INTO maintenance_photos (report_id, stage, storage_key) VALUES ($1, 'before', $2)`, [reportId, k]);
    await insertActivity({ userId: user.id, propertyId: d.propertyId, entity: 'maintenance_report', entityId: reportId, action: 'create', description: `${user.name} reportó «${d.title}» en ${prop.rows[0].name} (${d.category}, prioridad ${PRIORITY_ES[d.priority]}).` }, db);
    await notify([await brokerOf(d.propertyId, db), ...(await admins(db))].filter((u) => u !== user.id), {
      type: 'maintenance_reported', title: 'Nuevo reporte de mantenimiento',
      message: `${prop.rows[0].name}: ${d.title} (${d.category}, prioridad ${PRIORITY_ES[d.priority]}).`, entity: 'maintenance_report', entityId: reportId,
    }, db);
    return reportId;
  });
  res.status(201).json(await detail(user, id));
};

/** Cambio de estado (y proveedor/fotos «después»). Avisa al cliente que lo reportó. */
export const addUpdate: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const r = await load(user, id);
  const d = res.locals.body as z.infer<typeof updateDto>;
  if (r.status === 'resolved' || r.status === 'cancelled') throw new AppError(409, 'INVALID_STATUS', 'El reporte ya está cerrado.');
  if (d.providerId) {
    const p = await pool.query('SELECT 1 FROM providers WHERE id = $1 AND active', [d.providerId]);
    if (!p.rowCount) throw new AppError(400, 'VALIDATION_ERROR', 'El proveedor no existe o está inactivo.');
  }
  if (d.photosAfter?.length) await checkPhotos(r.property_code, d.photosAfter);

  await withTransaction(async (db) => {
    await db.query(
      `UPDATE maintenance_reports SET status = $2::maintenance_status, provider_id = CASE WHEN $3::boolean THEN $4::uuid ELSE provider_id END,
              closed_at = CASE WHEN $2::text IN ('resolved', 'cancelled') THEN now() ELSE NULL END WHERE id = $1`,
      [id, d.status, d.providerId !== undefined, d.providerId ?? null],
    );
    await db.query('INSERT INTO maintenance_updates (report_id, status, comment, user_id) VALUES ($1, $2, $3, $4)', [id, d.status, d.comment ?? null, user.id]);
    for (const k of d.photosAfter ?? []) await db.query(`INSERT INTO maintenance_photos (report_id, stage, storage_key) VALUES ($1, 'after', $2)`, [id, k]);
    await insertActivity({ userId: user.id, propertyId: r.property_id, entity: 'maintenance_report', entityId: id, action: 'status', description: `${user.name} cambió «${r.title}» a ${STATUS_ES[d.status].toLowerCase()}${d.comment ? `: ${d.comment}` : ''}.`, oldValues: { status: r.status }, newValues: d }, db);
    await notify([r.client_user_id], {
      type: 'maintenance_status', title: `Tu reporte está ${STATUS_ES[d.status].toLowerCase()}`,
      message: `${r.title}${d.comment ? `: ${d.comment}` : '.'}`, entity: 'maintenance_report', entityId: id,
    }, db);
  });
  res.json(await detail(user, id));
};
