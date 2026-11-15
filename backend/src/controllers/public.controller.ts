import type { RequestHandler } from 'express';
import { z } from 'zod';
import * as Properties from '../models/property.model.js';
import * as Svc from '../services/property.service.js';
import { createLead } from '../services/lead.service.js';
import * as Correction from '../services/lead-correction.service.js';
import { AppError } from '../middlewares/error-handler.js';
import { emailField, nameField, paged } from '../middlewares/validate.js';
import { labelsForKey, TYPE_KEYS } from '../config/property-types.js';
import { pool } from '../config/database.js';
import { env } from '../config/env.js';
import { PRIVACY_VERSION } from '../config/legal.js';

/* Parámetros con los mismos nombres que el listado del sitio (web/paginas/propiedades.html). */
export const catalogQueryDto = z.object({
  operacion: z.enum(['renta', 'venta']).optional(),
  tipo: z.enum(TYPE_KEYS).optional(),
  zona: z.string().max(60).optional(),
  precio_max: z.string().regex(/^(\d+|mas)$/).optional(),
  presupuesto: z.string().regex(/^(\d+|mas)$/).optional(),
  recamaras: z.coerce.number().int().min(1).max(10).optional(),
  banos: z.coerce.number().min(1).max(10).optional(),
  estacionamientos: z.coerce.number().int().min(1).max(10).optional(),
  precio_min: z.coerce.number().min(0).optional(),
  superficie: z.coerce.number().min(1).optional(),
  superficie_max: z.coerce.number().min(1).optional(),
  mascotas: z.enum(['si', 'no']).optional(),
  amueblada: z.enum(['si', 'semi', 'no']).optional(),
  orden: z.enum(['precio-asc', 'precio-desc', 'recientes']).default('precio-asc'),
  pagina: z.coerce.number().int().min(1).default(1),
  porPagina: z.coerce.number().int().min(1).max(50).default(6),
});

const FURNISHED = { si: 'Amueblada', semi: 'Semiamueblada', no: 'Sin amueblar' } as const;

/** GET /public/properties — catálogo publicado, sin datos de contacto del broker. */
export const catalog: RequestHandler = async (_req, res) => {
  const q = res.locals.query as z.infer<typeof catalogQueryDto>;
  const price = q.precio_max ?? q.presupuesto;
  const filters: Properties.PropertyFilters = {
    visibility: ['publicada'],
    status: ['disponible', 'reservada'],
    operation: q.operacion,
    types: q.tipo ? labelsForKey(q.tipo) : undefined,
    zoneKey: q.zona,
    banosMin: q.banos,
    estMin: q.estacionamientos,
    m2Min: q.superficie,
    m2Max: q.superficie_max,
    priceMin: q.precio_min,
    pets: q.mascotas ? q.mascotas === 'si' : undefined,
    furnished: q.amueblada ? FURNISHED[q.amueblada] : undefined,
    sort: q.orden === 'precio-desc' ? 'price_desc' : q.orden === 'recientes' ? 'recent' : 'price_asc',
    page: q.pagina,
    limit: q.porPagina,
  };
  // En el sitio, «4» recámaras significa «4 o más».
  if (q.recamaras !== undefined) Object.assign(filters, q.recamaras >= 4 ? { recMin: 4 } : { recExact: q.recamaras });
  if (price === 'mas') Object.assign(filters, { priceMin: 5_000_001, operation: 'venta' });
  else if (price) {
    const n = Number(price);
    // Los rangos de millones son de venta; los demás, rentas mensuales (igual que el sitio).
    Object.assign(filters, { priceMax: n, operation: q.operacion ?? (n >= 1_000_000 ? 'venta' : 'renta') });
  }
  const { rows, total } = await Properties.list(filters);
  const extras = await Svc.loadExtras(rows);
  const data = await Promise.all(rows.map((r) => Svc.presentPublic(r, extras.amenities(r.id), extras.photos(r.id))));
  res.json(paged(data, total, { page: q.pagina, limit: q.porPagina }));
};

/** GET /public/properties/:slug — ficha pública. */
export const bySlug: RequestHandler = async (req, res) => {
  const slug = String(req.params.slug ?? '');
  const row = /^[a-z0-9-]{2,80}$/.test(slug) ? await Properties.findBySlug(slug) : null;
  if (!row || row.visibility !== 'publicada') throw new AppError(404, 'NOT_FOUND', 'Esta casa ya no está publicada.');
  const extras = await Svc.loadExtras([row]);
  res.json(await Svc.presentPublic(row, extras.amenities(row.id), extras.photos(row.id)));
};

export const busyQueryDto = z.object({ fecha: z.iso.date({ error: 'Usa el formato AAAA-MM-DD.' }) });

/**
 * GET /public/properties/:slug/busy?fecha= — horas ocupadas ese día en la casa o por su broker
 * (citas por confirmar o confirmadas, aunque aún no tengan broker asignado), en bloques de 15 minutos. Solo horas: ningún dato de las personas.
 */
