import { Router } from 'express';
import * as C from '../controllers/activity.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requirePermission } from '../middlewares/authorize.js';
import { requirePropertyAccess } from '../middlewares/ownership.js';
import { validate } from '../middlewares/validate.js';

export const activityRouter = Router();

activityRouter.get(
  '/',
  authenticate,
  requirePermission('activity.read'),
  validate({ query: C.activityQueryDto }),
  requirePropertyAccess((req) => req.query.propertyId, { optional: true }),
  C.listActivityLog,
);
