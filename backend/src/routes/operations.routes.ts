import express, { Router } from 'express';
import * as Utilities from '../controllers/utilities.controller.js';
import * as Maintenance from '../controllers/maintenance.controller.js';
import * as Providers from '../controllers/providers.controller.js';
import * as Expenses from '../controllers/expenses.controller.js';
import * as Documents from '../controllers/documents.controller.js';
import * as Notifications from '../controllers/notifications.controller.js';
import { getDashboard } from '../controllers/dashboard.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requirePermission, requireStaff } from '../middlewares/authorize.js';
import { idParam, validate } from '../middlewares/validate.js';

/* Servicios de luz y agua (personal) */
export const utilityServicesRouter = Router();
utilityServicesRouter.use(authenticate, requirePermission('receipts.manage'));
utilityServicesRouter.get('/', validate({ query: Utilities.serviceQueryDto }), Utilities.listServices);
utilityServicesRouter.post('/', validate({ body: Utilities.serviceCreateDto }), Utilities.createService);
utilityServicesRouter.patch('/:id', validate({ params: idParam, body: Utilities.serviceUpdateDto }), Utilities.updateService);

/* Recibos y fichas de cobro: el cliente consulta los de su casa; el personal los registra */
export const receiptsRouter = Router();
receiptsRouter.use(authenticate);
receiptsRouter.get('/', validate({ query: Utilities.receiptQueryDto }), Utilities.listReceipts);
receiptsRouter.get('/:id', validate({ params: idParam }), Utilities.getReceipt);
receiptsRouter.post('/', requirePermission('receipts.manage'), validate({ body: Utilities.receiptCreateDto }), Utilities.createReceipt);
receiptsRouter.patch('/:id', requirePermission('receipts.manage'), validate({ params: idParam, body: Utilities.receiptUpdateDto }), Utilities.updateReceipt);

/* Mantenimiento: el cliente reporta en su casa; el personal actualiza el estado */
export const maintenanceRouter = Router();
maintenanceRouter.use(authenticate);
maintenanceRouter.get('/', validate({ query: Maintenance.listQueryDto }), Maintenance.list);
maintenanceRouter.post('/', validate({ body: Maintenance.createDto }), Maintenance.create);
maintenanceRouter.get('/:id', validate({ params: idParam }), Maintenance.getOne);
maintenanceRouter.get('/:id/updates', validate({ params: idParam }), Maintenance.getUpdates);
maintenanceRouter.post('/:id/updates', requirePermission('maintenance.manage'), validate({ params: idParam, body: Maintenance.updateDto }), Maintenance.addUpdate);

/* Proveedores: consulta para todo el personal; altas y cambios con providers.manage */
export const providersRouter = Router();
providersRouter.use(authenticate, requireStaff);
providersRouter.get('/', validate({ query: Providers.listQueryDto }), Providers.list);
providersRouter.get('/:id', validate({ params: idParam }), Providers.getOne);
providersRouter.post('/', requirePermission('providers.manage'), validate({ body: Providers.createDto }), Providers.create);
providersRouter.patch('/:id', requirePermission('providers.manage'), validate({ params: idParam, body: Providers.updateDto }), Providers.update);
providersRouter.delete('/:id', requirePermission('providers.manage'), validate({ params: idParam }), Providers.remove);

/* Gastos */
export const expensesRouter = Router();
expensesRouter.use(authenticate, requirePermission('expenses.manage'));
expensesRouter.get('/', validate({ query: Expenses.listQueryDto }), Expenses.list);
expensesRouter.get('/:id', validate({ params: idParam }), Expenses.getOne);
expensesRouter.post('/', validate({ body: Expenses.createDto }), Expenses.create);
expensesRouter.patch('/:id', validate({ params: idParam, body: Expenses.updateDto }), Expenses.update);

/* Documentos (URL firmadas) */
export const documentsRouter = Router();
documentsRouter.use(authenticate);
documentsRouter.post('/upload-url', validate({ body: Documents.uploadUrlDto }), Documents.uploadUrl);
documentsRouter.get('/', validate({ query: Documents.listQueryDto }), Documents.list);
documentsRouter.post('/', requirePermission('documents.manage'), validate({ body: Documents.confirmDto }), Documents.confirm);
documentsRouter.get('/:id/download-url', validate({ params: idParam }), Documents.downloadUrl);
documentsRouter.patch('/:id', requirePermission('documents.manage'), validate({ params: idParam, body: Documents.updateDto }), Documents.update);
documentsRouter.delete('/:id', requirePermission('documents.delete'), validate({ params: idParam }), Documents.remove);

/* Archivos del almacenamiento local (destino de las URL firmadas; la firma es la autorización) */
export const filesRouter = Router();
filesRouter.put('/:token', express.raw({ type: () => true, limit: '51mb' }), Documents.putFile);
filesRouter.get('/:token', Documents.getFile);

/* Notificaciones y dispositivos */
export const notificationsRouter = Router();
notificationsRouter.use(authenticate);
notificationsRouter.get('/', validate({ query: Notifications.listQueryDto }), Notifications.list);
notificationsRouter.post('/read-all', Notifications.markAllRead);
notificationsRouter.patch('/:id/read', validate({ params: idParam }), Notifications.markRead);

export const devicesRouter = Router();
devicesRouter.use(authenticate);
devicesRouter.post('/', validate({ body: Notifications.deviceDto }), Notifications.registerDevice);
devicesRouter.delete('/:token', Notifications.unregisterDevice);

/* Dashboard */
export const dashboardRouter = Router();
dashboardRouter.get('/', authenticate, getDashboard);
