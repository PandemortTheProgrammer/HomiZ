-- =============================================================================
-- Homiz · Migración 007: solicitudes atendidas desde el panel y la app
-- =============================================================================
-- En lugar de responder por correo, el asesor contesta y propone casas; el cliente lo ve en la app
-- (sección «Mis solicitudes») y recibe un aviso.

ALTER TABLE leads ADD COLUMN IF NOT EXISTS response TEXT;          -- respuesta del asesor para el cliente
ALTER TABLE leads ADD COLUMN IF NOT EXISTS responded_at TIMESTAMPTZ;
ALTER TABLE leads ADD COLUMN IF NOT EXISTS responded_by UUID REFERENCES users (id);

-- Casas que el asesor le propone a la persona (una vez cada casa por solicitud).
CREATE TABLE IF NOT EXISTS lead_proposals (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id     UUID NOT NULL REFERENCES leads (id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES properties (id),
  note        TEXT,
  proposed_by UUID REFERENCES users (id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (lead_id, property_id)
);
CREATE INDEX IF NOT EXISTS lead_proposals_lead_idx ON lead_proposals (lead_id);
CREATE INDEX IF NOT EXISTS leads_client_idx ON leads (client_id);
