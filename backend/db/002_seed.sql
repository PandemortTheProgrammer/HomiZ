-- =============================================================================
-- Homiz · Datos de ejemplo
-- Incluye los datos del panel existente (brokers, 6 propiedades, 8 personas,
-- 5 citas), las casas extra del catálogo del sitio y la inquilina Laura Mendez
-- con Casa Las Palmas. Contraseña de todos los usuarios: Zugar2026!
-- Fecha de referencia del proyecto: martes 20 de octubre de 2026 (Cancún, UTC-5).
-- =============================================================================

-- Ayudantes temporales (solo viven en esta sesión).
CREATE FUNCTION pg_temp.u(TEXT) RETURNS UUID LANGUAGE sql AS 'SELECT id FROM users WHERE email = $1';
CREATE FUNCTION pg_temp.p(TEXT) RETURNS UUID LANGUAGE sql AS 'SELECT id FROM properties WHERE code = $1';
CREATE FUNCTION pg_temp.c(TEXT) RETURNS UUID LANGUAGE sql AS 'SELECT id FROM clients WHERE email = $1';

-- ---------- Usuarios ----------
INSERT INTO users (name, email, phone, birth_date, password_hash, type, initials, photo_key, zones, specialty) VALUES
  ('Lucía Méndez',  'lucia@zugar.example',   '+52 998 555 0100', NULL,         '$argon2id$v=19$m=65536,p=4,t=3$w7BzGxx6LcgnCNKRVZgbFA$mm/Qqd95WwvECTDIODg0j9iy/bQiw7u7iPBzdAafo/k', 'staff',  'LM', NULL, NULL, 'Administradora'),
  ('Mariana Solís', 'mariana@zugar.example', '+52 998 555 0101', NULL,         '$argon2id$v=19$m=65536,p=4,t=3$w7BzGxx6LcgnCNKRVZgbFA$mm/Qqd95WwvECTDIODg0j9iy/bQiw7u7iPBzdAafo/k', 'staff',  'MS', 'asesora-mariana-solis.jpg', 'Arbolada · Aqua Residencial', 'Rentas · Arbolada y Aqua'),
  ('Diego Herrera', 'diego@zugar.example',   '+52 998 555 0102', NULL,         '$argon2id$v=19$m=65536,p=4,t=3$w7BzGxx6LcgnCNKRVZgbFA$mm/Qqd95WwvECTDIODg0j9iy/bQiw7u7iPBzdAafo/k', 'staff',  'DH', NULL, 'Cumbres · Lagos del Sol', 'Ventas · Cumbres y Lagos del Sol'),
  ('Valeria Cruz',  'valeria@zugar.example', '+52 998 555 0103', NULL,         '$argon2id$v=19$m=65536,p=4,t=3$w7BzGxx6LcgnCNKRVZgbFA$mm/Qqd95WwvECTDIODg0j9iy/bQiw7u7iPBzdAafo/k', 'staff',  'VC', NULL, 'Santa Fe · Jardines del Sur', 'Rentas y ventas · Santa Fe'),
  ('Laura Mendez',  'lau.mendez@correo.com', '+52 998 000 0000', '1995-03-15', '$argon2id$v=19$m=65536,p=4,t=3$w7BzGxx6LcgnCNKRVZgbFA$mm/Qqd95WwvECTDIODg0j9iy/bQiw7u7iPBzdAafo/k', 'client', 'LM', NULL, NULL, NULL);

-- ---------- Roles y permisos ----------
INSERT INTO roles (code, name) VALUES ('broker', 'Broker'), ('admin', 'Administrador');

INSERT INTO permissions (code, description) VALUES
  ('properties.read_all',       'Ver todo el catálogo, incluidas casas no publicadas'),
  ('properties.create',         'Registrar propiedades'),
  ('properties.update',         'Modificar propiedades y su disponibilidad'),
  ('properties.reassign',       'Reasignar el broker responsable'),
  ('clients.manage',            'Registrar y editar clientes e inquilinos'),
  ('contracts.manage',          'Registrar y finalizar contratos'),
  ('appointments.manage',       'Confirmar, rechazar y reprogramar citas'),
  ('payments.register',         'Registrar pagos en efectivo de pagarés'),
  ('payments.correct',          'Corregir o anular pagos registrados'),
  ('receipts.manage',           'Registrar recibos de luz y agua'),
  ('maintenance.manage',        'Actualizar reportes de mantenimiento'),
  ('providers.manage',          'Gestionar proveedores'),
  ('expenses.manage',           'Registrar gastos'),
  ('documents.manage',          'Subir y administrar documentos'),
  ('dossier.read',              'Consultar el expediente completo'),
  ('activity.read',             'Consultar el historial'),
  ('leads.manage',              'Atender solicitudes del sitio web'),
  ('users.manage',              'Gestionar usuarios del personal y sus roles'),
  ('notifications.overdue',     'Recibir avisos de pagarés y recibos vencidos');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p ON
  (r.code = 'admin') OR
  (r.code = 'broker' AND p.code NOT IN ('properties.reassign', 'payments.correct', 'users.manage', 'notifications.overdue'));

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON
  (u.email = 'lucia@zugar.example' AND r.code = 'admin') OR
  (u.email IN ('mariana@zugar.example', 'diego@zugar.example', 'valeria@zugar.example') AND r.code = 'broker');

