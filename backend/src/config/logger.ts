import pino from 'pino';
import { env } from './env.js';

/* Los logs nunca incluyen datos personales ni secretos: se ocultan encabezados y campos sensibles. */
export const logger = pino({
  level: env.NODE_ENV === 'test' ? 'silent' : 'info',
  redact: {
    paths: [
      'req.headers.authorization',
      'req.headers.cookie',
      '*.password',
      '*.password_hash',
      '*.token',
      '*.refreshToken',
      '*.email',
      '*.phone',
    ],
    censor: '[oculto]',
  },
});
