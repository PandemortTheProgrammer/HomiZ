-- Cuota de mantenimiento de cada casa (la captura administración): monto y día del mes en que se paga.
-- Ese día, la tarea diaria se lo recuerda a administración, al broker de la casa y al inquilino.
ALTER TABLE properties ADD COLUMN IF NOT EXISTS maintenance_fee NUMERIC(12, 2);
ALTER TABLE properties ADD COLUMN IF NOT EXISTS maintenance_fee_day SMALLINT;
DO $$ BEGIN
  ALTER TABLE properties ADD CONSTRAINT properties_maintenance_fee_day_chk CHECK (maintenance_fee_day BETWEEN 1 AND 28);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
