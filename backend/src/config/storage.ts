import { createHmac, randomUUID, timingSafeEqual } from 'node:crypto';
import { mkdir, readFile, rm, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { S3Client, DeleteObjectCommand, HeadObjectCommand, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { env } from './env.js';

/*
 * Almacenamiento de archivos con URL firmadas. La misma interfaz sirve para:
 * - local: carpeta STORAGE_LOCAL_DIR; las URL firmadas apuntan a /api/v1/files/:token de esta API.
 * - r2: Cloudflare R2 (compatible con S3); las URL firmadas apuntan directo al bucket.
 */

export type FilePurpose = 'document' | 'property_photo' | 'maintenance_photo';

export const FILE_RULES: Record<FilePurpose, { mimes: string[]; maxBytes: number; folder: string }> = {
  // Contratos escaneados de hasta ~22 páginas: 50 MB
  document: { mimes: ['application/pdf', 'image/jpeg', 'image/png', 'image/webp'], maxBytes: 50 * 1024 * 1024, folder: 'documents' },
  property_photo: { mimes: ['image/jpeg', 'image/png', 'image/webp'], maxBytes: 10 * 1024 * 1024, folder: 'photos' },
  maintenance_photo: { mimes: ['image/jpeg', 'image/png', 'image/webp'], maxBytes: 10 * 1024 * 1024, folder: 'maintenance' },
};

const EXT: Record<string, string> = { 'application/pdf': 'pdf', 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp' };

/** Clave de almacenamiento generada por el servidor: properties/ZUG-012/documents/<uuid>.pdf */
export function buildKey(propertyCode: string, purpose: FilePurpose, mime: string): string {
  return `properties/${propertyCode}/${FILE_RULES[purpose].folder}/${randomUUID()}.${EXT[mime]}`;
}

/** Verifica que una clave fue generada para esa propiedad y ese propósito (evita reutilizar archivos ajenos). */
export function keyBelongsTo(key: string, propertyCode: string, purpose: FilePurpose): boolean {
  const re = new RegExp(`^properties/${propertyCode.replace(/[^\w-]/g, '')}/${FILE_RULES[purpose].folder}/[0-9a-f-]{36}\\.(pdf|jpg|png|webp)$`);
  return re.test(key);
}

export interface SignedUrl {
  url: string;
  method: 'PUT' | 'GET';
  headers: Record<string, string>;
  expiresAt: string;
}

/* ---------- Driver local ---------- */
interface LocalToken {
  op: 'put' | 'get';
  key: string;
  mime: string;
  max?: number;
  name?: string;
  exp: number;
}

function sign(payload: string): string {
  return createHmac('sha256', `${env.JWT_ACCESS_SECRET}:storage`).update(payload).digest('base64url');
}

export function encodeLocalToken(t: LocalToken): string {
  const payload = Buffer.from(JSON.stringify(t)).toString('base64url');
  return `${payload}.${sign(payload)}`;
}

export function decodeLocalToken(token: string): LocalToken | null {
  const [payload, mac] = token.split('.');
  if (!payload || !mac) return null;
  const expected = Buffer.from(sign(payload));
  const given = Buffer.from(mac);
  if (expected.length !== given.length || !timingSafeEqual(expected, given)) return null;
  try {
    const t = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')) as LocalToken;
    return t.exp > Date.now() ? t : null;
  } catch {
    return null;
  }
}

export function localPath(key: string): string {
  const root = path.resolve(env.STORAGE_LOCAL_DIR);
  const full = path.resolve(root, key);
  if (!full.startsWith(root + path.sep)) throw new Error('Ruta de archivo inválida');
  return full;
}

/* ---------- Driver R2 ---------- */
let s3: S3Client | null = null;
export function r2(): S3Client {
  s3 ??= new S3Client({
    region: 'auto',
    endpoint: `https://${env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
    credentials: { accessKeyId: env.R2_ACCESS_KEY_ID, secretAccessKey: env.R2_SECRET_ACCESS_KEY },
  });
  return s3;
}

/* ---------- Interfaz común ---------- */
const expiry = () => new Date(Date.now() + env.STORAGE_URL_MINUTES * 60_000);

/**
 * URL firmada de subida. Siempre apunta a esta API (PUT /api/v1/files/:token), que guarda en la carpeta local o en R2:
 * así se sube igual desde el panel, el celular por la red local o el túnel público, sin depender del CORS del bucket.
 * [base]: dirección por la que llegó quien pide la URL (https://xxx.trycloudflare.com, http://192.168.1.68:3000…).
 */
export async function createUploadUrl(key: string, mime: string, maxBytes: number, base = env.API_PUBLIC_URL): Promise<SignedUrl> {
  const exp = expiry();
  const token = encodeLocalToken({ op: 'put', key, mime, max: maxBytes, exp: exp.getTime() });
  return { url: `${base}/api/v1/files/${token}`, method: 'PUT', headers: { 'Content-Type': mime }, expiresAt: exp.toISOString() };
}

/** Guarda el archivo recibido por la API en el almacenamiento configurado. */
export async function putObject(key: string, mime: string, body: Buffer): Promise<void> {
  if (env.STORAGE_DRIVER === 'r2') {
    await r2().send(new PutObjectCommand({ Bucket: env.R2_BUCKET, Key: key, ContentType: mime, Body: body, ContentLength: body.length }));
    return;
  }
  await writeFile(await ensureLocalDir(key), body);
}

/** Lee el archivo completo (para separar las hojas del PDF de pagarés). */
export async function getObject(key: string): Promise<Buffer> {
  if (env.STORAGE_DRIVER === 'r2') {
    const out = await r2().send(new GetObjectCommand({ Bucket: env.R2_BUCKET, Key: key }));
    return Buffer.from(await out.Body!.transformToByteArray());
  }
  return readFile(localPath(key));
}

export async function createDownloadUrl(key: string, mime: string, fileName: string): Promise<SignedUrl> {
  const exp = expiry();
  if (env.STORAGE_DRIVER === 'r2') {
    const url = await getSignedUrl(
      r2(),
      new GetObjectCommand({
        Bucket: env.R2_BUCKET,
        Key: key,
        ResponseContentType: mime,
        ResponseContentDisposition: `inline; filename="${encodeURIComponent(fileName)}"`,
      }),
      { expiresIn: env.STORAGE_URL_MINUTES * 60 },
    );
    return { url, method: 'GET', headers: {}, expiresAt: exp.toISOString() };
  }
  const token = encodeLocalToken({ op: 'get', key, mime, name: fileName, exp: exp.getTime() });
  return { url: `${env.API_PUBLIC_URL}/api/v1/files/${token}`, method: 'GET', headers: {}, expiresAt: exp.toISOString() };
}

/** Tamaño del archivo si existe (para confirmar que la subida se completó). */
export async function fileSize(key: string): Promise<number | null> {
  try {
    if (env.STORAGE_DRIVER === 'r2') {
      const head = await r2().send(new HeadObjectCommand({ Bucket: env.R2_BUCKET, Key: key }));
      return head.ContentLength ?? 0;
    }
    return (await stat(localPath(key))).size;
  } catch {
    return null;
  }
}

/** Borra el archivo del almacenamiento (si ya no existe, no pasa nada). */
export async function deleteFile(key: string): Promise<void> {
  if (env.STORAGE_DRIVER === 'r2') {
    await r2().send(new DeleteObjectCommand({ Bucket: env.R2_BUCKET, Key: key }));
    return;
  }
  await rm(localPath(key), { force: true });
}

export async function ensureLocalDir(key: string): Promise<string> {
  const full = localPath(key);
  await mkdir(path.dirname(full), { recursive: true });
  return full;
}
