/* Imprime secretos aleatorios para .env: npm run secrets */
import { randomBytes } from 'node:crypto';

const make = () => randomBytes(48).toString('base64url');
console.log(`JWT_ACCESS_SECRET=${make()}`);
console.log(`JWT_REFRESH_SECRET=${make()}`);
