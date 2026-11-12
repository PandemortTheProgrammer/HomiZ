/* Genera el hash Argon2 de una contraseña (para datos de ejemplo): npm run db:hash -- "MiClave2026" */
import argon2 from 'argon2';

const password = process.argv[2];
if (!password) {
  console.error('Uso: npm run db:hash -- "Contraseña"');
  process.exit(1);
}
console.log(await argon2.hash(password, { type: argon2.argon2id }));
