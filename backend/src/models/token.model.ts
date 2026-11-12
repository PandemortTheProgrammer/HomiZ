import { pool, type Db } from '../config/database.js';

/* Refresh tokens y enlaces de recuperación: en la base solo se guarda el hash, nunca el token. */

export interface RefreshTokenRow {
  id: string;
  user_id: string;
  expires_at: Date;
  revoked_at: Date | null;
}

export async function insertRefreshToken(userId: string, tokenHash: string, expiresAt: Date, db: Db = pool): Promise<void> {
  await db.query('INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)', [userId, tokenHash, expiresAt]);
}

export async function findRefreshToken(tokenHash: string, db: Db = pool): Promise<RefreshTokenRow | null> {
  const { rows } = await db.query<RefreshTokenRow>(
    'SELECT id, user_id, expires_at, revoked_at FROM refresh_tokens WHERE token_hash = $1',
    [tokenHash],
  );
  return rows[0] ?? null;
}

/** Revoca un token solo si seguía vigente; devuelve false si ya estaba revocado (evita carreras en la rotación). */
export async function revokeRefreshToken(id: string, db: Db = pool): Promise<boolean> {
  const { rowCount } = await db.query('UPDATE refresh_tokens SET revoked_at = now() WHERE id = $1 AND revoked_at IS NULL', [id]);
  return (rowCount ?? 0) > 0;
}

export async function revokeAllForUser(userId: string, db: Db = pool): Promise<void> {
  await db.query('UPDATE refresh_tokens SET revoked_at = now() WHERE user_id = $1 AND revoked_at IS NULL', [userId]);
}

export async function insertPasswordReset(userId: string, tokenHash: string, expiresAt: Date, db: Db = pool, codeHash: string | null = null): Promise<void> {
  // Un enlace nuevo invalida los anteriores que no se usaron.
  await db.query('UPDATE password_resets SET used_at = now() WHERE user_id = $1 AND used_at IS NULL', [userId]);
  await db.query('INSERT INTO password_resets (user_id, token_hash, expires_at, code_hash) VALUES ($1, $2, $3, $4)', [userId, tokenHash, expiresAt, codeHash]);
}

/**
 * Canjea la contraseña temporal del correo («olvidé mi contraseña»): solo la vigente (sin usar ni vencer).
 * Devuelve true si coincide; queda usada. La contraseña anterior sigue sirviendo hasta que se canjee.
 */
export async function consumeTemporaryPassword(userId: string, passwordHash: string, db: Db = pool): Promise<boolean> {
  const { rowCount } = await db.query(
    `UPDATE password_resets SET used_at = now()
      WHERE id = (SELECT id FROM password_resets
                   WHERE user_id = $1 AND used_at IS NULL AND expires_at > now() AND code_hash IS NOT NULL
                   ORDER BY created_at DESC LIMIT 1)
        AND code_hash = $2`,
    [userId, passwordHash],
  );
  return (rowCount ?? 0) > 0;
}

/** Marca el enlace como usado y devuelve el usuario, solo si existía, no se había usado y no venció. */
export async function consumePasswordReset(tokenHash: string, db: Db = pool): Promise<string | null> {
  const { rows } = await db.query<{ user_id: string }>(
    `UPDATE password_resets SET used_at = now()
      WHERE token_hash = $1 AND used_at IS NULL AND expires_at > now()
      RETURNING user_id`,
    [tokenHash],
  );
  return rows[0]?.user_id ?? null;
}
