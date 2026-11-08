import 'package:flutter/material.dart';

import '../../services/utils/formatters.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_spacing.dart';
import '../common/permission_gate.dart';
import '../common/segmented_tabs.dart';
import '../common/states.dart';
import '../../models/appointment.dart';
import '../../services/providers/appointments_provider.dart';
import 'appointment_card.dart';

/// Citas por estado: Por confirmar · Confirmadas · Realizadas · Canceladas (con cuántas hay en cada una).
/// La usan el personal (agenda) y el cliente (Mis citas); cada cita aparece en una sola pestaña.
class AppointmentsByStatus extends ConsumerStatefulWidget {
  const AppointmentsByStatus({super.key, this.initialFilter, this.staff = true});

  final int? initialFilter;

  /// Personal: acceso a Solicitudes. Cliente: botón «Solicitar visita».
  final bool staff;

  static const filters = ['Por confirmar', 'Confirmadas', 'Realizadas', 'Canceladas'];

  /// Pestaña de cada cita. Una confirmada que ya pasó cuenta como realizada (falta marcarla);
  /// una por confirmar que ya pasó sin confirmarse, como cancelada.
  static int tabOf(Appointment a, DateTime now) {
    final past = !a.scheduledAt.isAfter(now);
    return switch (a.status) {
      'por-confirmar' => past ? 3 : 0,
      'confirmada' => past ? 2 : 1,
      'realizada' => 2,
      _ => 3,
    };
  }

  /// Separa la lista según el filtro elegido: las vigentes de la más próxima a la más lejana; el historial, al revés.
  static List<Appointment> apply(List<Appointment> all, int filter, DateTime now) {
    final items = all.where((a) => tabOf(a, now) == filter).toList()..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return filter >= 2 ? items.reversed.toList() : items;
  }

  @override
  ConsumerState<AppointmentsByStatus> createState() => _AppointmentsByStatusState();
}

class _AppointmentsByStatusState extends ConsumerState<AppointmentsByStatus> {
  late int _filter = (widget.initialFilter ?? 0).clamp(0, AppointmentsByStatus.filters.length - 1);
  bool _picked = false;

  @override
  void didUpdateWidget(AppointmentsByStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilter != null && widget.initialFilter != oldWidget.initialFilter) {
      _filter = widget.initialFilter!.clamp(0, AppointmentsByStatus.filters.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(appointmentsProvider);
    final now = Fmt.now();
    final all = appointments.value ?? const <Appointment>[];
    final counts = List.generate(AppointmentsByStatus.filters.length, (i) => all.where((a) => AppointmentsByStatus.tabOf(a, now) == i).length);
    // Sin pestaña pedida: al cargar, se abre la primera que tenga citas (no una vacía)
    if (!_picked && appointments.hasValue) {
      _picked = true;
      if (widget.initialFilter == null && counts[_filter] == 0) {
        final first = counts.indexWhere((n) => n > 0);
        if (first >= 0) _filter = first;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedTabs(
          tabs: [for (var i = 0; i < counts.length; i++) counts[i] > 0 ? '${AppointmentsByStatus.filters[i]} · ${counts[i]}' : AppointmentsByStatus.filters[i]],
          selected: _filter,
          onChanged: (i) => setState(() => _filter = i),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.md, AppSpacing.screen, 0),
          child: widget.staff
              // Las citas nuevas salen de las solicitudes: ahí se agendan con «Agendar cita»
              ? PermissionGate(
                  permission: 'leads.manage',
                  child: OutlinedButton.icon(onPressed: () => context.go('/requests'), icon: const Icon(Icons.mark_email_unread_outlined), label: const Text('Solicitudes por agendar')),
                )
              // Una sola cita vigente por persona: si ya tiene una, «Solicitar visita» la cambia en lugar de crear otra
              : OutlinedButton.icon(
                  onPressed: () => context.push('/appointments/catalog'),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(counts[0] + counts[1] > 0 ? 'Cambiar mi visita a otra casa' : 'Solicitar visita'),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: switch (appointments) {
            AsyncData(:final value) => () {
              final items = AppointmentsByStatus.apply(value, _filter, now);
              if (items.isEmpty) {
                return EmptyState(
                  icon: Icons.event_available_outlined,
                  title: switch (_filter) {
                    0 => 'Nada por confirmar',
                    1 => 'Sin citas confirmadas',
                    2 => 'Sin visitas realizadas',
                    _ => 'Sin citas canceladas',
                  },
                  message: _filter == 0
                      ? (widget.staff ? 'Las solicitudes de visita del sitio y de la app aparecerán aquí.' : 'Cuando solicites una visita, aparecerá aquí hasta que tu asesor la confirme.')
                      : null,
                );
              }
              return RefreshIndicator(
                onRefresh: () => ref.refresh(appointmentsProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) => AppointmentCard(appointment: items[i], onTap: () => context.go('/appointments/${items[i].id}')),
                ),
              );
            }(),
            AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(appointmentsProvider)),
            _ => const LoadingState(),
          },
        ),
      ],
    );
  }
}
