import { useState, type FormEvent } from 'react';
import { Link } from 'react-router';
import { Field } from '../components/Field';
import { Icon } from '../components/Icon';
import { request, type ApiError } from '../lib/api';
import { LEGAL } from '../lib/legal';
import { usePageTitle } from '../lib/usePageTitle';

/**
 * /eliminar-cuenta — «Eliminar mi cuenta» sin la app (derecho de cancelación; Google Play pide un enlace web).
 * Con correo y contraseña. Si tiene contrato vigente, el servidor no lo permite y explica por qué.
 */
export function DeleteAccount() {
  usePageTitle('Eliminar mi cuenta | Zugar Inmobiliaria');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [sure, setSure] = useState(false);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const [done, setDone] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    if (!email.trim() || !password) return setError('Escribe tu correo y tu contraseña.');
    if (!sure) return setError('Confirma que entiendes que la eliminación no se puede deshacer.');
    setBusy(true);
    setError('');
    try {
      await request('/auth/delete-account', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email: email.trim(), password }) });
      setDone(true);
    } catch (er) {
      const x = er as ApiError;
      setError(x.sinConexion ? 'No pudimos conectar. Inténtalo de nuevo en unos minutos.' : x.mensaje || 'No pudimos eliminar tu cuenta. Inténtalo de nuevo.');
    } finally {
      setBusy(false);
      setPassword('');
    }
  };

  return (
    <section className="section">
      <div className="wrap" style={{ maxWidth: '36rem' }}>
        <span className="eyebrow">Tus datos</span>
        <h1 className="text-(length:--fs-2xl)">Eliminar mi cuenta</h1>
        {done ? (
          <div className="alert alert-success is-visible mt-6" role="status">
            <Icon id="check" />
            <div><strong>Tu cuenta se eliminó.</strong>Borramos tus datos de contacto y tus solicitudes, y cancelamos tus citas pendientes. Lo que la ley nos obliga a conservar (contratos y pagos terminados) queda guardado sin tus datos de contacto.</div>
          </div>
        ) : (
          <>
            <p className="lead mt-3">Se borran tus datos de contacto, tus solicitudes, mensajes y avisos, y se cancelan tus citas pendientes. Si tienes un contrato de renta vigente, tus datos se conservan hasta que termine.</p>
            <form className="booking-form mt-6" noValidate onSubmit={submit}>
              {error && <div className="alert alert-error is-visible" role="alert"><Icon id="alert" /><div>{error}</div></div>}
              <Field id="del-email" label="Correo de tu cuenta">
                <input className="input" id="del-email" type="email" autoComplete="email" value={email} onChange={(e) => setEmail(e.target.value)} />
              </Field>
              <Field id="del-pass" label="Contraseña">
                <input className="input" id="del-pass" type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} />
              </Field>
              <label className="check mt-3">
                <input type="checkbox" checked={sure} onChange={(e) => setSure(e.target.checked)} />
                <span>Entiendo que la eliminación no se puede deshacer.</span>
              </label>
              <button className="btn btn--block mt-6" type="submit" disabled={busy}>{busy ? 'Eliminando…' : 'Eliminar mi cuenta'}</button>
            </form>
            <p className="small muted mt-6">¿Olvidaste tu contraseña o prefieres pedirlo por correo? Escríbenos a <a href={`mailto:${LEGAL.privacyEmail}?subject=Eliminar%20mi%20cuenta`}>{LEGAL.privacyEmail}</a>. Más detalles en el <Link to="/aviso-de-privacidad">aviso de privacidad</Link>.</p>
          </>
        )}
      </div>
    </section>
  );
}
