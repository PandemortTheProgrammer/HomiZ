import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/common/homiz_header.dart';
import '../../widgets/common/segmented_tabs.dart';
import '../../widgets/common/states.dart';
import '../../services/providers/session_provider.dart';
import '../../services/providers/dashboard_provider.dart';
import '../../widgets/maintenance/maintenance_tab.dart';
import '../../widgets/payments/payments_tab.dart';
import '../../widgets/property/dossier_tab.dart';
import '../../widgets/property/staff_properties_list.dart';
import '../../widgets/property/summary_tab.dart';

/// Pantallas 7–10 · Mi propiedad: Resumen · Expediente · Pagos · Mantenimiento.
class PropertyPage extends ConsumerStatefulWidget {
  const PropertyPage({super.key, this.initialTab});

  /// Pestaña pedida por la ruta (`/property?tab=2`), p. ej. desde las tarjetas del inicio.
  final int? initialTab;

  static const tabs = ['Resumen', 'Expediente', 'Pagos', 'Mantenimiento'];

  @override
  ConsumerState<PropertyPage> createState() => _PropertyPageState();
}

class _PropertyPageState extends ConsumerState<PropertyPage> {
  late int _tab = (widget.initialTab ?? 0).clamp(0, PropertyPage.tabs.length - 1);

  @override
  void didUpdateWidget(PropertyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != null && widget.initialTab != oldWidget.initialTab) {
      _tab = widget.initialTab!.clamp(0, PropertyPage.tabs.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = ref.watch(sessionProvider.select((s) => s.value?.isStaff ?? false));
    if (isStaff) {
      return const SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [HomizHeader(section: 'Propiedades'), Expanded(child: StaffPropertiesList())],
        ),
      );
    }
    final propertyId = ref.watch(myPropertyIdProvider);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomizHeader(section: 'Mi propiedad'),
          Expanded(
            child: switch (propertyId) {
              AsyncData(value: null) => const EmptyState(
                  icon: Icons.apartment_outlined,
                  title: 'Aún no tienes una propiedad asignada',
                  message: 'Cuando firmes tu contrato verás aquí tu expediente, pagos y mantenimiento.',
                ),
              AsyncData(:final value?) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedTabs(tabs: PropertyPage.tabs, selected: _tab, onChanged: (i) => setState(() => _tab = i)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: switch (_tab) {
                        0 => SummaryTab(propertyId: value),
                        1 => DossierTab(propertyId: value),
                        2 => const PaymentsTab(),
                        _ => MaintenanceTab(propertyId: value),
                      },
                    ),
                  ],
                ),
              AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(clientDashboardProvider)),
              _ => const LoadingState(),
            },
          ),
        ],
      ),
    );
  }
}
