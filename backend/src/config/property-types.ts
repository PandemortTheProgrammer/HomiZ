/* Tipos de inmueble: nombre que se guarda en properties.type y clave que usa el sitio (?tipo=departamento). */
export const PROPERTY_TYPES = [
  { key: 'casa', label: 'Casa', group: 'Residencial' },
  { key: 'casa-condominio', label: 'Casa en condominio', group: 'Residencial' },
  { key: 'townhouse', label: 'Townhouse', group: 'Residencial' },
  { key: 'departamento', label: 'Departamento', group: 'Residencial' },
  { key: 'estudio', label: 'Estudio', group: 'Residencial' },
  { key: 'loft', label: 'Loft', group: 'Residencial' },
  { key: 'penthouse', label: 'Penthouse', group: 'Residencial' },
  { key: 'villa', label: 'Villa', group: 'Residencial' },
  { key: 'cuarto', label: 'Cuarto', group: 'Residencial' },
  { key: 'local', label: 'Local comercial', group: 'Comercial' },
  { key: 'oficina', label: 'Oficina', group: 'Comercial' },
  { key: 'consultorio', label: 'Consultorio', group: 'Comercial' },
  { key: 'bodega', label: 'Bodega', group: 'Comercial' },
  { key: 'nave-industrial', label: 'Nave industrial', group: 'Comercial' },
  { key: 'edificio', label: 'Edificio', group: 'Comercial' },
  { key: 'hotel', label: 'Hotel', group: 'Comercial' },
  { key: 'terreno', label: 'Terreno', group: 'Terrenos' },
  { key: 'terreno-comercial', label: 'Terreno comercial', group: 'Terrenos' },
  { key: 'rancho', label: 'Rancho o quinta', group: 'Terrenos' },
] as const;

export const TYPE_LABELS = PROPERTY_TYPES.map((t) => t.label) as unknown as [string, ...string[]];
export const TYPE_KEYS = PROPERTY_TYPES.map((t) => t.key) as unknown as [string, ...string[]];

/** Nombres guardados que corresponden a una clave del sitio («casa» incluye las casas en condominio). */
export function labelsForKey(key: string): string[] {
  if (key === 'casa') return ['Casa', 'Casa en condominio'];
  const t = PROPERTY_TYPES.find((x) => x.key === key);
  return t ? [t.label] : [];
}
