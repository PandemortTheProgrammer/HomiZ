import { Router } from 'express';
import * as C from '../controllers/properties.controller.js';
import * as Dossier from '../controllers/dossier.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requirePermission } from '../middlewares/authorize.js';
import { idParam, validate } from '../middlewares/validate.js';

export const propertiesRouter = Router();
propertiesRouter.use(authenticate);

propertiesRouter.get('/', validate({ query: C.listQueryDto }), C.list);
propertiesRouter.get('/:id', validate({ params: idParam }), C.getOne);
propertiesRouter.post('/', requirePermission('properties.create'), validate({ body: C.createDto }), C.create);
propertiesRouter.post('/locate', requirePermission('properties.update'), validate({ body: C.locateDto }), C.locate);
propertiesRouter.patch('/:id', requirePermission('properties.update'), validate({ params: idParam, body: C.updateDto }), C.update);
propertiesRouter.patch('/:id/availability', requirePermission('properties.update'), validate({ params: idParam, body: C.availabilityDto }), C.setAvailability);
propertiesRouter.patch('/:id/broker', requirePermission('properties.reassign'), validate({ params: idParam, body: C.brokerDto }), C.reassign);
propertiesRouter.delete('/:id', requirePermission('properties.update'), validate({ params: idParam }), C.remove);
propertiesRouter.get('/:id/dossier', validate({ params: idParam }), Dossier.getDossier);
