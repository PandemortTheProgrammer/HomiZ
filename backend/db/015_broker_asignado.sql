-- Las solicitudes nuevas llegan sin broker: administración las asigna (y su cita queda con ese broker).
ALTER TABLE leads ADD COLUMN IF NOT EXISTS broker_id UUID REFERENCES users (id);
CREATE INDEX IF NOT EXISTS leads_broker_idx ON leads (broker_id);

-- Las que ya existían conservan a quien las veía: el broker de su casa
UPDATE leads l SET broker_id = p.broker_id FROM properties p WHERE p.id = l.property_id AND l.broker_id IS NULL;