-- ---------- Propiedades (las 6 del panel + las del catálogo del sitio + Casa Las Palmas) ----------
INSERT INTO properties (code, slug, name, type, description, operation, price, rec, banos, m2, terreno, est, age, furnished, pets_allowed,
  maintenance, deposit, available_from, address, street, zone, zone_key, map_query, status, visibility, broker_id, published_at) VALUES
  ('ZUG-001', 'casa-ceiba', 'Casa Ceiba', 'Casa',
   'Casa de dos niveles con sala y comedor abiertos, cocina integral y jardín privado. La luz natural acompaña cada espacio; ideal para una vida tranquila en Arbolada.',
   'renta', 28000, 3, 2, 180, 160, 2, 5, 'Sin amueblar', TRUE, 'Incluido en la renta', 28000, '2026-10-20',
   'Calle Ceiba 24, Residencial Arbolada, C.P. 77560', 'Calle Ceiba 24', 'Arbolada', 'arbolada', 'Residencial Arbolada, Cancún, Quintana Roo',
   'disponible', 'publicada', pg_temp.u('mariana@zugar.example'), '2026-10-13'),
  ('ZUG-002', 'casa-del-patio', 'Casa del Patio', 'Casa',
   'Residencia de un nivel organizada alrededor de un patio con pérgola de madera. Espacios amplios, techos altos y una terraza para recibir a la familia.',
   'venta', 4850000, 3, 3, 240, 210, 2, 3, 'Sin amueblar', TRUE, '$2,400 MXN al mes', NULL, '2026-10-01',
   'Av. Cumbres 118, Residencial Cumbres, C.P. 77560', 'Av. Cumbres 118', 'Residencial Cumbres', 'cumbres', 'Residencial Cumbres, Cancún, Quintana Roo',
   'disponible', 'publicada', pg_temp.u('diego@zugar.example'), '2026-09-28'),
  ('ZUG-003', 'casa-olivo', 'Casa Olivo', 'Casa',
   'Casa compacta y luminosa de estilo caribeño, con balcón en planta alta y cocina abierta. Cerca de escuelas y plazas comerciales.',
   'renta', 22500, 2, 2, 135, 120, 1, 8, 'Semiamueblada', FALSE, 'Incluido en la renta', 22500, '2026-06-01',
   'Calle Olivo 7, Santa Fe, C.P. 77535', 'Calle Olivo 7', 'Santa Fe', 'santa-fe', 'Fraccionamiento Santa Fe, Cancún, Quintana Roo',
   'rentada', 'pausada', pg_temp.u('valeria@zugar.example'), '2026-05-12'),
  ('ZUG-004', 'casa-de-la-luz', 'Casa de la Luz', 'Casa',
   'Residencia de dos niveles con grandes ventanales, alberca privada y vista a las áreas verdes del residencial.',
   'venta', 6200000, 4, 4, 320, 300, 3, 2, 'Sin amueblar', TRUE, '$3,100 MXN al mes', NULL, '2026-11-15',
   'Paseo Lagos del Sol 52, C.P. 77560', 'Paseo Lagos del Sol 52', 'Lagos del Sol', 'lagos-del-sol', 'Lagos del Sol, Cancún, Quintana Roo',
   'reservada', 'publicada', pg_temp.u('diego@zugar.example'), '2026-09-02'),
  ('ZUG-005', 'casa-nativa', 'Casa Nativa', 'Casa en condominio',
   'Casa con fachada de madera y piedra, alberca y terraza techada. Se entrega amueblada y lista para habitar.',
   'renta', 35000, 3, 3, 210, 180, 2, 4, 'Amueblada', TRUE, 'Incluido en la renta', 35000, '2026-11-01',
   'Circuito Aqua 31, Aqua Residencial, C.P. 77560', 'Circuito Aqua 31', 'Aqua Residencial', 'aqua', 'Residencial Aqua, Cancún, Quintana Roo',
   'disponible', 'publicada', pg_temp.u('mariana@zugar.example'), '2026-10-05'),
  ('ZUG-006', 'casa-almendra', 'Casa Almendra', 'Casa',
   'Casa familiar con cochera para dos autos y jardín frontal, en una zona tranquila del sur de Cancún.',
   'venta', 3450000, 3, 2, 165, 150, 2, 6, 'Sin amueblar', FALSE, '$1,200 MXN al mes', NULL, '2026-11-01',
   'Calle Almendro 15, Jardines del Sur, C.P. 77536', 'Calle Almendro 15', 'Jardines del Sur', 'jardines-del-sur', 'Jardines del Sur, Cancún, Quintana Roo',
   'borrador', 'borrador', pg_temp.u('valeria@zugar.example'), NULL),
  ('ZUG-007', 'casa-zapote', 'Casa Zapote', 'Casa',
   'Casa de fachada clara con cochera techada, cerca de escuelas, mercados y transporte.',
   'renta', 24000, 3, 2, 150, 140, 1, 10, 'Sin amueblar', FALSE, 'Incluido en la renta', 24000, '2026-11-01',
   'Supermanzana 50, Cancún', NULL, 'Supermanzana 50', 'sm-50', 'Supermanzana 50, Cancún, Quintana Roo',
   'disponible', 'publicada', pg_temp.u('valeria@zugar.example'), '2026-09-20'),
  ('ZUG-008', 'casa-chaka', 'Casa Chaká', 'Casa',
   'Casa de muros blancos con ventanales hacia el jardín y espacios llenos de luz.',
   'renta', 32000, 3, 3, 205, 180, 2, 4, 'Sin amueblar', TRUE, 'Incluido en la renta', 32000, '2026-11-01',
   'Residencial Palmaris, Cancún', NULL, 'Residencial Palmaris', 'palmaris', 'Residencial Palmaris, Cancún, Quintana Roo',
   'disponible', 'publicada', pg_temp.u('mariana@zugar.example'), '2026-09-25'),
  ('ZUG-009', 'casa-ramon', 'Casa Ramón', 'Casa',
   'Residencia de dos niveles con terraza y pérgola, ideal para familias grandes.',
   'renta', 36500, 3, 3.5, 240, 220, 2, 6, 'Semiamueblada', TRUE, 'Incluido en la renta', 36500, '2026-11-15',
   'Residencial Cumbres, Cancún', NULL, 'Residencial Cumbres', 'cumbres', 'Residencial Cumbres, Cancún, Quintana Roo',
   'disponible', 'publicada', pg_temp.u('diego@zugar.example'), '2026-09-30'),
  ('ZUG-010', 'casa-huano', 'Casa Huano', 'Casa',
   'Casa con alberca rodeada de palmeras y amplias áreas sociales.',
   'renta', 38000, 3, 3.5, 265, 250, 3, 5, 'Sin amueblar', FALSE, 'Incluido en la renta', 38000, '2026-12-01',
   'Lagos del Sol, Cancún', NULL, 'Lagos del Sol', 'lagos-del-sol', 'Lagos del Sol, Cancún, Quintana Roo',
   'disponible', 'publicada', pg_temp.u('diego@zugar.example'), '2026-10-01'),
  ('ZUG-011', 'casa-kanan', 'Casa Kanán', 'Casa',
   'Fachada blanca con detalles de madera, en un residencial con áreas verdes.',
   'venta', 4150000, 3, 3, 190, 170, 2, 2, 'Sin amueblar', TRUE, '$1,900 MXN al mes', NULL, '2026-10-15',
   'Residencial Arbolada, Cancún', NULL, 'Residencial Arbolada', 'arbolada', 'Residencial Arbolada, Cancún, Quintana Roo',
   'disponible', 'publicada', pg_temp.u('mariana@zugar.example'), '2026-10-08'),
  ('ZUG-HUA-024', 'casa-huayacan', 'Casa con jardín en Huayacán', 'Casa en condominio',
   'Estrena una casa pensada para disfrutar en familia. Sus dos niveles conectan espacios luminosos, acabados en madera cálida y un jardín privado para tus tardes al aire libre.',
   'venta', 3900000, 3, 3, 140, 124, 2, 0, 'Sin amueblar', TRUE, '$1,800 MXN al mes', NULL, '2026-10-13',
   'Av. Huayacán, Cancún, Benito Juárez, Quintana Roo', 'Av. Huayacán', 'Huayacán', 'huayacan', 'Avenida Huayacán, Cancún, Quintana Roo',
   'disponible', 'publicada', pg_temp.u('mariana@zugar.example'), '2026-10-13'),
  ('ZUG-012', 'casa-las-palmas', 'Casa Las Palmas', 'Casa',
   'Casa de cinco habitaciones con alberca y jardín, en una zona tranquila de Isla Dorada.',
   'renta', 12000, 5, 3, 260, 300, 2, 7, 'Sin amueblar', TRUE, 'Incluido en la renta', 12000, '2026-07-01',
   'Isla Dorada, Cancún, Quintana Roo', NULL, 'Isla Dorada', 'isla-dorada', 'Isla Dorada, Cancún, Quintana Roo',
   'rentada', 'pausada', pg_temp.u('mariana@zugar.example'), '2026-06-10');

