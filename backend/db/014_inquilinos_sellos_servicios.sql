-- Fase 4 · inquilinos, sellos de pagarés y servicios de agua y luz

-- 1) Hacer inquilino (registrar o finalizar contratos) es solo de administración y del propietario, no del broker.
DELETE FROM role_permissions
 WHERE role_id = (SELECT id FROM roles WHERE code = 'broker')
   AND permission_id = (SELECT id FROM permissions WHERE code = 'contracts.manage');

-- 2) Fotos de los sellos de cada pagaré: constancia de que se entregó en físico y en digital.
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'stamp';

-- 3) Servicios de la propiedad: número de servicio de luz (CFE) y de agua (Aguakan), que captura administración,
--    y el día del mes en que se le recuerda al inquilino revisarlos en la app de cada compañía.
ALTER TABLE properties ADD COLUMN IF NOT EXISTS electricity_service_number TEXT;
ALTER TABLE properties ADD COLUMN IF NOT EXISTS water_service_number TEXT;
ALTER TABLE properties ADD COLUMN IF NOT EXISTS utility_reminder_day INT NOT NULL DEFAULT 1
  CHECK (utility_reminder_day BETWEEN 1 AND 28);
