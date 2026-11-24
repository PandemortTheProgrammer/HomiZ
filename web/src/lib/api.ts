import { IMG, type House } from './catalog';
import { typeKey } from './propertyTypes';

/* ==========================================================================
   Conexión con la API de Homiz.
   Por omisión la API está en el puerto 3000 del mismo servidor que sirve el sitio:
   localhost:5500 → localhost:3000 · 192.168.1.68:5500 → 192.168.1.68:3000 ·
   VS Code https://abc-5500.usw2.devtunnels.ms → https://abc-3000.usw2.devtunnels.ms
   Túnel público de Cloudflare (https://xxx.trycloudflare.com) → /api/v1 del mismo dominio (Vite la reenvía).
   Otro servidor: VITE_API_URL en .env (vacío = sin API: se muestra el error).
   ========================================================================== */
function defaultApiUrl(): string {
  const host = location.hostname;
  if (/\.trycloudflare\.com$/i.test(host)) return `${location.origin}/api/v1`;
  if (/^[a-z0-9]+-\d+\./i.test(host) && /\.devtunnels\.ms$/i.test(host)) return `${location.protocol}//${host.replace(/-\d+\./, '-3000.')}/api/v1`;
  return `${location.protocol}//${host}:3000/api/v1`;
}
const fromEnv = import.meta.env.VITE_API_URL as string | undefined;
export const API_URL: string = fromEnv !== undefined ? fromEnv : defaultApiUrl();

/** Si la API no contesta en este tiempo, se avisa que no hay conexión. */
const WAIT_MS = 8000;

export interface ApiError {
  status?: number;
  codigo?: string;
  mensaje?: string;
  detalles?: unknown;
  sinConexion?: boolean;
}

/** fetch con tiempo límite; rechaza con { sinConexion: true } si no hay respuesta. */
export async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  if (!API_URL) throw { sinConexion: true } satisfies ApiError;
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), WAIT_MS);
  let res: Response;
  try {
    res = await fetch(API_URL + path, { ...init, headers: { Accept: 'application/json', ...(init.headers || {}) }, signal: ctrl.signal });
  } catch {
    throw { sinConexion: true } satisfies ApiError;
  } finally {
    clearTimeout(timer);
  }
  const body = await res.json().catch(() => ({}));
  if (res.ok) return body as T;
  const err = body?.error ?? {};
  throw { status: res.status, codigo: err.code, mensaje: err.message, detalles: err.details } satisfies ApiError;
}

/* ---------- Catálogo público → formato del sitio ---------- */
const FURNISHED: Record<string, House['amueblada']> = { Amueblada: 'si', Semiamueblada: 'semi' };
const isUrl = (src: string) => /^(https?:|data:|blob:)/.test(src || '');

// La API devuelve JSON sin tipar; aquí se convierte al formato del sitio.
export function toHouse(p: any): House {
  const cover: string = p.photos?.[0]?.src ?? '';
  return {
    slug: p.slug,
    code: p.code,
    name: p.name,
    zona: p.zona,
    zonaKey: p.zonaKey,
    mapa: String(p.mapa || p.zona + ', Cancún').replace(/,\s*Quintana Roo\s*$/i, ''),
    lat: p.lat == null ? null : Number(p.lat),
    lng: p.lng == null ? null : Number(p.lng),
    op: p.op,
    price: Number(p.price),
    rec: Number(p.rec),
    banos: Number(p.banos),
    m2: Number(p.m2) || 0,
    est: Number(p.est) || 0,
    pets: !!p.pets,
    amueblada: FURNISHED[p.furnished] || 'no',
    tipo: typeKey(p.tipo),
    tipoTexto: p.tipo,
    asesor: p.asesor || '',
    orden: p.publishedAt ? Date.parse(p.publishedAt) / 864e5 : 0,
    img: cover && !isUrl(cover) ? cover.replace(/\.[a-z]+$/i, '') : undefined,
    foto: cover && isUrl(cover) ? cover : undefined,
    description: p.description || '',
    areaMeters: Number(p.areaMeters) || 1500,
    terreno: Number(p.terreno) || 0,
    age: p.age,
    maintenance: p.maintenance || '',
    amenities: p.amenities || [],
    photos: (p.photos || []).map((f: { src: string; label?: string }) => ({ src: isUrl(f.src) ? f.src : IMG + f.src, label: f.label || '' })),
    publishedAt: p.publishedAt || '',
  };
}

export async function fetchCatalog(): Promise<House[]> {
  const r = await request<{ data?: unknown[] }>('/public/properties?porPagina=50&orden=recientes');
  return (r.data || []).map(toHouse);
}

export async function fetchHouse(slug: string): Promise<House> {
  return toHouse(await request('/public/properties/' + encodeURIComponent(slug)));
}

/* ---------- Solicitudes del sitio (POST /public/leads) ---------- */
export type LeadReason = 'visita' | 'rentar' | 'comprar' | 'publicar' | 'otro';

export interface LeadInput {
  reason: LeadReason;
  name: string;
  email: string;
  phone?: string;
  message?: string;
  propertySlug?: string;
  propertyCode?: string;
  preferredDate?: string;
  preferredTime?: string;
  /** Resto de respuestas del formulario (ocupación, mascotas…). Los montos van como número (presupuesto_min/max). */
  payload: Record<string, string | number | null>;
}

/** account: la cuenta de la app que se creó sola («created») o que ya existía («existing»). */
export async function sendLead(input: LeadInput): Promise<{ folio: string; cita: string | null; account: 'created' | 'existing' | null; editToken: string | null }> {
  const body: Record<string, unknown> = {
    // Solo se envía después de marcar «Acepto el aviso de privacidad» (lo valida cada formulario)
    consent: true,
    // Campo trampa (invisible para personas): si un robot lo llena, el servidor ignora la solicitud
    website: document.querySelector<HTMLInputElement>('input[name="website"]')?.value ?? '',
    reason: input.reason,
    name: input.name,
    email: input.email,
    phone: input.phone || null,
    message: input.message || null,
    payload: Object.fromEntries(
      Object.entries(input.payload)
        .filter(([, v]) => (typeof v === 'number' ? Number.isFinite(v) : !!v && v.trim()))
        .map(([k, v]) => [k.slice(0, 40), typeof v === 'number' ? v : String(v).trim().slice(0, 500)]),
    ),
  };
  if (input.propertyCode) body.propertyCode = input.propertyCode;
  else if (input.propertySlug && input.reason !== 'publicar' && input.reason !== 'otro') body.propertySlug = input.propertySlug;
  if (input.reason === 'visita' && input.preferredDate) body.preferredDate = input.preferredDate;
  if (input.reason === 'visita' && input.preferredTime) body.preferredTime = input.preferredTime;
  const r = await request<{ folio: string; appointmentCode?: string; account?: 'created' | 'existing' | null; editToken?: string | null }>('/public/leads', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  return { folio: r.folio, cita: r.appointmentCode || null, account: r.account ?? null, editToken: r.editToken ?? null };
}

/** «Cambiar mis datos» (vale 2 horas después de enviar). Si cambia el correo, la cuenta de la app pasa al correo nuevo. */
export async function correctLead(folio: string, token: string, d: { name: string; email: string; phone: string }) {
  return request<{ folio: string; name: string; email: string; phone: string | null; account: 'created' | 'existing'; editToken: string; message: string }>(
    '/public/leads/' + encodeURIComponent(folio),
    { method: 'PATCH', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ token, name: d.name, email: d.email, phone: d.phone || null }) },
  );
}