INSERT INTO property_photos (property_id, storage_key, label, position) VALUES
  (pg_temp.p('ZUG-001'), 'casa-ceiba.jpg', 'Fachada', 0),
  (pg_temp.p('ZUG-001'), 'casa-ceiba-cocina.jpg', 'Cocina', 1),
  (pg_temp.p('ZUG-001'), 'casa-ceiba-recamara.jpg', 'Recámara', 2),
  (pg_temp.p('ZUG-002'), 'casa-del-patio.jpg', 'Patio', 0),
  (pg_temp.p('ZUG-003'), 'casa-olivo.jpg', 'Fachada', 0),
  (pg_temp.p('ZUG-004'), 'casa-de-la-luz.jpg', 'Fachada', 0),
  (pg_temp.p('ZUG-005'), 'casa-nativa.jpg', 'Alberca', 0),
  (pg_temp.p('ZUG-007'), 'casa-zapote.jpg', 'Fachada', 0),
  (pg_temp.p('ZUG-008'), 'casa-chaka.jpg', 'Fachada', 0),
  (pg_temp.p('ZUG-009'), 'casa-ramon.jpg', 'Fachada', 0),
  (pg_temp.p('ZUG-010'), 'casa-huano.jpg', 'Alberca', 0),
  (pg_temp.p('ZUG-011'), 'casa-kanan.jpg', 'Fachada', 0),
  (pg_temp.p('ZUG-HUA-024'), 'huayacan-01.jpg', 'Sala y comedor', 0),
  (pg_temp.p('ZUG-HUA-024'), 'huayacan-02.jpg', 'Cocina', 1),
  (pg_temp.p('ZUG-HUA-024'), 'huayacan-03.jpg', 'Recámara principal', 2),
  (pg_temp.p('ZUG-HUA-024'), 'huayacan-04.jpg', 'Alberca de la casa club', 3),
  (pg_temp.p('ZUG-012'), 'casa-las-palmas.jpg', 'Fachada', 0);

