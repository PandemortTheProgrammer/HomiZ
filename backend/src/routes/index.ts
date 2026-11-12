import { Router } from 'express';
import { getHealth } from '../controllers/health.controller.js';

/* Rutas de la API v1 (detalle en docs/api.md). */
export const apiRouter = Router();

apiRouter.get('/health', getHealth);
// Tiempo real: el panel escucha /events (SSE) y la app consulta /events/seq
