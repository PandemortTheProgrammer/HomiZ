-- =============================================================================
-- Homiz · Migración 008: mensajes de las solicitudes
-- =============================================================================
-- El cliente y su asesor platican dentro de cada solicitud (en la app y en el panel), en lugar del correo.
CREATE TABLE IF NOT EXISTS lead_messages (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id    UUID NOT NULL REFERENCES leads (id) ON DELETE CASCADE,
  sender_id  UUID REFERENCES users (id),
  from_staff BOOLEAN NOT NULL,
  body       TEXT NOT NULL CHECK (length(body) BETWEEN 1 AND 2000),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS lead_messages_lead_idx ON lead_messages (lead_id, created_at);