INSERT INTO property_amenities (property_id, name, position)
SELECT pg_temp.p(code), a.name, a.ord - 1
FROM (VALUES
  ('ZUG-001', ARRAY['Jardín privado', 'Cocina integral', 'Acceso controlado 24/7', 'Se aceptan mascotas']),
  ('ZUG-002', ARRAY['Jardín privado', 'Cocina integral', 'Acceso controlado 24/7', 'Terraza', 'Casa club']),
  ('ZUG-003', ARRAY['Cocina integral', 'Terraza']),
  ('ZUG-004', ARRAY['Alberca', 'Jardín privado', 'Casa club', 'Acceso controlado 24/7', 'Terraza']),
  ('ZUG-005', ARRAY['Alberca', 'Amueblada', 'Se aceptan mascotas', 'Acceso controlado 24/7', 'Terraza']),
  ('ZUG-006', ARRAY['Jardín privado', 'Cocina integral']),
  ('ZUG-008', ARRAY['Jardín privado', 'Se aceptan mascotas']),
  ('ZUG-009', ARRAY['Terraza', 'Se aceptan mascotas']),
  ('ZUG-010', ARRAY['Alberca', 'Terraza']),
  ('ZUG-011', ARRAY['Jardín privado', 'Se aceptan mascotas', 'Acceso controlado 24/7']),
  ('ZUG-HUA-024', ARRAY['Alberca en casa club', 'Jardín privado', 'Casa club', 'Acceso controlado 24/7', 'Se aceptan mascotas', 'Cocina integral']),
  ('ZUG-012', ARRAY['Alberca', 'Jardín privado', 'Se aceptan mascotas'])
) AS t(code, names)
CROSS JOIN LATERAL unnest(t.names) WITH ORDINALITY AS a(name, ord);

-- ---------- Clientes e inquilinos (los 8 del panel + Laura Mendez) ----------
INSERT INTO clients (user_id, kind, label, name, email, phone, nationality, occupation, operation, budget, budget_amount, needs,
  has_pets, pets_count, occupants, follow_status, property_id, broker_id) VALUES
  (NULL, 'cliente', NULL, 'Ana García López', 'ana@example.com', '998 000 0123', 'Mexicana', 'Diseño de interiores', 'Renta', '$30,000 MXN / mes', 30000, '3 recámaras · 2 personas · 1 perro pequeño', TRUE, 1, 2, 'Visita confirmada', pg_temp.p('ZUG-001'), pg_temp.u('mariana@zugar.example')),
  (NULL, 'cliente', NULL, 'Jorge Ramírez', 'jorge.r@example.com', '998 555 0124', 'Mexicana', 'Ingeniería civil', 'Compra', '$5,000,000 MXN', 5000000, '3 recámaras · 4 personas · Sin mascotas', FALSE, 0, 4, 'Por confirmar', pg_temp.p('ZUG-002'), pg_temp.u('diego@zugar.example')),
  (NULL, 'cliente', NULL, 'Sofía Martínez', 'sofia.m@example.com', '998 555 0125', 'Mexicana', 'Medicina', 'Renta', '$36,000 MXN / mes', 36000, '3 recámaras · 3 personas · 1 gato', TRUE, 1, 3, 'Visita confirmada', pg_temp.p('ZUG-005'), pg_temp.u('mariana@zugar.example')),
  (NULL, 'inquilino', 'Inquilina', 'Carolina Pérez', 'carolina.p@example.com', '998 555 0126', 'Mexicana', 'Hotelería', 'Renta', '$22,500 MXN / mes', 22500, 'Contrato compartido · 2 personas', FALSE, 0, 2, 'Contrato vigente', pg_temp.p('ZUG-003'), pg_temp.u('valeria@zugar.example')),
  (NULL, 'cliente', NULL, 'Andrés Torres', 'andres.t@example.com', '998 555 0127', 'Mexicana', 'Empresario', 'Compra', '$6,500,000 MXN', 6500000, '4 recámaras · 5 personas · 2 perros', TRUE, 2, 5, 'Reservada', pg_temp.p('ZUG-004'), pg_temp.u('diego@zugar.example')),
  (NULL, 'cliente', NULL, 'Laura Medina', 'laura.m@example.com', '998 555 0128', 'Colombiana', 'Arquitectura', 'Renta', '$32,000 MXN / mes', 32000, '3 recámaras · 2 personas · Sin mascotas', FALSE, 0, 2, 'En seguimiento', pg_temp.p('ZUG-005'), pg_temp.u('mariana@zugar.example')),
  (NULL, 'inquilino', NULL, 'Miguel Castillo', 'miguel.c@example.com', '998 555 0129', 'Mexicana', 'Gastronomía', 'Renta', '$22,500 MXN / mes', 22500, 'Contrato compartido · 2 personas', FALSE, 0, 2, 'Contrato vigente', pg_temp.p('ZUG-003'), pg_temp.u('valeria@zugar.example')),
  (NULL, 'cliente', NULL, 'Elena Ruiz', 'elena.r@example.com', '998 555 0130', 'Mexicana', 'Docencia', 'Compra', '$3,500,000 MXN', 3500000, '3 recámaras · 3 personas · Sin mascotas', FALSE, 0, 3, 'Nuevo contacto', pg_temp.p('ZUG-006'), pg_temp.u('valeria@zugar.example')),
  (pg_temp.u('lau.mendez@correo.com'), 'inquilino', 'Inquilina', 'Laura Mendez', 'lau.mendez@correo.com', '+52 998 000 0000', 'Mexicana', NULL, 'Renta', '$12,000 MXN / mes', 12000, '5 habitaciones · 3 inquilinos · 1 mascota', TRUE, 1, 3, 'Contrato vigente', pg_temp.p('ZUG-012'), pg_temp.u('mariana@zugar.example'));

