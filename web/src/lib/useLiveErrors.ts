import { useState, type FocusEvent } from 'react';
import type { Errors } from './validation';

/** Del id del campo a su regla: b-nombre → nombre, b-pres-max → presupuesto_max, p-zona → inmueble_zona */
const defaultKey = (id: string) =>
  id.startsWith('mascotas-') ? 'mascotas' : id === 'b-pres-max' ? 'presupuesto_max' : id.startsWith('p-') ? 'inmueble_' + id.slice(2) : id.replace(/^[a-z]+-/, '');

/**
 * Errores en tiempo real: cada campo muestra su mensaje en cuanto se escribe en él o se sale de él,
 * sin esperar a enviar. Al enviar se muestran todos los que falten.
 */
export function useLiveErrors(errors: Errors, keyOf: (id: string) => string = defaultKey) {
  const [touched, setTouched] = useState<Record<string, boolean>>({});
  const [all, setAll] = useState(false);
  const touch = (k: string) => setTouched((t) => (t[k] ? t : { ...t, [k]: true }));
  return {
    err: (k: string): string | undefined => (all || touched[k] ? errors[k] : undefined),
    touch,
    onBlur: (e: FocusEvent<HTMLFormElement>) => { const id = (e.target as HTMLElement).id; if (id) touch(keyOf(id)); },
    showAll: () => setAll(true),
    reset: () => { setTouched({}); setAll(false); },
    pending: all && Object.keys(errors).length > 0,
  };
}
