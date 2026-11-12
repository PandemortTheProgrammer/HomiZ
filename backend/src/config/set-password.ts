/*
 * Asigna una contraseña a una cuenta (soporte: «no me llegó el correo»): npm run db:set-password -- correo@ejemplo.com
 * La contraseña se escribe al ejecutarlo (no queda en el historial de la terminal). La persona debe cambiarla al entrar.
 */
import 'dotenv/config';
import { createInterface } from 'node:readline/promises';
import argon2 from 'argon2';
import pg from 'pg';

const email = process.argv[2]?.trim().toLowerCase();
if (!email || !process.env.DATABASE_URL) {
  console.error('Uso: npm run db:set-password -- correo@ejemplo.com   (necesita DATABASE_URL en .env)');
  process.exit(1);
}
const rl = createInterface({ input: process.stdin, output: process.stdout });
const password = (await rl.question(`Contraseña nueva para ${email} (mínimo 8 caracteres): `)).trim();
rl.close();
if (password.length < 8) {
  console.error('La contraseña debe tener al menos 8 caracteres. No se cambió nada.');
  process.exit(1);
}
const client = new pg.Client({ connectionString: process.env.DATABASE_URL });
await client.connect();
try {
  const hash = await argon2.hash(password, { type: argon2.argon2id });
  // Queda como temporal: al entrar, la app le pide crear la suya. Se desbloquea y se cierran sus otras sesiones.
  const { rows } = await client.query<{ id: string; name: string }>(
    `UPDATE users SET password_hash = $2, must_change_password = TRUE, failed_attempts = 0, locked_until = NULL
      WHERE lower(email) = $1 AND active RETURNING id, name`,
    [email, hash],
  );
  if (!rows[0]) {
    console.error(`No hay una cuenta activa con el correo ${email}. No se cambió nada.`);
    process.exit(1);
  }
  await client.query('UPDATE refresh_tokens SET revoked_at = now() WHERE user_id = $1 AND revoked_at IS NULL', [rows[0].id]).catch(() => {});
  await client.query(
    `INSERT INTO activity_log (user_id, entity, action, description) VALUES ($1, 'auth', 'password_set_by_support', 'Soporte le asignó una contraseña temporal (no le llegó el correo).')`,
    [rows[0].id],
  );
  console.log(`Listo: ${rows[0].name} ya puede entrar con esa contraseña. Al entrar la app le pedirá crear la suya.`);
} finally {
  await client.end();
}
