// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StaffDashboard _$StaffDashboardFromJson(Map<String, dynamic> json) =>
    _StaffDashboard(
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      counts: json['counts'] == null
          ? const StaffCounts()
          : StaffCounts.fromJson(json['counts'] as Map<String, dynamic>),
      pendingAppointments:
          (json['pendingAppointments'] as List<dynamic>?)
              ?.map(
                (e) => PendingAppointment.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <PendingAppointment>[],
      overdueNotes:
          (json['overdueNotes'] as List<dynamic>?)
              ?.map((e) => OverdueNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <OverdueNote>[],
      newReports:
          (json['newReports'] as List<dynamic>?)
              ?.map((e) => NewReport.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <NewReport>[],
    );

Map<String, dynamic> _$StaffDashboardToJson(_StaffDashboard instance) =>
    <String, dynamic>{
      'roles': instance.roles,
      'counts': instance.counts,
      'pendingAppointments': instance.pendingAppointments,
      'overdueNotes': instance.overdueNotes,
      'newReports': instance.newReports,
    };

_StaffCounts _$StaffCountsFromJson(Map<String, dynamic> json) => _StaffCounts(
  appointmentsToConfirm: (json['appointmentsToConfirm'] as num?)?.toInt() ?? 0,
  appointmentsToday: (json['appointmentsToday'] as num?)?.toInt() ?? 0,
  overdueNotes: (json['overdueNotes'] as num?)?.toInt() ?? 0,
  upcomingNotes: (json['upcomingNotes'] as num?)?.toInt() ?? 0,
  newReports: (json['newReports'] as num?)?.toInt() ?? 0,
  openReports: (json['openReports'] as num?)?.toInt() ?? 0,
  overdueReceipts: (json['overdueReceipts'] as num?)?.toInt() ?? 0,
  pendingExpenses: (json['pendingExpenses'] as num?)?.toInt() ?? 0,
  upcomingMaintenance: (json['upcomingMaintenance'] as num?)?.toInt() ?? 0,
  newLeads: (json['newLeads'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$StaffCountsToJson(_StaffCounts instance) =>
    <String, dynamic>{
      'appointmentsToConfirm': instance.appointmentsToConfirm,
      'appointmentsToday': instance.appointmentsToday,
      'overdueNotes': instance.overdueNotes,
      'upcomingNotes': instance.upcomingNotes,
      'newReports': instance.newReports,
      'openReports': instance.openReports,
      'overdueReceipts': instance.overdueReceipts,
      'pendingExpenses': instance.pendingExpenses,
      'upcomingMaintenance': instance.upcomingMaintenance,
      'newLeads': instance.newLeads,
    };

_PendingAppointment _$PendingAppointmentFromJson(Map<String, dynamic> json) =>
    _PendingAppointment(
      id: json['id'] as String,
      code: json['code'] as String,
      clientName: json['clientName'] as String,
      propertyName: json['propertyName'] as String,
      scheduledAt: const LocalDate().fromJson(json['scheduledAt'] as String),
    );

Map<String, dynamic> _$PendingAppointmentToJson(_PendingAppointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'clientName': instance.clientName,
      'propertyName': instance.propertyName,
      'scheduledAt': const LocalDate().toJson(instance.scheduledAt),
    };

_OverdueNote _$OverdueNoteFromJson(Map<String, dynamic> json) => _OverdueNote(
  id: json['id'] as String,
  number: (json['number'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  dueDate: const LocalDate().fromJson(json['dueDate'] as String),
  clientName: json['clientName'] as String,
  propertyName: json['propertyName'] as String,
  propertyId: json['propertyId'] as String?,
);

Map<String, dynamic> _$OverdueNoteToJson(_OverdueNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'amount': instance.amount,
      'dueDate': const LocalDate().toJson(instance.dueDate),
      'clientName': instance.clientName,
      'propertyName': instance.propertyName,
      'propertyId': instance.propertyId,
    };

_NewReport _$NewReportFromJson(Map<String, dynamic> json) => _NewReport(
  id: json['id'] as String,
  title: json['title'] as String,
  priority: json['priority'] as String,
  status: json['status'] as String,
  propertyName: json['propertyName'] as String,
  propertyId: json['propertyId'] as String?,
  createdAt: const LocalDate().fromJson(json['createdAt'] as String),
);

Map<String, dynamic> _$NewReportToJson(_NewReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'priority': instance.priority,
      'status': instance.status,
      'propertyName': instance.propertyName,
      'propertyId': instance.propertyId,
      'createdAt': const LocalDate().toJson(instance.createdAt),
    };
