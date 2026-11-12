import 'dotenv/config';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { z } from 'zod';

/* Variables de entorno validadas al arrancar: si falta algo obligatorio, el servidor no inicia. */
const secret = (name: string) =>
  z.string().min(32, `${name} debe tener al menos 32 caracteres (usa: npm run secrets)`);

const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().min(1, 'Falta DATABASE_URL'),
  JWT_ACCESS_SECRET: secret('JWT_ACCESS_SECRET'),
  JWT_REFRESH_SECRET: secret('JWT_REFRESH_SECRET'),
  JWT_ACCESS_TTL: z.string().default('15m'),
  JWT_REFRESH_DAYS: z.coerce.number().int().positive().default(30),
  LOGIN_MAX_ATTEMPTS: z.coerce.number().int().positive().default(5),
  LOGIN_LOCK_MINUTES: z.coerce.number().int().positive().default(15),
  // Revisiones de contraseña a la vez (cada una ~19 MiB) y cuántas pueden esperar en fila (password.service.ts)
  PASSWORD_HASH_CONCURRENCY: z.coerce.number().int().positive().default(2),
  PASSWORD_QUEUE_MAX: z.coerce.number().int().positive().default(200),
  PASSWORD_RESET_MINUTES: z.coerce.number().int().positive().default(60),
  RATE_LIMIT_MAX: z.coerce.number().int().positive().default(600), // por IP, sin sesión (con sesión: 3,000 por persona)
  RATE_LIMIT_LOGIN_MAX: z.coerce.number().int().positive().default(20),
  CORS_ORIGINS: z.string().default(''),
  APP_RESET_URL: z.string().default('http://localhost:5500/admin/#/login'), // el panel abre «Crea tu nueva contraseña» con ?token=
  // Enlace de la app Homiz para los clientes (crear o recuperar contraseña: ?reset=<código>&email=)
  APP_CLIENT_URL: z.string().default('http://localhost:5600/'),
  // Sitio público (para enlazar el aviso de privacidad y «Eliminar mi cuenta» desde la app). Vacío = el del panel (APP_RESET_URL).
  SITE_URL: z.string().default(''),
  MAIL_OUTBOX_DIR: z.string().default('outbox'),
  // Correo: «outbox» guarda cada correo como archivo (desarrollo); «smtp» lo envía (p. ej. Gmail con contraseña de aplicación)
  MAIL_DRIVER: z.enum(['outbox', 'smtp']).default('outbox'),
  SMTP_HOST: z.string().default('smtp.gmail.com'),
  SMTP_PORT: z.coerce.number().int().positive().default(465),
  SMTP_USER: z.string().default(''),
  SMTP_PASS: z.string().default(''),
  MAIL_FROM: z.string().default(''),
  API_PUBLIC_URL: z.string().default('http://localhost:3000'),
  STORAGE_DRIVER: z.enum(['local', 'r2']).default('local'),
  STORAGE_LOCAL_DIR: z.string().default('uploads'),
  STORAGE_URL_MINUTES: z.coerce.number().int().positive().default(15),
  R2_ACCOUNT_ID: z.string().default(''),
  R2_ACCESS_KEY_ID: z.string().default(''),
  R2_SECRET_ACCESS_KEY: z.string().default(''),
  R2_BUCKET: z.string().default(''),
  PUSH_DRIVER: z.enum(['mock', 'fcm']).default('mock'),
  FCM_KEY_FILE: z.string().default(''),
  FCM_PROJECT_ID: z.string().default(''),
  FCM_CLIENT_EMAIL: z.string().default(''),
  FCM_PRIVATE_KEY: z.string().default(''),
  JOBS_ENABLED: z.enum(['true', 'false']).default('true'),
  JOBS_CRON: z.string().default('0 7 * * *'),
  TZ_APP: z.string().default('America/Cancun'),
  // Solicitudes sin broker: prioridad del asesor de la casa, espera de administración en el pool y aviso a la dueña
  LEAD_PRIORITY_MINUTES: z.coerce.number().int().positive().default(120),
  LEAD_ADMIN_WAIT_MINUTES: z.coerce.number().int().nonnegative().default(30),
  LEAD_ESCALATE_MINUTES: z.coerce.number().int().positive().default(240),
  // Ubicación de las casas (enlace de Google Maps → coordenadas). Sin clave se usa Nominatim (OpenStreetMap).
  GOOGLE_MAPS_API_KEY: z.string().default(''),
  NOMINATIM_URL: z.string().default('https://nominatim.openstreetmap.org'),
})
  .refine((e) => e.STORAGE_DRIVER !== 'r2' || (e.R2_ACCOUNT_ID && e.R2_ACCESS_KEY_ID && e.R2_SECRET_ACCESS_KEY && e.R2_BUCKET), {
    message: 'Con STORAGE_DRIVER=r2 se requieren R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY y R2_BUCKET',
  })
  .refine((e) => e.MAIL_DRIVER !== 'smtp' || (e.SMTP_USER && e.SMTP_PASS), {
    message: 'Con MAIL_DRIVER=smtp se requieren SMTP_USER y SMTP_PASS (en Gmail, una contraseña de aplicación)',
  })
  .refine((e) => e.PUSH_DRIVER !== 'fcm' || (e.FCM_PROJECT_ID && e.FCM_CLIENT_EMAIL && e.FCM_PRIVATE_KEY), {
    message: 'Con PUSH_DRIVER=fcm se requiere FCM_KEY_FILE (JSON de Firebase) o FCM_PROJECT_ID, FCM_CLIENT_EMAIL y FCM_PRIVATE_KEY',
  })
  /* Producción: nada de configuración de pruebas (ver docs/produccion.md) */
  .refine((e) => e.NODE_ENV !== 'production' || !e.CORS_ORIGINS.includes('*'), {
    message: 'En producción CORS_ORIGINS lleva los dominios exactos (sin «*»), p. ej. https://zugar.mx,https://app.zugar.mx',
  })
  .refine((e) => e.NODE_ENV !== 'production' || /^https:\/\//.test(e.API_PUBLIC_URL), { message: 'En producción API_PUBLIC_URL debe empezar con https://' })
  .refine((e) => e.NODE_ENV !== 'production' || (e.STORAGE_DRIVER === 'r2' && e.MAIL_DRIVER === 'smtp'), {
    message: 'En producción los archivos van en R2 (STORAGE_DRIVER=r2) y los correos por SMTP (MAIL_DRIVER=smtp)',
  })
  .refine((e) => e.JWT_ACCESS_SECRET !== e.JWT_REFRESH_SECRET, { message: 'JWT_ACCESS_SECRET y JWT_REFRESH_SECRET deben ser distintos' })
  .refine((e) => e.NODE_ENV !== 'production' || !/[?&]sslmode=disable/.test(e.DATABASE_URL), { message: 'En producción la conexión a PostgreSQL debe ir cifrada (sin sslmode=disable)' });

/* Firebase: en lugar de copiar los datos a .env, FCM_KEY_FILE puede apuntar al JSON de la cuenta de servicio
   (Firebase → Configuración del proyecto → Cuentas de servicio → Generar nueva clave privada). */
if (process.env.FCM_KEY_FILE) {
  try {
    const key = JSON.parse(readFileSync(path.resolve(process.env.FCM_KEY_FILE), 'utf8')) as Record<string, string>;
    process.env.FCM_PROJECT_ID ||= key.project_id;
    process.env.FCM_CLIENT_EMAIL ||= key.client_email;
    process.env.FCM_PRIVATE_KEY ||= key.private_key;
  } catch {
    console.error(`No se pudo leer FCM_KEY_FILE (${process.env.FCM_KEY_FILE}). Revisa la ruta del archivo de Firebase.`);
    process.exit(1);
  }
}

const parsed = schema.safeParse(process.env);
if (!parsed.success) {
  console.error('Configuración inválida:\n' + z.prettifyError(parsed.error));
  process.exit(1);
}

export const env = {
  ...parsed.data,
  corsOrigins: parsed.data.CORS_ORIGINS.split(',').map((o) => o.trim()).filter(Boolean),
  isProduction: parsed.data.NODE_ENV === 'production',
  isTest: parsed.data.NODE_ENV === 'test',
};
