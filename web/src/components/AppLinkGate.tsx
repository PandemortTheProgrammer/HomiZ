import { useEffect, useState } from 'react';
import QRCode from 'qrcode';
import { APP_URL } from '../lib/appLink';
import { Dialog } from './Dialog';

import { isDesktop } from './AppQr';

/**
 * En la computadora, los enlaces a la app Homiz abren un aviso con un código QR para seguir en el celular
 * (en la computadora no se abre). En el celular el enlace abre la app directo.
 */
export function AppLinkGate() {
  const [href, setHref] = useState<string | null>(null);
  const [qr, setQr] = useState('');

  useEffect(() => {
    const onClick = (e: MouseEvent) => {
      const a = (e.target as HTMLElement).closest('a');
      if (!a || !a.href.startsWith(APP_URL) || a.dataset.direct !== undefined || e.ctrlKey || e.metaKey || e.shiftKey || !isDesktop()) return;
      e.preventDefault();
      setHref(a.href);
    };
    document.addEventListener('click', onClick);
    return () => document.removeEventListener('click', onClick);
  }, []);

  useEffect(() => {
    if (!href) return;
    QRCode.toDataURL(href, { width: 240, margin: 1, color: { dark: '#0B2545', light: '#FFFFFF' } }).then(setQr, () => setQr(''));
  }, [href]);

  return (
    <Dialog open={!!href} onClose={() => setHref(null)} labelledBy="app-qr-title">
      <div className="app-qr">
        <h2 id="app-qr-title">Sigue en tu celular</h2>
        <p className="dlg-lead">Homiz es la app de Zugar para tu teléfono. Escanea este código con la cámara del celular, crea tu cuenta (o entra con tu correo y contraseña) y te preguntaremos qué quieres hacer: rentar, comprar o publicar.{href?.includes('casa=') ? ' Ahí mismo podrás agendar tu cita para conocer la propiedad.' : ''}</p>
        {qr && <img className="app-qr__code" src={qr} width={240} height={240} alt="Código QR para abrir la app Homiz en el celular" />}
        <div className="dlg-actions">
          <button className="btn" type="button" onClick={() => setHref(null)}>Listo</button>
        </div>
      </div>
    </Dialog>
  );
}
