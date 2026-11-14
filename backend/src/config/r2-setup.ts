/*
 * Prepara el bucket de Cloudflare R2: npm run r2:setup  (añade --migrar para copiar uploads/ al bucket)
 * 1. Comprueba que las credenciales de .env abren el bucket.
 * 2. Configura CORS del bucket con CORS_ORIGINS: el panel y la app suben con PUT directo a R2.
 * 3. Con --migrar, copia los archivos de STORAGE_LOCAL_DIR con la misma clave (omite los que ya existen).
 */
import { readdir, readFile } from 'node:fs/promises';
import path from 'node:path';
import { HeadBucketCommand, HeadObjectCommand, PutBucketCorsCommand, PutObjectCommand } from '@aws-sdk/client-s3';
import { env } from './env.js';
import { r2 } from './storage.js';

const MIME: Record<string, string> = { pdf: 'application/pdf', jpg: 'image/jpeg', png: 'image/png', webp: 'image/webp' };

async function main() {
  if (env.STORAGE_DRIVER !== 'r2') {
    console.error('Pon STORAGE_DRIVER=r2 y los datos R2_* en .env antes de correr este comando.');
    process.exit(1);
  }

  try {
    await r2().send(new HeadBucketCommand({ Bucket: env.R2_BUCKET }));
    console.log(`✔ Conexión con el bucket «${env.R2_BUCKET}»`);
  } catch (e) {
    const status = (e as { $metadata?: { httpStatusCode?: number } }).$metadata?.httpStatusCode;
    console.error(status === 404
      ? `✘ El bucket «${env.R2_BUCKET}» no existe en esa cuenta. Revisa R2_BUCKET y R2_ACCOUNT_ID.`
      : `✘ No se pudo abrir el bucket (${status ?? (e as Error).message}). Revisa R2_ACCESS_KEY_ID y R2_SECRET_ACCESS_KEY.`);
    process.exit(1);
  }

  // R2 acepta un solo «*» por origen; los demás (p. ej. https://*.*.devtunnels.ms) se omiten.
  const origins = env.corsOrigins.filter((o) => (o.match(/\*/g) ?? []).length <= 1);
  const skipped = env.corsOrigins.filter((o) => !origins.includes(o));
  const rule = { AllowedOrigins: origins, AllowedMethods: ['GET', 'PUT', 'HEAD'], AllowedHeaders: ['Content-Type'], MaxAgeSeconds: 3600 };
  try {
    await r2().send(new PutBucketCorsCommand({ Bucket: env.R2_BUCKET, CORSConfiguration: { CORSRules: [rule] } }));
    console.log(`✔ CORS del bucket: ${origins.join(', ') || '(ninguno)'}`);
    if (skipped.length) console.log(`  Omitidos (R2 no admite más de un «*»): ${skipped.join(', ')}`);
  } catch {
    // Un token «Object Read & Write» no puede cambiar la configuración del bucket: se pega a mano en Cloudflare.
    console.log('⚠ Este token no puede configurar CORS. En Cloudflare → R2 → bucket → Settings → CORS Policy → Edit, pega:');
    console.log(JSON.stringify([rule], null, 2));
  }

  if (!process.argv.includes('--migrar')) return;
  const root = path.resolve(env.STORAGE_LOCAL_DIR);
  const files = (await readdir(root, { recursive: true, withFileTypes: true }).catch(() => []))
    .filter((f) => f.isFile())
    .map((f) => path.relative(root, path.join(f.parentPath, f.name)).split(path.sep).join('/'));
  let copied = 0;
  let existing = 0;
  for (const key of files) {
    const mime = MIME[key.split('.').pop() ?? ''];
    if (!mime) continue;
    try {
      await r2().send(new HeadObjectCommand({ Bucket: env.R2_BUCKET, Key: key }));
      existing++;
      continue;
    } catch {
      // no existe: se sube
    }
    await r2().send(new PutObjectCommand({ Bucket: env.R2_BUCKET, Key: key, ContentType: mime, Body: await readFile(path.join(root, key)) }));
    copied++;
  }
  console.log(`✔ Migración: ${copied} copiados, ${existing} ya estaban en R2 (de ${files.length} archivos en ${env.STORAGE_LOCAL_DIR}/)`);
}

main().catch((e) => {
  console.error('✘', (e as Error).message);
  process.exit(1);
});
