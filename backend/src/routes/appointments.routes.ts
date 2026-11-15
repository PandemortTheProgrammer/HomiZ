import { Router } from 'express';
import * as C from '../controllers/appointments.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { idParam, validate } from '../middlewares/validate.js';

/*
 * Clientes y personal comparten rutas; el servicio aplica qué puede hacer cada perfil
 * (confirmar, rechazar y marcar realizada: solo personal con appointments.manage).
 */
export const appointmentsRouter = Router();
appointmentsRouter.use(authenticate);

appointmentsRouter.get('/', validate({ query: C.listQueryDto }), C.list);
appointmentsRouter.post('/', validate({ body: C.createDto }), C.create);
appointmentsRouter.get('/active', C.active);
appointmentsRouter.get('/:id', validate({ params: idParam }), C.getOne);
appointmentsRouter.post('/:id/confirm', validate({ params: idParam }), C.confirm);
appointmentsRouter.post('/:id/reject', validate({ params: idParam, body: C.reasonDto }), C.reject);
appointmentsRouter.post('/:id/cancel', validate({ params: idParam, body: C.reasonDto }), C.cancel);
appointmentsRouter.post('/:id/complete', validate({ params: idParam }), C.complete);
appointmentsRouter.post('/:id/reschedule', validate({ params: idParam, body: C.rescheduleDto }), C.reschedule);
appointmentsRouter.get('/:id/messages', validate({ params: idParam }), C.listMessages);
appointmentsRouter.post('/:id/messages', validate({ params: idParam, body: C.messageDto }), C.postMessage);
