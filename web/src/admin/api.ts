import { API_URL } from '../lib/api';
import { clearSession, currentSession, isAdminSession, refreshAccess, saveTokens } from './auth';
import { pushLogout } from './push';
import { addMinutes, D, dateShort, norm, cap, rerender, viewState, Z, type Appointment, type Broker, type Person, type Property } from './store';

/* ==========================================================================
   Conexión del panel con la API de Homiz.
   El panel carga los datos del servidor y cada cambio se guarda ahí. El aviso de éxito se muestra
   solo cuando el servidor confirma; si falla, se muestra su mensaje de error.
   ========================================================================== */
const WAIT_MS = 8000;

export interface ApiFailure {
  status?: number;
  codigo?: string;
  mensaje?: string;
  detalles?: unknown;
  sinConexion?: boolean;
  /** Propiedad nueva que se creó aunque fallara un paso posterior (fotos, estado…) */
  creada?: string;
}

/** Avisos flotantes del panel (los registra el Shell) */
export const notify = { toast: (_msg: string) => {} };

async function fetchJson<T>(path: string, init: RequestInit): Promise<T> {
  if (!API_URL) throw { sinConexion: true, mensaje: 'No hay conexión con el servidor de Zugar.' } satisfies ApiFailure;
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), WAIT_MS);
  let res: Response;
  try {
    res = await fetch(API_URL + path, { ...init, signal: ctrl.signal });
  } catch {
    throw { sinConexion: true, mensaje: 'No hay conexión con el servidor de Zugar.' } satisfies ApiFailure;
  } finally {
    clearTimeout(timer);
  }
  const body = await res.json().catch(() => ({}));
  if (res.ok) return body as T;
  const e = body?.error ?? {};
  throw { status: res.status, codigo: e.code, mensaje: e.message || 'El servidor no pudo completar la acción.', detalles: e.details } satisfies ApiFailure;
}

let renewing: Promise<void> | null = null;
function renew(): Promise<void> {
  const s = currentSession();
  if (!s?.refresh) return Promise.reject({ status: 401 });
  renewing ??= fetchJson<{ accessToken: string; refreshToken: string }>('/auth/refresh', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ refreshToken: s.refresh }),
  })
    .then((r) => saveTokens(r.accessToken, r.refreshToken))
    .finally(() => (renewing = null));
  return renewing;
}

export async function request<T = any>(method: string, path: string, body?: unknown, retry = false): Promise<T> {
  const s = currentSession();
  const headers: Record<string, string> = { Accept: 'application/json' };
  if (s?.token) headers.Authorization = 'Bearer ' + s.token;
  if (body !== undefined) headers['Content-Type'] = 'application/json';
  try {
    return await fetchJson<T>(path, { method, headers, body: body === undefined ? undefined : JSON.stringify(body) });
  } catch (err) {
    const e = err as ApiFailure;
    if (e.status === 401 && !retry) {
      try {
        await renew();
      } catch {
        clearSession(); // la sesión del servidor terminó
        location.replace('#/login');
        throw e;
      }
      return request<T>(method, path, body, true);
    }
    throw e;
  }
}

export const apiActive = () => {
  const s = currentSession();
  return !!(API_URL && s?.api && s.token);
};

export function apiLogin(email: string, password: string) {
  return fetchJson<{ user: { type: string; email: string; name: string; roles: string[]; permissions: string[]; mustChangePassword?: boolean }; accessToken: string; refreshToken: string }>('/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ email: email.trim(), password }),
  });
}

export function apiForgot(email: string) {
  return fetchJson('/auth/forgot-password', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ email: email.trim() }),
  }).catch(() => {
    /* el mensaje en pantalla es el mismo exista o no la cuenta */
  });
}

/** Nueva contraseña con el código del correo de recuperación (POST /auth/reset-password) */
export function apiReset(token: string, password: string) {
  return fetchJson<{ message: string }>('/auth/reset-password', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ token, password }),
  });
}

/** Crea su contraseña (tras entrar con la temporal del correo); devuelve tokens nuevos (POST /auth/change-password) */
export function apiChangePassword(currentPassword: string, newPassword: string) {
  return request<{ message: string; accessToken: string; refreshToken: string }>('POST', '/auth/change-password', { currentPassword, newPassword });
}

export function apiLogout() {
  const s = currentSession();
  if (!apiActive() || !s?.refresh) return;
  pushLogout(s.token!); // este navegador deja de recibir los avisos de la cuenta
  fetchJson('/auth/logout', {
    method: 'POST',
    keepalive: true,
    headers: { 'Content-Type': 'application/json', Accept: 'application/json', Authorization: 'Bearer ' + s.token },
    body: JSON.stringify({ refreshToken: s.refresh }),
  }).catch(() => {});
}

