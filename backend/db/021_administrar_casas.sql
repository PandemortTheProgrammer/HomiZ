-- Expediente, pagos y contratos de una casa: solo quien la tiene asignada y además la puede administrar.
INSERT INTO permissions (code, description) VALUES ('properties.manage', 'Llevar expediente, pagos y contratos de las casas asignadas')
ON CONFLICT (code) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p ON p.code = 'properties.manage' WHERE r.code IN ('owner', 'admin')
ON CONFLICT DO NOTHING;
