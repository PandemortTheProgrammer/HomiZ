import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/utils/json_converters.dart';

part 'client_dashboard.freezed.dart';
part 'client_dashboard.g.dart';

/// GET /dashboard para el cliente: próximo pago, próxima cita y reportes abiertos.
@freezed
abstract class ClientDashboard with _$ClientDashboard {
  const factory ClientDashboard({
    DashboardProperty? property,
    DashboardPayment? nextPayment,
    DashboardAppointment? nextAppointment,
    @Default(OpenReports()) OpenReports openReports,
    @Default(0) int unreadNotifications,
  }) = _ClientDashboard;

  factory ClientDashboard.fromJson(Map<String, dynamic> json) => _$ClientDashboardFromJson(json);
}

@freezed
abstract class DashboardProperty with _$DashboardProperty {
  const factory DashboardProperty({required String id, required String name, String? zone}) = _DashboardProperty;

  factory DashboardProperty.fromJson(Map<String, dynamic> json) => _$DashboardPropertyFromJson(json);
}

@freezed
abstract class DashboardPayment with _$DashboardPayment {
  const factory DashboardPayment({
    required String id,
    required int number,
    required double amount,
    @LocalDate() required DateTime dueDate,
    required String status,
  }) = _DashboardPayment;

  factory DashboardPayment.fromJson(Map<String, dynamic> json) => _$DashboardPaymentFromJson(json);
}

@freezed
abstract class DashboardAppointment with _$DashboardAppointment {
  const factory DashboardAppointment({
    required String id,
    required String code,
    required String propertyName,
    @LocalDate() required DateTime scheduledAt,
    required String status,
  }) = _DashboardAppointment;

  factory DashboardAppointment.fromJson(Map<String, dynamic> json) => _$DashboardAppointmentFromJson(json);
}

@freezed
abstract class OpenReports with _$OpenReports {
  const factory OpenReports({@Default(0) int count, LatestReport? latest}) = _OpenReports;

  factory OpenReports.fromJson(Map<String, dynamic> json) => _$OpenReportsFromJson(json);
}

@freezed
abstract class LatestReport with _$LatestReport {
  const factory LatestReport({required String id, required String title, required String status, @LocalDate() required DateTime createdAt}) = _LatestReport;

  factory LatestReport.fromJson(Map<String, dynamic> json) => _$LatestReportFromJson(json);
}
