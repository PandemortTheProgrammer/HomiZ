-- La fecha de una cita la acuerdan el cliente y el personal: quien la propone espera a que la otra parte la acepte.
-- awaiting = de quién se espera la confirmación ('staff': el broker o administración; 'client': la persona).
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS awaiting TEXT NOT NULL DEFAULT 'staff';
DO $$ BEGIN
  ALTER TABLE appointments ADD CONSTRAINT appointments_awaiting_chk CHECK (awaiting IN ('staff', 'client'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
