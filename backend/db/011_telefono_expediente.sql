-- Expedientes sin teléfono cuya cuenta de la app sí lo tiene (al ligar la cuenta no se copiaba):
-- así el personal puede llamar o escribir por WhatsApp al inquilino o cliente.
UPDATE clients c SET phone = u.phone
  FROM users u
 WHERE u.id = c.user_id AND (c.phone IS NULL OR c.phone = '') AND u.phone IS NOT NULL AND u.phone <> '';
