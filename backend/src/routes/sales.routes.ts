import { Router, type RequestHandler } from 'express';
import * as Sales from '../controllers/sales.controller.js';
import { authenticate, currentUser } from '../middlewares/authenticate.js';
import { requirePermission } from '../middlewares/authorize.js';
import { idParam, validate } from '../middlewares/validate.js';

/** Personal: consultar exige atender clientes (el broker, solo sus casas). El cliente solo ve sus compras. */
const staffNeedsClients: RequestHandler = (req, res, next) =>
  currentUser(res).type === 'client' ? next() : requirePermission('clients.manage')(req, res, next);

/* Ventas: comprobante de que el cliente cerró la compra con la inmobiliaria (decisión 124). */
export const salesRouter = Router();
salesRouter.use(authenticate);
salesRouter.get('/', staffNeedsClients, validate({ query: Sales.listQueryDto }), Sales.list);
salesRouter.get('/anti-money-laundering', requirePermission('clients.manage'), Sales.thresholds);
salesRouter.get('/:id', staffNeedsClients, validate({ params: idParam }), Sales.getOne);
salesRouter.get('/:id/receipt-url', staffNeedsClients, validate({ params: idParam }), Sales.receiptUrl);
salesRouter.get('/:id/document-url', staffNeedsClients, validate({ params: idParam }), Sales.documentUrl);
// Registrar, anular y subir el contrato: administración (igual que los contratos de renta)
salesRouter.post('/', requirePermission('contracts.manage'), validate({ body: Sales.createDto }), Sales.create);
salesRouter.post('/:id/void', requirePermission('contracts.manage'), validate({ params: idParam, body: Sales.voidDto }), Sales.voidOne);
salesRouter.post('/:id/document', requirePermission('contracts.manage'), validate({ params: idParam, body: Sales.pdfDto }), Sales.attachDocument);
