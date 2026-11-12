-- =============================================================================
-- Homiz · Migración 006: PDF del pagaré firmado
-- =============================================================================
-- Cada pagaré puede tener su PDF (documento tipo «promissory_note» ligado con promissory_note_id).
-- Se distingue del comprobante de pago (los demás documentos ligados al pagaré).
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'promissory_note';
