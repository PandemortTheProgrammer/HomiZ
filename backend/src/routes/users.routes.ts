import { Router } from 'express';
import * as C from '../controllers/users.controller.js';
import * as Staff from '../controllers/staff.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { requirePermission } from '../middlewares/authorize.js';
import { idParam, validate } from '../middlewares/validate.js';

export const usersRouter = Router();
usersRouter.use(authenticate);

/* Perfil propio (cualquier usuario). */
usersRouter.get('/me', C.getMe);
usersRouter.patch('/me', validate({ body: C.updateMeDto }), C.updateMe);
// «Eliminar mi cuenta» (derecho de cancelación): solo clientes, con su contraseña
usersRouter.delete('/me', validate({ body: C.deleteMeDto }), C.deleteMe);

/* Personal, roles y permisos (administración). */
usersRouter.get('/', requirePermission('users.manage'), validate({ query: Staff.listQueryDto }), Staff.list);
usersRouter.post('/', requirePermission('users.manage'), validate({ body: Staff.createDto }), Staff.create);
usersRouter.get('/roles', requirePermission('users.manage'), Staff.listRoles);
usersRouter.put('/roles/:code/permissions', requirePermission('users.manage'), validate({ params: Staff.roleParam, body: Staff.rolePermissionsDto }), Staff.setRolePermissions);
usersRouter.patch('/:id', requirePermission('users.manage'), validate({ params: idParam, body: Staff.updateDto }), Staff.update);
