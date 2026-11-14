import type { RequestHandler } from 'express';
import { z } from 'zod';
import * as Properties from '../models/property.model.js';
import * as Svc from '../services/property.service.js';
import { checkPropertyAccess } from '../services/access.service.js';
import { locateFromMapsUrl } from '../services/maps.service.js';
import { TYPE_LABELS } from '../config/property-types.js';
import { currentUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import { dateField, money, pagination, paged, positiveMoney, queryArray } from '../middlewares/validate.js';

// Sin «borrador» (decisión 104): lo registrado queda disponible y pausado hasta publicarse
const STATUS = ['disponible', 'reservada', 'rentada', 'vendida'] as const;
const VISIBILITY = ['publicada', 'pausada'] as const;
const TYPES = TYPE_LABELS;
const FURNISHED = ['Sin amueblar', 'Semiamueblada', 'Amueblada'] as const;

/* ---------- DTOs ---------- */
export const listQueryDto = pagination.extend({
  q: z.string().trim().max(80).optional(),
  operation: z.enum(['renta', 'venta']).optional(),
  status: queryArray,
  visibility: queryArray,
  zoneKey: z.string().max(60).optional(),
  type: z.string().max(40).optional(),
  brokerId: z.uuid().optional(),
  priceMin: money.optional(),
  priceMax: money.optional(),
  bedrooms: z.coerce.number().int().min(0).max(20).optional(),
  bathrooms: z.coerce.number().min(0).max(20).optional(),
  parking: z.coerce.number().int().min(0).max(20).optional(),
  m2Min: z.coerce.number().min(0).optional(),
  pets: z.enum(['true', 'false']).transform((v) => v === 'true').optional(),
  furnished: z.enum(FURNISHED).optional(),
  amenity: queryArray,
  sort: z.enum(['price_asc', 'price_desc', 'recent', 'updated']).optional(),
});

const writeFields = {
  name: z.string().trim().min(2, 'Escribe el nombre de la propiedad.').max(120),
  type: z.enum(TYPES, { error: 'Tipo de inmueble no válido.' }),
  description: z.string().trim().max(4000),
  operation: z.enum(['renta', 'venta'], { error: 'La operación debe ser renta o venta.' }),
  price: positiveMoney,
  rec: z.coerce.number().min(0).max(20),
  banos: z.coerce.number().min(0).max(20).multipleOf(0.5, 'Los baños van en enteros o medios.'),
  m2: z.coerce.number().positive().max(100000).nullable(),
  terreno: z.coerce.number().positive().max(1000000).nullable(),
  est: z.coerce.number().int().min(0).max(20),
  age: z.coerce.number().int().min(0).max(200).nullable(),
  furnished: z.enum(FURNISHED),
  petsAllowed: z.boolean(),
  maintenance: z.string().trim().max(80).nullable(),
  deposit: money.nullable(),
  availableFrom: dateField.nullable(),
  address: z.string().trim().max(200),
  street: z.string().trim().max(120).nullable(),
  city: z.string().trim().max(80),
  zone: z.string().trim().min(2, 'Escribe la zona.').max(80),
  zoneKey: z.string().regex(/^[a-z0-9-]{2,60}$/, 'La clave de zona solo lleva minúsculas, números y guiones.'),
  mapQuery: z.string().trim().max(200).nullable(),
  lat: z.coerce.number().min(-90).max(90).nullable(),
  lng: z.coerce.number().min(-180).max(180).nullable(),
  amenities: z.array(z.string().trim().min(1).max(60)).max(40),
  // Servicios (los captura administración): número de servicio de CFE y de Aguakan
  electricityServiceNumber: z.string().trim().regex(/^[\d\s-]{6,20}$/, 'El número de servicio de CFE lleva solo números (12 dígitos).').nullable(),
  waterServiceNumber: z.string().trim().regex(/^[\w\s-]{4,20}$/, 'Revisa el número de contrato de Aguakan.').nullable(),
  utilityReminderDay: z.coerce.number().int().min(1).max(28),
  // Cuota de mantenimiento (administración): monto y día del mes; ese día se recuerda a todos
  maintenanceFee: z.coerce.number().min(0).max(1_000_000).nullable(),
  maintenanceFeeDay: z.coerce.number().int().min(1, 'El día va del 1 al 28.').max(28, 'El día va del 1 al 28.').nullable(),
};

export const createDto = z.object({
  ...writeFields,
  type: writeFields.type.default('Casa'),
  description: writeFields.description.default(''),
  rec: writeFields.rec.default(0),
  banos: writeFields.banos.default(0),
  est: writeFields.est.default(0),
  furnished: writeFields.furnished.default('Sin amueblar'),
  petsAllowed: writeFields.petsAllowed.default(false),
  address: writeFields.address.default(''),
  city: writeFields.city.default('Cancún, Quintana Roo'),
  m2: writeFields.m2.optional(), terreno: writeFields.terreno.optional(), age: writeFields.age.optional(),
  maintenance: writeFields.maintenance.optional(), deposit: writeFields.deposit.optional(),
  availableFrom: writeFields.availableFrom.optional(), street: writeFields.street.optional(),
  zoneKey: writeFields.zoneKey.optional(), mapQuery: writeFields.mapQuery.optional(),
  lat: writeFields.lat.optional(), lng: writeFields.lng.optional(), amenities: writeFields.amenities.optional(),
  electricityServiceNumber: writeFields.electricityServiceNumber.optional(), waterServiceNumber: writeFields.waterServiceNumber.optional(),
  utilityReminderDay: writeFields.utilityReminderDay.optional(),
  maintenanceFee: writeFields.maintenanceFee.optional(), maintenanceFeeDay: writeFields.maintenanceFeeDay.optional(),
  brokerId: z.uuid().optional(),
});

export const updateDto = z
  .object({
    ...Object.fromEntries(Object.entries(writeFields).map(([k, v]) => [k, v.optional()])),
    photos: z
      .array(z.object({ storageKey: z.string().min(3).max(300), label: z.string().trim().max(80).default('') }))
      .max(20, 'Máximo 20 fotos por propiedad.')
      .optional(),
  })
  .refine((v) => Object.keys(v).length > 0, 'Envía al menos un dato para actualizar.');

export const availabilityDto = z
  .object({ status: z.enum(STATUS).optional(), visibility: z.enum(VISIBILITY).optional() })
  .refine((v) => v.status || v.visibility, 'Indica el estado o la visibilidad.');

export const brokerDto = z.object({ brokerId: z.uuid({ error: 'Elige un broker válido.' }) });

export const locateDto = z.object({ url: z.string().trim().min(1, 'Pega el enlace de Google Maps.').max(2048) });

/* ---------- Controladores ---------- */
export const list: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const q = res.locals.query as z.infer<typeof listQueryDto>;
  const filters: Properties.PropertyFilters = {
    ...q,
    status: q.status,
    visibility: q.visibility,
    recMin: q.bedrooms,
    banosMin: q.bathrooms,
    estMin: q.parking,
    amenities: q.amenity,
    page: q.page,
    limit: q.limit,
  };
  if (user.type === 'client') {
    // El cliente solo ve el catálogo disponible y publicado, y nunca filtra por broker.
    Object.assign(filters, { status: ['disponible'], visibility: ['publicada'], brokerId: undefined });
  }
  const { rows, total } = await Properties.list(filters);
  const extras = await Svc.loadExtras(rows);
  const exact = await Svc.exactLocationFor(user);
  const data = await Promise.all(rows.map((r) => Svc.present(r, extras.amenities(r.id), extras.photos(r.id), user, user.type === 'staff' || exact.has(r.id))));
  res.json(paged(data, total, q));
};

