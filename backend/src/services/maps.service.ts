import { env } from '../config/env.js';
import { logger } from '../config/logger.js';
import { AppError } from '../middlewares/error-handler.js';

/*
 * Ubicación de una casa a partir de un enlace de Google Maps (también los cortos maps.app.goo.gl).
 * Orden: place_id → coordenadas del enlace → texto del lugar. Con GOOGLE_MAPS_API_KEY se usa la API de Google;
 * sin clave (o si falla), Nominatim de OpenStreetMap. Si no se obtiene la dirección, se devuelven las coordenadas.
 */

export interface MapsLocation {
  lat: number;
  lng: number;
  address: string | null;
  placeId: string | null;
  expandedUrl: string;
}

/** Inyectable en pruebas para no salir a internet. */
export const mapsDeps = { fetch: (url: string, init?: RequestInit) => fetch(url, init) };

const TIMEOUT_MS = 8000;
const USER_AGENT = 'Homiz/1.0 (Inmobiliaria Zugar)';
const PLACEHOLDER_KEYS = new Set(['tu_api_key', 'your_api_key', 'replace_with_your_api_key']);

const fail = (message: string) => new AppError(422, 'MAPS_URL_INVALID', message);

function apiKey(): string | null {
  const k = env.GOOGLE_MAPS_API_KEY.trim();
  return k && !PLACEHOLDER_KEYS.has(k.toLowerCase()) && !/^x+$/i.test(k) ? k : null;
}

export function normalizeUrl(raw: string): string {
  let url = raw.trim();
  if (!url) throw fail('Pega el enlace de Google Maps.');
  if (url.startsWith('//')) url = 'https:' + url;
  else if (/^(www\.|maps\.app\.goo\.gl|goo\.gl|maps\.google\.)/i.test(url)) url = 'https://' + url;
  return url;
}

/** Solo se aceptan enlaces de Google Maps: evita que el servidor visite direcciones arbitrarias. */
export function isGoogleMapsUrl(url: string): boolean {
  let u: URL;
  try {
    u = new URL(url);
  } catch {
    return false;
  }
  if (u.protocol !== 'https:' && u.protocol !== 'http:') return false;
  const host = u.hostname.toLowerCase();
  if (host === 'maps.app.goo.gl' || host === 'goo.gl') return true;
  const google = /^(www\.|maps\.)?google\.[a-z.]{2,6}$/.test(host);
  return google && (host.startsWith('maps.') || u.pathname.startsWith('/maps'));
}

export function isShortMapsUrl(url: string): boolean {
  const host = new URL(url).hostname.toLowerCase();
  return host === 'maps.app.goo.gl' || host === 'goo.gl';
}

async function get(url: string, method: 'HEAD' | 'GET', headers: Record<string, string> = {}) {
  return mapsDeps.fetch(url, { method, redirect: 'follow', headers: { 'User-Agent': USER_AGENT, ...headers }, signal: AbortSignal.timeout(TIMEOUT_MS) });
}

/** Sigue las redirecciones del enlace corto hasta la URL completa de Google Maps. */
export async function expandShortUrl(url: string): Promise<string> {
  try {
    let res = await get(url, 'HEAD');
    let expanded = res.url;
    if (!expanded || expanded === url || [400, 404, 405].includes(res.status)) {
      res = await get(url, 'GET');
      expanded = res.url;
    }
    if (expanded && expanded !== url) return expanded;
  } catch (err) {
    logger.warn({ err }, 'No se pudo expandir el enlace corto de Google Maps');
    throw fail('No pudimos abrir el enlace corto de Google Maps. Revisa tu conexión o pega el enlace completo.');
  }
  throw fail('No pudimos abrir el enlace corto de Google Maps. Pega el enlace completo.');
}

export function extractPlaceId(url: string): string | null {
  return /[?&]place_id=([A-Za-z0-9_-]+)/.exec(url)?.[1] ?? /place_id:([A-Za-z0-9_-]+)/.exec(url)?.[1] ?? null;
}

const inRange = (lat: number, lng: number) => Number.isFinite(lat) && Number.isFinite(lng) && Math.abs(lat) <= 90 && Math.abs(lng) <= 180;
const pair = (a: string, b: string, swap = false) => {
  const lat = Number(swap ? b : a), lng = Number(swap ? a : b);
  return inRange(lat, lng) ? { lat, lng } : null;
};

/** Coordenadas escritas en el enlace (parámetros ll, center, q, query o los segmentos !3d!4d y @lat,lng). */
export function extractCoordinates(url: string): { lat: number; lng: number } | null {
  let u: URL | null = null;
  try {
    u = new URL(url);
  } catch {
    /* se intenta con los patrones */
  }
  if (u) {
    for (const key of ['ll', 'center', 'q', 'query']) {
      const v = u.searchParams.get(key);
      const m = v && /^\s*([-+]?\d+(?:\.\d+)?)\s*,\s*([-+]?\d+(?:\.\d+)?)\s*$/.exec(v);
      if (m) {
        const c = pair(m[1], m[2]);
        if (c) return c;
      }
    }
  }
  // El marcador del lugar (!3d!4d) es más exacto que el centro de la vista (@lat,lng).
  const patterns: [RegExp, boolean][] = [
    [/!3d(-?\d+(?:\.\d+)?)!4d(-?\d+(?:\.\d+)?)/, false],
    [/!4d(-?\d+(?:\.\d+)?)!3d(-?\d+(?:\.\d+)?)/, true],
    [/!2d(-?\d+(?:\.\d+)?)!3d(-?\d+(?:\.\d+)?)/, true],
    [/\/search\/(-?\d+(?:\.\d+)?),(?:\s|\+|%20)*(-?\d+(?:\.\d+)?)/, false], // el «+» es un espacio del enlace
    [/@(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)/, false],
  ];
  for (const [re, swap] of patterns) {
    const m = re.exec(url);
    if (m) {
      const c = pair(m[1], m[2], swap);
      if (c) return c;
    }
  }
  return null;
}

