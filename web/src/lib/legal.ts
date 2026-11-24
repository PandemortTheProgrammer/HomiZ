/**
 * Datos legales del responsable. Los que dicen «POR CONFIRMAR» los debe completar la inmobiliaria
 * (razón social, RFC y domicilio fiscal) antes de publicar en producción. Al cambiar el aviso,
 * actualiza PRIVACY_VERSION aquí y en backend/src/config/legal.ts (cada consentimiento guarda la versión).
 */
export const LEGAL = {
  /** Nombre comercial */
  brand: 'Zugar Inmobiliaria',
  /** Persona física o moral responsable de los datos (como aparece ante el SAT) */
  responsible: 'Zugar Inmobiliaria (razón social POR CONFIRMAR)',
  rfc: 'POR CONFIRMAR',
  address: 'Cancún, Quintana Roo, México (domicilio completo POR CONFIRMAR)',
  /** Correo para derechos ARCO, revocación del consentimiento y dudas de privacidad */
  privacyEmail: 'hola@zugar.mx',
  phone: '+52 998 555 0142',
};

export const PRIVACY_VERSION = '2026-11-01';
export const PRIVACY_UPDATED = '1 de noviembre de 2026';
