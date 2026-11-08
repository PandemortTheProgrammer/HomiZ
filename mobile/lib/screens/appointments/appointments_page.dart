import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/common/homiz_header.dart';
import '../../services/providers/session_provider.dart';
import '../../widgets/appointments/staff_appointments.dart';

/// Pantalla 5 · Mis citas (cliente) o Citas (personal), separadas por estado.
class AppointmentsPage extends ConsumerWidget {
  const AppointmentsPage({super.key, this.initialFilter});

  /// Pestaña pedida por la ruta (`/appointments?filter=0`).
  final int? initialFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStaff = ref.watch(sessionProvider.select((s) => s.value?.isStaff ?? false));
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomizHeader(section: isStaff ? 'Citas' : 'Mis citas'),
          Expanded(
            child: AppointmentsByStatus(initialFilter: initialFilter, staff: isStaff),
          ),
        ],
      ),
    );
  }
}
