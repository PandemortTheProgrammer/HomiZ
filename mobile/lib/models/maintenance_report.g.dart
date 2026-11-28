// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaintenanceReport _$MaintenanceReportFromJson(Map<String, dynamic> json) =>
    _MaintenanceReport(
      id: json['id'] as String,
      property: json['property'] == null
          ? null
          : ReportProperty.fromJson(json['property'] as Map<String, dynamic>),
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      subtitle: json['subtitle'] as String,
      status: json['status'] as String,
      statusLabel: json['statusLabel'] as String,
      provider: json['provider'] == null
          ? null
          : ReportProvider.fromJson(json['provider'] as Map<String, dynamic>),
      closedAt: const LocalDateOrNull().fromJson(json['closedAt'] as String?),
      createdAt: const LocalDate().fromJson(json['createdAt'] as String),
      timeline:
          (json['timeline'] as List<dynamic>?)
              ?.map((e) => TimelineEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TimelineEntry>[],
      photos: json['photos'] == null
          ? const ReportPhotos()
          : ReportPhotos.fromJson(json['photos'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MaintenanceReportToJson(_MaintenanceReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'property': instance.property,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'priority': instance.priority,
      'subtitle': instance.subtitle,
      'status': instance.status,
      'statusLabel': instance.statusLabel,
      'provider': instance.provider,
      'closedAt': const LocalDateOrNull().toJson(instance.closedAt),
      'createdAt': const LocalDate().toJson(instance.createdAt),
      'timeline': instance.timeline,
      'photos': instance.photos,
    };

_ReportProperty _$ReportPropertyFromJson(Map<String, dynamic> json) =>
    _ReportProperty(
      id: json['id'] as String,
      code: json['code'] as String?,
      name: json['name'] as String,
    );

Map<String, dynamic> _$ReportPropertyToJson(_ReportProperty instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
    };

_ReportProvider _$ReportProviderFromJson(Map<String, dynamic> json) =>
    _ReportProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$ReportProviderToJson(_ReportProvider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'specialty': instance.specialty,
      'phone': instance.phone,
    };

_TimelineEntry _$TimelineEntryFromJson(Map<String, dynamic> json) =>
    _TimelineEntry(
      id: json['id'] as String,
      status: json['status'] as String,
      statusLabel: json['statusLabel'] as String,
      comment: json['comment'] as String?,
      author: json['author'] as String?,
      createdAt: const LocalDate().fromJson(json['createdAt'] as String),
    );

Map<String, dynamic> _$TimelineEntryToJson(_TimelineEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'statusLabel': instance.statusLabel,
      'comment': instance.comment,
      'author': instance.author,
      'createdAt': const LocalDate().toJson(instance.createdAt),
    };

_ReportPhotos _$ReportPhotosFromJson(Map<String, dynamic> json) =>
    _ReportPhotos(
      before:
          (json['before'] as List<dynamic>?)
              ?.map((e) => ReportPhoto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ReportPhoto>[],
      after:
          (json['after'] as List<dynamic>?)
              ?.map((e) => ReportPhoto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ReportPhoto>[],
    );

Map<String, dynamic> _$ReportPhotosToJson(_ReportPhotos instance) =>
    <String, dynamic>{'before': instance.before, 'after': instance.after};

_ReportPhoto _$ReportPhotoFromJson(Map<String, dynamic> json) =>
    _ReportPhoto(id: json['id'] as String, url: json['url'] as String);

Map<String, dynamic> _$ReportPhotoToJson(_ReportPhoto instance) =>
    <String, dynamic>{'id': instance.id, 'url': instance.url};
