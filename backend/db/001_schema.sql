-- =============================================================================
-- Homiz (Rentia) · Esquema de base de datos · PostgreSQL 13+
-- Los nombres y estados de propiedades, citas y solicitudes siguen al sitio
-- existente (ver docs/decisiones.md). El script es re-ejecutable: borra y crea.
-- ⚠️ Borra TODO el esquema public: ejecútalo solo sobre la base dedicada "homiz".
-- =============================================================================

DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- ---------- Tipos ----------
CREATE TYPE user_type            AS ENUM ('client', 'staff');
CREATE TYPE property_operation   AS ENUM ('renta', 'venta');
CREATE TYPE property_status      AS ENUM ('disponible', 'reservada', 'rentada', 'vendida', 'borrador');
CREATE TYPE property_visibility  AS ENUM ('publicada', 'pausada', 'borrador');
CREATE TYPE client_kind          AS ENUM ('cliente', 'inquilino');
CREATE TYPE lead_reason          AS ENUM ('visita', 'rentar', 'comprar', 'publicar', 'otro');
CREATE TYPE lead_status          AS ENUM ('nuevo', 'en_seguimiento', 'cerrado');
CREATE TYPE appointment_status   AS ENUM ('por-confirmar', 'confirmada', 'rechazada', 'cancelada', 'realizada');
CREATE TYPE contract_status      AS ENUM ('active', 'finished', 'cancelled');
CREATE TYPE note_status          AS ENUM ('pending', 'paid', 'overdue');
CREATE TYPE utility_type         AS ENUM ('electricity', 'water');
CREATE TYPE receipt_kind         AS ENUM ('bill', 'charge_slip');
CREATE TYPE receipt_status       AS ENUM ('pending', 'paid', 'overdue');
CREATE TYPE maintenance_priority AS ENUM ('low', 'medium', 'high');
CREATE TYPE maintenance_status   AS ENUM ('reported', 'in_review', 'in_repair', 'resolved', 'cancelled');
CREATE TYPE photo_stage          AS ENUM ('before', 'after');
CREATE TYPE expense_status       AS ENUM ('pending', 'paid');
CREATE TYPE document_type        AS ENUM ('contract', 'deposit', 'delivery_sheet', 'rules', 'annex', 'receipt', 'proof', 'photo', 'other');
CREATE TYPE device_platform      AS ENUM ('android', 'ios', 'web');

-- ---------- Usuarios, roles y permisos ----------
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  email           TEXT NOT NULL,
  phone           TEXT,
  birth_date      DATE,
  password_hash   TEXT NOT NULL,
  type            user_type NOT NULL,
  initials        TEXT,
  photo_key       TEXT,
  zones           TEXT,               -- zonas que atiende (brokers)
  specialty       TEXT,               -- p. ej. "Rentas · Arbolada y Aqua"
  active          BOOLEAN NOT NULL DEFAULT TRUE,
  failed_attempts INT NOT NULL DEFAULT 0,
  locked_until    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX users_email_unique ON users (lower(email));

CREATE TABLE roles (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code        TEXT NOT NULL UNIQUE,     -- 'broker' | 'admin'
  name        TEXT NOT NULL
);

CREATE TABLE permissions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code        TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL
);

