import type { InputHTMLAttributes } from 'react';

/* ==========================================================================
   Campos numéricos que se escriben con el formato que se lee:
   - MoneyInput: escribes 12000 y se ve «$12,000» (el valor es «12000»).
   - AreaInput: escribes 1500 y se ve «1,500» con «m²» al lado.
   Se puede pegar «$12,000 MXN»: solo se toman los dígitos. Con `suggestions`
   aparece una lista de montos sugeridos y también se puede escribir cualquiera.
   ========================================================================== */
type Base = Omit<InputHTMLAttributes<HTMLInputElement>, 'value' | 'onChange' | 'type' | 'list'> & {
  value: string | number | null | undefined;
  onChange: (digits: string) => void;
  suggestions?: number[];
};

export const digitsOf = (v: string) => v.replace(/\D/g, '').replace(/^0+(?=\d)/, '').slice(0, 12);
const grouped = (digits: string) => (digits ? Number(digits).toLocaleString('en-US') : '');
export const moneyText = (n: number | string) => (n === '' || n == null ? '' : '$' + grouped(digitsOf(String(n))));

function Suggestions({ id, list, fmt }: { id: string; list?: number[]; fmt: (n: number) => string }) {
  if (!list?.length) return null;
  return <datalist id={id}>{list.map((n) => <option key={n} value={fmt(n)} />)}</datalist>;
}

export function MoneyInput({ value, onChange, suggestions, id, className = 'input', ...rest }: Base) {
  const digits = digitsOf(String(value ?? ''));
  const listId = suggestions?.length && id ? id + '-sugerencias' : undefined;
  return (
    <>
      <input {...rest} id={id} className={className} type="text" inputMode="numeric" autoComplete="off" list={listId}
        value={digits ? '$' + grouped(digits) : ''} onChange={(e) => onChange(digitsOf(e.target.value))} />
      {listId && <Suggestions id={listId} list={suggestions} fmt={(n) => '$' + n.toLocaleString('en-US')} />}
    </>
  );
}

export function AreaInput({ value, onChange, suggestions, id, className = 'input', ...rest }: Base) {
  const digits = digitsOf(String(value ?? ''));
  const listId = suggestions?.length && id ? id + '-sugerencias' : undefined;
  return (
    <span className="input-unit">
      <input {...rest} id={id} className={className} type="text" inputMode="numeric" autoComplete="off" list={listId}
        value={grouped(digits)} onChange={(e) => onChange(digitsOf(e.target.value))} />
      <span className="input-unit__suffix" aria-hidden="true">m²</span>
      {listId && <Suggestions id={listId} list={suggestions} fmt={(n) => n.toLocaleString('en-US')} />}
    </span>
  );
}
