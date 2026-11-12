-- =============================================================================
-- Homiz · Migración 005: rol «Propietario» y eliminación de documentos
-- =============================================================================
-- Cada persona del personal puede ser broker, administrador o ambos. Solo el propietario de la aplicación
-- decide quién es qué (users.manage); el administrador ya no puede cambiar roles.
-- Eliminar documentos del expediente: administración (y propietario). El broker solo los oculta al cliente.

INSERT INTO roles (code, name) VALUES ('owner', 'Propietario') ON CONFLICT (code) DO NOTHING;

INSERT INTO permissions (code, description) VALUES ('documents.delete', 'Eliminar documentos del expediente')
ON CONFLICT (code) DO NOTHING;

-- El propietario tiene todos los permisos.
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p WHERE r.code = 'owner'
ON CONFLICT DO NOTHING;

-- Administración: puede eliminar documentos, pero ya no gestiona al personal ni sus roles.
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p ON p.code = 'documents.delete' WHERE r.code = 'admin'
ON CONFLICT DO NOTHING;
DELETE FROM role_permissions
 WHERE role_id = (SELECT id FROM roles WHERE code = 'admin')
   AND permission_id = (SELECT id FROM permissions WHERE code = 'users.manage');

-- Lucía (administración del ejemplo) es la propietaria.
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON r.code = 'owner' WHERE u.email = 'lucia@zugar.example'
ON CONFLICT DO NOTHING;
