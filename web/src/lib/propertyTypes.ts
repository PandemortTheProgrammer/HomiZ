/* Tipos de inmueble (los mismos que backend/src/config/property-types.ts): clave del sitio y nombre guardado. */
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

export const TYPE_GROUPS = ['Residencial', 'Comercial', 'Terrenos'] as const;
export const TYPE_LABELS: string[] = PROPERTY_TYPES.map((t) => t.label);

export const typeKey = (label: string) => PROPERTY_TYPES.find((t) => t.label === label)?.key ?? 'casa';
export const typeLabel = (key: string) => PROPERTY_TYPES.find((t) => t.key === key)?.label ?? 'Casa';
const PLURAL: Record<string, string> = {
  casa: 'Casas', 'casa-condominio': 'Casas en condominio', townhouse: 'Townhouses', departamento: 'Departamentos', estudio: 'Estudios',
  loft: 'Lofts', penthouse: 'Penthouses', villa: 'Villas', cuarto: 'Cuartos', local: 'Locales comerciales', oficina: 'Oficinas',
  consultorio: 'Consultorios', bodega: 'Bodegas', 'nave-industrial': 'Naves industriales', edificio: 'Edificios', hotel: 'Hoteles',
  terreno: 'Terrenos', 'terreno-comercial': 'Terrenos comerciales', rancho: 'Ranchos y quintas',
};
/** «departamento» → «Departamentos»; sin tipo, «Propiedades» */
export const typePlural = (key: string) => PLURAL[key] ?? 'Propiedades';
export const typeGroup = (key: string) => PROPERTY_TYPES.find((t) => t.key === key)?.group ?? 'Residencial';
/** Terrenos, locales, bodegas… no tienen recámaras: las tarjetas no las muestran */
export const hasRooms = (key: string) => typeGroup(key) === 'Residencial';
/** «casa» del filtro incluye las casas en condominio */
export const typeMatches = (filter: string, key: string) => !filter || key === filter || (filter === 'casa' && key === 'casa-condominio');

/** Etiquetas de mascotas en la ficha y los filtros */
export const PET_OPTIONS: [string, string][] = [['', 'Indistinto'], ['si', 'Acepta mascotas'], ['no', 'No acepta mascotas']];