CREATE TABLE user_roles (
  user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES roles (id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE role_permissions (
  role_id       UUID NOT NULL REFERENCES roles (id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES permissions (id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE refresh_tokens (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX refresh_tokens_user_idx ON refresh_tokens (user_id);

CREATE TABLE password_resets (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  used_at    TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Verdadero si el usuario tiene el rol indicado (para reglas de integridad).
CREATE FUNCTION user_has_role(p_user UUID, p_role TEXT) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_roles ur JOIN roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_user AND r.code = p_role
  );
$$;

-- ---------- Propiedades ----------
CREATE TABLE properties (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code           TEXT NOT NULL UNIQUE,          -- clave legible: ZUG-001
  slug           TEXT NOT NULL UNIQUE,          -- ficha pública: casa-ceiba
  name           TEXT NOT NULL,
  type           TEXT NOT NULL DEFAULT 'Casa',  -- Casa | Casa en condominio | Townhouse
  description    TEXT NOT NULL DEFAULT '',
  operation      property_operation NOT NULL,
  price          NUMERIC(12,2) NOT NULL CHECK (price >= 0),
  rec            NUMERIC(3,1) NOT NULL CHECK (rec >= 0),     -- recámaras
  banos          NUMERIC(3,1) NOT NULL CHECK (banos >= 0),   -- admite medios baños
  m2             NUMERIC(8,2),                               -- construcción
  terreno        NUMERIC(8,2),
  est            INT NOT NULL DEFAULT 0,                     -- estacionamientos
  age            INT,                                        -- antigüedad en años
  furnished      TEXT NOT NULL DEFAULT 'Sin amueblar',       -- Sin amueblar | Semiamueblada | Amueblada
  pets_allowed   BOOLEAN NOT NULL DEFAULT FALSE,
  maintenance    TEXT,                                       -- "Incluido en la renta" o monto
  deposit        NUMERIC(12,2),
  available_from DATE,
  address        TEXT NOT NULL DEFAULT '',
  street         TEXT,
  city           TEXT NOT NULL DEFAULT 'Cancún, Quintana Roo',
  zone           TEXT NOT NULL,                              -- texto visible: Arbolada
  zone_key       TEXT NOT NULL,                              -- filtro del sitio: arbolada
  map_query      TEXT,                                       -- texto q= de Google Maps
  lat            NUMERIC(9,6),
  lng            NUMERIC(9,6),
  status         property_status NOT NULL DEFAULT 'borrador',
  visibility     property_visibility NOT NULL DEFAULT 'borrador',
  broker_id      UUID REFERENCES users (id),
  published_at   DATE,
  active         BOOLEAN NOT NULL DEFAULT TRUE,              -- baja lógica
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT properties_publish_rule CHECK (NOT (status = 'borrador' AND visibility = 'publicada'))
);

-- El broker responsable debe tener el rol broker.
CREATE FUNCTION properties_check_broker() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.broker_id IS NOT NULL AND NOT user_has_role(NEW.broker_id, 'broker') THEN
    RAISE EXCEPTION 'El responsable de la propiedad debe tener rol broker';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER properties_broker_role BEFORE INSERT OR UPDATE OF broker_id ON properties
  FOR EACH ROW EXECUTE FUNCTION properties_check_broker();
CREATE INDEX properties_broker_idx ON properties (broker_id);
CREATE INDEX properties_status_idx ON properties (status, visibility) WHERE active;
CREATE INDEX properties_zone_idx ON properties (zone_key);

CREATE TABLE property_photos (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties (id) ON DELETE CASCADE,
  storage_key TEXT NOT NULL,
  label       TEXT NOT NULL DEFAULT '',
  position    INT NOT NULL DEFAULT 0          -- 0 = portada
);
CREATE INDEX property_photos_property_idx ON property_photos (property_id, position);

-- Amenidades: el panel las administra por propiedad, sin catálogo compartido.
CREATE TABLE property_amenities (
  property_id UUID NOT NULL REFERENCES properties (id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  position    INT NOT NULL DEFAULT 0,
  PRIMARY KEY (property_id, name)
);

-- ---------- Clientes, inquilinos y solicitudes ----------
CREATE TABLE clients (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID UNIQUE REFERENCES users (id),
  kind           client_kind NOT NULL DEFAULT 'cliente',
  label          TEXT,                        -- p. ej. "Inquilina"
  name           TEXT NOT NULL,
  email          TEXT,
  phone          TEXT,
  address        TEXT,
  nationality    TEXT,
  occupation     TEXT,
  operation      TEXT,                        -- Renta | Compra
  budget         TEXT,                        -- "$12,000 MXN / mes"
  budget_amount  NUMERIC(12,2),
  needs          TEXT,                        -- "3 recámaras · 2 personas · 1 perro pequeño"
  has_pets       BOOLEAN NOT NULL DEFAULT FALSE,
  pets_count     INT NOT NULL DEFAULT 0,
  occupants      INT,
  follow_status  TEXT NOT NULL DEFAULT 'Nuevo contacto',
  property_id    UUID REFERENCES properties (id),   -- propiedad de interés o rentada
  broker_id      UUID REFERENCES users (id),
  active         BOOLEAN NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX clients_property_idx ON clients (property_id);
CREATE INDEX clients_broker_idx ON clients (broker_id);

CREATE TABLE leads (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  folio          TEXT NOT NULL UNIQUE,
  reason         lead_reason NOT NULL,
  name           TEXT NOT NULL,
  email          TEXT NOT NULL,
  phone          TEXT,
  message        TEXT,
  property_id    UUID REFERENCES properties (id),
  preferred_date DATE,
  preferred_time TEXT,
  payload        JSONB NOT NULL DEFAULT '{}'::jsonb,   -- campos variables del formulario
  status         lead_status NOT NULL DEFAULT 'nuevo',
  client_id      UUID REFERENCES clients (id),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX leads_status_idx ON leads (status, created_at DESC);
CREATE INDEX leads_property_idx ON leads (property_id);

-- ---------- Documentos y expediente ----------
CREATE TABLE dossiers (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL UNIQUE REFERENCES properties (id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE documents (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id         UUID NOT NULL REFERENCES properties (id),
  type                document_type NOT NULL,
  name                TEXT NOT NULL,
  description         TEXT,
  storage_key         TEXT NOT NULL,
  mime                TEXT NOT NULL,
  size                INT NOT NULL CHECK (size >= 0),
  visible_to_client   BOOLEAN NOT NULL DEFAULT FALSE,
  uploaded_by         UUID REFERENCES users (id),
  contract_id         UUID,
  promissory_note_id  UUID,
  receipt_id          UUID,
  report_id           UUID,
  expense_id          UUID,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX documents_property_idx ON documents (property_id);

-- ---------- Contratos y pagarés ----------
CREATE TABLE contracts (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id  UUID NOT NULL REFERENCES properties (id),
  client_id    UUID NOT NULL REFERENCES clients (id),
  start_date   DATE NOT NULL,
  end_date     DATE NOT NULL,
  monthly_rent NUMERIC(12,2) NOT NULL CHECK (monthly_rent > 0),
  payment_day  INT NOT NULL CHECK (payment_day BETWEEN 1 AND 28),
  deposit      NUMERIC(12,2),
  status       contract_status NOT NULL DEFAULT 'active',
  document_id  UUID REFERENCES documents (id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (end_date > start_date)
);
-- Una propiedad tiene a lo sumo un contrato vigente.
CREATE UNIQUE INDEX contracts_one_active_per_property ON contracts (property_id) WHERE status = 'active';
CREATE INDEX contracts_client_idx ON contracts (client_id);

CREATE TABLE promissory_notes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID NOT NULL REFERENCES contracts (id),
  number      INT NOT NULL,
  amount      NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  due_date    DATE NOT NULL,
  paid_at     TIMESTAMPTZ,
  status      note_status NOT NULL DEFAULT 'pending',
  UNIQUE (contract_id, number)
);
CREATE INDEX promissory_notes_due_idx ON promissory_notes (status, due_date);

CREATE TABLE payments (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  promissory_note_id UUID NOT NULL REFERENCES promissory_notes (id),
  amount             NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  paid_at            TIMESTAMPTZ NOT NULL,
  receipt_folio      TEXT NOT NULL,
  notes              TEXT,
  registered_by      UUID NOT NULL REFERENCES users (id),
  voided             BOOLEAN NOT NULL DEFAULT FALSE,
  void_reason        TEXT,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (NOT voided OR void_reason IS NOT NULL)
);
-- Un pagaré solo tiene un pago vigente (no anulado).
CREATE UNIQUE INDEX payments_one_valid_per_note ON payments (promissory_note_id) WHERE NOT voided;

-- ---------- Citas ----------
CREATE TABLE appointments (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code         TEXT NOT NULL UNIQUE,             -- CIT-024
  property_id  UUID NOT NULL REFERENCES properties (id),
  client_id    UUID NOT NULL REFERENCES clients (id),
  broker_id    UUID REFERENCES users (id),
  scheduled_at TIMESTAMPTZ NOT NULL,
  duration_min INT NOT NULL DEFAULT 45,
  kind         TEXT NOT NULL DEFAULT 'Presencial',
  status       appointment_status NOT NULL DEFAULT 'por-confirmar',
  note         TEXT,                             -- nota del cliente
  reason       TEXT,                             -- motivo de rechazo/cancelación/reprogramación
  proposed_at  TIMESTAMPTZ,                      -- nuevo horario propuesto
  confirmed_by TEXT,
  lead_id      UUID REFERENCES leads (id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX appointments_property_idx ON appointments (property_id);
CREATE INDEX appointments_client_idx ON appointments (client_id);
CREATE INDEX appointments_status_idx ON appointments (status, scheduled_at);
-- No dos citas activas del mismo broker a la misma hora (regla del panel).
CREATE UNIQUE INDEX appointments_broker_slot ON appointments (broker_id, scheduled_at)
  WHERE status IN ('por-confirmar', 'confirmada');

CREATE TABLE appointment_messages (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id UUID NOT NULL REFERENCES appointments (id) ON DELETE CASCADE,
  sender_id      UUID NOT NULL REFERENCES users (id),
  body           TEXT NOT NULL CHECK (length(body) BETWEEN 1 AND 2000),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX appointment_messages_idx ON appointment_messages (appointment_id, created_at);

-- ---------- Servicios de luz y agua ----------
CREATE TABLE utility_services (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id    UUID NOT NULL REFERENCES properties (id),
  type           utility_type NOT NULL,
  provider_name  TEXT NOT NULL,                  -- CFE | Aguakan
  account_number TEXT NOT NULL,
  active         BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX utility_services_property_idx ON utility_services (property_id);

CREATE TABLE receipts (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  utility_service_id UUID REFERENCES utility_services (id),
  property_id        UUID NOT NULL REFERENCES properties (id),
  kind               receipt_kind NOT NULL DEFAULT 'bill',  -- recibo o ficha de cobro
  concept            TEXT NOT NULL,
  period_start       DATE,
  period_end         DATE,
  amount             NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  due_date           DATE,
  paid_at            TIMESTAMPTZ,
  status             receipt_status NOT NULL DEFAULT 'pending',
  document_id        UUID REFERENCES documents (id),
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX receipts_property_idx ON receipts (property_id);
CREATE INDEX receipts_due_idx ON receipts (status, due_date);

-- ---------- Proveedores y mantenimiento ----------
CREATE TABLE providers (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name      TEXT NOT NULL,
  specialty TEXT NOT NULL,
  phone     TEXT,
  email     TEXT,
  zone      TEXT,
  notes     TEXT,
  active    BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE maintenance_reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties (id),
  client_id   UUID REFERENCES clients (id),
  title       TEXT NOT NULL,
  description TEXT NOT NULL,
  category    TEXT NOT NULL,          -- Plomería, Electricidad, Climatización, Cerrajería, Jardín, Otro
  priority    maintenance_priority NOT NULL DEFAULT 'medium',
  status      maintenance_status NOT NULL DEFAULT 'reported',
  provider_id UUID REFERENCES providers (id),
  closed_at   TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX maintenance_reports_property_idx ON maintenance_reports (property_id);
CREATE INDEX maintenance_reports_client_idx ON maintenance_reports (client_id);
CREATE INDEX maintenance_reports_status_idx ON maintenance_reports (status);

CREATE TABLE maintenance_updates (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id  UUID NOT NULL REFERENCES maintenance_reports (id) ON DELETE CASCADE,
  status     maintenance_status NOT NULL,
  comment    TEXT,
  user_id    UUID REFERENCES users (id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX maintenance_updates_report_idx ON maintenance_updates (report_id, created_at);

CREATE TABLE maintenance_photos (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id   UUID NOT NULL REFERENCES maintenance_reports (id) ON DELETE CASCADE,
  stage       photo_stage NOT NULL,
  storage_key TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE expenses (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id           UUID NOT NULL REFERENCES properties (id),
  provider_id           UUID REFERENCES providers (id),
  report_id             UUID REFERENCES maintenance_reports (id),
  concept               TEXT NOT NULL,
  amount                NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  date                  DATE NOT NULL,
  status                expense_status NOT NULL DEFAULT 'pending',
  next_maintenance_date DATE,
  notes                 TEXT,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX expenses_property_idx ON expenses (property_id, date);

-- Llaves opcionales de documentos hacia sus entidades (se declaran al final por el orden de creación).
ALTER TABLE documents
  ADD FOREIGN KEY (contract_id)        REFERENCES contracts (id),
  ADD FOREIGN KEY (promissory_note_id) REFERENCES promissory_notes (id),
  ADD FOREIGN KEY (receipt_id)         REFERENCES receipts (id),
  ADD FOREIGN KEY (report_id)          REFERENCES maintenance_reports (id),
  ADD FOREIGN KEY (expense_id)         REFERENCES expenses (id);

-- ---------- Notificaciones ----------
CREATE TABLE notifications (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id   UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  type      TEXT NOT NULL,
  title     TEXT NOT NULL,
  message   TEXT NOT NULL,
  entity    TEXT,
  entity_id UUID,
  read      BOOLEAN NOT NULL DEFAULT FALSE,
  sent_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX notifications_user_idx ON notifications (user_id, read, sent_at DESC);

CREATE TABLE devices (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  fcm_token  TEXT NOT NULL UNIQUE,
  platform   device_platform NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------- Historial (solo inserción) ----------
CREATE TABLE activity_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users (id),
  property_id UUID REFERENCES properties (id),
  entity      TEXT NOT NULL,
  entity_id   UUID,
  action      TEXT NOT NULL,
  description TEXT,                    -- texto legible para el panel ("Mariana confirmó la visita…")
  old_values  JSONB,
  new_values  JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX activity_log_property_idx ON activity_log (property_id, created_at DESC);
CREATE INDEX activity_log_created_idx ON activity_log (created_at DESC);

CREATE FUNCTION activity_log_append_only() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'El historial es de solo inserción: no se permite %', TG_OP;
END;
$$;
CREATE TRIGGER activity_log_no_update BEFORE UPDATE OR DELETE ON activity_log
  FOR EACH ROW EXECUTE FUNCTION activity_log_append_only();
