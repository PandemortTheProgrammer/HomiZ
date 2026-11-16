import { PDFDocument, StandardFonts, rgb, type PDFFont, type PDFPage } from 'pdf-lib';
import { pool, withTransaction } from '../config/database.js';
import { fileSize, keyBelongsTo } from '../config/storage.js';
import { AppError } from '../middlewares/error-handler.js';
import type { AuthUser } from '../middlewares/authenticate.js';
import { insertActivity } from '../models/activity.model.js';
import { assertPropertyAccess } from './access.service.js';
import { nextCode } from './codes.service.js';
import { notify, staffWithPermission, userOfClient } from './notification.service.js';

/*
 * Ventas (decisión 124). La inmobiliaria no administra la casa vendida: solo deja constancia de que el cliente
 * cerró la compra con nosotros (folio VEN-###, comprobante PDF y, si se sube, el contrato firmado).
 * La escritura pública la otorga el notario: el comprobante no la sustituye.
 */

/**
 * Ley Antilavado (LFPIORPI, art. 17 fr. V): la compraventa de inmuebles es actividad vulnerable. Siempre se identifica
 * al cliente; si el precio llega a 8,025 UMA se presenta aviso al SAT. UMA diaria 2026: $117.31 (INEGI, vigente desde
 * el 1 de febrero de 2026). Actualizar cada febrero.
 */
export const UMA_DAILY = 117.31;
export const NOTICE_UMA = 8025;
export const noticeThreshold = () => Math.round(UMA_DAILY * NOTICE_UMA * 100) / 100;

export interface SaleInput {
  propertyId: string;
  clientId: string;
  saleDate: string;
  price: number;
  paymentMethod?: string | null;
  notary?: string | null;
  identityChecked: boolean;
  notes?: string | null;
}

/** Registra la venta: la casa queda vendida y fuera del sitio; el cliente recibe su comprobante en la app. */
export async function createSale(user: AuthUser, s: SaleInput): Promise<string> {
  await assertPropertyAccess(user, s.propertyId);
  const prop = await pool.query<{ name: string; operation: string; broker_id: string | null }>('SELECT name, operation, broker_id FROM properties WHERE id = $1', [s.propertyId]);
  if (prop.rows[0].operation !== 'venta') throw new AppError(409, 'NOT_FOR_SALE', `${prop.rows[0].name} está en renta, no en venta. Las rentas se registran en Rentas › Contrato.`);
  const client = await pool.query<{ name: string }>('SELECT name FROM clients WHERE id = $1 AND active', [s.clientId]);
  if (!client.rows[0]) throw new AppError(404, 'NOT_FOUND', 'El cliente no existe o está dado de baja.');
  // Arriba del umbral de aviso, la identificación del comprador es obligatoria (y también se recomienda siempre)
  if (s.price >= noticeThreshold() && !s.identityChecked) {
    throw new AppError(400, 'IDENTITY_REQUIRED', `La venta es de ${money(s.price)} (igual o mayor a ${money(noticeThreshold())}, 8,025 UMA): por la Ley Antilavado debes revisar la identificación oficial del comprador antes de registrarla. Marca «Revisé su identificación oficial».`);
  }

  try {
    return await withTransaction(async (db) => {
      const folio = await nextCode(db, 'sales', 'VEN');
      const { rows } = await db.query<{ id: string }>(
        `INSERT INTO sales (folio, property_id, client_id, sale_date, price, payment_method, notary, identity_checked, notes, created_by)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id`,
        [folio, s.propertyId, s.clientId, s.saleDate, s.price, s.paymentMethod || null, s.notary || null, s.identityChecked, s.notes || null, user.id],
      );
      const id = rows[0].id;
      await db.query(`UPDATE properties SET status = 'vendida', visibility = 'pausada', updated_at = now() WHERE id = $1`, [s.propertyId]);
      await db.query(`UPDATE clients SET follow_status = 'Compra cerrada', property_id = $2, operation = 'Compra' WHERE id = $1`, [s.clientId, s.propertyId]);
      // Las citas pendientes de esa casa ya no tienen caso
      await db.query(
        `UPDATE appointments SET status = 'cancelada', reason = 'La casa se vendió.'
          WHERE property_id = $1 AND status IN ('por-confirmar', 'confirmada') AND scheduled_at > now()`,
        [s.propertyId],
      );
      await insertActivity({
        userId: user.id, propertyId: s.propertyId, entity: 'sale', entityId: id, action: 'create',
        description: `${user.name} registró la venta ${folio} de ${prop.rows[0].name} a ${client.rows[0].name} por ${money(s.price)}.`,
        newValues: s,
      }, db);
      await notify([await userOfClient(s.clientId, db)], {
        type: 'sale_closed', title: '¡Felicidades por tu compra!',
        message: `Registramos la compra de ${prop.rows[0].name} (folio ${folio}). Tu comprobante está en la app, en Inicio › Mis compras.`,
        entity: 'sale', entityId: id,
      }, db);
      const staff = [...(await staffWithPermission('properties.reassign', db)), prop.rows[0].broker_id].filter((u) => u && u !== user.id);
      await notify(staff, {
        type: 'sale_closed', title: 'Casa vendida',
        message: `${prop.rows[0].name} se vendió a ${client.rows[0].name} (${folio}). Se quitó del sitio.`,
        entity: 'sale', entityId: id,
      }, db);
      return id;
    });
  } catch (err) {
    if ((err as { code?: string }).code === '23505') throw new AppError(409, 'SALE_EXISTS', `${prop.rows[0].name} ya tiene una venta registrada. Si fue un error, anúlala primero.`);
    throw err;
  }
}

