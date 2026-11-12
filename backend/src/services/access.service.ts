import type { AuthUser } from '../middlewares/authenticate.js';
import { AppError } from '../middlewares/error-handler.js';
import * as Access from '../models/property-access.model.js';

/*
 * Pertenencia de recursos. Regla general:
 * - Propietario: acceso a todo (sus permisos se validan aparte con requirePermission).
 * - Administrador o broker-administrador: administra (expediente, pagos, contratos) solo las casas que tiene asignadas.
 * - Broker: no administra casas. Ver, proponer y agendar cualquier casa disponible no pasa por aquí.
 * - Cliente: solo a la propiedad con la que está vinculado (contrato vigente o inquilino registrado).
 */
export type PropertyAccess = 'ok' | 'not_found' | 'forbidden';

export function isAdmin(user: AuthUser): boolean {
  return user.type === 'staff' && (user.roles.includes('admin') || user.roles.includes('owner'));
}

export function isOwner(user: AuthUser): boolean {
  return user.type === 'staff' && user.roles.includes('owner');
}

export function isBroker(user: AuthUser): boolean {
  return user.type === 'staff' && user.roles.includes('broker');
}

export async function checkPropertyAccess(user: AuthUser, propertyId: string): Promise<PropertyAccess> {
  const brokerId = await Access.propertyBrokerId(propertyId);
  if (brokerId === undefined) return 'not_found';
  if (user.type === 'staff') {
    if (isOwner(user)) return 'ok';
    return user.permissions.has('properties.manage') && brokerId === user.id ? 'ok' : 'forbidden';
  }
  if (!user.clientId) return 'forbidden';
  return (await Access.clientLinkedToProperty(user.clientId, propertyId)) ? 'ok' : 'forbidden';
}

/** Igual que checkPropertyAccess pero lanza el error HTTP correspondiente. */
export async function assertPropertyAccess(user: AuthUser, propertyId: string): Promise<void> {
  const r = await checkPropertyAccess(user, propertyId);
  if (r === 'not_found') throw new AppError(404, 'NOT_FOUND', 'La propiedad no existe.');
  if (r === 'forbidden') throw new AppError(403, 'NOT_OWNER', 'Esto lo lleva el administrador que tiene asignada esta casa.');
}

/** Editar los datos de la casa y su disponibilidad: el propietario o quien la tiene asignada, sea cual sea su rol. */
export async function assertPropertyEdit(user: AuthUser, propertyId: string): Promise<void> {
  const brokerId = await Access.propertyBrokerId(propertyId);
  if (brokerId === undefined) throw new AppError(404, 'NOT_FOUND', 'La propiedad no existe.');
  if (!isOwner(user) && brokerId !== user.id) throw new AppError(403, 'NOT_OWNER', 'Esta casa no está asignada a ti.');
}

/** Alcance de propiedades para listados: null = todas (propietario); arreglo = solo esas (administrador o cliente). */
export async function propertyScope(user: AuthUser): Promise<string[] | null> {
  if (isOwner(user)) return null;
  if (user.type === 'staff') return user.permissions.has('properties.manage') ? Access.brokerPropertyIds(user.id) : [];
  return user.clientId ? Access.clientPropertyIds(user.clientId) : [];
}

/** Quita del objeto los datos del broker cuando la respuesta va para un cliente. */
export function forProfile<T extends Record<string, unknown>>(user: AuthUser, data: T): T {
  if (user.type === 'staff') return data;
  const copy = { ...data } as Record<string, unknown>;
  for (const k of ['broker', 'brokerId', 'broker_id', 'brokerName', 'broker_name', 'confirmedBy']) delete copy[k];
  return copy as T;
}
