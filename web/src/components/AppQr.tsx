import { useEffect, useState } from 'react';
import QRCode from 'qrcode';

/** ¿Es una computadora? (mouse y sin sistema de celular): ahí la app se abre mejor en el teléfono */
export const isDesktop = () => !window.matchMedia('(pointer: coarse)').matches && !/Android|iPhone|iPad|iPod|Mobile/i.test(navigator.userAgent);

/**
 * Código QR para seguir en el celular. Se muestra en la computadora (en el celular ya hay un botón que abre la app).
 * Lo usan la confirmación de «Contáctanos» y «Gracias» (QR con tu correo: entras con la contraseña temporal).
 */
export function AppQr({ href, title, text }: { href: string; title: string; text: string }) {
  const [qr, setQr] = useState('');
  const [desktop] = useState(isDesktop);
  useEffect(() => {
    if (!desktop) return;
    QRCode.toDataURL(href, { width: 200, margin: 1, color: { dark: '#0B2545', light: '#FFFFFF' } }).then(setQr, () => setQr(''));
  }, [href, desktop]);
  if (!desktop || !qr) return null;
  return (
    <div className="app-qr-inline">
      <img src={qr} width={160} height={160} alt="Código QR para abrir tu cuenta en la app Homiz en el celular" />
      <div><strong>{title}</strong><p>{text}</p></div>
    </div>
  );
}
