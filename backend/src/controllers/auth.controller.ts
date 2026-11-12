import type { RequestHandler } from 'express';
import { z } from 'zod';
import * as Auth from '../services/auth.service.js';
import { passwordSchema } from '../services/password.service.js';
import { emailField, nameField, phoneField } from '../middlewares/validate.js';
import { currentUser } from '../middlewares/authenticate.js';
import { deleteClientAccount } from '../services/account-deletion.service.js';

/* ---------- DTOs ---------- */
export const loginDto = z.object({
  email: emailField,
  password: z.string({ error: 'Escribe tu contraseña.' }).min(1, 'Escribe tu contraseña.').max(128),
});
export const registerDto = z.object({
  name: nameField,
  email: emailField,
  phone: phoneField,
  password: passwordSchema,
  // Consentimiento expreso del aviso de privacidad (LFPDPPP)
  consent: z.literal(true, { error: 'Acepta el aviso de privacidad para crear tu cuenta.' }),
});
export const refreshDto = z.object({ refreshToken: z.string({ error: 'Falta el refresh token.' }).min(20).max(200) });
export const logoutDto = z.object({
  refreshToken: z.string().min(20).max(200).optional(),
  allDevices: z.boolean().optional().default(false),
});
export const changePasswordDto = z.object({
  currentPassword: z.string({ error: 'Escribe tu contraseña actual.' }).min(1, 'Escribe tu contraseña actual.').max(128),
  newPassword: passwordSchema,
});
export const forgotPasswordDto = z.object({ email: emailField });
export const resetPasswordDto = z.object({
  token: z.string({ error: 'Falta el código de recuperación.' }).min(20).max(200),
  password: passwordSchema,
});

/* ---------- Controladores ---------- */
export const login: RequestHandler = async (_req, res) => {
  const { email, password } = res.locals.body as z.infer<typeof loginDto>;
  res.json(await Auth.login(email, password));
};

export const register: RequestHandler = async (_req, res) => {
  const { consent: _consent, ...body } = res.locals.body as z.infer<typeof registerDto>;
  res.status(201).json(await Auth.register(body));
};

export const refresh: RequestHandler = async (_req, res) => {
  const { refreshToken } = res.locals.body as z.infer<typeof refreshDto>;
  res.json(await Auth.refresh(refreshToken));
};

export const logout: RequestHandler = async (_req, res) => {
  const { refreshToken, allDevices } = res.locals.body as z.infer<typeof logoutDto>;
  await Auth.logout(currentUser(res).id, refreshToken, allDevices);
  res.status(204).end();
};

export const changePassword: RequestHandler = async (_req, res) => {
  const { currentPassword, newPassword } = res.locals.body as z.infer<typeof changePasswordDto>;
  const session = await Auth.changePassword(currentUser(res).id, currentPassword, newPassword);
  res.json({ message: 'Tu contraseña se actualizó. Vuelve a iniciar sesión en tus otros dispositivos.', ...session });
};

export const forgotPassword: RequestHandler = async (_req, res) => {
  const { email } = res.locals.body as z.infer<typeof forgotPasswordDto>;
  await Auth.forgotPassword(email);
  res.json({ message: Auth.MSG_FORGOT });
};

export const resetPassword: RequestHandler = async (_req, res) => {
  const { token, password } = res.locals.body as z.infer<typeof resetPasswordDto>;
  await Auth.resetPassword(token, password);
  res.json({ message: 'Listo, ya puedes iniciar sesión con tu nueva contraseña.' });
};
/** POST /auth/delete-account — «Eliminar mi cuenta» desde el sitio (sin la app): con su correo y contraseña. */
export const deleteAccountDto = z.object({ email: emailField, password: z.string().min(1, 'Escribe tu contraseña.').max(128) });
export const deleteAccount: RequestHandler = async (_req, res) => {
  const { email, password } = res.locals.body as z.infer<typeof deleteAccountDto>;
  // Mismas reglas que el inicio de sesión (bloqueo por intentos, mensaje igual exista o no el correo)
  const session = await Auth.login(email, password);
  await deleteClientAccount(session.user.id);
  res.status(204).end();
};