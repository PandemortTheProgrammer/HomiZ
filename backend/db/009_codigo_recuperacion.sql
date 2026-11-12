-- Código de 6 dígitos para recuperar la contraseña escribiéndolo en el panel o en la app
-- (además del enlace del correo). Se guarda solo su hash; tras 5 intentos fallidos deja de servir.
ALTER TABLE password_resets ADD COLUMN IF NOT EXISTS code_hash TEXT;
ALTER TABLE password_resets ADD COLUMN IF NOT EXISTS attempts INT NOT NULL DEFAULT 0;
