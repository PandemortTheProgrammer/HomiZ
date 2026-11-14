import { pool, withTransaction } from '../config/database.js';
import { createDownloadUrl, fileSize, keyBelongsTo } from '../config/storage.js';
import { AppError } from '../middlewares/error-handler.js';
import type { AuthUser } from '../middlewares/authenticate.js';
import * as Properties from '../models/property.model.js';
import { insertActivity } from '../models/activity.model.js';
import { isAdmin, assertPropertyEdit } from './access.service.js';
import { cancelVisitsOfHouse } from './appointment.service.js';
import { nextCode, slugify, uniqueSlug } from './codes.service.js';
import { notify, userOfClient } from './notification.service.js';

/* ---------- Presentación ---------- */

/** Las fotos del sitio (sin carpeta, p. ej. "casa-ceiba.jpg") viven en web/assets/img; las subidas, en el almacenamiento. */
export async function photoUrl(key: string): Promise<string | null> {
  if (!key.includes('/')) return null;
  const mime = key.endsWith('.png') ? 'image/png' : key.endsWith('.webp') ? 'image/webp' : 'image/jpeg';
  return (await createDownloadUrl(key, mime, key.split('/').pop()!)).url;
}

async function presentPhotos(photos: Properties.PhotoRow[]) {
  return Promise.all(photos.map(async (p) => ({ id: p.id, key: p.storage_key, label: p.label, position: p.position, url: await photoUrl(p.storage_key) })));
}

/**
 * Propiedades cuya ubicación exacta puede ver un cliente: con cita confirmada o visita realizada, o donde es inquilino.
 * Para las demás recibe la zona aproximada, igual que el sitio.
 */
export async function exactLocationFor(user: AuthUser): Promise<Set<string>> {
  if (user.type === 'staff') return new Set();
  if (!user.clientId) return new Set();
  const { rows } = await pool.query<{ id: string }>(
    `SELECT property_id AS id FROM appointments WHERE client_id = $1 AND status IN ('confirmada', 'realizada')
     UNION SELECT property_id FROM contracts WHERE client_id = $1 AND status = 'active'`,
    [user.clientId],
  );
  return new Set(rows.map((r) => r.id));
}

