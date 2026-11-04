import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/utils/json_converters.dart';

part 'staff_dashboard.freezed.dart';
part 'staff_dashboard.g.dart';

/// GET /dashboard para el personal: pendientes y listas cortas (broker: sus casas; administración: todo).
@freezed
abstract class StaffDashboard with _$StaffDashboard {
  const factory StaffDashboard({
    @Default(<String>[]) List<String> roles,
    @Default(StaffCounts()) StaffCounts counts,
    @Default(<PendingAppointment>[]) List<PendingAppointment> pendingAppointments,
    @Default(<OverdueNote>[]) List<OverdueNote> overdueNotes,
    @Default(<NewReport>[]) List<NewReport> newReports,
  }) = _StaffDashboard;

  factory StaffDashboard.fromJson(Map<String, dynamic> json) => _$StaffDashboardFromJson(json);
}

@freezed
abstract class StaffCounts with _$StaffCounts {
  const factory StaffCounts({
    @Default(0) int appointmentsToConfirm,
    @Default(0) int appointmentsToday,
    @Default(0) int overdueNotes,
    @Default(0) int upcomingNotes,
    @Default(0) int newReports,
    @Default(0) int openReports,
    @Default(0) int overdueReceipts,
    @Default(0) int pendingExpenses,
    @Default(0) int upcomingMaintenance,
    @Default(0) int newLeads,
  }) = _StaffCounts;

  factory StaffCounts.fromJson(Map<String, dynamic> json) => _$StaffCountsFromJson(json);
}

@freezed
abstract class PendingAppointment with _$PendingAppointment {
  const factory PendingAppointment({
    required String id,
    required String code,
    required String clientName,
    required String propertyName,
    @LocalDate() required DateTime scheduledAt,
  }) = _PendingAppointment;

  factory PendingAppointment.fromJson(Map<String, dynamic> json) => _$PendingAppointmentFromJson(json);
}

@freezed
abstract class OverdueNote with _$OverdueNote {
  const factory OverdueNote({
    required String id,
    required int number,
    required double amount,
    @LocalDate() required DateTime dueDate,
    required String clientName,
    required String propertyName,
    String? propertyId,
  }) = _OverdueNote;

  factory OverdueNote.fromJson(Map<String, dynamic> json) => _$OverdueNoteFromJson(json);
}

@freezed
abstract class NewReport with _$NewReport {
  const factory NewReport({
    required String id,
    required String title,
    required String priority,
    required String status,
    required String propertyName,
    String? propertyId,
    @LocalDate() required DateTime createdAt,
  }) = _NewReport;

  factory NewReport.fromJson(Map<String, dynamic> json) => _$NewReportFromJson(json);
}
