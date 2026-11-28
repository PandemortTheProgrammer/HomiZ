import { ZApi } from './api';
import { currentSession } from './auth';
import type { Property } from './store';

/* ==========================================================================
   Borrador del formulario de propiedad: se guarda en este navegador (IndexedDB, con las fotos elegidas)
   mientras se escribe y se borra cuando el servidor confirma el guardado.
   Uno por persona y por propiedad («nueva» o su código). Los archivos se guardan por borrador (token).
   ========================================================================== */
type Data = Partial<Property>;
interface Stored { token: string; savedAt: number; data: Data; custom: string[]; mapsUrl: string }
export interface LoadedDraft extends Stored { lostPhotos: number }

let dbPromise: Promise<IDBDatabase> | null = null;
function db(): Promise<IDBDatabase> {
  return (dbPromise ??= new Promise<IDBDatabase>((resolve, reject) => {
    const r = indexedDB.open('zugar-borradores', 1);
    r.onupgradeneeded = () => {
      r.result.createObjectStore('drafts');
      r.result.createObjectStore('files');
    };
    r.onsuccess = () => resolve(r.result);
    r.onerror = () => reject(r.error);
  }).catch((e) => { dbPromise = null; throw e; }));
}
/** Ejecuta en una transacción y resuelve cuando ya quedó escrita */
async function tx<T>(mode: IDBTransactionMode, run: (drafts: IDBObjectStore, files: IDBObjectStore) => IDBRequest<T> | void): Promise<T> {
  const d = await db();
  return new Promise<T>((resolve, reject) => {
    const t = d.transaction(['drafts', 'files'], mode);
    const req = run(t.objectStore('drafts'), t.objectStore('files'));
    t.oncomplete = () => resolve(req?.result as T);
    t.onerror = t.onabort = () => reject(t.error);
  });
}

/** Borradores que se están enviando al servidor: no se ofrecen otra vez mientras tanto */
const sending = new Set<string>();
/** blob: de esta página → nombre con que se guardó el archivo (los blob: mueren al recargar) */
const fileIds = new Map<string, string>();

export const draftKey = (id: string) => `${currentSession()?.email ?? ''}|${id}`;
export const newToken = () => `${Date.now()}-${Math.random().toString(36).slice(2)}`;
const filesOf = (token: string) => IDBKeyRange.bound(token + '|', token + '|￿');

/** Guarda en este navegador los datos y los archivos que aún no estaban guardados */
export async function saveDraft(key: string, token: string, d: { data: Data; custom: string[]; mapsUrl: string }) {
  // Lo que pone el servidor no va en el borrador
  const { id: _i, _id, _zoneKey, slug: _s, published: _p, updated: _u, updatedAt: _a, ...data } = d.data;
  const fresh: [string, string, File][] = [];
  const photos = (data.photos ?? []).map((p) => {
    const file = ZApi.files[p.src];
    if (!file) return p;
    let id = fileIds.get(p.src);
    if (!id?.startsWith(token + '|')) fresh.push([p.src, (id = token + '|' + newToken()), file]);
    return { ...p, src: id! };
  });
  // Se reservan antes de escribir: dos guardados seguidos no duplican la misma foto
  for (const [src, id] of fresh) fileIds.set(src, id);
  try {
    await tx('readwrite', (drafts, files) => {
      for (const [, id, file] of fresh) files.put(file, id);
      drafts.put({ token, savedAt: Date.now(), data: { ...data, photos }, custom: d.custom, mapsUrl: d.mapsUrl } satisfies Stored, key);
    });
  } catch (e) {
    for (const [src] of fresh) fileIds.delete(src);
    throw e;
  }
}

/** Borrador guardado, con sus fotos listas para verse y subirse */
export async function loadDraft(key: string): Promise<LoadedDraft | null> {
  const s = await tx<Stored | undefined>('readonly', (drafts) => drafts.get(key));
  if (!s || sending.has(s.token)) return null;
  let lostPhotos = 0;
  const photos: Property['photos'] = [];
  for (const p of s.data.photos ?? []) {
    if (!p.src.startsWith(s.token + '|')) {
      if (p.src.startsWith('blob:')) lostPhotos++; else photos.push(p);
      continue;
    }
    const file = await tx<File | undefined>('readonly', (_d, files) => files.get(p.src));
    if (!file) { lostPhotos++; continue; }
    const url = URL.createObjectURL(file);
    ZApi.rememberFile(url, file);
    fileIds.set(url, p.src);
    photos.push({ ...p, src: url });
  }
  return { ...s, data: { ...s.data, photos }, lostPhotos };
}

/** Borra el borrador y sus fotos (si en esa clave ya hay otro más nuevo, ese se conserva) */
export async function deleteDraft(key: string, token: string) {
  sending.delete(token);
  await tx('readwrite', (drafts, files) => {
    const r = drafts.get(key);
    r.onsuccess = () => { if ((r.result as Stored | undefined)?.token === token) drafts.delete(key); };
    files.delete(filesOf(token));
  });
}

export const markSending = (token: string) => { sending.add(token); };
/** El guardado falló: el borrador vuelve a estar disponible. Si la casa sí se creó, pasa a su edición (no se duplica). */
export async function restoreDraft(key: string, token: string, movedTo?: string) {
  sending.delete(token);
  if (!movedTo) return;
  await tx('readwrite', (drafts) => {
    const r = drafts.get(key);
    r.onsuccess = () => {
      const s = r.result as Stored | undefined;
      if (s?.token !== token) return;
      drafts.put(s, movedTo);
      drafts.delete(key);
    };
  });
}
