import { Router } from 'express';
import * as C from '../controllers/payments.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requirePermission, requireStaff } from '../middlewares/authorize.js';
import { idParam, validate } from '../middlewares/validate.js';

/* Pagarés: el cliente solo consulta los suyos; el personal registra pagos en efectivo. */
export const paymentsRouter = Router();
paymentsRouter.use(authenticate);

paymentsRouter.get('/', validate({ query: C.listQueryDto }), C.list);
paymentsRouter.post('/', requireStaff, requirePermission('contracts.manage'), validate({ body: C.createNoteDto }), C.createNote);
paymentsRouter.post('/:id/cancel', requireStaff, requirePermission('contracts.manage'), validate({ params: idParam, body: C.cancelNoteDto }), C.cancelNote);
paymentsRouter.get('/:id', validate({ params: idParam }), C.getOne);
paymentsRouter.patch('/:id', requireStaff, requirePermission('contracts.manage'), validate({ params: idParam, body: C.updateNoteDto }), C.updateNote);
paymentsRouter.post('/:id/payments', requireStaff, requirePermission('payments.register'), validate({ params: idParam, body: C.paymentDto }), C.registerPayment);
paymentsRouter.patch('/:id/payments/:paymentId', requireStaff, requirePermission('payments.correct'), validate({ params: C.paymentParams, body: C.correctDto }), C.correctPayment);
paymentsRouter.post('/:id/payments/:paymentId/void', requireStaff, requirePermission('payments.correct'), validate({ params: C.paymentParams, body: C.voidDto }), C.voidPayment);
