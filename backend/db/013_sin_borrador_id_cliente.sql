-- Fase 2 · reglas de negocio

-- 1) Ya no hay borradores: lo registrado queda disponible; lo que no se ve en el sitio queda pausado.
UPDATE properties SET status = 'disponible' WHERE status = 'borrador';
UPDATE properties SET visibility = 'pausada' WHERE visibility = 'borrador';
ALTER TABLE properties ALTER COLUMN status SET DEFAULT 'disponible';
ALTER TABLE properties ALTER COLUMN visibility SET DEFAULT 'pausada';

-- 2) ID visible de cada persona (prospecto o inquilino): CLI-0001, CLI-0002… No cambia al volverse inquilino.
CREATE SEQUENCE IF NOT EXISTS clients_code_seq;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS code TEXT;
WITH o AS (SELECT id, row_number() OVER (ORDER BY created_at, id) AS n FROM clients WHERE code IS NULL)
UPDATE clients c SET code = 'CLI-' || lpad(o.n::text, 4, '0') FROM o WHERE o.id = c.id;
SELECT setval('clients_code_seq', GREATEST((SELECT count(*) FROM clients), 1), (SELECT count(*) > 0 FROM clients));
ALTER TABLE clients ALTER COLUMN code SET DEFAULT 'CLI-' || lpad(nextval('clients_code_seq')::text, 4, '0');
ALTER TABLE clients ALTER COLUMN code SET NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS clients_code_key ON clients (code);

-- 3) Una cita vigente por persona: índice para encontrarla rápido (la regla se aplica en la API)
CREATE INDEX IF NOT EXISTS appointments_client_active_idx ON appointments (client_id) WHERE status IN ('por-confirmar', 'confirmada');
