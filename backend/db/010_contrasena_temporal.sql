-- Contraseña temporal en lugar de código: «Olvidé mi contraseña» y las cuentas creadas desde el sitio
-- reciben por correo una contraseña temporal; al entrar con ella se pide crear una propia.
-- password_resets.code_hash guarda ahora el hash de la contraseña temporal (la de 009 ya no se usa como código).
ALTER TABLE users ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN NOT NULL DEFAULT FALSE;
