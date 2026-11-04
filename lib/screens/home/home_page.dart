import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/theme/app_spacing.dart';
import '../../services/utils/formatters.dart';
import '../../widgets/common/cards.dart';
import '../../widgets/common/homiz_header.dart';
import '../../widgets/common/states.dart';
import '../../services/providers/session_provider.dart';
import '../../services/providers/notifications_provider.dart';
import '../../models/client_dashboard.dart';
import '../../services/providers/dashboard_provider.dart';
import '../../widgets/home/staff_home.dart';

/// Pantalla 4 · Inicio: próxima cita y solicitudes.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStaff = ref.watch(sessionProvider.select((s) => s.value?.isStaff ?? false));
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomizHeader(section: isStaff ? 'Pendientes' : 'Información'),
          Expanded(child: isStaff ? const StaffHome() : const _ClientHome()),
        ],
      ),
    );
  }
}

class _ClientHome extends ConsumerWidget {
  const _ClientHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(clientDashboardProvider);
    Future<void> reload() async {
      ref.invalidate(notificationsProvider);
      return ref.refresh(clientDashboardProvider.future).then((_) {});
    }

    return switch (dashboard) {
      AsyncData(:final value) => RefreshIndicator(onRefresh: reload, child: DashboardCards(dashboard: value)),
      AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(clientDashboardProvider)),
      _ => const LoadingState(items: 3, itemHeight: 132),
    };
  }
}

/// Las tarjetas azules del inicio (separadas para probarlas sin red).
class DashboardCards extends StatelessWidget {
  const DashboardCards({super.key, required this.dashboard});

  final ClientDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final appt = dashboard.nextAppointment;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm, AppSpacing.screen, AppSpacing.xl),
      children: [
        DashboardCard(
          title: 'Próxima cita...',
          value: appt == null ? 'Sin citas próximas' : Fmt.dayMonth(appt.scheduledAt),
          detail: appt == null ? null : '${appt.propertyName} · ${Fmt.time(appt.scheduledAt)}',
          illustration: 'assets/illustrations/cita.svg',
          onTap: () => appt == null ? context.go('/appointments') : context.go('/appointments/${appt.id}'),
        ),
        const SizedBox(height: AppSpacing.md),
        // «Busco casa»: lo que pide al asesor y las casas que le propone (en lugar del correo)
        DashboardCard(
          title: 'Mis solicitudes...',
          value: 'Nueva solicitud',
          detail: 'Rentar, comprar o publicar: tu asesor te contesta aquí',
          illustration: 'assets/illustrations/solicitud.svg',
          onTap: () => context.go('/home/requests'),
        ),
      ],
    );
  }
}