/** Nombre o dirección del lugar escrito en el enlace (/place/…, /search/…, q= o query=). */
export function extractPlaceText(url: string): string | null {
  const decode = (s: string) => decodeURIComponent(s.replace(/\+/g, ' ')).trim();
  const m = /\/place\/([^/?]+)/.exec(url) ?? /\/search\/([^/?]+)/.exec(url) ?? /[?&]q=([^&]+)/.exec(url) ?? /[?&]query=([^&]+)/.exec(url);
  if (!m) return null;
  const text = decode(m[1]);
  return text && !/^[-+\d.,\s]+$/.test(text) ? text : null; // si solo son coordenadas no es un lugar
}

async function json(url: string): Promise<any> {
  const res = await get(url, 'GET', { Accept: 'application/json', 'Accept-Language': 'es' });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

/* ---------- Google Maps (con clave) ---------- */
async function googlePlace(placeId: string, key: string) {
  const r = await json(`https://maps.googleapis.com/maps/api/place/details/json?place_id=${encodeURIComponent(placeId)}&fields=formatted_address,geometry&language=es&key=${key}`);
  const loc = r.result?.geometry?.location;
  if (r.status !== 'OK' || !loc) throw new Error(r.error_message || r.status);
  return { lat: loc.lat, lng: loc.lng, address: r.result.formatted_address ?? null, placeId };
}
async function googleGeocode(params: string, key: string) {
  const r = await json(`https://maps.googleapis.com/maps/api/geocode/json?${params}&language=es&key=${key}`);
  const first = r.results?.[0];
  if (r.status !== 'OK' || !first) throw new Error(r.error_message || r.status);
  return { lat: first.geometry.location.lat, lng: first.geometry.location.lng, address: first.formatted_address ?? null, placeId: first.place_id ?? null };
}

/* ---------- Nominatim de OpenStreetMap (sin clave) ---------- */
async function nominatimSearch(text: string) {
  const r = await json(`${env.NOMINATIM_URL}/search?format=json&limit=1&q=${encodeURIComponent(text)}`);
  if (!Array.isArray(r) || !r[0]) throw fail('No encontramos ese lugar. Prueba con el enlace del lugar exacto («Compartir» en Google Maps).');
  return { lat: Number(r[0].lat), lng: Number(r[0].lon), address: r[0].display_name ?? null, placeId: null };
}
async function nominatimReverse(lat: number, lng: number): Promise<string | null> {
  const r = await json(`${env.NOMINATIM_URL}/reverse?format=json&lat=${lat}&lon=${lng}`);
  return r?.display_name ?? null;
}

/** Dirección de unas coordenadas; si ningún servicio responde, las coordenadas se guardan sin dirección. */
async function reverseGeocode(lat: number, lng: number): Promise<{ address: string | null; placeId: string | null }> {
  const key = apiKey();
  if (key) {
    try {
      const g = await googleGeocode(`latlng=${lat},${lng}`, key);
      return { address: g.address, placeId: g.placeId };
    } catch (err) {
      logger.warn({ err }, 'Google Maps no respondió la dirección; se usa Nominatim');
    }
  }
  try {
    return { address: await nominatimReverse(lat, lng), placeId: null };
  } catch (err) {
    logger.warn({ err }, 'Nominatim no respondió la dirección; se guardan solo las coordenadas');
    return { address: null, placeId: null };
  }
}

async function geocodeText(text: string) {
  const key = apiKey();
  if (key) {
    try {
      return await googleGeocode(`address=${encodeURIComponent(text)}`, key);
    } catch (err) {
      logger.warn({ err }, 'Google Maps no encontró el lugar; se usa Nominatim');
    }
  }
  try {
    return await nominatimSearch(text);
  } catch (err) {
    if (err instanceof AppError) throw err;
    throw fail('No pudimos consultar el mapa en este momento. Intenta de nuevo.');
  }
}

/** Procesa el enlace pegado en el panel y devuelve latitud, longitud y dirección. */
export async function locateFromMapsUrl(raw: string): Promise<MapsLocation> {
  let url = normalizeUrl(raw);
  if (!isGoogleMapsUrl(url)) throw fail('El enlace debe ser de Google Maps (por ejemplo https://maps.app.goo.gl/…).');
  if (isShortMapsUrl(url)) {
    url = await expandShortUrl(url);
    if (!isGoogleMapsUrl(url)) throw fail('El enlace corto no lleva a Google Maps.');
  }

  const placeId = extractPlaceId(url);
  const key = apiKey();
  if (placeId && key) {
    try {
      return { ...(await googlePlace(placeId, key)), expandedUrl: url };
    } catch (err) {
      logger.warn({ err }, 'No se pudo consultar el place_id; se intenta con las coordenadas del enlace');
    }
  }

  const coords = extractCoordinates(url);
  if (coords) {
    const r = await reverseGeocode(coords.lat, coords.lng);
    return { ...coords, ...r, placeId: placeId ?? r.placeId, expandedUrl: url };
  }

  const text = extractPlaceText(url);
  if (text) return { ...(await geocodeText(text)), expandedUrl: url };

  throw fail('El enlace no trae una ubicación. En Google Maps abre el lugar, toca «Compartir» y copia ese enlace.');
}
