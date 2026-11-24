/* Los botones que antes abrían el WhatsApp de Zugar llevan a la app Homiz (puerto 5600 del mismo servidor:
   localhost, IP de la red o puerto reenviado de VS Code). Otra dirección: VITE_APP_URL en .env.
   Con una casa, la app la recibe en ?casa=, pide crear cuenta y abre «Solicitar visita» de esa casa. */
function defaultAppUrl(): string {
  const host = location.hostname;
  if (/^[a-z0-9]+-\d+\./i.test(host) && /\.devtunnels\.ms$/i.test(host)) return `${location.protocol}//${host.replace(/-\d+\./, '-5600.')}/`;
  return `${location.protocol}//${host}:5600/`;
}

export const APP_URL: string = (import.meta.env.VITE_APP_URL as string | undefined) || defaultAppUrl();

/**
 * QR sin datos (una casa o «Cómo trabajamos»): la app pide crear cuenta o entrar y, al entrar, pregunta
 * «¿Qué quieres hacer?» (con esa casa como de interés y la opción de agendar la cita).
 */
export const appLink = (slug?: string | null) => APP_URL + '?empezar=1' + (slug ? '&casa=' + encodeURIComponent(slug) : '');

/** Después de enviar un formulario: la app abre el acceso con su correo ya escrito y al entrar muestra sus solicitudes. */
/**
 * Botones del sitio: «Descarga nuestra app». Con la app publicada, VITE_PLAY_STORE_URL lleva a Google Play;
 * mientras tanto abre el QR en la computadora y la app en el celular.
 */
export const downloadLink = (slug?: string | null) => (import.meta.env.VITE_PLAY_STORE_URL as string | undefined) || appLink(slug);

export const appAccountLink = (email: string) => APP_URL + '?email=' + encodeURIComponent(email.trim().toLowerCase());