-- ---------- Expediente y documentos de Casa Las Palmas ----------
INSERT INTO dossiers (property_id) VALUES (pg_temp.p('ZUG-012')), (pg_temp.p('ZUG-003'));

INSERT INTO documents (property_id, type, name, description, storage_key, mime, size, visible_to_client, uploaded_by) VALUES
  (pg_temp.p('ZUG-012'), 'contract',       'Contrato de renta',      'Vigente hasta 30 jun 2027',                         'dossiers/ZUG-012/contrato-renta.pdf',          'application/pdf', 482133, TRUE,  pg_temp.u('mariana@zugar.example')),
  (pg_temp.p('ZUG-012'), 'deposit',        'Depósito en garantía',   '$12,000 · 01 jul · comprobante',                    'dossiers/ZUG-012/deposito-garantia.pdf',       'application/pdf', 120554, TRUE,  pg_temp.u('mariana@zugar.example')),
  (pg_temp.p('ZUG-012'), 'delivery_sheet', 'Ficha de entrega',       'Entregado el 01 jul · 12 fotos · llaves y estado',  'dossiers/ZUG-012/ficha-entrega.pdf',           'application/pdf', 2843120, TRUE, pg_temp.u('mariana@zugar.example')),
  (pg_temp.p('ZUG-012'), 'rules',          'Reglamento',             'Reglamento de la casa',                             'dossiers/ZUG-012/reglamento.pdf',              'application/pdf', 98211, TRUE,   pg_temp.u('mariana@zugar.example')),
  (pg_temp.p('ZUG-012'), 'annex',          'Anexo A · Inventario',   'Inventario de muebles y equipos',                   'dossiers/ZUG-012/anexo-a-inventario.pdf',      'application/pdf', 154002, TRUE,  pg_temp.u('mariana@zugar.example')),
  (pg_temp.p('ZUG-012'), 'annex',          'Anexo B · Uso de alberca', 'Horarios y cuidados de la alberca',               'dossiers/ZUG-012/anexo-b-alberca.pdf',         'application/pdf', 76450, TRUE,   pg_temp.u('mariana@zugar.example')),
  (pg_temp.p('ZUG-012'), 'other',          'Identificación del aval', 'Uso interno',                                      'dossiers/ZUG-012/identificacion-aval.pdf',     'application/pdf', 210330, FALSE, pg_temp.u('mariana@zugar.example'));

-- ---------- Contratos y pagarés ----------
INSERT INTO contracts (property_id, client_id, start_date, end_date, monthly_rent, payment_day, deposit, status, document_id) VALUES
  (pg_temp.p('ZUG-012'), pg_temp.c('lau.mendez@correo.com'), '2026-07-01', '2027-06-30', 12000, 5, 12000, 'active',
   (SELECT id FROM documents WHERE storage_key = 'dossiers/ZUG-012/contrato-renta.pdf')),
  (pg_temp.p('ZUG-003'), pg_temp.c('carolina.p@example.com'), '2026-06-01', '2027-05-31', 22500, 1, 22500, 'active', NULL);

UPDATE documents SET contract_id = (SELECT id FROM contracts WHERE property_id = pg_temp.p('ZUG-012'))
WHERE storage_key = 'dossiers/ZUG-012/contrato-renta.pdf';

-- 12 pagarés por contrato, uno por mes desde el inicio, el día de pago del contrato.
INSERT INTO promissory_notes (contract_id, number, amount, due_date, status)
SELECT ct.id, n, ct.monthly_rent,
       make_date(EXTRACT(YEAR FROM ct.start_date)::INT, EXTRACT(MONTH FROM ct.start_date)::INT, ct.payment_day) + make_interval(months => n - 1),
       'pending'
