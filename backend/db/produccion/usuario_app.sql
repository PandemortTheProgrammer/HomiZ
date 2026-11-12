-- Usuario de base de datos con permisos mínimos para la API (no es superusuario ni dueño de las tablas).
-- Ejecútalo UNA vez como administrador de la base, después de crear las tablas (npm run db:setup).
-- Cambia la contraseña por una larga y aleatoria y úsala en DATABASE_URL de la API:
--   postgres://homiz_app:<contraseña>@<servidor>:5432/homiz?sslmode=require
-- No se ejecuta solo: esta carpeta no la recorre db:setup.

DO $$ BEGIN
  CREATE ROLE homiz_app LOGIN PASSWORD 'CAMBIA-ESTA-CONTRASEÑA';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Puede conectarse y usar el esquema, pero no crear ni borrar tablas
GRANT CONNECT ON DATABASE homiz TO homiz_app;
GRANT USAGE ON SCHEMA public TO homiz_app;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- Leer y escribir datos; las secuencias (claves CIT-, CLI-, folios) también
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO homiz_app;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO homiz_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO homiz_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO homiz_app;

-- Bitácora de actividad: solo agregar y consultar (nadie desde la API la edita ni la borra)
REVOKE UPDATE, DELETE, TRUNCATE ON activity_log FROM homiz_app;
