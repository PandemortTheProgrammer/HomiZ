import { Field, invalid } from './Field';
import { MoneyInput } from './NumberInput';

/* ==========================================================================
   Presupuesto con mínimo y máximo: se escriben como números (sin «$» ni texto)
   o se eligen de una lista de montos sugeridos según sea renta o compra.
   ========================================================================== */
const SUGGESTED = {
  renta: [8000, 10000, 15000, 20000, 25000, 30000, 40000, 50000, 70000],
  compra: [1500000, 2000000, 2500000, 3000000, 3500000, 4000000, 5000000, 7000000, 10000000],
};

/** «15000» → 15000; vacío o inválido → null */
export const toAmount = (v: string): number | null => {
  const n = Number(v.replace(/[^\d.]/g, ''));
  return v.trim() && Number.isFinite(n) && n > 0 ? Math.round(n) : null;
};

const fmt = (n: number) => '$' + n.toLocaleString('en-US');

/** «$10,000 – $20,000 MXN / mes», «Hasta $20,000…» o «Desde $10,000…» */
export function budgetLabel(min: string, max: string, op: 'renta' | 'compra') {
  const a = toAmount(min);
  const b = toAmount(max);
  const unit = op === 'renta' ? ' MXN / mes' : ' MXN';
  if (a && b) return `${fmt(a)} – ${fmt(b)}${unit}`;
  if (b) return `Hasta ${fmt(b)}${unit}`;
  if (a) return `Desde ${fmt(a)}${unit}`;
  return '';
}

/** Montos con sentido para cada operación: una renta al mes y una compra no se miden igual */
export const BUDGET_LIMITS = { renta: [1_000, 1_000_000], compra: [100_000, 999_999_999] } as const;

/** Error del rango (para la validación del formulario) */
export function budgetError(min: string, max: string, op: 'renta' | 'compra'): string {
  const [low, high] = BUDGET_LIMITS[op];
  const a = toAmount(min), b = toAmount(max);
  if (min.trim() && !a) return 'Escribe el mínimo solo con números.';
  if (a && a < low) return `El mínimo debe ser de al menos ${fmt(low)}.`;
  if (!b) return 'Escribe tu presupuesto máximo (solo números).';
  if (b < low) return `El presupuesto debe ser de al menos ${fmt(low)}.`;
  if (b > high) return `El presupuesto no puede pasar de ${fmt(high)}.`;
  if (a && a > b) return 'El mínimo no puede ser mayor que el máximo.';
  return '';
}

export function BudgetRange({ idPrefix, op, min, max, error, onChange }: {
  idPrefix: string; op: 'renta' | 'compra'; min: string; max: string; error?: string; onChange: (min: string, max: string) => void;
}) {
  return (
    <Field id={`${idPrefix}-max`} label={op === 'renta' ? 'Presupuesto al mes (MXN) *' : 'Presupuesto (MXN) *'} error={error} className="span-2"
      help={error ? undefined : 'Escribe la cantidad (se pone sola con $ y comas) o elige un monto de la lista. El mínimo es opcional.'}>
      <div className="budget-range">
        <label className="sr-only" htmlFor={`${idPrefix}-min`}>Presupuesto mínimo</label>
        <MoneyInput id={`${idPrefix}-min`} placeholder="Mínimo" value={min} onChange={(v) => onChange(v, max)} suggestions={SUGGESTED[op]} />
        <span aria-hidden="true">a</span>
        <MoneyInput id={`${idPrefix}-max`} placeholder="Máximo" value={max} onChange={(v) => onChange(min, v)} suggestions={SUGGESTED[op]} {...invalid(`${idPrefix}-max`, error)} />
      </div>
    </Field>
  );
}
