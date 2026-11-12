import { createApp } from './app.js';
import { env } from './config/env.js';
import { logger } from './config/logger.js';
import { pool } from './config/database.js';
import { attachWebSocket } from './services/live.service.js';

const server = createApp().listen(env.PORT, () => {
  logger.info(`API de Homiz escuchando en http://localhost:${env.PORT}/api/v1`);
});
// Tiempo real: /api/v1/ws en el mismo puerto
attachWebSocket(server);

async function shutdown(signal: string) {
  logger.info(`${signal} recibido, cerrando…`);
  server.close();
  await pool.end(); 
  process.exit(0);
}
process.on('SIGINT', () => void shutdown('SIGINT'));
process.on('SIGTERM', () => void shutdown('SIGTERM'));
