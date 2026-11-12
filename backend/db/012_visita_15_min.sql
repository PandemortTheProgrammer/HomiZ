-- Las visitas duran 15 minutos (antes 45). Las citas ya guardadas conservan su duración.
ALTER TABLE appointments ALTER COLUMN duration_min SET DEFAULT 15;