FROM contracts ct CROSS JOIN generate_series(1, 12) AS n;

-- Laura: pagados julio a octubre. Casa Olivo: pagados junio a octubre.
UPDATE promissory_notes pn SET status = 'paid', paid_at = ((pn.due_date - 2) + TIME '11:00') AT TIME ZONE 'America/Cancun'
FROM contracts ct
WHERE pn.contract_id = ct.id AND pn.due_date < DATE '2026-11-01';

INSERT INTO payments (promissory_note_id, amount, paid_at, receipt_folio, notes, registered_by)
SELECT pn.id, pn.amount, pn.paid_at,
       'REC-' || pr.code || '-' || lpad(pn.number::TEXT, 2, '0'),
       'Pago en efectivo en la propiedad',
       pr.broker_id
FROM promissory_notes pn
JOIN contracts ct ON ct.id = pn.contract_id
JOIN properties pr ON pr.id = ct.property_id
WHERE pn.status = 'paid';

-- Comprobantes de los pagarés pagados de Laura (visibles para ella).
INSERT INTO documents (property_id, type, name, description, storage_key, mime, size, visible_to_client, uploaded_by, promissory_note_id)
SELECT ct.property_id, 'proof', 'Comprobante pagaré ' || lpad(pn.number::TEXT, 2, '0'), 'Pago en efectivo · ' || to_char(pn.due_date, 'DD/MM/YYYY'),
       'dossiers/ZUG-012/comprobante-pagare-' || lpad(pn.number::TEXT, 2, '0') || '.pdf', 'application/pdf', 64000, TRUE,
       pg_temp.u('mariana@zugar.example'), pn.id
FROM promissory_notes pn JOIN contracts ct ON ct.id = pn.contract_id
WHERE ct.property_id = pg_temp.p('ZUG-012') AND pn.status = 'paid';

-- ---------- Servicios y recibos de Casa Las Palmas ----------
INSERT INTO utility_services (property_id, type, provider_name, account_number) VALUES
  (pg_temp.p('ZUG-012'), 'electricity', 'CFE', '402 180 556 901'),
  (pg_temp.p('ZUG-012'), 'water', 'Aguakan', '0077 3391 0215');

INSERT INTO receipts (utility_service_id, property_id, kind, concept, period_start, period_end, amount, due_date, paid_at, status) VALUES
  ((SELECT id FROM utility_services WHERE account_number = '402 180 556 901'), pg_temp.p('ZUG-012'), 'bill', 'Recibo de luz',  '2026-09-01', '2026-10-31', 1840, '2026-11-12', NULL, 'pending'),
  ((SELECT id FROM utility_services WHERE account_number = '402 180 556 901'), pg_temp.p('ZUG-012'), 'bill', 'Recibo de luz',  '2026-07-01', '2026-08-31', 2215, '2026-09-12', '2026-09-08 12:00-05', 'paid'),
  ((SELECT id FROM utility_services WHERE account_number = '0077 3391 0215'),  pg_temp.p('ZUG-012'), 'bill', 'Recibo de agua', '2026-10-01', '2026-10-31',  412, '2026-11-15', '2026-10-30 10:30-05', 'paid'),
  ((SELECT id FROM utility_services WHERE account_number = '0077 3391 0215'),  pg_temp.p('ZUG-012'), 'bill', 'Recibo de agua', '2026-09-01', '2026-09-30',  398, '2026-10-15', '2026-10-10 10:30-05', 'paid'),
  (NULL, pg_temp.p('ZUG-012'), 'charge_slip', 'Ficha de cobro · 3 oct', NULL, NULL, 12000, '2026-10-05', '2026-10-03 11:00-05', 'paid');

-- ---------- Proveedores, mantenimiento y gastos ----------
INSERT INTO providers (name, specialty, phone, email, zone, notes) VALUES
  ('Plomería Caribe',   'Plomería',     '+52 998 555 0201', 'contacto@plomeriacaribe.example', 'Cancún centro y Huayacán', 'Atiende urgencias en fin de semana'),
  ('Electro Sureste',   'Electricidad', '+52 998 555 0202', 'servicio@electrosureste.example', 'Todo Cancún', NULL),
  ('Albercas Nichupté', 'Albercas',     '+52 998 555 0203', 'hola@albercasnichupte.example',   'Zona sur', 'Mantenimiento mensual');

INSERT INTO maintenance_reports (property_id, client_id, title, description, category, priority, status, provider_id, closed_at, created_at) VALUES
  (pg_temp.p('ZUG-012'), pg_temp.c('lau.mendez@correo.com'), 'Fuga en el baño',
   'Gotea la llave del lavabo del baño principal y se humedece el mueble.', 'Plomería', 'high', 'in_repair',
   (SELECT id FROM providers WHERE name = 'Plomería Caribe'), NULL, '2026-10-14 09:20-05'),
  (pg_temp.p('ZUG-012'), pg_temp.c('lau.mendez@correo.com'), 'Foco de la sala',
   'Desde el martes pasado no funciona el foco de la sala.', 'Electricidad', 'low', 'resolved',
   (SELECT id FROM providers WHERE name = 'Electro Sureste'), '2026-10-12 13:00-05', '2026-10-07 19:45-05');

