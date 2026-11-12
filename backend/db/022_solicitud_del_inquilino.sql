-- Quien ya renta la casa no sigue con una solicitud abierta de esa misma casa.
UPDATE leads l
   SET status = 'cerrado'
  FROM contracts c
 WHERE c.status = 'active'
   AND c.property_id = l.property_id
   AND c.client_id = l.client_id
   AND l.status <> 'cerrado';