export async function present(row: Properties.PropertyRow, amenities: string[], photos: Properties.PhotoRow[], user: AuthUser, exact = true) {
  const base = {
    id: row.id,
    code: row.code,
    slug: row.slug,
    name: row.name,
    type: row.type,
    description: row.description,
    operation: row.operation,
    price: row.price,
    rec: row.rec,
    banos: row.banos,
    m2: row.m2,
    terreno: row.terreno,
    est: row.est,
    age: row.age,
    furnished: row.furnished,
    petsAllowed: row.pets_allowed,
    maintenance: row.maintenance,
    deposit: row.deposit,
    availableFrom: row.available_from,
    address: row.address,
    street: row.street,
    city: row.city,
    zone: row.zone,
    zoneKey: row.zone_key,
    mapQuery: row.map_query,
    lat: row.lat,
    lng: row.lng,
    exactLocation: true,
    status: row.status,
    visibility: row.visibility,
    publishedAt: row.published_at,
    amenities,
    photos: await presentPhotos(photos),
  };
  if (user.type !== 'staff') {
    // Al cliente nunca se le envía el broker de la casa aquí; la dirección exacta, solo con cita confirmada
    if (exact) return base;
    return { ...base, address: '', street: null, mapQuery: null, ...approxLocation(row.id, row.lat, row.lng), exactLocation: false, areaMeters: PUBLIC_AREA_METERS };
  }
  return {
    ...base,
    broker: row.broker_id ? { id: row.broker_id, name: row.broker_name, phone: row.broker_phone, email: row.broker_email } : null,
    utilities: { electricityServiceNumber: row.electricity_service_number, waterServiceNumber: row.water_service_number, reminderDay: row.utility_reminder_day },
    maintenanceFee: row.maintenance_fee == null ? null : { amount: Number(row.maintenance_fee), day: row.maintenance_fee_day },
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

/** Radio del círculo que el sitio dibuja alrededor de la ubicación aproximada (≈ 3 km de diámetro). */
export const PUBLIC_AREA_METERS = 1500;

/**
 * Ubicación aproximada para el sitio público: el punto se mueve entre 300 m y 1 km en una dirección
 * fija por propiedad (siempre la misma, para que no se pueda promediar) y queda dentro del círculo.
 */
export function approxLocation(id: string, lat: number | null, lng: number | null): { lat: number | null; lng: number | null } {
  if (lat == null || lng == null) return { lat: null, lng: null };
  let h = 2166136261;
  for (const ch of id) h = Math.imul(h ^ ch.charCodeAt(0), 16777619) >>> 0;
  const angle = ((h & 0xffff) / 0xffff) * 2 * Math.PI;
  const meters = 300 + ((h >>> 16) / 0xffff) * 700;
  const dLat = (meters * Math.cos(angle)) / 111_320;
  const dLng = (meters * Math.sin(angle)) / (111_320 * Math.cos((Number(lat) * Math.PI) / 180));
  const round = (v: number) => Math.round(v * 1000) / 1000;
  return { lat: round(Number(lat) + dLat), lng: round(Number(lng) + dLng) };
}

/** Formato del catálogo público (mismos nombres que usa el sitio en assets/js/main.js). */
export async function presentPublic(row: Properties.PropertyRow, amenities: string[], photos: Properties.PhotoRow[]) {
  return {
    slug: row.slug,
    code: row.code,
    name: row.name,
    tipo: row.type,
    description: row.description,
    op: row.operation,
    price: row.price,
    rec: row.rec,
    banos: row.banos,
    m2: row.m2,
    terreno: row.terreno,
    est: row.est,
    age: row.age,
    pets: row.pets_allowed,
    furnished: row.furnished,
    maintenance: row.maintenance,
    zona: row.zone,
    zonaKey: row.zone_key,
    mapa: row.map_query,
    // Ubicación aproximada (zona de ≈ 3 km): el sitio público no revela la dirección ni el punto exacto.
    ...approxLocation(row.id, row.lat, row.lng),
    areaMeters: PUBLIC_AREA_METERS,
    status: row.status,
    publishedAt: row.published_at,
    amenities,
    photos: await Promise.all(photos.map(async (p) => ({ src: (await photoUrl(p.storage_key)) ?? p.storage_key, label: p.label }))),
    // El sitio muestra «Te acompaña: …» en la solicitud de visita: solo el nombre, sin datos de contacto.
    asesor: row.broker_name,
  };
}

export async function loadExtras(rows: Properties.PropertyRow[]) {
  const ids = rows.map((r) => r.id);
  const [amenities, photos] = await Promise.all([Properties.amenitiesFor(ids), Properties.photosFor(ids)]);
  return { amenities: (id: string) => amenities.get(id) ?? [], photos: (id: string) => photos.get(id) ?? [] };
}

/* ---------- Reglas de negocio ---------- */

async function assertBroker(brokerId: string): Promise<void> {
  const { rows } = await pool.query(
    `SELECT 1 FROM users u JOIN user_roles ur ON ur.user_id = u.id JOIN roles r ON r.id = ur.role_id
      WHERE u.id = $1 AND u.active AND r.code IN ('broker', 'admin')`,
    [brokerId],
  );
  if (!rows.length) throw new AppError(400, 'INVALID_BROKER', 'El responsable debe ser un broker o administrador activo.');
}

async function validatePhotoKeys(code: string, propertyId: string, photos: { storageKey: string }[]): Promise<void> {
  const current = new Set((await Properties.photosFor([propertyId])).get(propertyId)?.map((p) => p.storage_key) ?? []);
  for (const p of photos) {
    if (current.has(p.storageKey)) continue;
    if (!keyBelongsTo(p.storageKey, code, 'property_photo') || (await fileSize(p.storageKey)) === null) {
      throw new AppError(400, 'INVALID_FILE', 'Una de las fotos no se subió correctamente. Vuelve a subirla.', { storageKey: p.storageKey });
    }
  }
}

type CreateInput = Properties.PropertyWrite & {
  name: string;
  operation: 'renta' | 'venta';
  price: number;
  zone: string;
  amenities?: string[];
  brokerId?: string;
};

/** Alta: un broker queda asignado a la casa que registra; el administrador puede elegir el broker. */
export async function create(user: AuthUser, data: CreateInput): Promise<string> {
  let brokerId: string | null = user.id;
  if (isAdmin(user) && data.brokerId) brokerId = data.brokerId;
  else if (!user.roles.includes('broker')) brokerId = data.brokerId ?? null;
  if (brokerId) await assertBroker(brokerId);

  return withTransaction(async (db) => {
    const code = await nextCode(db, 'properties', 'ZUG');
    const slug = await uniqueSlug(db, data.name);
    const zoneKey = data.zoneKey ?? slugify(data.zone);
    // Sin borradores: queda disponible y pausada hasta que tenga fotos y se publique
    const id = await Properties.insert(db, { ...data, zoneKey, code, slug, brokerId, status: 'disponible', visibility: 'pausada' });
    if (data.amenities) await Properties.replaceAmenities(db, id, data.amenities);
    await insertActivity({ userId: user.id, propertyId: id, entity: 'property', entityId: id, action: 'create', description: `${user.name} registró ${data.name} (${code}).`, newValues: data }, db);
    return id;
  });
}

export async function update(
  user: AuthUser,
  id: string,
  data: Properties.PropertyWrite & { amenities?: string[]; photos?: { storageKey: string; label: string }[] },
): Promise<void> {
  await assertPropertyEdit(user, id);
  const before = await Properties.findById(id);
  if (!before) throw new AppError(404, 'NOT_FOUND', 'La propiedad no existe.');
  // Los números de servicio de agua y luz los captura administración
  const utilities = data.electricityServiceNumber !== undefined || data.waterServiceNumber !== undefined || data.utilityReminderDay !== undefined;
  if (utilities && !isAdmin(user)) throw new AppError(403, 'FORBIDDEN', 'Los números de servicio de agua y luz los captura administración.');
  if ((data.maintenanceFee !== undefined || data.maintenanceFeeDay !== undefined) && !isAdmin(user)) throw new AppError(403, 'FORBIDDEN', 'La cuota de mantenimiento la captura administración.');
  if (data.photos) await validatePhotoKeys(before.code, id, data.photos);
  await withTransaction(async (db) => {
    const slug = data.name && data.name !== before.name ? await uniqueSlug(db, data.name, id) : undefined;
    await Properties.update(db, id, { ...data, slug });
    if (data.amenities) await Properties.replaceAmenities(db, id, data.amenities);
    if (data.photos) await Properties.replacePhotos(db, id, data.photos);
    if (data.photos && !data.photos.length && before.visibility === 'publicada') {
      await db.query(`UPDATE properties SET visibility = 'pausada' WHERE id = $1`, [id]);
    }
    await insertActivity({ userId: user.id, propertyId: id, entity: 'property', entityId: id, action: 'update', description: `${user.name} actualizó la información de ${data.name ?? before.name}.`, newValues: data }, db);
  });
}

export async function setAvailability(user: AuthUser, id: string, data: { status?: Properties.PropertyRow['status']; visibility?: Properties.PropertyRow['visibility'] }): Promise<void> {
  await assertPropertyEdit(user, id);
  const p = await Properties.findById(id);
  if (!p) throw new AppError(404, 'NOT_FOUND', 'La propiedad no existe.');
  const status = data.status ?? p.status;
  const visibility = data.visibility ?? p.visibility;
  if (status === 'borrador' || visibility === 'borrador') {
    throw new AppError(400, 'VALIDATION_ERROR', 'Ya no hay borradores: la propiedad está disponible, pausada o publicada.');
  }
  // Con contrato vigente la casa sigue rentada y fuera del sitio: se libera solo al finalizar el contrato
  if ((status !== 'rentada' || visibility === 'publicada') && p.operation === 'renta') {
    const { rows: [ct] } = await pool.query<{ name: string; end_date: string }>(
      `SELECT c.name, to_char(ct.end_date, 'DD/MM/YYYY') AS end_date FROM contracts ct JOIN clients c ON c.id = ct.client_id
        WHERE ct.property_id = $1 AND ct.status = 'active' LIMIT 1`,
      [id],
    );
    if (ct) throw new AppError(409, 'ACTIVE_CONTRACT', `Tiene contrato vigente con ${ct.name} hasta el ${ct.end_date}. Para volver a publicarla, primero finaliza el contrato (Rentas › Contrato).`);
  }
  // Vendida con venta registrada: sigue vendida y fuera del sitio hasta que se anule la venta
  if ((status !== 'vendida' || visibility === 'publicada') && p.operation === 'venta') {
    const { rows: [sale] } = await pool.query<{ folio: string; name: string }>(
      `SELECT s.folio, c.name FROM sales s JOIN clients c ON c.id = s.client_id WHERE s.property_id = $1 AND s.status = 'closed' LIMIT 1`,
      [id],
    );
    if (sale) throw new AppError(409, 'CLOSED_SALE', `Se vendió a ${sale.name} (venta ${sale.folio}). Para volver a publicarla, primero anula la venta (Rentas y ventas › Ventas).`);
  }
  // No se aparta una propiedad hasta que se realizó una visita
  if (status === 'reservada' && p.status !== 'reservada') {
    const { rowCount } = await pool.query(`SELECT 1 FROM appointments WHERE property_id = $1 AND status = 'realizada' LIMIT 1`, [id]);
    if (!rowCount) throw new AppError(409, 'VISIT_REQUIRED', 'Solo se puede apartar después de una visita realizada. Marca primero la visita como realizada.');
  }
  // Rentada o vendida: sale del catálogo (queda pausada)
  const finalVisibility = status === 'rentada' || status === 'vendida' ? 'pausada' : visibility;
  if (visibility === 'publicada' && !(status === 'rentada' || status === 'vendida') && (await Properties.photoCount(id)) === 0) {
    throw new AppError(409, 'PHOTOS_REQUIRED', 'Agrega al menos una fotografía antes de publicar la casa.');
  }
  await pool.query(
    `UPDATE properties SET status = $2::property_status, visibility = $3::property_visibility, updated_at = now(),
            published_at = CASE WHEN $3::text = 'publicada' AND published_at IS NULL THEN CURRENT_DATE ELSE published_at END
      WHERE id = $1`,
    [id, status, finalVisibility],
  );
  if (status === 'rentada' || status === 'vendida') await cancelVisitsOfHouse(pool, id, status === 'rentada' ? 'La casa ya se rentó.' : 'La casa se vendió.');
  await insertActivity({
    userId: user.id, propertyId: id, entity: 'property', entityId: id, action: 'availability',
    description: `${user.name} cambió ${p.name} a ${status} · ${finalVisibility}.`,
    oldValues: { status: p.status, visibility: p.visibility }, newValues: { status, visibility: finalVisibility },
  });
}

/** Reasigna el broker y sus citas próximas (regla del panel). Solo administrador (properties.reassign). */
export async function reassignBroker(user: AuthUser, id: string, brokerId: string): Promise<number> {
  const p = await Properties.findById(id);
  if (!p) throw new AppError(404, 'NOT_FOUND', 'La propiedad no existe.');
  await assertBroker(brokerId);
  if (p.broker_id === brokerId) return 0;
  try {
    return await withTransaction(async (db) => {
      await db.query('UPDATE properties SET broker_id = $2, updated_at = now() WHERE id = $1', [id, brokerId]);
      const moved = await db.query(
        `UPDATE appointments SET broker_id = $2
          WHERE property_id = $1 AND status IN ('por-confirmar', 'confirmada') AND scheduled_at > now()`,
        [id, brokerId],
      );
      const { rows } = await db.query<{ name: string }>('SELECT name FROM users WHERE id = $1', [brokerId]);
      await insertActivity({
        userId: user.id, propertyId: id, entity: 'property', entityId: id, action: 'reassign_broker',
        description: `${user.name} asignó ${p.name} a ${rows[0].name}${moved.rowCount ? ` y se reasignaron ${moved.rowCount} citas` : ''}.`,
        oldValues: { brokerId: p.broker_id }, newValues: { brokerId },
      }, db);
      await notify([brokerId], { type: 'property_assigned', title: 'Nueva casa asignada', message: `Ahora eres responsable de ${p.name} (${p.code}).`, entity: 'property', entityId: id }, db);
      return moved.rowCount ?? 0;
    });
  } catch (err) {
    if ((err as { code?: string }).code === '23505') {
      throw new AppError(409, 'SCHEDULE_CONFLICT', 'El nuevo broker ya tiene una cita a la misma hora que una de esta casa. Reprograma esa cita primero.');
    }
    throw err;
  }
}

/** Baja lógica. Cancela sus citas próximas (quedan en historial) y avisa a los clientes. */
export async function remove(user: AuthUser, id: string): Promise<number> {
  await assertPropertyEdit(user, id);
  const p = await Properties.findById(id);
  if (!p) throw new AppError(404, 'NOT_FOUND', 'La propiedad no existe.');
  const { rowCount: contracts } = await pool.query(`SELECT 1 FROM contracts WHERE property_id = $1 AND status = 'active'`, [id]);
  if (contracts) throw new AppError(409, 'HAS_ACTIVE_CONTRACT', 'La casa tiene un contrato vigente. Finalízalo antes de darla de baja.');

  return withTransaction(async (db) => {
    await db.query(`UPDATE properties SET active = FALSE, visibility = 'pausada', updated_at = now() WHERE id = $1`, [id]);
    const { rows } = await db.query<{ id: string; client_id: string; scheduled_at: Date }>(
      `UPDATE appointments SET status = 'cancelada', reason = 'La propiedad se retiró del inventario.'
        WHERE property_id = $1 AND status IN ('por-confirmar', 'confirmada') AND scheduled_at > now()
        RETURNING id, client_id, scheduled_at`,
      [id],
    );
    for (const a of rows) {
      await notify([await userOfClient(a.client_id, db)], {
        type: 'appointment_cancelled', title: 'Cita cancelada', message: `Tu cita en ${p.name} se canceló porque la casa ya no está disponible.`,
        entity: 'appointment', entityId: a.id,
      }, db);
    }
    await insertActivity({
      userId: user.id, propertyId: id, entity: 'property', entityId: id, action: 'delete',
      description: `${user.name} dio de baja ${p.name} (${p.code})${rows.length ? ` y se cancelaron ${rows.length} citas` : ''}.`,
    }, db);
    return rows.length;
  });
}
