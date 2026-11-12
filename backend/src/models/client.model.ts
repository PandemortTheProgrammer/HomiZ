import { pool, type Db } from '../config/database.js';

/** Datos del expediente del cliente que puede ver él mismo (nunca incluye al broker responsable). */
export interface ClientProfile {
  id: string;
  kind: 'cliente' | 'inquilino';
  name: string;
  email: string | null;
  phone: string | null;
  budget: string | null;
  budget_amount: number | null;
  has_pets: boolean;
  pets_count: number;
  occupants: number | null;
  property_id: string | null;
}

/** Datos que el propio cliente puede actualizar desde la app («Mis datos» de la cita). */
export interface OwnClientUpdate {
  budgetAmount?: number | null;
  hasPets?: boolean;
  petsCount?: number;
  occupants?: number | null;
}

export async function updateOwn(userId: string, d: OwnClientUpdate, db: Db = pool): Promise<void> {
  const budgetText = d.budgetAmount === undefined ? undefined : d.budgetAmount === null ? null : `$${d.budgetAmount.toLocaleString('en-US')} MXN / mes`;
  await db.query(
    `UPDATE clients
        SET budget_amount = CASE WHEN $2::boolean THEN $3::numeric ELSE budget_amount END,
            budget        = CASE WHEN $2::boolean THEN $4::text ELSE budget END,
            has_pets      = COALESCE($5::boolean, has_pets),
            pets_count    = CASE WHEN $5::boolean = FALSE THEN 0 ELSE COALESCE($6::int, pets_count) END,
            occupants     = CASE WHEN $7::boolean THEN $8::int ELSE occupants END
      WHERE user_id = $1 AND active`,
    [userId, d.budgetAmount !== undefined, d.budgetAmount ?? null, budgetText ?? null, d.hasPets ?? null, d.petsCount ?? null, d.occupants !== undefined, d.occupants ?? null],
  );
}

export async function findByUserId(userId: string, db: Db = pool): Promise<ClientProfile | null> {
  const { rows } = await db.query<ClientProfile>(
    `SELECT id, kind, name, email, phone, budget, budget_amount, has_pets, pets_count, occupants, property_id
       FROM clients WHERE user_id = $1 AND active`,
    [userId],
  );
  return rows[0] ?? null;
}

/**
 * Al registrarse, si la inmobiliaria ya tenía a la persona como cliente (mismo correo, sin cuenta),
 * se vincula ese expediente; si no, se crea uno nuevo.
 */
export async function linkOrCreateForUser(
  user: { id: string; name: string; email: string; phone: string | null },
  db: Db = pool,
): Promise<string> {
  const linked = await db.query<{ id: string }>(
    // Si el expediente no tenía teléfono, se toma el de la cuenta (para poder contactarlo)
    `UPDATE clients SET user_id = $1, phone = COALESCE(phone, $3)
      WHERE id = (SELECT id FROM clients WHERE lower(email) = lower($2) AND user_id IS NULL AND active ORDER BY created_at LIMIT 1)
      RETURNING id`,
    [user.id, user.email, user.phone],
  );
  if (linked.rows[0]) return linked.rows[0].id;
  const created = await db.query<{ id: string }>(
    `INSERT INTO clients (user_id, kind, name, email, phone, follow_status)
     VALUES ($1, 'cliente', $2, $3, $4, 'Nuevo contacto') RETURNING id`,
    [user.id, user.name, user.email, user.phone],
  );
  return created.rows[0].id;
}
