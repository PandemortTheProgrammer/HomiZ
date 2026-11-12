import type { Server } from 'node:http';
import type { Request, RequestHandler, Response } from 'express';
import { WebSocketServer, type WebSocket } from 'ws';
import { verifyAccessToken } from './token.service.js';
import { originAllowed } from '../config/cors.js';

/*
 * Avisos en tiempo real de «algo cambió» (sin datos: cada pantalla vuelve a pedir lo suyo con sus permisos).
 * - Cada escritura correcta de la API (POST/PATCH/PUT/DELETE) y cada notificación suben un contador.
 * - Panel y app escuchan por WebSocket (/api/v1/ws?token=…): el aviso llega al instante, también por los
 *   túneles de Cloudflare (que retienen el SSE). Respaldo: SSE (GET /events) y el contador (GET /events/seq).
 */
let seq = 0;
const streams = new Set<Response>();
const sockets = new Set<WebSocket>();

/** Algo cambió en [scope] (solicitudes, citas, pagos…): avisa a todas las pantallas conectadas. */
export function bump(scope: string): void {
  seq += 1;
  const msg = JSON.stringify({ seq, scope });
  const line = `data: ${msg}\n\n`;
  for (const res of streams) res.write(line);
  for (const ws of sockets) if (ws.readyState === ws.OPEN) ws.send(msg);
}

/** Canal WebSocket en el mismo servidor HTTP: /api/v1/ws?token=<token de acceso>. */
export function attachWebSocket(server: Server): WebSocketServer {
  // El canal solo envía avisos de «algo cambió»; no se aceptan mensajes grandes de los clientes
  const wss = new WebSocketServer({ noServer: true, maxPayload: 1024 });
  server.on('upgrade', (req, socket, head) => {
    const url = new URL(req.url ?? '', 'http://x');
    if (url.pathname !== '/api/v1/ws') return socket.destroy();
    // Solo desde el sitio, el panel o la app (no desde páginas ajenas)
    const host = String(req.headers['x-forwarded-host'] ?? req.headers.host ?? '');
    if (!originAllowed(req.headers.origin, host)) {
      socket.write('HTTP/1.1 403 Forbidden\r\nConnection: close\r\n\r\n');
      return socket.destroy();
    }
    if (!verifyAccessToken(url.searchParams.get('token') ?? '')) {
      socket.write('HTTP/1.1 401 Unauthorized\r\nConnection: close\r\n\r\n');
      return socket.destroy();
    }
    wss.handleUpgrade(req, socket, head, (ws) => {
      sockets.add(ws);
      ws.send(JSON.stringify({ seq, scope: 'hello' }));
      // Latido: los túneles cortan las conexiones calladas; si no contesta, se cierra
      let alive = true;
      ws.on('pong', () => (alive = true));
      const beat = setInterval(() => {
        if (!alive) return ws.terminate();
        alive = false;
        ws.ping();
      }, 25_000);
      ws.on('close', () => {
        clearInterval(beat);
        sockets.delete(ws);
      });
      ws.on('error', () => ws.terminate());
    });
  });
  return wss;
}

/** Middleware: tras cada escritura exitosa en la API, avisa que cambió ese recurso (/api/v1/leads/… → «leads»). */
export const bumpOnWrite: RequestHandler = (req, res, next) => {
  if (req.method !== 'GET' && req.method !== 'HEAD' && req.method !== 'OPTIONS') {
    res.on('finish', () => {
      const scope = req.path.split('/').filter(Boolean)[0] ?? '';
      if (res.statusCode < 400 && scope !== 'auth' && scope !== 'devices') bump(scope);
    });
  }
  next();
};

/** GET /events?token=… — flujo SSE (EventSource no puede mandar encabezados: el token va en la URL). */
export function stream(req: Request, res: Response): void {
  const token = typeof req.query.token === 'string' ? req.query.token : '';
  if (!verifyAccessToken(token)) {
    res.status(401).json({ error: { code: 'UNAUTHENTICATED', message: 'Tu sesión no es válida o expiró.' } });
    return;
  }
  res.writeHead(200, {
    'Content-Type': 'text/event-stream; charset=utf-8',
    'Cache-Control': 'no-cache, no-transform',
    Connection: 'keep-alive',
    'X-Accel-Buffering': 'no',
  });
  res.write(`retry: 5000\ndata: ${JSON.stringify({ seq, scope: 'hello' })}\n\n`);
  streams.add(res);
  // Latido: los túneles y proxys cortan las conexiones calladas
  const beat = setInterval(() => res.write(': ping\n\n'), 25_000);
  req.on('close', () => {
    clearInterval(beat);
    streams.delete(res);
  });
}

/** GET /events/seq — contador actual (la app lo consulta y, si cambió, vuelve a cargar). */
export const current: RequestHandler = (_req, res) => {
  res.json({ seq });
};
