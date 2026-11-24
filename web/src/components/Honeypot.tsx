/**
 * Campo trampa contra robots: está fuera de la vista y del teclado, así que una persona nunca lo llena.
 * Si llega con texto, el servidor responde como si nada pero no guarda la solicitud ni envía correos.
 */
export function Honeypot() {
  return (
    <div aria-hidden="true" style={{ position: 'absolute', left: '-10000px', top: 'auto', width: 1, height: 1, overflow: 'hidden' }}>
      <label htmlFor="website">No llenes este campo</label>
      <input type="text" id="website" name="website" tabIndex={-1} autoComplete="off" defaultValue="" />
    </div>
  );
}
