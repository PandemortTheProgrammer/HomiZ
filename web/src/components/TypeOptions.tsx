import { PROPERTY_TYPES, TYPE_GROUPS } from '../lib/propertyTypes';

/** <option> de todos los tipos de inmueble, agrupados (Residencial, Comercial, Terrenos). `by` elige el valor: clave o nombre. */
export function TypeOptions({ by = 'key' }: { by?: 'key' | 'label' }) {
  return (
    <>
      {TYPE_GROUPS.map((g) => (
        <optgroup key={g} label={g}>
          {PROPERTY_TYPES.filter((t) => t.group === g).map((t) => <option key={t.key} value={t[by]}>{t.label}</option>)}
        </optgroup>
      ))}
    </>
  );
}
