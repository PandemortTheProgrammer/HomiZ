import type { RequestHandler } from 'express';
import { currentUser, type AuthUser } from '../middlewares/authenticate.js';
import * as Repo from '../repositories/dashboard.repository.js';
import { isAdmin, isOwner, propertyScope } from '../services/access.service.js';
import { warnOwnerOfUnattended } from '../services/lead-window.service.js';

/* GET /dashboard — resumen según el perfil. El SQL vive en repositories/dashboard.repository.ts. */

async function clientDashboard(user: AuthUser) {
  const clientId = user.clientId ?? null;
  const [property, nextPayment, nextAppointment, report, unread] = await Promise.all([
    Repo.clientRentedProperty(clientId),
    Repo.clientNextPayment(clientId),
    Repo.clientNextAppointment(clientId),
    Repo.clientLatestOpenReport(clientId),
    Repo.unreadNotifications(user.id),
  ]);
  return {
    profile: 'client',
    property,
    nextPayment,
    nextAppointment,
    openReports: { count: Number(report?.total ?? 0), latest: report ? { id: report.id, title: report.title, status: report.status, createdAt: report.createdAt } : null },
    unreadNotifications: unread,
  };
}

async function staffDashboard(user: AuthUser) {
  // null = propietario (todo); lista = casas asignadas. Las citas se cuentan por broker asignado, igual que la lista de Citas.
  const scope: Repo.StaffScope = { propertyIds: await propertyScope(user), userId: user.id, adminWaits: isAdmin(user) && !isOwner(user), owner: isOwner(user) };
  await warnOwnerOfUnattended();
  const counts = await Repo.staffCounts(scope);
  const [pendingAppointments, overdueNotes, newReports] = await Promise.all([
    Repo.staffPendingAppointments(scope),
    Repo.staffOverdueNotes(scope),
    Repo.staffOpenReports(scope),
  ]);
  return { profile: 'staff', roles: user.roles, counts, pendingAppointments, overdueNotes, newReports };
}

export const getDashboard: RequestHandler = async (_req, res) => {
  const user = currentUser(res);
  res.json(user.type === 'client' ? await clientDashboard(user) : await staffDashboard(user));
};
