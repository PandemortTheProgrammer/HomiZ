import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../common/cards.dart';
import '../common/permission_gate.dart';
import '../common/primary_button.dart';
import '../common/states.dart';
import '../../services/providers/notifications_provider.dart';
import '../../services/providers/session_provider.dart';
import '../../models/staff_dashboard.dart';
import '../../services/providers/dashboard_provider.dart';

/// Punto 13 · Inicio del personal: tarjetas de pendientes y accesos rápidos.
/// El broker ve citas, solicitudes y el directorio; pagos, pagarés y reportes son de administración.
class StaffHome extends ConsumerWidget {
  const StaffHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(staffDashboardProvider);
    final admin = ref.watch(sessionProvider.select((s) => s.value?.isAdmin ?? false));
    return switch (dashboard) {
      AsyncData(:final value) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(notificationsProvider);
            ref.invalidate(staffDashboardProvider);
            await ref.read(staffDashboardProvider.future);
          },
          child: StaffDashboardView(dashboard: value, admin: admin),
        ),
      AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(staffDashboardProvider)),
      _ => const LoadingState(items: 3, itemHeight: 132),
    };
  }
}

class StaffDashboardView extends StatelessWidget {
  const StaffDashboardView({super.key, required this.dashboard, this.admin = true});

  final StaffDashboard dashboard;

  /// Administración ve todo; el broker, solo citas, solicitudes y el directorio de proveedores.
  final bool admin;

  static String _count(int n, String one, String many) => n == 0 ? 'Sin pendientes' : '$n ${n == 1 ? one : many}';

  @override
  Widget build(BuildContext context) {
    final c = dashboard.counts;
    final appt = dashboard.pendingAppointments.firstOrNull;
    final note = dashboard.overdueNotes.firstOrNull;
    final report = dashboard.newReports.firstOrNull;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm, AppSpacing.screen, AppSpacing.xl),
      children: [
        DashboardCard(
          title: 'Citas por confirmar...',
          value: _count(c.appointmentsToConfirm, 'cita', 'citas'),
          detail: appt == null ? null : '${appt.clientName} · ${appt.propertyName} · ${Fmt.appointment(appt.scheduledAt)}',
          illustration: 'assets/illustrations/cita.svg',
          onTap: () => context.go('/appointments?filter=0'),
        ),
        if (admin) ...[
          const SizedBox(height: AppSpacing.md),
          DashboardCard(
            title: 'Pagarés vencidos...',
            value: _count(c.overdueNotes, 'pagaré', 'pagarés'),
            detail: note == null ? null : '${note.clientName} · ${note.propertyName} · ${Fmt.money(note.amount)}',
            illustration: 'assets/illustrations/pago.svg',
            onTap: () => context.go('/home/overdue'),
          ),
          const SizedBox(height: AppSpacing.md),
          DashboardCard(
            title: 'Reportes abiertos...',
            value: _count(c.openReports, 'reporte', 'reportes'),
            detail: report == null ? null : '${report.title} · ${report.propertyName}',
            illustration: 'assets/illustrations/reportes.svg',
            onTap: () => context.go('/home/reports'),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text('Resumen', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.cardAll, border: Border.all(color: AppColors.divider)),
          child: Column(
            children: [
              KeyValueRow(label: 'Citas confirmadas hoy', value: '${c.appointmentsToday}'),
              if (admin) ...[
                KeyValueRow(label: 'Pagarés que vencen en 7 días', value: '${c.upcomingNotes}'),
                KeyValueRow(label: 'Reportes abiertos', value: '${c.openReports}'),
                KeyValueRow(label: 'Recibos vencidos', value: '${c.overdueReceipts}'),
                KeyValueRow(label: 'Mantenimientos en 14 días', value: '${c.upcomingMaintenance}'),
              ],
              KeyValueRow(label: 'Solicitudes nuevas del sitio', value: '${c.newLeads}', showDivider: false),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PermissionGate(
          permission: 'leads.manage',
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: PrimaryButton(
              label: c.newLeads > 0 ? 'Solicitudes · ${c.newLeads} nuevas' : 'Solicitudes del sitio y la app',
              icon: Icons.mark_email_unread_outlined,
              onPressed: () => context.go('/requests'),
            ),
          ),
        ),
        // Como «Pagos» del panel: todos los pagarés con registrar, corregir o anular el pago, sellos y PDF
        if (admin)
          PermissionGate(
            permission: 'properties.manage',
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: PrimaryButton(label: 'Pagos y pagarés', icon: Icons.payments_outlined, onPressed: () => context.go('/home/payments')),
            ),
          ),
        PrimaryButton(label: 'Directorio de proveedores', icon: Icons.engineering_outlined, variant: ButtonVariant.outline, onPressed: () => context.go('/home/providers')),
      ],
    );
  }
}
