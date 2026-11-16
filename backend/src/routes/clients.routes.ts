import { Router } from 'express';
import * as Clients from '../controllers/clients.controller.js';
import * as Contracts from '../controllers/contracts.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requirePermission } from '../middlewares/authorize.js';
import { idParam, validate } from '../middlewares/validate.js';

export const clientsRouter = Router();
clientsRouter.use(authenticate, requirePermission('clients.manage'));
clientsRouter.get('/', validate({ query: Clients.listQueryDto }), Clients.list);
clientsRouter.get('/:id', validate({ params: idParam }), Clients.getOne);
clientsRouter.get('/:id/overview', validate({ params: idParam }), Clients.overview);
clientsRouter.post('/', validate({ body: Clients.createDto }), Clients.create);
clientsRouter.patch('/:id', validate({ params: idParam, body: Clients.updateDto }), Clients.update);
clientsRouter.delete('/:id', validate({ params: idParam }), Clients.remove);

export const contractsRouter = Router();
contractsRouter.use(authenticate);
// Consultar (sección «Rentas»): el personal que atiende clientes (el broker, solo sus casas). Hacer cambios: administración.
contractsRouter.get('/', requirePermission('clients.manage'), validate({ query: Contracts.listQueryDto }), Contracts.list);
contractsRouter.get('/:id', requirePermission('clients.manage'), validate({ params: idParam }), Contracts.getOne);
contractsRouter.use(requirePermission('contracts.manage'));
contractsRouter.post('/', validate({ body: Contracts.createDto }), Contracts.create);
contractsRouter.post('/:id/finish', validate({ params: idParam, body: Contracts.finishDto }), Contracts.finish);
// PDF del contrato firmado y de los pagarés (uno solo con todas las hojas: se separa, hoja N → pagaré N)
contractsRouter.post('/:id/document', validate({ params: idParam, body: Contracts.pdfDto }), Contracts.attachDocument);
