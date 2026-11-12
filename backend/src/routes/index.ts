import { Router } from 'express';
import { getHealth } from '../controllers/health.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import * as Live from '../services/live.service.js';
import { authRouter } from './auth.routes.js';
import { usersRouter } from './users.routes.js';
import { activityRouter } from './activity.routes.js';

/* Rutas de la API v1 (detalle en docs/api.md). */
export const apiRouter = Router();

apiRouter.get('/health', getHealth);
// Tiempo real: el panel escucha /events (SSE) y la app consulta /events/seq
apiRouter.get('/events', Live.stream);
apiRouter.get('/events/seq', authenticate, Live.current);
apiRouter.use(Live.bumpOnWrite);
apiRouter.use('/auth', authRouter);
apiRouter.use('/users', usersRouter);
apiRouter.use('/activity-log', activityRouter);
