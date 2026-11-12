import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/utils/json_converters.dart';

part 'maintenance_report.freezed.dart';
part 'maintenance_report.g.dart';

/// Categorías que acepta la API (backend/src/controllers/maintenance.controller.ts).
const maintenanceCategories = ['Plomería', 'Electricidad', 'Climatización', 'Cerrajería', 'Jardinería', 'Albercas', 'Pintura', 'Electrodomésticos', 'Otro'];

/// Reporte de mantenimiento. [timeline] y [photos] solo vienen en el detalle.
@freezed
abstract class MaintenanceReport with _$MaintenanceReport {
  const factory MaintenanceReport({
    required String id,
    ReportProperty? property,
    required String title,
    required String description,
    required String category,
    required String priority,
    required String subtitle,
    required String status,
    required String statusLabel,
    ReportProvider? provider,
    @LocalDateOrNull() DateTime? closedAt,
    @LocalDate() required DateTime createdAt,
    @Default(<TimelineEntry>[]) List<TimelineEntry> timeline,
    @Default(ReportPhotos()) ReportPhotos photos,
  }) = _MaintenanceReport;

  const MaintenanceReport._();

  factory MaintenanceReport.fromJson(Map<String, dynamic> json) => _$MaintenanceReportFromJson(json);

  bool get isOpen => status != 'resolved' && status != 'cancelled';
}

/// Estados a los que el personal puede mover un reporte, con su etiqueta.
const maintenanceStatusLabels = {
  'in_review': 'En revisión',
  'in_repair': 'En reparación',
  'resolved': 'Resuelto',
  'cancelled': 'Cancelado',
};

@freezed
abstract class ReportProperty with _$ReportProperty {
  const factory ReportProperty({required String id, String? code, required String name}) = _ReportProperty;

  factory ReportProperty.fromJson(Map<String, dynamic> json) => _$ReportPropertyFromJson(json);
}

@freezed
abstract class ReportProvider with _$ReportProvider {
  const factory ReportProvider({required String id, required String name, String? specialty, String? phone}) = _ReportProvider;

  factory ReportProvider.fromJson(Map<String, dynamic> json) => _$ReportProviderFromJson(json);
}

@freezed
abstract class TimelineEntry with _$TimelineEntry {
  const factory TimelineEntry({
    required String id,
    required String status,
    required String statusLabel,
    String? comment,
    String? author,
    @LocalDate() required DateTime createdAt,
  }) = _TimelineEntry;

  factory TimelineEntry.fromJson(Map<String, dynamic> json) => _$TimelineEntryFromJson(json);
}

@freezed
abstract class ReportPhotos with _$ReportPhotos {
  const factory ReportPhotos({@Default(<ReportPhoto>[]) List<ReportPhoto> before, @Default(<ReportPhoto>[]) List<ReportPhoto> after}) = _ReportPhotos;

  factory ReportPhotos.fromJson(Map<String, dynamic> json) => _$ReportPhotosFromJson(json);
}

@freezed
abstract class ReportPhoto with _$ReportPhoto {
  const factory ReportPhoto({required String id, required String url}) = _ReportPhoto;

  factory ReportPhoto.fromJson(Map<String, dynamic> json) => _$ReportPhotoFromJson(json);
}
