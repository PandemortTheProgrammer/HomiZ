import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../repositories/documents_repository.dart';
import 'dashboard_provider.dart';
import '../../models/maintenance_report.dart';
import '../repositories/maintenance_repository.dart';

/// Reportes de una casa (abiertos primero, como los ordena la API).
final maintenanceReportsProvider = FutureProvider.family<List<MaintenanceReport>, String>(
  (ref, propertyId) => ref.watch(maintenanceRepositoryProvider).list(propertyId: propertyId),
);

final maintenanceReportProvider = FutureProvider.family<MaintenanceReport, String>((ref, id) => ref.watch(maintenanceRepositoryProvider).get(id));

/// Reportes de las casas del personal que siguen abiertos: salen del inicio cuando se resuelven (o se cancelan).
final newReportsProvider = FutureProvider<List<MaintenanceReport>>((ref) => ref.watch(maintenanceRepositoryProvider).list(status: const ['reported', 'in_review', 'in_repair']));

final newReportProvider = Provider<NewReportAction>(NewReportAction.new);

/// Sube las fotos (máx. 5) y crea el reporte; después refresca la lista y el panel.
class NewReportAction {
  NewReportAction(this._ref);

  final Ref _ref;

  Future<MaintenanceReport> submit({
    required String propertyId,
    required String title,
    required String description,
    required String category,
    required String priority,
    List<XFile> photos = const [],
  }) async {
    final docs = _ref.read(documentsRepositoryProvider);
    final keys = <String>[];
    for (final p in photos) {
      keys.add(await docs.uploadMaintenancePhoto(propertyId, p));
    }
    final report = await _ref.read(maintenanceRepositoryProvider).create(
          propertyId: propertyId,
          title: title,
          description: description,
          category: category,
          priority: priority,
          photos: keys,
        );
    _ref.invalidate(maintenanceReportsProvider(propertyId));
    _ref.invalidate(clientDashboardProvider);
    _ref.invalidate(staffDashboardProvider);
    return report;
  }
}

final maintenanceActionsProvider = Provider<MaintenanceActions>(MaintenanceActions.new);

/// Cambios de estado del personal (UpdateStatusSheet).
class MaintenanceActions {
  MaintenanceActions(this._ref);

  final Ref _ref;

  Future<MaintenanceReport> updateStatus(String reportId, {required String status, String? comment, String? providerId}) async {
    final report = await _ref.read(maintenanceRepositoryProvider).addUpdate(reportId, status: status, comment: comment, providerId: providerId);
    _ref.invalidate(maintenanceReportProvider(reportId));
    _ref.invalidate(maintenanceReportsProvider);
    _ref.invalidate(newReportsProvider);
    _ref.invalidate(staffDashboardProvider);
    return report;
  }
}