/* ---------- Fechas en hora de Cancún (UTC-5 todo el año) ---------- */
const FMT = new Intl.DateTimeFormat('en-CA', { timeZone: 'America/Cancun', year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', hourCycle: 'h23' });
function inCancun(iso: string) {
  const p: Record<string, string> = {};
  FMT.formatToParts(new Date(iso)).forEach((x) => (p[x.type] = x.value));
  return { date: `${p.year}-${p.month}-${p.day}`, time: `${p.hour}:${p.minute}` };
}
export const toIso = (date: string, time: string) => `${date}T${time}:00-05:00`;
function when(iso: string) {
  const c = inCancun(iso);
  return (c.date === Z.TODAY ? 'Hoy' : dateShort(c.date) + ' ' + c.date.slice(0, 4)) + ' · ' + c.time + ' h';
}
const today = () => inCancun(new Date().toISOString()).date;
const slug = (s: string) => norm(s).replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

/* ---------- De la API al formato del panel ---------- */
const uuid: { prop: Record<string, string> } = { prop: {} }; // código ZUG-### → id de la base

function toProperty(p: any): Property {
  uuid.prop[p.code] = p.id;
  const act = p.updatedAt ? inCancun(p.updatedAt) : null;
  return {
    id: p.code, _id: p.id, _zoneKey: p.zoneKey, slug: p.slug, lat: p.lat == null ? null : Number(p.lat), lng: p.lng == null ? null : Number(p.lng),
    name: p.name, type: p.type, zone: p.zone, city: p.city, address: p.address, street: p.street || '',
    op: p.operation, price: Number(p.price), rec: Number(p.rec), banos: Number(p.banos), m2: p.m2 == null ? '' : Number(p.m2),
    terreno: p.terreno == null ? '' : Number(p.terreno), est: p.est, age: p.age == null ? '' : p.age,
    status: p.status, visibility: p.visibility, broker: p.broker ? p.broker.id : '',
    maintenance: p.maintenance || '', deposit: p.deposit == null ? 0 : Number(p.deposit),
    availableFrom: p.availableFrom ? String(p.availableFrom).slice(0, 10) : '', furnished: p.furnished, desc: p.description || '',
    amenities: p.amenities || [],
    utilities: p.utilities ? { electricity: p.utilities.electricityServiceNumber || '', water: p.utilities.waterServiceNumber || '', day: Number(p.utilities.reminderDay) || 1 } : undefined,
    fee: p.maintenanceFee ? { amount: Number(p.maintenanceFee.amount) || 0, day: Number(p.maintenanceFee.day) || 1 } : { amount: 0, day: 1 },
    // Las fotos subidas llegan con URL firmada; las del sitio, con su nombre de archivo en assets/img.
    photos: (p.photos || []).map((f: any) => ({ src: f.url || f.key, label: f.label || '', key: f.key })),
    published: p.publishedAt ? String(p.publishedAt).slice(0, 10) : '',
    updated: act ? (act.date === Z.TODAY ? 'Hoy a las ' + act.time + ' h' : dateShort(act.date) + ' · ' + act.time + ' h') : '',
    updatedAt: p.updatedAt ? Date.parse(p.updatedAt) : 0,
  };
}
function toPerson(c: any): Person {
  return {
    id: c.id, code: c.code || undefined, name: c.name, email: c.email || '', phone: c.phone || '', type: c.kind, label: c.label || undefined,
    property: c.property ? c.property.code : '', broker: c.broker ? c.broker.id : '', follow: c.followStatus,
    op: c.operation || 'Renta', budget: c.budget || '', needs: c.needs || '',
    job: [c.occupation, c.nationality ? 'Nacionalidad ' + c.nationality.toLowerCase() : ''].filter(Boolean).join(' · '),
  };
}
function toAppointment(a: any): Appointment {
  const c = inCancun(a.scheduledAt);
  return {
    id: a.code, _id: a.id, person: a.client ? a.client.id : '', property: a.property.code, broker: a.broker ? a.broker.id : '',
    date: c.date, start: c.time, end: addMinutes(c.time, a.durationMin || 15), status: a.status, kind: a.kind || 'Presencial',
    note: a.note || a.reason || '', confirmedBy: a.confirmedBy || '', lead: a.lead ?? null, awaiting: a.awaiting ?? null,
  };
}
/** Fotos del equipo que viven en assets/img (la API aún no guarda foto del personal) */
const STAFF_PHOTOS: Record<string, string> = { 'mariana@zugar.example': 'asesora-mariana-solis.jpg' };
function toBroker(u: any): Broker {
  return {
    id: u.id, name: u.name, initials: u.initials || norm(u.name).split(/\s+/).map((w) => w[0]).slice(0, 2).join('').toUpperCase(),
    role: u.specialty || '', zones: u.zones || '', email: u.email || '', phone: u.phone || '',
    photo: STAFF_PHOTOS[String(u.email || '').toLowerCase()] || '', active: u.active !== false,
  };
}

/** Llena los datos del panel con los del servidor */
export async function load() {
  if (!apiActive()) return;
  // Estados que el servidor maneja y el diseño no tenía
  Z.STATUS.vendida ??= { label: 'Vendida', tone: 'gris' };
  Z.APPT_STATUS.rechazada ??= { label: 'Rechazada', tone: 'error' };
  Z.TODAY = today();
  const list = (path: string) => request<{ data?: any[] }>('GET', path).then((r) => r.data || []);
  const [me, props, people, appts, staffOrNull, activity] = await Promise.all([
    request<{ roles: string[]; permissions: string[] }>('GET', '/users/me').catch(() => null),
    list('/properties?limit=100&sort=updated'),
    list('/clients?limit=100'),
    list('/appointments?limit=100'),
    list('/users?limit=100').catch(() => null), // solo el propietario gestiona al personal
    list('/activity-log?limit=60').catch(() => []),
  ]);
  if (me) refreshAccess(me.roles, me.permissions);
  D.staff = (staffOrNull || []).map((u: any) => ({ id: u.id, name: u.name, email: u.email, roles: u.roles || [], active: u.active !== false, properties: u.properties || 0 }));
  // Reciben casas y solicitudes: brokers y administradores (el propietario solo si también es broker)
  let users = staffOrNull && staffOrNull.filter((u: any) => { const r = u.roles || []; return r.includes('broker') || (r.includes('admin') && !r.includes('owner')); });
  if (!users) {
    // sin permiso para ver al personal: los brokers salen de las casas
    const seen = new Set<string>();
    users = props.filter((p) => p.broker && !seen.has(p.broker.id) && seen.add(p.broker.id)).map((p) => p.broker);
  }
  D.brokers = users.map(toBroker);
  D.properties = props.map(toProperty);
  D.people = people.map(toPerson);
  D.appointments = appts.map(toAppointment);
  D.properties.forEach((p) => !Z.ZONES.includes(p.zone) && Z.ZONES.push(p.zone));
  D.activity = activity.slice(0, 20).map((a: any) => ({ when: when(a.createdAt), text: a.description || a.action }));
  D.history = {};
  activity.forEach((a: any) => {
    if (a.property) (D.history[a.property.code] ??= []).push({ when: when(a.createdAt), text: a.description || a.action });
  });
  const sp = viewState.people;
  if (!D.people.some((x) => x.id === sp.selected)) sp.selected = D.people[0]?.id ?? null;
  const sc = viewState.citas;
  if (!D.appointments.some((a) => a.id === sc.selected)) sc.selected = null;
}

/** Después de guardar: recarga desde el servidor. Si falla, avisa y vuelve a los datos reales. */
function sync<T>(promise: Promise<T>, done?: (r: T) => void) {
  if (!apiActive()) return;
  promise.then(
    async (r) => {
      await load();
      done?.(r);
      rerender();
    },
    async (e: ApiFailure) => {
      notify.toast('No se guardó: ' + (e?.mensaje || 'error del servidor') + ' Se restauraron los datos.');
      await load().catch(() => {});
      rerender();
    },
  );
}

/**
 * Guardado confirmado por el servidor (clientes, brokers y citas):
 * espera la respuesta, recarga los datos reales y entonces resuelve; si la API rechaza o no responde,
 * la promesa se rechaza con el error (`mensaje`) para mostrarlo en pantalla. Nunca hay éxito falso.
 */
async function save<T>(promise: Promise<T>): Promise<T> {
  let r: T;
  try {
    r = await promise;
  } catch (e) {
    await load().catch(() => {}); // por si algo quedó a medias: se vuelve a lo que dice el servidor
    rerender();
    throw e;
  }
  await load().catch(() => {});
  rerender();
  return r;
}

/** Texto para mostrar un error de la API: el mensaje del servidor o el de sin conexión */
export const errorText = (e: unknown) => {
  const f = e as ApiFailure;
  const fields = f?.detalles && typeof f.detalles === 'object' ? Object.values(f.detalles as Record<string, string[]>).flat().filter((x) => typeof x === 'string') : [];
  const msg = f?.mensaje || 'El servidor no pudo completar la acción.';
  const extra = fields.filter((x) => !msg.includes(x)); // el mensaje ya trae el primer detalle
  return msg + (extra.length ? ' ' + extra.join(' ') : '');
};

/* ---------- Escrituras: una por cada cambio del panel ---------- */
export const ZApi = {
  appointmentStatus(a: Appointment, status: string, reason?: string) {
    const action = ({ confirmada: 'confirm', cancelada: 'cancel', realizada: 'complete', rechazada: 'reject' } as Record<string, string>)[status];
    if (!action) return Promise.reject({ mensaje: 'Estado no válido.' } satisfies ApiFailure);
    return save(request('POST', `/appointments/${a._id}/${action}`, reason ? { reason } : {}));
  },
  appointmentReschedule(a: Appointment, date: string, start: string, reason?: string) {
    return save(request('POST', `/appointments/${a._id}/reschedule`, { scheduledAt: toIso(date, start), reason: reason || undefined }));
  },
  appointmentNew(a: Pick<Appointment, 'person' | 'property' | 'date' | 'start' | 'note'>) {
    return save(request<{ code: string; moved?: boolean }>('POST', '/appointments', { propertyId: uuid.prop[a.property], clientId: a.person, scheduledAt: toIso(a.date, a.start), note: a.note || null })).then((r) => {
      viewState.citas.selected = r.code;
      return r;
    });
  },

  personSave(p: Person, isNew: boolean) {
    // «Ocupación y nacionalidad» del panel = ocupación + «Nacionalidad …» en la base
    const parts = String(p.job || '').split(/\s*·\s*/).filter(Boolean);
    const nat = parts.find((x) => /^nacionalidad\s+/i.test(x));
    const body = {
      name: p.name, email: p.email || null, phone: p.phone || null, kind: p.type, followStatus: p.follow,
      propertyId: uuid.prop[p.property] || null, brokerId: p.broker || null, operation: p.op || null,
      budget: p.budget || null, needs: p.needs || null,
      occupation: parts.filter((x) => x !== nat).join(' · ') || null,
      nationality: nat ? cap(nat.replace(/^nacionalidad\s+/i, '')) : null,
    };
    return save(isNew ? request<{ id: string }>('POST', '/clients', body) : request<{ id: string }>('PATCH', '/clients/' + p.id, body)).then((r) => {
      viewState.people.selected = r.id;
      return r;
    });
  },
  personDelete(p: Person) {
    return save(request('DELETE', '/clients/' + p.id));
  },

  brokerSave(b: Broker, isNew: boolean) {
    if (isNew) {
      // La cuenta se crea con una contraseña aleatoria; la persona entra con «¿Olvidaste tu contraseña?».
      const password = 'Zg' + Math.random().toString(36).slice(2, 10) + 'A' + Math.floor(Math.random() * 90 + 10) + 'x';
      return save(request('POST', '/users', { name: b.name, email: b.email, phone: b.phone || null, zones: b.zones || null, specialty: b.role || null, roles: ['broker'], password }));
    }
    return save(request('PATCH', '/users/' + b.id, { name: b.name, phone: b.phone || null, zones: b.zones || null, specialty: b.role || null }));
  },
  brokerActive(b: Broker, active: boolean) {
    return save(request('PATCH', '/users/' + b.id, { active }));
  },
  /** Broker, administración o ambos (solo el propietario). Devuelve la promesa para mostrar el error en el diálogo. */
  staffRoles(id: string, roles: string[]) {
    return request('PATCH', '/users/' + id, { roles }).then(async () => { await load(); rerender(); });
  },
  propertyBroker(p: Property, brokerId: string) {
    return save(request('PATCH', `/properties/${p._id || uuid.prop[p.id]}/broker`, { brokerId }));
  },
  propertyDelete(p: Property) {
    sync(request('DELETE', '/properties/' + (p._id || uuid.prop[p.id])));
  },
  propertyVisibility(p: Property) {
    sync(request('PATCH', `/properties/${p._id || uuid.prop[p.id]}/availability`, { visibility: p.visibility }));
  },

  /** Enlace de Google Maps → { lat, lng, address } (lo procesa el servidor; sin clave usa OpenStreetMap) */
  locate(url: string) {
    return request<{ lat: number; lng: number; address: string | null }>('POST', '/properties/locate', { url });
  },

  /** Archivos elegidos en el formulario (blob: → File) para subirlos al guardar */
  files: {} as Record<string, File>,
  rememberFile(src: string, file: File) {
    ZApi.files[src] = file;
  },

  /** Resuelve con el código cuando el servidor confirmó todo. Si falla, el error trae `creada`: el código si la casa nueva sí alcanzó a crearse. */
  propertySave(p: Property, isNew: boolean, before: Property | null): Promise<string> {
    if (!apiActive()) return Promise.reject({ mensaje: 'No hay sesión con el servidor.' } satisfies ApiFailure);
    const prevZone = before && before.zone === p.zone ? before._zoneKey : null;
    const sameZone = D.properties.find((x) => x.zone === p.zone && x._zoneKey);
    const data: Record<string, unknown> = {
      name: p.name, type: p.type, description: p.desc || '', operation: p.op, price: p.price, rec: p.rec, banos: p.banos,
      m2: p.m2 || null, terreno: p.terreno || null, est: p.est || 0, age: p.age === '' || p.age == null ? null : +p.age,
      furnished: p.furnished || 'Sin amueblar', petsAllowed: p.amenities.includes('Se aceptan mascotas'),
      maintenance: p.maintenance || null, deposit: p.deposit || null, availableFrom: p.availableFrom || null,
      address: p.address || '', street: p.street || null, city: p.city, zone: p.zone,
      zoneKey: prevZone || (sameZone ? sameZone._zoneKey : slug(p.zone)),
      mapQuery: p.zone + ', ' + (p.city || 'Cancún, Quintana Roo'), amenities: p.amenities,
    };
    // Ubicación del enlace de Google Maps (solo se envía si se conoce: no borra la que ya tenga)
    if (p.lat != null && p.lng != null) Object.assign(data, { lat: p.lat, lng: p.lng });
    // Servicios de agua y luz: solo administración los captura (si cambiaron)
    const u = p.utilities, bu = before?.utilities;
    if (u && isAdminSession() && (!bu || u.electricity !== bu.electricity || u.water !== bu.water || u.day !== bu.day)) {
      Object.assign(data, { electricityServiceNumber: u.electricity.trim() || null, waterServiceNumber: u.water.trim() || null, utilityReminderDay: u.day });
    }
    // Cuota de mantenimiento: también la captura administración (si cambió)
    const fe = p.fee, bf = before?.fee;
    if (fe && isAdminSession() && (!bf || fe.amount !== bf.amount || fe.day !== bf.day)) {
      Object.assign(data, { maintenanceFee: fe.amount || null, maintenanceFeeDay: fe.amount ? fe.day : null });
    }
    let id = before ? before._id! : '';
    let code = '';
    const steps = (isNew
      ? request<{ id: string; code: string }>('POST', '/properties', { brokerId: p.broker || undefined, ...data }).then((r) => { id = r.id; code = r.code; })
      : request('PATCH', '/properties/' + id, data)
    )
      .then(() => Promise.all(p.photos.map((f) => uploadPhoto(id, f))))
      .then((photos) => request('PATCH', '/properties/' + id, { photos }))
      .then(() => { if (!isNew && before!.broker !== p.broker && p.broker) return request('PATCH', `/properties/${id}/broker`, { brokerId: p.broker }); })
      .then(() => request('PATCH', `/properties/${id}/availability`, { status: p.status, visibility: p.visibility }));
    return save(steps).then(() => code || before!.id, (e: ApiFailure) => {
      throw { ...e, mensaje: e?.mensaje || 'No se pudo completar el guardado. Revisa tu conexión.', creada: code || undefined };
    });
  },
};

/* ---------- Pagos y expediente (solo con servidor; la API valida el rol en cada acción) ---------- */
export interface Note {
  id: string; number: number; label: string; amount: number; dueDate: string; status: 'pending' | 'paid' | 'overdue' | 'cancelled';
  paidAt: string | null; proofDocumentId: string | null; property: { id: string; name: string }; client?: { id: string; name: string };
  /** PDF del pagaré firmado */
  documentId: string | null;
  /** Fotos de los sellos (entrega en físico y digital) */
  stamps: { id: string; name: string; createdAt: string }[];
  payment: { id: string; amount: number; paidAt: string; receiptFolio: string; notes: string | null; registeredBy?: string } | null;
}
export interface NotesSummary { total: number; paid: number; remaining: number; remainingAmount: number; next: { number: number; dueDate: string; amount: number } | null }
export interface DossierDoc { id: string; type: string; name: string; description: string | null; mime: string; size: number; visibleToClient: boolean; createdAt: string }
export interface Dossier {
  property: { id: string; code: string; name: string };
  contract: { id: string; startDate: string; endDate: string; monthlyRent: number; paymentDay: number; deposit: number | null; status: string } | null;
  tenant: { id: string; name: string; phone: string | null; email: string | null } | null;
  documents: DossierDoc[];
  utilities?: { reminderDay: number; electricity: { serviceNumber: string } | null; water: { serviceNumber: string } | null };
  payments?: { total: number; paid: number; remaining: number; overdue: number; remainingAmount: number; nextDue: string | null } | null;
  maintenance?: { id: string; title: string; category: string; priority: string; status: string; createdAt: string; closedAt: string | null }[];
  receipts?: { id: string; kind: string; concept: string; amount: number; dueDate: string | null; status: string }[];
  expenses?: { total: number; pending: number; nextMaintenance: string | null };
}

/** Contrato de renta: la persona pasa a inquilina, se generan sus pagarés y la casa queda rentada. */
export function createContract(body: { propertyId: string; clientId: string; startDate: string; endDate: string; monthlyRent: number; paymentDay: number; deposit: number | null }) {
  return request<{ id: string }>('POST', '/contracts', body);
}

/* ---------- Rentas: cada contrato con su inquilino, pagos, mantenimiento, expediente y agua y luz ---------- */
export interface Rental {
  id: string; status: 'active' | 'finished' | 'cancelled'; startDate: string; endDate: string; monthlyRent: number; paymentDay: number; deposit: number | null; documentId: string | null;
  property: { id: string; code: string; name: string };
  client: { id: string; code: string | null; name: string; phone: string | null; email: string | null };
  broker: { id: string; name: string } | null;
  notes: { total: number; paid: number; overdue: number; owed: number; nextDue: string | null };
  openReports: number;
  utilities: { electricity: string | null; water: string | null; reminderDay: number | null };
  maintenanceFee: { amount: number; day: number | null } | null;
}
export interface MaintReport {
  id: string; title: string; description: string; category: string; priority: 'low' | 'medium' | 'high'; status: string; statusLabel: string;
  provider: { id: string; name: string; specialty: string | null; phone?: string | null } | null; createdAt: string; closedAt: string | null;
}
export interface MaintDetail extends MaintReport {
  timeline: { id: string; status: string; statusLabel: string; comment: string | null; createdAt: string; author: string | null }[];
  photos: { before: { id: string; url: string }[]; after: { id: string; url: string }[] };
}
export const Rentals = {
  list: (status: string) => request<{ data: Rental[] }>('GET', '/contracts?limit=100' + (status ? '&status=' + status : '')).then((r) => r.data),
  finish: (id: string, body: { endDate?: string; reason?: string }) => request('POST', `/contracts/${id}/finish`, body),
  reports: (propertyId: string) => request<{ data: MaintReport[] }>('GET', `/maintenance-reports?limit=100&propertyId=${propertyId}`).then((r) => r.data),
  report: (id: string) => request<MaintDetail>('GET', '/maintenance-reports/' + id),
  updateReport: (id: string, body: { status: string; comment?: string; providerId?: string | null }) => request('POST', `/maintenance-reports/${id}/updates`, body),
  providers: () => request<{ data: { id: string; name: string; specialty: string | null }[] }>('GET', '/providers?limit=100').then((r) => r.data),
};

export const Finance = {
  dossier: (propertyId: string) => request<Dossier>('GET', `/properties/${propertyId}/dossier`),
  notes: (query: string) => request<{ data: Note[]; pagination: { total: number }; summary: NotesSummary | null }>('GET', '/promissory-notes?' + query),
  note: (id: string) => request<Note & { voidedPayments?: { id: string; amount: number; paidAt: string; receiptFolio: string; voidReason: string; registeredBy: string }[] }>('GET', '/promissory-notes/' + id),
  registerPayment: (n: Note, body: { paidAt: string; notes?: string }) =>
    request<Note>('POST', `/promissory-notes/${n.id}/payments`, { amount: n.amount, ...body }),
  updateNote: (n: Note, body: { amount?: number; dueDate?: string }) => request<Note>('PATCH', '/promissory-notes/' + n.id, body),
  createNote: (contractId: string, amount: number, dueDate: string) => request<Note>('POST', '/promissory-notes', { contractId, amount, dueDate }),
  cancelNote: (n: Note, reason: string) => request<Note>('POST', `/promissory-notes/${n.id}/cancel`, { reason }),
  correctPayment: (n: Note, body: { amount?: number; paidAt?: string; receiptFolio?: string; notes?: string }) =>
    request<Note>('PATCH', `/promissory-notes/${n.id}/payments/${n.payment!.id}`, body),
  voidPayment: (n: Note, reason: string) => request<Note>('POST', `/promissory-notes/${n.id}/payments/${n.payment!.id}/void`, { reason }),

  /** Abre el archivo con su URL firmada (dura unos minutos) */
  async openDocument(id: string) {
    const win = window.open('', '_blank'); // se abre antes de esperar para que el navegador no la bloquee
    try {
      const r = await request<{ url: string }>('GET', `/documents/${id}/download-url`);
      if (win) win.location.href = r.url;
      else location.href = r.url;
    } catch (e) {
      win?.close();
      throw e;
    }
  },
  /** Sube el archivo directo al almacenamiento (URL firmada) y lo registra en el expediente */
  /** Sube el archivo y devuelve su clave (sin registrarlo todavía) */
  async uploadFile(propertyId: string, file: File) {
    const r = await request<{ upload: { url: string; headers?: Record<string, string> }; storageKey: string }>('POST', '/documents/upload-url', { propertyId, purpose: 'document', mime: file.type, size: file.size });
    const res = await fetch(r.upload.url, { method: 'PUT', headers: r.upload.headers || { 'Content-Type': file.type }, body: file }).catch(() => null);
    if (!res?.ok) throw { mensaje: 'No se pudo subir el archivo. Revisa tu conexión e inténtalo de nuevo.' } satisfies ApiFailure;
    return r.storageKey;
  },
  async uploadDocument(propertyId: string, file: File, data: { type: string; name: string; description?: string; visibleToClient: boolean; promissoryNoteId?: string }) {
    const storageKey = await Finance.uploadFile(propertyId, file);
    return request<DossierDoc>('POST', '/documents', { propertyId, storageKey, mime: file.type, ...data, description: data.description || null });
  },
  /** Contrato firmado (PDF) del contrato */
  async attachContractPdf(contractId: string, propertyId: string, file: File) {
    const storageKey = await Finance.uploadFile(propertyId, file);
    return request<{ documentId: string }>('POST', `/contracts/${contractId}/document`, { storageKey });
  },
  updateDocument: (id: string, body: { name?: string; description?: string | null; visibleToClient?: boolean }) => request<DossierDoc>('PATCH', '/documents/' + id, body),
  deleteDocument: (id: string) => request('DELETE', '/documents/' + id),
};

/* ---------- Ventas: comprobante de que el cliente cerró la compra con nosotros (no se administra la casa después) ---------- */
export interface Sale {
  id: string; folio: string; status: 'closed' | 'voided'; saleDate: string; price: number; paymentMethod: string | null; notary: string | null;
  hasDocument: boolean; documentId: string | null; identityChecked: boolean; notes: string | null; voidReason: string | null; voidedAt: string | null;
  createdAt: string; createdBy: string | null;
  property: { id: string; code: string; name: string; address: string | null; zone: string | null };
  client: { id: string; code: string | null; name: string; phone: string | null; email: string | null };
  broker: { id: string; name: string } | null;
  antiMoneyLaundering: { threshold: number; uma: number; umaCount: number; requiresNotice: boolean };
}
export interface SaleInput {
  propertyId: string; clientId: string; saleDate: string; price: number; paymentMethod?: string | null; notary?: string | null; identityChecked: boolean; notes?: string | null;
}
/** Abre en otra pestaña una URL firmada que devuelve la API (comprobante o contrato) */
async function openSigned(path: string) {
  const win = window.open('', '_blank');
  try {
    const r = await request<{ url: string }>('GET', path);
    if (win) win.location.href = r.url;
    else location.href = r.url;
  } catch (e) {
    win?.close();
    throw e;
  }
}
export const Sales = {
  list: (status: string) => request<{ data: Sale[] }>('GET', '/sales?limit=100' + (status ? '&status=' + status : '')).then((r) => r.data),
  thresholds: () => request<{ threshold: number; uma: number; umaCount: number }>('GET', '/sales/anti-money-laundering'),
  create: (body: SaleInput) => request<Sale>('POST', '/sales', body),
  void: (id: string, reason: string) => request<Sale>('POST', `/sales/${id}/void`, { reason }),
  async attachPdf(s: Sale, file: File) {
    const storageKey = await Finance.uploadFile(s.property.id, file);
    return request<{ documentId: string }>('POST', `/sales/${s.id}/document`, { storageKey });
  },
  openReceipt: (id: string) => openSigned(`/sales/${id}/receipt-url`),
  openContract: (id: string) => openSigned(`/sales/${id}/document-url`),
};

/* ---------- Solicitudes del sitio y de la app ---------- */
export interface Proposal {
  id: string; note: string | null; createdAt: string;
  property: { id: string; code: string; slug: string; name: string; zone: string; city: string | null; operation: 'renta' | 'venta'; price: number; rec: number; banos: number; photo: string | null };
}
export interface Lead {
  id: string; folio: string; reason: 'visita' | 'rentar' | 'comprar' | 'publicar' | 'otro'; name: string; email: string; phone: string | null;
  message: string | null; property: { id: string; code: string; name: string } | null; preferredDate: string | null; preferredTime: string | null;
  payload: Record<string, string | number | boolean>; status: 'nuevo' | 'en_seguimiento' | 'cerrado'; statusLabel: string;
  response: string | null; respondedAt: string | null; respondedBy: string | null; proposalCount: number; proposals?: Proposal[]; createdAt: string;
  clientId: string | null; appointmentCount: number; appointments?: LeadAppointment[];
  /** Lo asigna administración; mientras tanto la solicitud está «sin asignar» */
  broker: { id: string; name: string } | null;
  /** Asesor de la casa con prioridad mientras nadie toma la solicitud */
  priority: { brokerId: string; brokerName: string; until: string } | null;
  /** Lleva demasiado tiempo sin que nadie la atienda */
  overdue: boolean;
  /** Otras solicitudes de la misma persona (mismo correo) */
  others?: { id: string; folio: string; reason: Lead['reason']; status: Lead['status']; statusLabel: string; property: string | null; payload: Lead['payload']; message: string | null; createdAt: string }[];
}
/** Cita agendada desde la solicitud */
export interface LeadAppointment { id: string; code: string; scheduledAt: string; status: string; property: { code: string; name: string }; broker: string | null }
export interface NewLead { reason: Lead['reason']; name: string; email: string; phone?: string | null; message?: string | null; propertyCode?: string | null; payload?: Record<string, string | number | boolean> }

export const Requests = {
  list: (query: string) => request<{ data: Lead[]; pagination: { total: number } }>('GET', '/leads?' + query),
  get: (id: string) => request<Lead>('GET', '/leads/' + id),
  create: (body: NewLead) => request<Lead>('POST', '/leads', body),
  update: (id: string, body: { status?: Lead['status']; response?: string; name?: string; phone?: string | null; message?: string | null; reason?: Lead['reason'] }) => request<Lead>('PATCH', '/leads/' + id, body),
  remove: (id: string) => request('DELETE', '/leads/' + id),
  /** Administración asigna el broker: la cita (si hay) se va con él; los datos de la persona no cambian */
  assign: (id: string, brokerId: string) => request<Lead>('PATCH', `/leads/${id}/broker`, { brokerId }),
  /** Agenda la visita: crea la cita ligada a la solicitud (y el expediente si faltaba) */
  schedule: (id: string, body: { propertyId: string; scheduledAt: string; note?: string | null }) =>
    request<{ appointment: { id: string; code: string }; rescheduled: boolean; lead: Lead }>('POST', `/leads/${id}/appointment`, body),
  propose: (id: string, propertyId: string, note?: string) => request<Lead>('POST', `/leads/${id}/proposals`, { propertyId, note: note || null }),
  unpropose: (id: string, proposalId: string) => request<Lead>('DELETE', `/leads/${id}/proposals/${proposalId}`),
  messages: (id: string) => request<{ data: LeadMessage[] }>('GET', `/leads/${id}/messages`).then((r) => r.data),
  send: (id: string, body: string) => request<{ data: LeadMessage[] }>('POST', `/leads/${id}/messages`, { body }).then((r) => r.data),
};
export interface LeadMessage { id: string; body: string; fromStaff: boolean; mine: boolean; sender: string; createdAt: string }

/** Sube una foto nueva (blob:) con URL firmada; las existentes conservan su clave. */
async function uploadPhoto(propertyId: string, f: { src: string; label: string; key?: string }) {
  const file = ZApi.files[f.src];
  if (!file) return { storageKey: f.key || f.src, label: f.label || '' };
  const r = await request<{ upload: { url: string; headers?: Record<string, string> }; storageKey: string }>('POST', '/documents/upload-url', { propertyId, purpose: 'property_photo', mime: file.type, size: file.size });
  const res = await fetch(r.upload.url, { method: 'PUT', headers: r.upload.headers || { 'Content-Type': file.type }, body: file });
  if (!res.ok) throw { mensaje: `No se pudo subir la foto «${f.label}».` };
  return { storageKey: r.storageKey, label: f.label || '' };
}
