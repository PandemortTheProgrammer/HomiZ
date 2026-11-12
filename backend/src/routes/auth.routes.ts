import { Router } from 'express';
import * as C from '../controllers/auth.controller.js';
import { validate } from '../middlewares/validate.js';
import { authenticate } from '../middlewares/authenticate.js';
import { authLimiter } from '../middlewares/rate-limit.js';

export const authRouter = Router();

authRouter.post('/login', authLimiter, validate({ body: C.loginDto }), C.login);
authRouter.post('/register', authLimiter, validate({ body: C.registerDto }), C.register);
authRouter.post('/refresh', validate({ body: C.refreshDto }), C.refresh);
authRouter.post('/logout', authenticate, validate({ body: C.logoutDto }), C.logout);
authRouter.post('/change-password', authenticate, validate({ body: C.changePasswordDto }), C.changePassword);
authRouter.post('/forgot-password', authLimiter, validate({ body: C.forgotPasswordDto }), C.forgotPassword);
authRouter.post('/reset-password', authLimiter, validate({ body: C.resetPasswordDto }), C.resetPassword);
authRouter.post('/delete-account', authLimiter, validate({ body: C.deleteAccountDto }), C.deleteAccount);