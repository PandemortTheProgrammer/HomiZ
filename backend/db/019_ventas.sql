-- Ventas: comprobante de que el cliente cerró con la inmobiliaria la compra de una casa en venta.
-- La inmobiliaria no administra la casa después (no hay pagarés ni expediente): solo queda el registro,
-- el comprobante en PDF y, si se sube, el contrato de compraventa / promesa firmado.
-- La escritura pública la otorga el notario; este registro no la sustituye.
DO $$ BEGIN
  CREATE TYPE sale_status AS ENUM ('closed', 'voided');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS sales (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  folio            TEXT NOT NULL UNIQUE,                 -- VEN-001, VEN-002…
  property_id      UUID NOT NULL REFERENCES properties(id),
  client_id        UUID NOT NULL REFERENCES clients(id),
  sale_date        DATE NOT NULL,                        -- fecha de cierre (firma de la promesa o de la escritura)
  price            NUMERIC(14, 2) NOT NULL CHECK (price > 0),
  payment_method   TEXT,                                 -- contado, crédito bancario, Infonavit, Fovissste…
  notary           TEXT,                                 -- notaría que escritura (opcional)
  identity_checked BOOLEAN NOT NULL DEFAULT FALSE,       -- se verificó la identificación oficial (Ley Antilavado)
  notes            TEXT,
  document_id      UUID REFERENCES documents(id) ON DELETE SET NULL, -- contrato firmado (PDF)
  status           sale_status NOT NULL DEFAULT 'closed',
  void_reason      TEXT,
  created_by       UUID REFERENCES users(id),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  voided_at        TIMESTAMPTZ
);
-- Una casa solo tiene una venta cerrada a la vez (si se anula, se puede registrar otra)
CREATE UNIQUE INDEX IF NOT EXISTS sales_one_closed_per_property ON sales (property_id) WHERE status = 'closed';
CREATE INDEX IF NOT EXISTS sales_client_idx ON sales (client_id);
