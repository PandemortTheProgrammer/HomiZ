import { Icon } from './Icon';

/** En «Revisa tu solicitud»: con qué correo se crea la cuenta de la app y qué hacer si está mal. */
export function ReviewAccountNote({ email }: { email: string }) {
  return (
    <div className="review-account" role="note">
      <Icon id="shield" />
      <div>
        <strong>Tu cuenta de la app Homiz será: {email.trim().toLowerCase()}</strong>
        <p>Ahí te enviaremos tu contraseña temporal y todo el seguimiento (citas, propuestas y mensajes). Si el correo o algún dato está mal, toca «Corregir datos» antes de enviar.</p>
      </div>
    </div>
  );
}
