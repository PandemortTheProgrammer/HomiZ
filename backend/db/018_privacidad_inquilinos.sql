-- Privacidad entre inquilinos de una misma casa: cada documento personal queda ligado al contrato en que se subió.
-- (Reglamento, anexos y fotos son de la casa y no se ligan.) Solo se completa donde falta; no borra nada.
UPDATE documents d
   SET contract_id = ct.id
  FROM contracts ct
 WHERE d.contract_id IS NULL
   AND d.promissory_note_id IS NULL
   AND d.type NOT IN ('rules', 'annex', 'photo')
   AND ct.property_id = d.property_id
   AND d.created_at >= ct.created_at - interval '1 day'
   AND d.created_at::date <= ct.end_date;

-- Quien quedó como «inquilino» sin contrato vigente vuelve a cliente (marcarlo a mano ya no da acceso a la casa)
UPDATE clients c
   SET kind = 'cliente',
       follow_status = CASE WHEN c.follow_status = 'Contrato vigente' THEN 'En seguimiento' ELSE c.follow_status END
 WHERE c.kind = 'inquilino'
   AND NOT EXISTS (SELECT 1 FROM contracts ct WHERE ct.client_id = c.id AND ct.status = 'active');

CREATE INDEX IF NOT EXISTS documents_contract_idx ON documents (contract_id);
