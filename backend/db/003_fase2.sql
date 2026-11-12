-- =============================================================================
-- Homiz · Migración 003 (Fase 2)
-- =============================================================================

-- Pagarés que ya no se cobrarán porque el contrato terminó antes (no se borran: quedan en el historial).
ALTER TYPE note_status ADD VALUE IF NOT EXISTS 'cancelled';

-- Recordatorios ya enviados por las tareas diarias (evita repetir el mismo aviso el mismo día).
CREATE TABLE IF NOT EXISTS reminder_log (
  kind      TEXT NOT NULL,
  entity_id UUID NOT NULL,
  sent_on   DATE NOT NULL,
  PRIMARY KEY (kind, entity_id, sent_on)
);

-- Búsquedas frecuentes de la Fase 2.
CREATE INDEX IF NOT EXISTS leads_reason_idx ON leads (reason);
CREATE INDEX IF NOT EXISTS expenses_next_maintenance_idx ON expenses (next_maintenance_date) WHERE next_maintenance_date IS NOT NULL;
CREATE INDEX IF NOT EXISTS clients_user_idx ON clients (user_id);
