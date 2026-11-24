import { emailSuggestion } from '../lib/validation';
import { Field, invalid } from './Field';
import { Icon } from './Icon';

/* ==========================================================================
   Correo con doble verificación: se escribe dos veces y, si el dominio parece un error de dedo
   (gmial.com, hotmal.com, gmail.con…), se ofrece la corrección con un botón.
   Es el correo de la cuenta de la app: ahí llega la contraseña temporal.
   ========================================================================== */
interface Props {
  /** Prefijo de los id: «b» → b-correo y b-correo2 */
  prefix: string;
  value: string;
  repeat: string;
  onChange: (value: string, repeat: string) => void;
  error?: string;
  repeatError?: string;
}

export function EmailFields({ prefix, value, repeat, onChange, error, repeatError }: Props) {
  const fix = emailSuggestion(value);
  const id = `${prefix}-correo`, id2 = `${prefix}-correo2`;
  return (
    <>
      <Field id={id} label="Correo electrónico *" error={error}
        help={error ? undefined : 'Aquí te llega la contraseña temporal de tu cuenta en la app Homiz.'}>
        <input className="input" id={id} type="email" autoComplete="email" inputMode="email" spellCheck={false} placeholder="tu@correo.com" value={value}
          onChange={(e) => onChange(e.target.value.trim(), repeat)} {...invalid(id, error)} />
        {fix && (
          <p className="email-fix" role="status">
            <Icon id="alert" size="sm" />¿Quisiste decir <strong>{fix}</strong>?
            <button type="button" className="link-btn" onClick={() => onChange(fix, repeat && repeat.toLowerCase() === value.toLowerCase() ? fix : repeat)}>Sí, corregir</button>
          </p>
        )}
      </Field>
      <Field id={id2} label="Confirma tu correo *" error={repeatError}>
        <input className="input" id={id2} type="email" autoComplete="off" inputMode="email" spellCheck={false} placeholder="Escríbelo otra vez" value={repeat}
          onChange={(e) => onChange(value, e.target.value.trim())} onPaste={(e) => e.preventDefault()} {...invalid(id2, repeatError)} />
      </Field>
    </>
  );
}
