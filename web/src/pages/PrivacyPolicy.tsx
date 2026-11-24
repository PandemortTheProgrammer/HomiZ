import { Link } from 'react-router';
import { PrivacyText } from '../components/PrivacyText';
import { usePageTitle } from '../lib/usePageTitle';

/** /aviso-de-privacidad — aviso de privacidad integral */
export function PrivacyPolicy() {
  usePageTitle('Aviso de privacidad | Zugar Inmobiliaria');
  return (
    <section className="section">
      <div className="wrap" style={{ maxWidth: '48rem' }}>
        <span className="eyebrow">Tus datos</span>
        <h1 className="text-(length:--fs-2xl)">Aviso de privacidad</h1>
        <p className="lead mt-3">Cómo cuidamos y usamos tu información, y cómo ejercer tus derechos.</p>
        <div className="mt-6"><PrivacyText /></div>
        <p className="mt-6 flex flex-wrap gap-3">
          <Link className="btn btn--secondary" to="/eliminar-cuenta">Eliminar mi cuenta</Link>
          <Link className="btn" to="/">Ir al inicio</Link>
        </p>
      </div>
    </section>
  );
}