export const getOne: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  const { id } = res.locals.params as { id: string };
  const row = await Properties.findById(id);
  if (!row) throw new AppError(404, 'NOT_FOUND', 'La propiedad no existe.');
  if (user.type === 'client') {
    const inCatalog = row.status === 'disponible' && row.visibility === 'publicada';
    if (!inCatalog && (await checkPropertyAccess(user, id)) !== 'ok') throw new AppError(404, 'NOT_FOUND', 'La propiedad no existe.');
  }
  const extras = await Svc.loadExtras([row]);
  const exact = user.type === 'staff' || (await Svc.exactLocationFor(user)).has(id);
  res.json(await Svc.present(row, extras.amenities(id), extras.photos(id), user, exact));
};

async function respondWith(res: Parameters<RequestHandler>[1], id: string, status = 200) {
  const row = (await Properties.findById(id))!;
  const extras = await Svc.loadExtras([row]);
  res.status(status).json(await Svc.present(row, extras.amenities(id), extras.photos(id), currentUser(res)));
}

export const create: RequestHandler = async (_req, res) => {
  const id = await Svc.create(currentUser(res), res.locals.body as z.infer<typeof createDto>);
  await respondWith(res, id, 201);
};

export const update: RequestHandler = async (_req, res) => {
  const { id } = res.locals.params as { id: string };
  await Svc.update(currentUser(res), id, res.locals.body as Properties.PropertyWrite);
  await respondWith(res, id);
};

export const setAvailability: RequestHandler = async (_req, res) => {
  const { id } = res.locals.params as { id: string };
  await Svc.setAvailability(currentUser(res), id, res.locals.body as z.infer<typeof availabilityDto>);
  await respondWith(res, id);
};

export const reassign: RequestHandler = async (_req, res) => {
  const { id } = res.locals.params as { id: string };
  const moved = await Svc.reassignBroker(currentUser(res), id, (res.locals.body as z.infer<typeof brokerDto>).brokerId);
  const row = (await Properties.findById(id))!;
  const extras = await Svc.loadExtras([row]);
  res.json({ ...(await Svc.present(row, extras.amenities(id), extras.photos(id), currentUser(res))), appointmentsReassigned: moved });
};

/** Convierte el enlace de Google Maps que pega el personal en latitud, longitud y dirección. */
export const locate: RequestHandler = async (_req, res) => {
  res.json(await locateFromMapsUrl((res.locals.body as z.infer<typeof locateDto>).url));
};

export const remove: RequestHandler = async (_req, res) => {
  const { id } = res.locals.params as { id: string };
  const cancelled = await Svc.remove(currentUser(res), id);
  res.json({ message: 'La propiedad se dio de baja del inventario y del catálogo.', appointmentsCancelled: cancelled });
};
