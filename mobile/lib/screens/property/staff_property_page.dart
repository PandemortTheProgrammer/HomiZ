import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/theme/app_spacing.dart';
import '../../widgets/common/segmented_tabs.dart';
import '../../widgets/common/states.dart';
import '../../widgets/maintenance/maintenance_tab.dart';
import '../../widgets/payments/payments_tab.dart';
import '../../services/providers/property_provider.dart';
import '../../widgets/property/dossier_tab.dart';
import '../../widgets/property/summary_tab.dart';
import 'property_page.dart';

/// Ficha de una casa para el personal: Resumen (con inquilino y asesor) · Expediente · Pagos · Mantenimiento.
class StaffPropertyPage extends ConsumerStatefulWidget {
  const StaffPropertyPage({super.key, required this.propertyId, this.initialTab});

  final String propertyId;
  final int? initialTab;

  @override
  ConsumerState<StaffPropertyPage> createState() => _StaffPropertyPageState();
}

class _StaffPropertyPageState extends ConsumerState<StaffPropertyPage> {
  late int _tab = (widget.initialTab ?? 0).clamp(0, PropertyPage.tabs.length - 1);

  @override
  Widget build(BuildContext context) {
    final dossier = ref.watch(dossierProvider(widget.propertyId));
    return Scaffold(
      appBar: AppBar(title: Text(dossier.value?.property.name ?? 'Propiedad')),
      body: switch (dossier) {
        AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedTabs(tabs: PropertyPage.tabs, selected: _tab, onChanged: (i) => setState(() => _tab = i)),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: switch (_tab) {
                  0 => SummaryTab(propertyId: widget.propertyId),
                  1 => DossierTab(propertyId: widget.propertyId, staff: true),
                  // Solo el contrato vigente genera pagarés.
                  2 => PaymentsTab(
                      staff: true,
                      propertyId: widget.propertyId,
                      contractId: value.contract?.status == 'active' ? value.contract!.id : null,
                    ),
                  _ => MaintenanceTab(propertyId: widget.propertyId),
                },
              ),
            ],
          ),
        AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(dossierProvider(widget.propertyId))),
        _ => const LoadingState(),
      },
    );
  }
}
