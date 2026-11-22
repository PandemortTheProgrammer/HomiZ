/* Genera el recibo de los pagarés que se pagaron antes de que existiera el recibo automático. */
import { pool } from './database.js';
import { issueReceipt } from '../services/payment-receipt.service.js';

const { rows } = await pool.query<{ id: string }>(
  `SELECT n.id FROM promissory_notes n
     JOIN payments pay ON pay.promissory_note_id = n.id AND NOT pay.voided
    WHERE NOT EXISTS (SELECT 1 FROM documents d WHERE d.promissory_note_id = n.id AND d.type = 'receipt')`,
);
for (const { id } of rows) await issueReceipt(id, null);
console.log(`Recibos generados: ${rows.length}`);
await pool.end();
