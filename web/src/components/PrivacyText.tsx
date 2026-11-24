import { LEGAL, PRIVACY_UPDATED } from '../lib/legal';

/**
 * Aviso de privacidad integral (Ley Federal de Protección de Datos Personales en Posesión de los Particulares, 2025).
 * Se muestra en /aviso-de-privacidad y en la ventana de «Acepto el aviso de privacidad».
 * Revisión legal recomendada antes de producción.
 */
export function PrivacyText() {
  const L = LEGAL;
  return (
    <div className="legal-text">
      <p><strong>Última actualización:</strong> {PRIVACY_UPDATED}.</p>

      <h2>1. ¿Quién es responsable de tus datos?</h2>
      <p>{L.responsible} («{L.brand}», «nosotros»), con domicilio en {L.address}, RFC {L.rfc}, es responsable del uso y protección de tus datos personales. Para cualquier asunto de privacidad escríbenos a <a href={`mailto:${L.privacyEmail}`}>{L.privacyEmail}</a> o llámanos al {L.phone}.</p>

      <h2>2. ¿Qué datos recabamos?</h2>
      <ul>
        <li><strong>Identificación y contacto:</strong> nombre, correo electrónico, teléfono, nacionalidad y ocupación.</li>
        <li><strong>Lo que buscas:</strong> tipo de inmueble, zona, presupuesto, número de personas, mascotas y fechas para visitar.</li>
        <li><strong>Datos patrimoniales y financieros</strong> (solo si rentas o compras con nosotros): renta, depósito, pagarés, pagos, recibos de servicios y el contrato firmado.</li>
        <li><strong>De tu cuenta en la app Homiz:</strong> contraseña (guardada cifrada), avisos, mensajes con tu asesor, reportes de mantenimiento con fotos y documentos de tu expediente.</li>
        <li><strong>Técnicos:</strong> dirección IP y registros de seguridad (inicios de sesión) para proteger tu cuenta.</li>
      </ul>
      <p>No solicitamos datos personales sensibles. Si al reportar un mantenimiento o en un mensaje compartes alguno, lo usaremos solo para atender ese asunto.</p>

      <h2>3. ¿Para qué los usamos?</h2>
      <p><strong>Finalidades necesarias</strong> (sin ellas no podemos darte el servicio):</p>
      <ul>
        <li>Atender tu solicitud, proponerte casas y agendar y confirmar visitas.</li>
        <li>Crear y administrar tu cuenta de la app Homiz.</li>
        <li>Si rentas o compras: elaborar y administrar el contrato, los pagarés, pagos y recibos; tu expediente; el mantenimiento de la casa y los recordatorios de pago, agua, luz y mantenimiento.</li>
        <li>Cumplir obligaciones legales y fiscales, y proteger la seguridad de la plataforma.</li>
      </ul>
      <p><strong>Finalidades adicionales</strong> (puedes negarte sin afectar el servicio): enviarte otras casas que te puedan interesar. Si no lo deseas, escríbenos a {L.privacyEmail}.</p>

      <h2>4. ¿Con quién los compartimos?</h2>
      <p>No vendemos tus datos. Solo los compartimos con:</p>
      <ul>
        <li>El asesor (broker) de Zugar asignado a tu solicitud o a tu casa.</li>
        <li>Proveedores que nos prestan servicios tecnológicos y actúan por nuestra cuenta (encargados): almacenamiento de archivos (Cloudflare), envío de correos (Google) y notificaciones de la app (Google Firebase). Sus servidores pueden estar fuera de México y están obligados a proteger tus datos.</li>
        <li>Proveedores de mantenimiento, solo con los datos necesarios para atender un reporte de tu casa.</li>
        <li>Autoridades, cuando una ley o una orden lo exija.</li>
      </ul>
      <p>Estas comunicaciones no requieren tu consentimiento conforme a la ley, por ser necesarias para el servicio o por obligación legal.</p>

      <h2>5. ¿Cuánto tiempo los guardamos?</h2>
      <p>Mientras tengas una solicitud o contrato activo y, después, el tiempo que exijan las leyes (por ejemplo, fiscales: 5 años para contratos y pagos). Las solicitudes sin contrato se conservan hasta 2 años y luego se eliminan o anonimizan.</p>

      <h2>6. Tus derechos ARCO y revocación del consentimiento</h2>
      <p>Puedes <strong>acceder</strong> a tus datos, <strong>rectificarlos</strong>, <strong>cancelarlos</strong> u <strong>oponerte</strong> a su uso, así como <strong>revocar tu consentimiento</strong>:</p>
      <ul>
        <li>Desde la app Homiz: «Mis datos» para corregirlos y «Eliminar mi cuenta» para cancelarlos.</li>
        <li>Desde el sitio: <a href="/eliminar-cuenta">Eliminar mi cuenta</a>.</li>
        <li>Por correo a <a href={`mailto:${L.privacyEmail}`}>{L.privacyEmail}</a> indicando tu nombre, el correo de tu cuenta, lo que pides y una identificación. Te responderemos en un máximo de 20 días hábiles y, si procede, lo haremos efectivo en los 15 días hábiles siguientes.</li>
      </ul>
      <p>Si tienes un contrato vigente, algunos datos debemos conservarlos hasta terminarlo y cumplir las obligaciones que derivan de él.</p>

      <h2>7. Cookies y almacenamiento en tu navegador</h2>
      <p>No usamos cookies de publicidad ni de rastreo. El sitio guarda en tu navegador solo lo necesario para funcionar (por ejemplo, tus casas favoritas y tu sesión del panel). Puedes borrarlo desde la configuración de tu navegador.</p>

      <h2>8. Seguridad</h2>
      <p>Protegemos tus datos con conexiones cifradas (HTTPS), contraseñas cifradas, acceso solo para el personal autorizado y documentos privados que se abren con enlaces temporales.</p>

      <h2>9. Cambios a este aviso</h2>
      <p>Si cambia, lo publicaremos aquí con su fecha de actualización y, si el cambio es importante, te avisaremos en la app o por correo.</p>

      <h2>10. ¿Dónde reclamar?</h2>
      <p>Si consideras que tu derecho a la protección de datos fue vulnerado, puedes acudir ante la autoridad competente en materia de protección de datos personales en México.</p>
    </div>
  );
}
