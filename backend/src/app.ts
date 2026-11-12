import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { pinoHttp } from 'pino-http';
import { env } from './config/env.js';

import { corsAllowed } from './config/cors.js';
export { corsAllowed };
import { logger } from './config/logger.js';

/** /api/v1/events?token=abc → ?token=[oculto]; /api/v1/files/<firma> → /api/v1/files/[oculto] */
export const redactUrl = (url: string) =>
  url.replace(/([?&](?:token|access_token|refreshToken)=)[^&]*/gi, '$1[oculto]').replace(/(\/files\/)[^/?]+/, '$1[oculto]');
import { requestId } from './middlewares/request-id.js';
import { errorHandler, notFound } from './middlewares/error-handler.js';
import { globalLimiter } from './middlewares/rate-limit.js';
import { apiRouter } from './routes/index.js';

export function createApp() {
  const app = express();
  app.disable('x-powered-by');
  app.set('trust proxy', 1);

  app.use(requestId);
  app.use(
    pinoHttp({
      logger,
      genReqId: (_req, res) => res.locals.requestId,
      // Los tokens nunca se escriben en los registros: ni el de sesión en ?token= ni el de los archivos firmados
      serializers: { req: (req) => ({ id: req.id, method: req.method, url: redactUrl(String(req.url)) }) },
    }),
  );
  // Las fotos firmadas (/files/:token) se muestran desde el sitio, el panel y la app, que viven en otro origen.
  app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
  app.use(
    cors({
      // CORS mínimo: solo los orígenes configurados (sitio web, panel y app web).
      origin: (origin, cb) => cb(null, !origin || corsAllowed(origin)),
      credentials: false,
    }),
  );
  app.use(globalLimiter);
  app.use(express.json({ limit: '1mb' }));

  app.use('/api/v1', apiRouter);
  app.use(notFound);
  app.use(errorHandler);
  return app;
}
