import { todayISO } from './format';

/* Reglas de validación del sitio (mismos mensajes que el original). */
export type Errors = Record<string, string>;

export const required = (v: string, isSelect = false) => (v.trim() ? '' : isSelect ? 'Elige una opción.' : 'Completa este campo.');

export const email = (v: string) =>
  !v.trim() ? 'Completa este campo.' : /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v.trim()) ? '' : 'Escribe un correo válido, por ejemplo nombre@correo.com.';

/* ---------- Correo: errores de dedo en el dominio (gmial.com, hotmal.com, gmail.con…) ---------- */
const DOMAINS = [
  'gmail.com', 'hotmail.com', 'hotmail.es', 'outlook.com', 'outlook.es', 'live.com', 'live.com.mx', 'yahoo.com', 'yahoo.com.mx',
  'icloud.com', 'me.com', 'msn.com', 'aol.com', 'protonmail.com', 'proton.me', 'prodigy.net.mx',
  // Dominios reales que se parecen a los anteriores (no son errores de dedo)
  'ymail.com', 'mail.com', 'email.com', 'gmx.com', 'gmx.net', 'hotmail.com.mx', 'outlook.com.mx', 'live.com.ar', 'yahoo.es',
  'zoho.com', 'yandex.com', 'tutanota.com', 'mac.com', 'hotmail.fr', 'hotmail.co.uk', 'yahoo.co.uk', 'live.ca', 'outlook.fr',
];

function distance(a: string, b: string): number {
  const d = Array.from({ length: a.length + 1 }, (_, i) => [i, ...Array(b.length).fill(0)]);
  for (let j = 1; j <= b.length; j++) d[0][j] = j;
  for (let i = 1; i <= a.length; i++)
    for (let j = 1; j <= b.length; j++) {
      d[i][j] = Math.min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1));
      // letras volteadas: gmial → gmail
      if (i > 1 && j > 1 && a[i - 1] === b[j - 2] && a[i - 2] === b[j - 1]) d[i][j] = Math.min(d[i][j], d[i - 2][j - 2] + 1);
    }
  return d[a.length][b.length];
}

/** Si el dominio parece un error de dedo de uno conocido, el correo corregido; si no, '' */
export function emailSuggestion(v: string): string {
  const m = v.trim().toLowerCase().match(/^([^\s@]+)@([^\s@]+)$/);
  if (!m) return '';
  const [, user, domain] = m;
  if (DOMAINS.includes(domain)) return '';
  let best = '', score = 3;
  for (const d of DOMAINS) {
    const s = distance(domain, d);
    if (s < score) [best, score] = [d, s];
  }
  // Sin punto o terminación rara en un dominio conocido: gmailcom, gmail.c, gmail.co
  if (!best && domain.split('.').length <= 2 && ['gmail', 'hotmail', 'outlook', 'gmailcom', 'hotmailcom', 'outlookcom'].includes(domain.split('.')[0])) {
    const base = domain.split('.')[0];
    best = DOMAINS.find((d) => d.split('.')[0] === base) ?? '';
  }
  return best ? `${user}@${best}` : '';
}

/** Correo válido y sin errores de dedo en el dominio */
export const emailStrict = (v: string) => {
  const basic = email(v);
  if (basic) return basic;
  const s = emailSuggestion(v);
  return s ? `Revisa tu correo: ¿quisiste decir ${s}?` : '';
};

/** El correo repetido debe ser igual al primero */
export const emailRepeat = (first: string, second: string) =>
  !second.trim() ? 'Escribe tu correo otra vez para confirmarlo.' : first.trim().toLowerCase() !== second.trim().toLowerCase() ? 'Los dos correos no coinciden.' : '';

/** 10 dígitos; también se acepta con la lada del país: +52 998 000 0000 */
export const phone = (v: string, isRequired = false) => {
  if (!v.trim()) return isRequired ? 'Completa este campo.' : '';
  const digits = v.replace(/\D/g, '').replace(/^52(?=\d{10}$)/, '');
  return digits.length === 10 ? '' : `El teléfono debe tener 10 dígitos (llevas ${digits.length}).`;
};
/** Mientras se escribe el teléfono: solo números, espacios y + ( ) - */
export const phoneChars = (v: string) => v.replace(/[^\d\s()+-]/g, '');

/** Texto con mínimo y máximo de caracteres. Opcional: vacío no es error, pero lo escrito sí se revisa. */
export const text = (v: string, min: number, max: number, isRequired = true) => {
  const n = v.trim().length;
  if (!n) return isRequired ? 'Completa este campo.' : '';
  if (n < min) return `Escribe al menos ${min} caracteres.`;
  return n > max ? `Escribe máximo ${max} caracteres.` : '';
};

/** Nombre y al menos un apellido, solo con letras */
export const personName = (v: string) => {
  if (!v.trim()) return 'Completa este campo.';
  if (/[^\p{L}\s.'-]/u.test(v)) return 'Escribe solo letras.';
  if (v.trim().split(/\s+/).length < 2) return 'Escribe tu nombre y al menos un apellido.';
  return text(v, 5, 80);
};

/** Nacionalidad y datos parecidos: solo letras */
export const words = (v: string, min: number, max: number) => (/[^\p{L}\s.'-]/u.test(v) ? 'Escribe solo letras.' : text(v, min, max));

/** Cantidad opcional dentro de un rango (metros, precio esperado) */
export const amount = (v: string, min: number, max: number, unit: (n: number) => string) => {
  if (!v.trim()) return '';
  const n = Number(v);
  if (n < min) return `Debe ser de al menos ${unit(min)}.`;
  return n > max ? `No puede pasar de ${unit(max)}.` : '';
};

export const futureDate = (v: string) => (!v ? 'Completa este campo.' : v < todayISO() ? 'Elige una fecha a partir de hoy.' : '');

/** Quita las reglas vacías: { a: '', b: 'Completa…' } → { b: 'Completa…' } */
export const clean = (e: Errors): Errors => Object.fromEntries(Object.entries(e).filter(([, m]) => m));
