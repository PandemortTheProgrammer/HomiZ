-- Una casa no recibe dos visitas a la misma hora, sin importar quién las pida o qué broker las atienda.
CREATE UNIQUE INDEX IF NOT EXISTS appointments_property_slot
  ON appointments (property_id, scheduled_at)
  WHERE status IN ('por-confirmar', 'confirmada');