interface SaleRef { id: string; folio: string; status: string; property_id: string; property_code: string; property_name: string; client_id: string; client_name: string }

async function saleFor(user: AuthUser, id: string): Promise<SaleRef> {
  const { rows } = await pool.query<SaleRef>(
    `SELECT s.id, s.folio, s.status, s.property_id, p.code AS property_code, p.name AS property_name, s.client_id, c.name AS client_name
       FROM sales s JOIN properties p ON p.id = s.property_id JOIN clients c ON c.id = s.client_id WHERE s.id = $1`,
    [id],
  );
  if (!rows[0]) throw new AppError(404, 'NOT_FOUND', 'La venta no existe.');
  await assertPropertyAccess(user, rows[0].property_id);
  return rows[0];
}

/** Anula una venta registrada por error: la casa vuelve a estar disponible (pausada; se publica a mano). */
export async function voidSale(user: AuthUser, id: string, reason: string): Promise<void> {
  const s = await saleFor(user, id);
  if (s.status !== 'closed') throw new AppError(409, 'SALE_VOIDED', `La venta ${s.folio} ya estaba anulada.`);
  await withTransaction(async (db) => {
    await db.query(`UPDATE sales SET status = 'voided', void_reason = $2, voided_at = now() WHERE id = $1`, [id, reason]);
    await db.query(`UPDATE properties SET status = 'disponible', updated_at = now() WHERE id = $1`, [s.property_id]);
    await db.query(`UPDATE clients SET follow_status = 'Venta anulada' WHERE id = $1 AND follow_status = 'Compra cerrada'`, [s.client_id]);
    await insertActivity({
      userId: user.id, propertyId: s.property_id, entity: 'sale', entityId: id, action: 'void',
      description: `${user.name} anuló la venta ${s.folio} de ${s.property_name} (${reason}).`,
    }, db);
    await notify([await userOfClient(s.client_id, db)], {
      type: 'sale_voided', title: 'Se anuló un registro de compra',
      message: `La inmobiliaria anuló el registro ${s.folio} de ${s.property_name}. Motivo: ${reason}. Si tienes dudas, contáctanos.`,
      entity: 'sale', entityId: id,
    }, db);
  });
}

/** POST /sales/:id/document — contrato de compraventa o promesa firmado (PDF ya subido con /documents/upload-url). */
export async function attachSalePdf(user: AuthUser, id: string, storageKey: string): Promise<string> {
  const s = await saleFor(user, id);
  if (!keyBelongsTo(storageKey, s.property_code, 'document') || !storageKey.endsWith('.pdf')) {
    throw new AppError(400, 'INVALID_FILE', 'El archivo no es un PDF subido para esta casa.');
  }
  const size = await fileSize(storageKey);
  if (size === null) throw new AppError(400, 'UPLOAD_NOT_FOUND', 'No encontramos el archivo. Termina de subirlo e inténtalo de nuevo.');
  return withTransaction(async (db) => {
    // No visible en la lista general de documentos de la casa: el comprador lo descarga desde su venta
    const { rows } = await db.query<{ id: string }>(
      `INSERT INTO documents (property_id, type, name, storage_key, mime, size, visible_to_client, uploaded_by)
       VALUES ($1, 'contract', $2, $3, 'application/pdf', $4, FALSE, $5) RETURNING id`,
      [s.property_id, `Contrato de compraventa · ${s.client_name} (${s.folio})`, storageKey, size, user.id],
    );
    await db.query('UPDATE sales SET document_id = $2 WHERE id = $1', [id, rows[0].id]);
    await insertActivity({ userId: user.id, propertyId: s.property_id, entity: 'sale', entityId: id, action: 'upload', description: `${user.name} subió el contrato firmado de la venta ${s.folio}.` }, db);
    return rows[0].id;
  });
}

/* ---------- Comprobante en PDF ---------- */

export const money = (n: number) => `$${n.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} MXN`;

const LONG_DATE = (iso: string) => new Date(`${iso}T12:00:00Z`).toLocaleDateString('es-MX', { day: 'numeric', month: 'long', year: 'numeric', timeZone: 'UTC' });

/** Las fuentes estándar del PDF solo tienen caracteres latinos: el resto se reemplaza. */
export const safe = (t: string) => t.replace(/[^\x20-\x7E -ÿ–—‘’“”•…]/g, '?');

