/**
 * Evidencia de persistencia para el entregable: muestra las últimas citas, clientes y brokers guardados
 * (solo claves, estados y fechas; sin nombres ni datos de contacto). Uso: npx tsx src/config/evidencia-persistencia.ts
 */
import { pool } from './database.js';

const q = async (title: string, sql: string) => {
  const { rows } = await pool.query(sql);
  console.log(`\n${title}\n${sql.replace(/\s+/g, ' ').trim()}`);
  console.table(rows);
};

await q('Citas', `SELECT code, status, to_char(scheduled_at AT TIME ZONE 'America/Cancun', 'YYYY-MM-DD HH24:MI') AS fecha_cancun, to_char(created_at AT TIME ZONE 'America/Cancun', 'YYYY-MM-DD HH24:MI') AS creada FROM appointments ORDER BY created_at DESC LIMIT 5`);
await q('Clientes', `SELECT code, kind, follow_status, active, to_char(created_at AT TIME ZONE 'America/Cancun', 'YYYY-MM-DD HH24:MI') AS creado FROM clients ORDER BY created_at DESC LIMIT 5`);
await q('Brokers', `SELECT u.initials, u.active, (SELECT count(*) FROM properties p WHERE p.broker_id = u.id AND p.active)::int AS casas FROM users u JOIN user_roles ur ON ur.user_id = u.id JOIN roles r ON r.id = ur.role_id WHERE r.code = 'broker' ORDER BY u.created_at`);
await pool.end();
