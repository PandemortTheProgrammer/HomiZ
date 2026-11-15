import { Router } from 'express';
import * as C from '../controllers/public.controller.js';
import * as Leads from '../controllers/leads.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requirePermission } from '../middlewares/authorize.js';
import { authLimiter } from '../middlewares/rate-limit.js';
import { idParam, validate } from '../middlewares/validate.js';

/* Sin sesión: lo que usa el sitio web. */
export const publicRouter = Router();
publicRouter.get('/legal', C.legal);
publicRouter.get('/properties', validate({ query: C.catalogQueryDto }), C.catalog);
publicRouter.get('/properties/:slug', C.bySlug);
publicRouter.get('/properties/:slug/busy', validate({ query: C.busyQueryDto }), C.busy);
publicRouter.post('/leads', authLimiter, validate({ body: C.leadDto }), C.postLead);
publicRouter.patch('/leads/:folio', authLimiter, validate({ body: C.correctionDto }), C.correctLead);

/* Con sesión: el personal atiende las solicitudes (contesta y propone casas). */
export const leadsRouter = Router();
leadsRouter.use(authenticate, requirePermission('leads.manage'));
leadsRouter.get('/', validate({ query: Leads.listQueryDto }), Leads.list);
leadsRouter.post('/', validate({ body: Leads.createDto }), Leads.create);
leadsRouter.get('/:id', validate({ params: idParam }), Leads.getOne);
leadsRouter.patch('/:id', validate({ params: idParam, body: Leads.updateDto }), Leads.update);
leadsRouter.delete('/:id', validate({ params: idParam }), Leads.remove);
leadsRouter.post('/:id/appointment', validate({ params: idParam, body: Leads.appointmentDto }), Leads.schedule);
leadsRouter.post('/:id/take', validate({ params: idParam }), Leads.take);
leadsRouter.patch('/:id/broker', validate({ params: idParam, body: Leads.brokerDto }), Leads.assignBroker);
leadsRouter.post('/:id/proposals', validate({ params: idParam, body: Leads.proposalDto }), Leads.addProposal);
leadsRouter.delete('/:id/proposals/:proposalId', validate({ params: Leads.proposalParams }), Leads.removeProposal);
leadsRouter.get('/:id/messages', validate({ params: idParam }), Leads.staffMessages);
leadsRouter.post('/:id/messages', validate({ params: idParam, body: Leads.messageDto }), Leads.staffSend);

/* Cliente de la app: «Mis solicitudes» (lo que busca y las casas que le propone su asesor). */
export const requestsRouter = Router();
requestsRouter.use(authenticate);
requestsRouter.get('/', Leads.mine);
requestsRouter.post('/', validate({ body: Leads.myRequestDto }), Leads.createMine);
requestsRouter.get('/:id', validate({ params: idParam }), Leads.mineOne);
requestsRouter.patch('/:id', validate({ params: idParam, body: Leads.editRequestDto }), Leads.updateMine);
requestsRouter.get('/:id/messages', validate({ params: idParam }), Leads.mineMessages);
requestsRouter.post('/:id/messages', validate({ params: idParam, body: Leads.messageDto }), Leads.mineSend);