export function wrap(text: string, font: PDFFont, size: number, width: number): string[] {
  const lines: string[] = [];
  let line = '';
  for (const word of safe(text).split(/\s+/)) {
    const next = line ? `${line} ${word}` : word;
    if (font.widthOfTextAtSize(next, size) > width && line) {
      lines.push(line);
      line = word;
    } else line = next;
  }
  if (line) lines.push(line);
  return lines;
}

export interface SaleReceiptData {
  folio: string; status: string; saleDate: string; price: number; paymentMethod: string | null; notary: string | null;
  property: { code: string; name: string; address: string | null }; client: { code: string | null; name: string };
  voidReason: string | null; issuedAt: Date;
}

/** Comprobante de cierre de compraventa con la inmobiliaria (no es factura ni escritura). */
export async function saleReceiptPdf(d: SaleReceiptData): Promise<Buffer> {
  const pdf = await PDFDocument.create();
  pdf.setTitle(`Comprobante de compra ${d.folio}`);
  pdf.setAuthor('Inmobiliaria Zugar');
  const page: PDFPage = pdf.addPage([612, 792]); // carta
  const regular = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  const ink = rgb(0.1, 0.12, 0.16);
  const muted = rgb(0.42, 0.45, 0.5);
  const brand = rgb(0.06, 0.38, 0.33);
  const left = 56;
  const width = 612 - left * 2;
  let y = 736;

  const text = (t: string, opts: { size?: number; font?: PDFFont; color?: ReturnType<typeof rgb>; x?: number } = {}) => {
    page.drawText(safe(t), { x: opts.x ?? left, y, size: opts.size ?? 11, font: opts.font ?? regular, color: opts.color ?? ink });
  };
  const paragraph = (t: string, size = 10, color = muted) => {
    for (const l of wrap(t, regular, size, width)) {
      text(l, { size, color });
      y -= size + 4;
    }
  };

  text('Inmobiliaria Zugar', { size: 20, font: bold, color: brand });
  text(`Folio ${d.folio}`, { size: 12, font: bold, x: 612 - left - bold.widthOfTextAtSize(`Folio ${d.folio}`, 12) });
  y -= 22;
  text('Comprobante de cierre de compraventa', { size: 14, font: bold });
  y -= 14;
  page.drawLine({ start: { x: left, y }, end: { x: 612 - left, y }, thickness: 1, color: rgb(0.85, 0.87, 0.9) });
  y -= 26;

  if (d.status === 'voided') {
    text('ANULADO', { size: 26, font: bold, color: rgb(0.75, 0.1, 0.1) });
    y -= 18;
    paragraph(`Este registro fue anulado por la inmobiliaria${d.voidReason ? `: ${d.voidReason}` : ''}. No tiene validez como comprobante.`, 10, rgb(0.6, 0.1, 0.1));
    y -= 10;
  }

  paragraph(`Inmobiliaria Zugar hace constar que ${d.client.name} cerró con nosotros la compra de la propiedad que se describe a continuación.`, 11, ink);
  y -= 12;

  const rows: [string, string][] = [
    ['Comprador', `${d.client.name}${d.client.code ? ` (${d.client.code})` : ''}`],
    ['Propiedad', `${d.property.name} (${d.property.code})`],
    ...(d.property.address ? [['Dirección', d.property.address] as [string, string]] : []),
    ['Fecha de cierre', LONG_DATE(d.saleDate)],
    ['Precio de venta', money(d.price)],
    ...(d.paymentMethod ? [['Forma de pago', d.paymentMethod] as [string, string]] : []),
    ...(d.notary ? [['Notaría', d.notary] as [string, string]] : []),
  ];
  for (const [label, value] of rows) {
    text(label, { size: 10, font: bold, color: muted });
    const lines = wrap(value, regular, 11, width - 140);
    for (const [i, l] of lines.entries()) {
      text(l, { size: 11, x: left + 140 });
      if (i < lines.length - 1) y -= 15;
    }
    y -= 24;
  }

  y -= 6;
  page.drawLine({ start: { x: left, y }, end: { x: 612 - left, y }, thickness: 1, color: rgb(0.85, 0.87, 0.9) });
  y -= 20;
  text('Importante', { size: 10, font: bold });
  y -= 15;
  paragraph('Este comprobante solo hace constar el cierre de la operación con la inmobiliaria. No es una factura (CFDI), no es la escritura pública y no transmite la propiedad: la compraventa de un inmueble se formaliza en escritura ante notario público y se inscribe en el Registro Público de la Propiedad.');
  y -= 6;
  paragraph('Inmobiliaria Zugar no administra la propiedad después de la venta. Para cualquier aclaración, comunícate con nosotros citando el folio.');

  page.drawText(safe(`Emitido el ${d.issuedAt.toLocaleString('es-MX', { timeZone: 'America/Cancun', dateStyle: 'long', timeStyle: 'short' })} (hora de Cancún) · ${d.folio}`), {
    x: left, y: 48, size: 8, font: regular, color: muted,
  });
  return Buffer.from(await pdf.save());
}
