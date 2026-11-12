// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientDashboard _$ClientDashboardFromJson(
  Map<String, dynamic> json,
) => _ClientDashboard(
  property: json['property'] == null
      ? null
      : DashboardProperty.fromJson(json['property'] as Map<String, dynamic>),
  nextPayment: json['nextPayment'] == null
      ? null
      : DashboardPayment.fromJson(json['nextPayment'] as Map<String, dynamic>),
  nextAppointment: json['nextAppointment'] == null
      ? null
      : DashboardAppointment.fromJson(
          json['nextAppointment'] as Map<String, dynamic>,
        ),
  openReports: json['openReports'] == null
      ? const OpenReports()
      : OpenReports.fromJson(json['openReports'] as Map<String, dynamic>),
  unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ClientDashboardToJson(_ClientDashboard instance) =>
    <String, dynamic>{
      'property': instance.property,
      'nextPayment': instance.nextPayment,
      'nextAppointment': instance.nextAppointment,
      'openReports': instance.openReports,
      'unreadNotifications': instance.unreadNotifications,
    };

_DashboardProperty _$DashboardPropertyFromJson(Map<String, dynamic> json) =>
    _DashboardProperty(
      id: json['id'] as String,
      name: json['name'] as String,
      zone: json['zone'] as String?,
    );

Map<String, dynamic> _$DashboardPropertyToJson(_DashboardProperty instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'zone': instance.zone,
    };

_DashboardPayment _$DashboardPaymentFromJson(Map<String, dynamic> json) =>
    _DashboardPayment(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      dueDate: const LocalDate().fromJson(json['dueDate'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$DashboardPaymentToJson(_DashboardPayment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'amount': instance.amount,
      'dueDate': const LocalDate().toJson(instance.dueDate),
      'status': instance.status,
    };

_DashboardAppointment _$DashboardAppointmentFromJson(
  Map<String, dynamic> json,
) => _DashboardAppointment(
  id: json['id'] as String,
  code: json['code'] as String,
  propertyName: json['propertyName'] as String,
  scheduledAt: const LocalDate().fromJson(json['scheduledAt'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$DashboardAppointmentToJson(
  _DashboardAppointment instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'propertyName': instance.propertyName,
  'scheduledAt': const LocalDate().toJson(instance.scheduledAt),
  'status': instance.status,
};

_OpenReports _$OpenReportsFromJson(Map<String, dynamic> json) => _OpenReports(
  count: (json['count'] as num?)?.toInt() ?? 0,
  latest: json['latest'] == null
      ? null
      : LatestReport.fromJson(json['latest'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OpenReportsToJson(_OpenReports instance) =>
    <String, dynamic>{'count': instance.count, 'latest': instance.latest};

_LatestReport _$LatestReportFromJson(Map<String, dynamic> json) =>
    _LatestReport(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      createdAt: const LocalDate().fromJson(json['createdAt'] as String),
    );

Map<String, dynamic> _$LatestReportToJson(_LatestReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'status': instance.status,
      'createdAt': const LocalDate().toJson(instance.createdAt),
    };
