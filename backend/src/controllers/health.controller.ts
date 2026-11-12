import type { RequestHandler } from 'express';
import { checkDatabase } from '../config/database.js';

/* GET /api/v1/health — estado del servicio y de la base de datos. */
export const getHealth: RequestHandler = async (_req, res) => {
  const database = await checkDatabase();
  res.status(database ? 200 : 503).json({
    status: database ? 'ok' : 'degraded',
    service: 'homiz-api',
    database: database ? 'up' : 'down',
    time: new Date().toISOString(),
  });
};