INSERT INTO maintenance_updates (report_id, status, comment, user_id, created_at)
SELECT r.id, x.status::maintenance_status, x.comment, pg_temp.u(x.who), x.at::TIMESTAMPTZ
FROM maintenance_reports r
JOIN (VALUES
  ('Fuga en el baño', 'reported',  'Reporte creado desde la app.',                        'lau.mendez@correo.com', '2026-10-14 09:20-05'),
  ('Fuga en el baño', 'in_review', 'Revisamos las fotos y agendamos al plomero.',          'mariana@zugar.example', '2026-10-15 10:05-05'),
  ('Fuga en el baño', 'in_repair', 'Plomería Caribe cambiará la llave de paso el lunes.',  'mariana@zugar.example', '2026-10-17 16:40-05'),
  ('Foco de la sala', 'reported',  'Reporte creado desde la app.',                        'lau.mendez@correo.com', '2026-10-07 19:45-05'),
  ('Foco de la sala', 'in_repair', 'Electro Sureste revisará el apagador.',                'mariana@zugar.example', '2026-10-09 09:30-05'),
  ('Foco de la sala', 'resolved',  'Se cambiaron el foco y el apagador.',                  'mariana@zugar.example', '2026-10-12 13:00-05')
) AS x(title, status, comment, who, at) ON x.title = r.title;

INSERT INTO maintenance_photos (report_id, stage, storage_key)
SELECT r.id, x.stage::photo_stage, x.key FROM maintenance_reports r
JOIN (VALUES
  ('Fuga en el baño', 'before', 'maintenance/ZUG-012/fuga-bano-antes-1.jpg'),
  ('Fuga en el baño', 'before', 'maintenance/ZUG-012/fuga-bano-antes-2.jpg'),
  ('Foco de la sala', 'before', 'maintenance/ZUG-012/foco-sala-antes.jpg'),
  ('Foco de la sala', 'after',  'maintenance/ZUG-012/foco-sala-despues.jpg')
) AS x(title, stage, key) ON x.title = r.title;

INSERT INTO expenses (property_id, provider_id, report_id, concept, amount, date, status, next_maintenance_date, notes) VALUES
  (pg_temp.p('ZUG-012'), (SELECT id FROM providers WHERE name = 'Electro Sureste'), (SELECT id FROM maintenance_reports WHERE title = 'Foco de la sala'),
   'Cambio de foco y apagador', 350, '2026-10-12', 'paid', NULL, NULL),
  (pg_temp.p('ZUG-012'), (SELECT id FROM providers WHERE name = 'Plomería Caribe'), (SELECT id FROM maintenance_reports WHERE title = 'Fuga en el baño'),
   'Cambio de llave de paso del baño', 1200, '2026-10-19', 'pending', NULL, 'Se paga al terminar'),
  (pg_temp.p('ZUG-012'), (SELECT id FROM providers WHERE name = 'Albercas Nichupté'), NULL,
   'Mantenimiento de alberca', 900, '2026-10-15', 'paid', '2026-11-15', 'Servicio mensual');

-- ---------- Solicitudes del sitio web ----------
INSERT INTO leads (folio, reason, name, email, phone, message, property_id, preferred_date, preferred_time, payload, status, client_id, created_at) VALUES
  ('Z-10418', 'visita', 'Ana García López', 'ana@example.com', '998 000 0123', 'Nos gustaría conocer el patio y la iluminación de la casa por la mañana.',
   pg_temp.p('ZUG-001'), '2026-10-24', '10:00',
   '{"nacionalidad":"Mexicana","ocupacion":"Diseño de interiores","presupuesto":"$30,000 MXN / mes","personas":"2","mascotas":"si","mascotas_detalle":"1 perro pequeño"}',
   'cerrado', pg_temp.c('ana@example.com'), '2026-10-18 20:10-05'),
  ('Z-10425', 'publicar', 'Roberto Alcalá', 'roberto.a@example.com', '998 555 0140', 'Quiero rentar mi casa en Residencial Cumbres.',
   NULL, NULL, NULL,
   '{"inmueble_tipo":"casa","inmueble_operacion":"renta","inmueble_zona":"Residencial Cumbres","inmueble_recamaras":"3","inmueble_precio":"$25,000"}',
   'nuevo', NULL, '2026-10-20 08:12-05');

