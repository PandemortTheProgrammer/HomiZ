import { useState, type ReactNode } from 'react';
import { createPortal } from 'react-dom';
import { Dialog } from './Dialog';
import { Icon } from './Icon';
import { PrivacyText } from './PrivacyText';

/* ==========================================================================
   Aviso de privacidad integral en una ventana flotante (sin salir de la página).
   El texto es el mismo de /aviso-de-privacidad (components/PrivacyText.tsx).
   ========================================================================== */
export const PRIVACY_URL = '/aviso-de-privacidad';

export function PrivacyLink({ children = 'Aviso de privacidad', className = 'link-btn' }: { children?: ReactNode; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)} aria-haspopup="dialog">{children}</button>
      {/* En el <body>: el enlace suele estar dentro de un <p> o de una <label> */}
      {createPortal(<Dialog open={open} onClose={() => setOpen(false)} labelledBy="privacy-title" wide>
        <div className="privacy-dialog">
          <div className="privacy-dialog__head">
            <h2 id="privacy-title">Aviso de privacidad</h2>
            <button type="button" className="icon-close" onClick={() => setOpen(false)} aria-label="Cerrar el aviso de privacidad"><Icon id="x" /></button>
          </div>
          <div className="privacy-dialog__body"><PrivacyText /></div>
          <div className="dlg-actions">
            <a className="btn btn--secondary" href="/aviso-de-privacidad" target="_blank" rel="noopener"><Icon id="arrow-ur" />Abrir en otra pestaña</a>
            <button className="btn" type="button" onClick={() => setOpen(false)}>Entendido</button>
          </div>
        </div>
      </Dialog>, document.body)}
    </>
  );
}
