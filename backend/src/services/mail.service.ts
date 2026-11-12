import { mkdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import nodemailer, { type Transporter } from 'nodemailer';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';

/*
 * Envío de correos.
 * - MAIL_DRIVER=smtp: se envía de verdad por SMTP (Gmail: smtp.gmail.com, puerto 465, con una «contraseña de aplicación»).
 * - MAIL_DRIVER=outbox (por omisión): cada correo se guarda como archivo en MAIL_OUTBOX_DIR para revisarlo en desarrollo.
 * En pruebas se guarda en memoria (sentMail).
 */
export interface MailMessage {
  to: string;
  subject: string;
  text: string;
  /** Enlace principal: en el correo HTML se muestra como botón */
  action?: { label: string; url: string };
}

export const sentMail: MailMessage[] = [];

let transport: Transporter | null = null;
function smtp(): Transporter {
  transport ??= nodemailer.createTransport({
    host: env.SMTP_HOST,
    port: env.SMTP_PORT,
    secure: env.SMTP_PORT === 465,
    auth: { user: env.SMTP_USER, pass: env.SMTP_PASS },
    connectionTimeout: 15_000,
    greetingTimeout: 15_000,
    socketTimeout: 30_000,
  });
  return transport;
}

const escape = (s: string) => s.replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[c]!);

/** Versión HTML sencilla: el texto con saltos de línea y el enlace principal como botón. */
function html(m: MailMessage): string {
  const body = escape(m.text).replace(/\n/g, '<br>');
  const button = m.action
    ? `<p style="margin:24px 0"><a href="${escape(m.action.url)}" style="background:#1F5BDB;color:#fff;padding:12px 20px;border-radius:8px;text-decoration:none;font-weight:600">${escape(m.action.label)}</a></p>`
    : '';
  return `<div style="font-family:Arial,sans-serif;font-size:15px;color:#1B2A44;max-width:560px">${body}${button}<p style="color:#5A6A82;font-size:13px">Inmobiliaria Zugar · Homiz</p></div>`;
}

/** Esperas entre intentos: una caída breve de la red no debe perder el correo con la contraseña temporal. */
const RETRY_MS = [3_000, 15_000, 60_000];

async function deliver(message: MailMessage): Promise<void> {
  for (let attempt = 0; ; attempt++) {
    try {
      await smtp().sendMail({ from: env.MAIL_FROM || `Inmobiliaria Zugar <${env.SMTP_USER}>`, to: message.to, subject: message.subject, text: message.text, html: html(message) });
      logger.info({ subject: message.subject, attempt: attempt + 1 }, 'Correo enviado');
      return;
    } catch (err) {
      const e = err as { code?: string; responseCode?: number; message: string };
      // Clave o destinatario rechazados: repetir no lo arregla
      const permanent = e.code === 'EAUTH' || e.code === 'EENVELOPE' || (e.responseCode ?? 0) >= 500;
      if (permanent || attempt === RETRY_MS.length) {
        logger.error({ err: e.message, code: e.code, subject: message.subject, attempts: attempt + 1 }, 'No se pudo enviar el correo');
        return;
      }
      logger.warn({ err: e.message, code: e.code, subject: message.subject, attempt: attempt + 1 }, 'Falló el envío del correo; se reintenta');
      await new Promise((ok) => setTimeout(ok, RETRY_MS[attempt]));
    }
  }
}

/** No lanza error ni hace esperar a quien llama: el correo sale aparte y, si falla, se reintenta y se registra. */
export async function sendMail(message: MailMessage): Promise<void> {
  sentMail.push(message);
  if (sentMail.length > 50) sentMail.shift();
  if (env.isTest) return;
  if (env.MAIL_DRIVER === 'smtp') {
    void deliver(message);
    return;
  }
  const dir = path.resolve(env.MAIL_OUTBOX_DIR);
  await mkdir(dir, { recursive: true });
  const file = path.join(dir, `${new Date().toISOString().replace(/[:.]/g, '-')}.txt`);
  await writeFile(file, `Para: ${message.to}\nAsunto: ${message.subject}\n\n${message.text}\n`, 'utf8');
  logger.info({ file: path.basename(file) }, 'Correo de desarrollo guardado en la bandeja local (MAIL_DRIVER=outbox)');
}
