import { PDFDocument, StandardFonts, rgb, type PDFFont } from 'pdf-lib';
import { pool } from '../config/database.js';
import { buildKey, putObject } from '../config/storage.js';
import { logger } from '../config/logger.js';
import { money, safe, wrap } from './sale.service.js';

/*
 * Recibo de cada pagaré pagado: se genera solo al registrar el pago (PDF) y queda visible para el inquilino
 * junto a su pagaré. Si el pago se corrige se emite otro; si se anula, el recibo deja de verse.
 */
interface ReceiptData {
  folio: string; amount: string; paid_at: Date; notes: string | null; number: number; total: number;
  client_name: string; client_code: string | null; property_id: string; property_code: string; property_name: string; registered_by: string | null;
}

async function receiptPdf(d: ReceiptData): Promise<Buffer> {
  const pdf = await PDFDocument.create();
  pdf.setTitle(`Recibo de pago ${d.folio}`);
  pdf.setAuthor('Inmobiliaria Zugar');
  const page = pdf.addPage([612, 396]); // media carta
  const regular = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  const ink = rgb(0.1, 0.12, 0.16), muted = rgb(0.42, 0.45, 0.5), brand = rgb(0.06, 0.38, 0.33);
  const left = 48, width = 612 - left * 2;
  let y = 346;
  const text = (t: string, o: { size?: number; font?: PDFFont; color?: ReturnType<typeof rgb>; x?: number } = {}) =>
    page.drawText(safe(t), { x: o.x ?? left, y, size: o.size ?? 11, font: o.font ?? regular, color: o.color ?? ink });
  text('Inmobiliaria Zugar', { size: 18, font: bold, color: brand });
  text(`Folio ${d.folio}`, { size: 11, font: bold, x: 612 - left - bold.widthOfTextAtSize(safe(`Folio ${d.folio}`), 11) });
  y -= 22;
  text('Recibo de pago', { size: 13, font: bold });
  y -= 12;
  page.drawLine({ start: { x: left, y }, end: { x: 612 - left, y }, thickness: 1, color: rgb(0.85, 0.87, 0.9) });
  y -= 24;
  const rows: [string, string][] = [
    ['Recibimos de', `${d.client_name}${d.client_code ? ` (${d.client_code})` : ''}`],
    ['Monto', money(Number(d.amount))],
    ['Concepto', `Pagaré ${String(d.number).padStart(2, '0')} de ${d.total} · renta de ${d.property_name} (${d.property_code})`],
    ['Fecha de pago', d.paid_at.toLocaleDateString('es-MX', { timeZone: 'America/Cancun', day: 'numeric', month: 'long', year: 'numeric' })],
    ...(d.registered_by ? [['Registró', d.registered_by] as [string, string]] : []),
    ...(d.notes ? [['Notas', d.notes] as [string, string]] : []),
  ];
  for (const [label, value] of rows) {
    text(label, { size: 10, font: bold, color: muted });
    const lines = wrap(value, regular, 11, width - 120);
    for (const [i, l] of lines.entries()) {
      text(l, { size: 11, x: left + 120 });
      if (i < lines.length - 1) y -= 14;
    }
    y -= 21;
  }
  page.drawText(safe('Comprobante interno de pago; no es factura (CFDI).'), { x: left, y: 40, size: 9, font: regular, color: muted });
  return Buffer.from(await pdf.save());
}

/** Genera el recibo del pago vigente del pagaré y oculta los anteriores. Devuelve el documento creado. */
export async function issueReceipt(noteId: string, userId: string | null): Promise<string | null> {
  const { rows: [d] } = await pool.query<ReceiptData>(
    `SELECT pay.receipt_folio AS folio, pay.amount, pay.paid_at, pay.notes, n.number,
            (SELECT count(*)::int FROM promissory_notes x WHERE x.contract_id = n.contract_id AND x.status <> 'cancelled') AS total,
            c.name AS client_name, c.code AS client_code, p.id AS property_id, p.code AS property_code, p.name AS property_name, u.name AS registered_by
       FROM promissory_notes n
       JOIN payments pay ON pay.promissory_note_id = n.id AND NOT pay.voided
       JOIN contracts ct ON ct.id = n.contract_id
       JOIN clients c ON c.id = ct.client_id
       JOIN properties p ON p.id = ct.property_id
       LEFT JOIN users u ON u.id = pay.registered_by
      WHERE n.id = $1`,
    [noteId],
  );
  if (!d) return null;
  const body = await receiptPdf(d);
  const key = buildKey(d.property_code, 'document', 'application/pdf');
  await putObject(key, 'application/pdf', body);
  await hideReceipts(noteId);
  const { rows } = await pool.query<{ id: string }>(
    `INSERT INTO documents (property_id, type, name, storage_key, mime, size, visible_to_client, uploaded_by, promissory_note_id)
     VALUES ($1, 'receipt', $2, $3, 'application/pdf', $4, TRUE, $5, $6) RETURNING id`,
    [d.property_id, `Recibo ${d.folio}`, key, body.length, userId, noteId],
  );
  return rows[0].id;
}

/** Un recibo que ya no vale (pago anulado o corregido) deja de verse; el pago sigue en el historial. */
export async function hideReceipts(noteId: string): Promise<void> {
  await pool.query(`UPDATE documents SET visible_to_client = FALSE WHERE promissory_note_id = $1 AND type = 'receipt'`, [noteId]);
}

/** El pago ya quedó guardado: si el recibo falla se registra, sin deshacer el pago. */
export const tryIssueReceipt = (noteId: string, userId: string | null) =>
  issueReceipt(noteId, userId).catch((err) => { logger.error({ err: (err as Error).message, noteId }, 'No se pudo generar el recibo'); return null; });
