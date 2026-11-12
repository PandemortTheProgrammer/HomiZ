-- =============================================================================
-- Homiz · Migración 004 (mapas)
-- Coordenadas APROXIMADAS (centro de la colonia o residencial) de las casas de ejemplo,
-- para que el mapa del sitio tenga marcadores. Solo llena las que no tienen ubicación:
-- si el personal ya pegó el enlace de Google Maps en el panel, no se toca.
-- =============================================================================

UPDATE properties p
   SET lat = c.lat, lng = c.lng, updated_at = now()
  FROM (VALUES
    -- Centros de colonia según OpenStreetMap (Nominatim); las casas de la misma colonia se separan unos metros.
    ('casa-ceiba',       21.0964, -86.8698),  -- Arbolada
    ('casa-kanan',       21.0957, -86.8686),  -- Arbolada
    ('casa-del-patio',   21.1125, -86.8389),  -- Cumbres
    ('casa-ramon',       21.1118, -86.8400),  -- Cumbres
    ('casa-olivo',       21.1315, -86.8559),  -- Santa Fe
    ('casa-de-la-luz',   21.0556, -86.8493),  -- Lagos del Sol
    ('casa-huano',       21.0548, -86.8481),  -- Lagos del Sol
    ('casa-nativa',      21.1072, -86.8564),  -- Av. Huayacán (Aqua no tiene punto propio en OSM)
    ('casa-almendra',    21.1142, -86.8845),  -- Jardines del Sur
    ('casa-zapote',      21.1461, -86.8526),  -- Supermanzana 50
    ('casa-chaka',       21.1186, -86.8455),  -- Av. Huayacán (Palmaris no tiene punto propio en OSM)
    ('casa-huayacan',    21.1147, -86.8494),  -- Avenida Huayacán
    ('casa-las-palmas',  21.1156, -86.7671)   -- Isla Dorada
  ) AS c(slug, lat, lng)
 WHERE p.slug = c.slug
   AND p.lat IS NULL;
