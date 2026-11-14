import { pool, type Db } from '../config/database.js';

export interface PropertyRow {
  id: string;
  code: string;
  slug: string;
  name: string;
  type: string;
  description: string;
  operation: 'renta' | 'venta';
  price: number;
  rec: number;
  banos: number;
  m2: number | null;
  terreno: number | null;
  est: number;
  age: number | null;
  furnished: string;
  pets_allowed: boolean;
  maintenance: string | null;
  deposit: number | null;
  available_from: string | null;
  address: string;
  street: string | null;
  city: string;
  zone: string;
  zone_key: string;
  map_query: string | null;
  lat: number | null;
  lng: number | null;
  status: 'disponible' | 'reservada' | 'rentada' | 'vendida' | 'borrador';
  visibility: 'publicada' | 'pausada' | 'borrador';
  broker_id: string | null;
  broker_name: string | null;
  broker_phone: string | null;
  broker_email: string | null;
  published_at: string | null;
  /** Servicios: número de servicio de luz (CFE) y agua (Aguakan) y día del recordatorio mensual al inquilino */
  electricity_service_number: string | null;
  water_service_number: string | null;
  utility_reminder_day: number;
  /** Cuota de mantenimiento (la captura administración) y día del mes en que se paga */
  maintenance_fee: string | null;
  maintenance_fee_day: number | null;
  active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface PhotoRow {
  id: string;
  property_id: string;
  storage_key: string;
  label: string;
  position: number;
}

const SELECT = `
  SELECT p.id, p.code, p.slug, p.name, p.type, p.description, p.operation, p.price, p.rec, p.banos, p.m2, p.terreno,
         p.est, p.age, p.furnished, p.pets_allowed, p.maintenance, p.deposit,
         to_char(p.available_from, 'YYYY-MM-DD') AS available_from, p.address, p.street, p.city, p.zone, p.zone_key,
         p.map_query, p.lat, p.lng, p.status, p.visibility, p.broker_id,
         b.name AS broker_name, b.phone AS broker_phone, b.email AS broker_email,
         to_char(p.published_at, 'YYYY-MM-DD') AS published_at, p.electricity_service_number, p.water_service_number,
         p.utility_reminder_day, p.maintenance_fee, p.maintenance_fee_day, p.active, p.created_at, p.updated_at
    FROM properties p
    LEFT JOIN users b ON b.id = p.broker_id`;

export interface PropertyFilters {
  q?: string;
  operation?: 'renta' | 'venta';
  status?: string[];
  visibility?: string[];
  zoneKey?: string;
  type?: string;
  types?: string[];
  brokerId?: string;
  priceMin?: number;
  priceMax?: number;
  recMin?: number;
  recExact?: number;
  banosMin?: number;
  estMin?: number;
  m2Min?: number;
  m2Max?: number;
  pets?: boolean;
  furnished?: string;
  amenities?: string[];
  /** null = sin restricción; arreglo = solo esas propiedades */
  ids?: string[] | null;
  sort?: 'price_asc' | 'price_desc' | 'recent' | 'updated';
  page: number;
  limit: number;
}

export async function list(f: PropertyFilters): Promise<{ rows: PropertyRow[]; total: number }> {
  const where = ['p.active'];
  const params: unknown[] = [];
  const add = (sql: string, ...values: unknown[]) => {
    let s = sql;
    for (const v of values) {
      params.push(v);
      s = s.replace('?', `$${params.length}`);
    }
    where.push(s);
  };
  if (f.ids) add('p.id = ANY(?::uuid[])', f.ids);
  if (f.q) add(`(p.name ILIKE ? OR p.code ILIKE ? OR p.address ILIKE ? OR p.zone ILIKE ?)`, ...Array(4).fill(`%${f.q}%`));
  if (f.operation) add('p.operation = ?', f.operation);
  if (f.status?.length) add('p.status::text = ANY(?::text[])', f.status);
  if (f.visibility?.length) add('p.visibility::text = ANY(?::text[])', f.visibility);
  if (f.zoneKey) add('p.zone_key = ?', f.zoneKey);
  if (f.type) add('p.type = ?', f.type);
  if (f.types?.length) add('p.type = ANY(?::text[])', f.types);
  if (f.brokerId) add('p.broker_id = ?', f.brokerId);
  if (f.priceMin !== undefined) add('p.price >= ?', f.priceMin);
  if (f.priceMax !== undefined) add('p.price <= ?', f.priceMax);
  if (f.recMin !== undefined) add('p.rec >= ?', f.recMin);
  if (f.recExact !== undefined) add('p.rec = ?', f.recExact);
  if (f.banosMin !== undefined) add('p.banos >= ?', f.banosMin);
  if (f.estMin !== undefined) add('p.est >= ?', f.estMin);
  if (f.m2Min !== undefined) add('p.m2 >= ?', f.m2Min);
  if (f.m2Max !== undefined) add('p.m2 <= ?', f.m2Max);
  if (f.pets !== undefined) add('p.pets_allowed = ?', f.pets);
  if (f.furnished) add('p.furnished = ?', f.furnished);
  if (f.amenities?.length) {
    add(
      `(SELECT count(DISTINCT lower(a.name)) FROM property_amenities a WHERE a.property_id = p.id AND lower(a.name) = ANY(?::text[])) = ?`,
      f.amenities.map((a) => a.toLowerCase()),
      new Set(f.amenities.map((a) => a.toLowerCase())).size,
    );
  }
  const order = {
    price_asc: 'p.price ASC, p.code',
    price_desc: 'p.price DESC, p.code',
    recent: 'p.published_at DESC NULLS LAST, p.created_at DESC',
    updated: 'p.updated_at DESC',
  }[f.sort ?? 'updated'];
  const whereSql = `WHERE ${where.join(' AND ')}`;
  const total = await pool.query<{ count: string }>(`SELECT count(*) FROM properties p ${whereSql}`, params);
  const { rows } = await pool.query<PropertyRow>(
    `${SELECT} ${whereSql} ORDER BY ${order} LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, f.limit, (f.page - 1) * f.limit],
  );
  return { rows, total: Number(total.rows[0].count) };
}

export async function findById(id: string, db: Db = pool): Promise<PropertyRow | null> {
  const { rows } = await db.query<PropertyRow>(`${SELECT} WHERE p.id = $1 AND p.active`, [id]);
  return rows[0] ?? null;
}

export async function findBySlug(slug: string): Promise<PropertyRow | null> {
  const { rows } = await pool.query<PropertyRow>(`${SELECT} WHERE p.slug = $1 AND p.active`, [slug]);
  return rows[0] ?? null;
}

export async function findByCode(code: string): Promise<PropertyRow | null> {
  const { rows } = await pool.query<PropertyRow>(`${SELECT} WHERE p.code = $1 AND p.active`, [code]);
  return rows[0] ?? null;
}

export async function amenitiesFor(ids: string[]): Promise<Map<string, string[]>> {
  const map = new Map<string, string[]>();
  if (!ids.length) return map;
  const { rows } = await pool.query<{ property_id: string; name: string }>(
    'SELECT property_id, name FROM property_amenities WHERE property_id = ANY($1::uuid[]) ORDER BY position, name',
    [ids],
  );
  for (const r of rows) map.set(r.property_id, [...(map.get(r.property_id) ?? []), r.name]);
  return map;
}

export async function photosFor(ids: string[]): Promise<Map<string, PhotoRow[]>> {
  const map = new Map<string, PhotoRow[]>();
  if (!ids.length) return map;
  const { rows } = await pool.query<PhotoRow>(
    'SELECT id, property_id, storage_key, label, position FROM property_photos WHERE property_id = ANY($1::uuid[]) ORDER BY position',
    [ids],
  );
  for (const r of rows) map.set(r.property_id, [...(map.get(r.property_id) ?? []), r]);
  return map;
}

export interface PropertyWrite {
  name?: string;
  type?: string;
  description?: string;
  operation?: 'renta' | 'venta';
  price?: number;
  rec?: number;
  banos?: number;
  m2?: number | null;
  terreno?: number | null;
  est?: number;
  age?: number | null;
  furnished?: string;
  petsAllowed?: boolean;
  maintenance?: string | null;
  deposit?: number | null;
  availableFrom?: string | null;
  address?: string;
  street?: string | null;
  city?: string;
  zone?: string;
  zoneKey?: string;
  mapQuery?: string | null;
  lat?: number | null;
  lng?: number | null;
  electricityServiceNumber?: string | null;
  waterServiceNumber?: string | null;
  utilityReminderDay?: number;
  maintenanceFee?: number | null;
  maintenanceFeeDay?: number | null;
}

const COLUMN: Record<keyof PropertyWrite, string> = {
  name: 'name', type: 'type', description: 'description', operation: 'operation', price: 'price', rec: 'rec', banos: 'banos',
  m2: 'm2', terreno: 'terreno', est: 'est', age: 'age', furnished: 'furnished', petsAllowed: 'pets_allowed',
  maintenance: 'maintenance', deposit: 'deposit', availableFrom: 'available_from', address: 'address', street: 'street',
  city: 'city', zone: 'zone', zoneKey: 'zone_key', mapQuery: 'map_query', lat: 'lat', lng: 'lng',
  electricityServiceNumber: 'electricity_service_number', waterServiceNumber: 'water_service_number', utilityReminderDay: 'utility_reminder_day',
  maintenanceFee: 'maintenance_fee', maintenanceFeeDay: 'maintenance_fee_day',
};

export async function insert(
  db: Db,
  data: PropertyWrite & { code: string; slug: string; brokerId: string | null; status: string; visibility: string },
): Promise<string> {
  const cols = ['code', 'slug', 'broker_id', 'status', 'visibility'];
  const vals: unknown[] = [data.code, data.slug, data.brokerId, data.status, data.visibility];
  for (const [k, col] of Object.entries(COLUMN) as [keyof PropertyWrite, string][]) {
    if (data[k] !== undefined) {
      cols.push(col);
      vals.push(data[k]);
    }
  }
  const { rows } = await db.query<{ id: string }>(
    `INSERT INTO properties (${cols.join(', ')}) VALUES (${cols.map((_, i) => `$${i + 1}`).join(', ')}) RETURNING id`,
    vals,
  );
  return rows[0].id;
}

export async function update(db: Db, id: string, data: PropertyWrite & { slug?: string }): Promise<void> {
  const sets: string[] = [];
  const vals: unknown[] = [];
  const entries = Object.entries(COLUMN) as [keyof PropertyWrite, string][];
  for (const [k, col] of entries) {
    if (data[k] !== undefined) {
      vals.push(data[k]);
      sets.push(`${col} = $${vals.length}`);
    }
  }
  if (data.slug) {
    vals.push(data.slug);
    sets.push(`slug = $${vals.length}`);
  }
  if (!sets.length) return;
  vals.push(id);
  await db.query(`UPDATE properties SET ${sets.join(', ')}, updated_at = now() WHERE id = $${vals.length}`, vals);
}

export async function replaceAmenities(db: Db, id: string, names: string[]): Promise<void> {
  await db.query('DELETE FROM property_amenities WHERE property_id = $1', [id]);
  const unique = [...new Map(names.map((n) => [n.trim().toLowerCase(), n.trim()])).values()].filter(Boolean);
  for (const [i, name] of unique.entries()) {
    await db.query('INSERT INTO property_amenities (property_id, name, position) VALUES ($1, $2, $3)', [id, name, i]);
  }
}

export async function replacePhotos(db: Db, id: string, photos: { storageKey: string; label: string }[]): Promise<void> {
  await db.query('DELETE FROM property_photos WHERE property_id = $1', [id]);
  for (const [i, p] of photos.entries()) {
    await db.query('INSERT INTO property_photos (property_id, storage_key, label, position) VALUES ($1, $2, $3, $4)', [id, p.storageKey, p.label, i]);
  }
}

export async function photoCount(id: string, db: Db = pool): Promise<number> {
  const { rows } = await db.query<{ n: string }>('SELECT count(*) AS n FROM property_photos WHERE property_id = $1', [id]);
  return Number(rows[0].n);
}
