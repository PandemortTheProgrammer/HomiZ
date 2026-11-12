import pg from 'pg';
import { env } from './env.js';
import { logger } from './logger.js';

/* NUMERIC llega como texto desde pg; lo convertimos a número para montos (NUMERIC(12,2)). */
pg.types.setTypeParser(pg.types.builtins.NUMERIC, (value) => Number(value));

export const pool = new pg.Pool({
  connectionString: env.DATABASE_URL,
  max: 10,
  idleTimeoutMillis: 30_000,
});

pool.on('error', (err) => logger.error({ err: err.message }, 'Error inesperado en la conexión a PostgreSQL'));

/** Consulta parametrizada: nunca concatenar valores en el SQL. */
export function query<T extends pg.QueryResultRow = pg.QueryResultRow>(text: string, params: unknown[] = []) {
  return pool.query<T>(text, params);
}

/** Ejecuta varias consultas en una transacción; si algo falla, se revierte todo. */
export async function withTransaction<T>(fn: (client: pg.PoolClient) => Promise<T>): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

/** Cliente o pool: los modelos aceptan ambos para poder usarse dentro de transacciones. */
export type Db = pg.Pool | pg.PoolClient;

/** Verifica que la base responde (para /health). */
export async function checkDatabase(): Promise<boolean> {
  try {
    await pool.query('SELECT 1');
    return true;
  } catch {
    return false;
  }
}