export const busy: RequestHandler = async (req, res) => {
  const slug = String(req.params.slug ?? '');
  const row = /^[a-z0-9-]{2,80}$/.test(slug) ? await Properties.findBySlug(slug) : null;
  if (!row || row.visibility !== 'publicada') throw new AppError(404, 'NOT_FOUND', 'Esta propiedad ya no está publicada.');
  const { fecha } = res.locals.query as z.infer<typeof busyQueryDto>;
  const { rows } = await pool.query<{ t: string }>(
    `SELECT DISTINCT to_char(gs AT TIME ZONE $3, 'HH24:MI') AS t
       FROM appointments a,
            generate_series(date_trunc('hour', a.scheduled_at) + floor(extract(minute FROM a.scheduled_at) / 15) * interval '15 minutes',
                            a.scheduled_at + (a.duration_min - 1) * interval '1 minute', interval '15 minutes') gs
      WHERE (a.broker_id = $1 OR a.property_id = $4) AND a.status IN ('por-confirmar', 'confirmada')
        AND (a.scheduled_at AT TIME ZONE $3)::date = $2::date
      ORDER BY 1`,
    [row.broker_id, fecha, env.TZ_APP, row.id],
  );
  res.json({ fecha, busy: rows.map((r) => r.t) });
};

const textField = (max: number) => z.string().trim().max(max);
export const leadDto = z
  .object({
    reason: z.enum(['visita', 'rentar', 'comprar', 'publicar', 'otro'], { error: 'Indica el motivo de tu solicitud.' }),
    name: nameField,
    email: emailField,
    phone: textField(30).optional().nullable(),
    message: textField(2000).optional().nullable(),
    propertySlug: z.string().regex(/^[a-z0-9-]{2,80}$/).optional(),
    propertyCode: z.string().regex(/^[A-Z]{3}-[A-Z0-9-]{2,12}$/).optional(),
    preferredDate: z.iso.date({ error: 'Usa el formato AAAA-MM-DD.' }).optional(),
    // Las visitas van en bloques de 15 minutos (09:00, 09:15, 09:30…)
    preferredTime: z.string().regex(/^([01]\d|2[0-3]):(00|15|30|45)$/, 'Elige una hora en bloques de 15 minutos (HH:00, :15, :30 o :45).').optional(),
    payload: z.record(z.string().max(40), z.union([z.string().max(500), z.number(), z.boolean()])).optional(),
    // Consentimiento expreso del aviso de privacidad (LFPDPPP): sin él no se reciben datos
    consent: z.literal(true, { error: 'Acepta el aviso de privacidad para enviar tus datos.' }),
    // Campo trampa invisible para personas: si un robot lo llena, se ignora la solicitud
    website: z.string().max(200).optional(),
  })
  // «Hoy» en Cancún (en UTC ya es mañana desde las 19:00)
  .refine((v) => !v.preferredDate || v.preferredDate >= new Date().toLocaleDateString('en-CA', { timeZone: env.TZ_APP }), {
    message: 'Elige una fecha a partir de hoy.',
    path: ['preferredDate'],
  });

export const correctionDto = z.object({
  token: z.string().min(20).max(400),
  name: nameField.optional(),
  email: emailField.optional(),
  phone: z.string().trim().max(30).nullable().optional(),
});

/** PATCH /public/leads/:folio — «Cambiar mis datos» (2 horas después de enviar; ver lead-correction.service). */
export const correctLead: RequestHandler = async (req, res) => {
  const folio = String(req.params.folio ?? '');
  if (!/^Z-\d{5,8}$/.test(folio)) throw new AppError(404, 'NOT_FOUND', 'La solicitud no existe.');
  const { token, ...d } = res.locals.body as z.infer<typeof correctionDto>;
  const r = await Correction.correctLead(folio, token, d);
  res.json({
    ...r,
    message: r.account === 'created'
      ? `Listo. Te enviamos una contraseña temporal nueva a ${r.email}; la del correo anterior ya no sirve.`
      : `Listo. Tu solicitud quedó en tu cuenta de ${r.email}: entra a la app Homiz con ella.`,
  });
};

/** POST /public/leads — formularios del sitio. Devuelve el folio real. */
export const postLead: RequestHandler = async (_req, res) => {
  const { consent: _consent, website, ...lead } = res.locals.body as z.infer<typeof leadDto>;
  // Robot: llenó el campo trampa. Se responde como si nada para no darle pistas, pero no se guarda ni se envía correo.
  if (website) return void res.status(201).json({ folio: 'Z-' + String(Date.now()).slice(-5), appointmentCode: null, account: null, editToken: null, message: 'Recibimos tu solicitud.' });
  // Nadie puede usar el formulario para mandar muchos correos a una misma dirección
  const recent = await pool.query(`SELECT count(*)::int AS n FROM leads WHERE lower(email) = lower($1) AND created_at > now() - interval '1 hour'`, [lead.email]);
  if (recent.rows[0].n >= 5) throw new AppError(429, 'RATE_LIMITED', 'Ya recibimos varias solicitudes con este correo. Espera un momento o escríbenos por WhatsApp.');
  const result = await createLead({ ...lead, payload: { ...(lead.payload ?? {}), aviso_privacidad: `Aceptado ${new Date().toISOString()} · versión ${PRIVACY_VERSION}` } });
  res.status(201).json({
    ...result,
    message: result.account === 'created'
      ? 'Recibimos tu solicitud y te creamos tu cuenta en la app Homiz. Te enviamos por correo una contraseña temporal para entrar.'
      : 'Recibimos tu solicitud. Síguela en la app Homiz.',
  });
};

/** GET /public/legal — versión del aviso de privacidad y dónde leerlo o eliminar la cuenta (la app los enlaza). */
export const legal: RequestHandler = (_req, res) => {
  let site = env.SITE_URL.replace(/\/+$/, '');
  if (!site) {
    try {
      site = new URL(env.APP_RESET_URL).origin;
    } catch {
      site = '';
    }
  }
  res.json({ privacyVersion: PRIVACY_VERSION, privacyUrl: `${site}/aviso-de-privacidad`, deleteAccountUrl: `${site}/eliminar-cuenta` });
};