-- ---------- Citas (las 5 del panel + la de Laura) ----------
INSERT INTO appointments (code, property_id, client_id, broker_id, scheduled_at, status, note, confirmed_by, lead_id) VALUES
  ('CIT-020', pg_temp.p('ZUG-004'), pg_temp.c('andres.t@example.com'),  pg_temp.u('diego@zugar.example'),   '2026-10-20 09:00-05', 'realizada',     NULL, NULL, NULL),
  ('CIT-021', pg_temp.p('ZUG-005'), pg_temp.c('laura.m@example.com'),   pg_temp.u('mariana@zugar.example'), '2026-10-21 16:00-05', 'cancelada',     'Pidió reprogramar para noviembre.', NULL, NULL),
  ('CIT-024', pg_temp.p('ZUG-001'), pg_temp.c('ana@example.com'),       pg_temp.u('mariana@zugar.example'), '2026-10-24 10:00-05', 'confirmada',    'Nos gustaría conocer el patio y la iluminación de la casa por la mañana.', 'Confirmada por Mariana · 20 oct., 08:45 h.', (SELECT id FROM leads WHERE folio = 'Z-10418')),
  ('CIT-025', pg_temp.p('ZUG-002'), pg_temp.c('jorge.r@example.com'),   pg_temp.u('diego@zugar.example'),   '2026-10-24 12:30-05', 'por-confirmar', 'Quiere revisar la terraza y el estado de la cocina.', NULL, NULL),
  ('CIT-026', pg_temp.p('ZUG-005'), pg_temp.c('sofia.m@example.com'),   pg_temp.u('mariana@zugar.example'), '2026-10-25 11:00-05', 'confirmada',    'Viene con su pareja; preguntan por el reglamento de mascotas.', 'Confirmada por Mariana · 19 oct., 18:10 h.', NULL),
  ('CIT-019', pg_temp.p('ZUG-012'), pg_temp.c('lau.mendez@correo.com'), pg_temp.u('mariana@zugar.example'), '2026-10-22 17:00-05', 'confirmada',    'Revisión de la fuga del baño con el plomero.', 'Confirmada por Mariana · 18 oct., 12:00 h.', NULL);

INSERT INTO appointment_messages (appointment_id, sender_id, body, created_at) VALUES
  ((SELECT id FROM appointments WHERE code = 'CIT-019'), pg_temp.u('mariana@zugar.example'), 'Tu cita en Casa Las Palmas es el jueves 22 de octubre a las 5:00 pm.', '2026-10-18 12:00-05'),
  ((SELECT id FROM appointments WHERE code = 'CIT-019'), pg_temp.u('lau.mendez@correo.com'), 'Sí, ahí estaré. Gracias', '2026-10-18 12:20-05');

-- ---------- Notificaciones de Laura ----------
INSERT INTO notifications (user_id, type, title, message, entity, entity_id, read, sent_at) VALUES
  (pg_temp.u('lau.mendez@correo.com'), 'promissory_note_due', 'Pagaré próximo a vencer', 'Tu pagaré 05 de $12,000 vence el 5 de noviembre.', 'promissory_note',
   (SELECT pn.id FROM promissory_notes pn JOIN contracts ct ON ct.id = pn.contract_id WHERE ct.property_id = pg_temp.p('ZUG-012') AND pn.number = 5), FALSE, '2026-10-20 08:00-05'),
  (pg_temp.u('lau.mendez@correo.com'), 'maintenance_status', 'Tu reporte está en reparación', 'Fuga en el baño: Plomería Caribe cambiará la llave de paso el lunes.', 'maintenance_report',
   (SELECT id FROM maintenance_reports WHERE title = 'Fuga en el baño'), FALSE, '2026-10-17 16:40-05'),
  (pg_temp.u('lau.mendez@correo.com'), 'appointment_confirmed', 'Cita confirmada', 'Tu cita en Casa Las Palmas es el jueves 22 de octubre a las 5:00 pm.', 'appointment',
   (SELECT id FROM appointments WHERE code = 'CIT-019'), TRUE, '2026-10-18 12:00-05'),
  (pg_temp.u('lau.mendez@correo.com'), 'payment_registered', 'Pago registrado', 'Registramos tu pago del pagaré 04 por $12,000.', 'promissory_note',
   (SELECT pn.id FROM promissory_notes pn JOIN contracts ct ON ct.id = pn.contract_id WHERE ct.property_id = pg_temp.p('ZUG-012') AND pn.number = 4), TRUE, '2026-10-03 11:05-05');

-- ---------- Historial (actividad del panel) ----------
INSERT INTO activity_log (user_id, property_id, entity, entity_id, action, description, created_at) VALUES
  (pg_temp.u('lucia@zugar.example'),   pg_temp.p('ZUG-001'), 'property',    pg_temp.p('ZUG-001'), 'create',  'Lucía Méndez creó la propiedad y asignó a Mariana Solís.', '2026-10-12 17:05-05'),
  (pg_temp.u('mariana@zugar.example'), pg_temp.p('ZUG-001'), 'property',    pg_temp.p('ZUG-001'), 'publish', 'Propiedad publicada en el catálogo público.',               '2026-10-13 10:30-05'),
  (pg_temp.u('diego@zugar.example'),   pg_temp.p('ZUG-004'), 'property',    pg_temp.p('ZUG-004'), 'status',  'Diego marcó Casa de la Luz como reservada.',                 '2026-10-19 16:20-05'),
  (pg_temp.u('mariana@zugar.example'), pg_temp.p('ZUG-001'), 'appointment', (SELECT id FROM appointments WHERE code = 'CIT-024'), 'confirm', 'Mariana confirmó la visita de Ana a Casa Ceiba.', '2026-10-20 08:45-05');
