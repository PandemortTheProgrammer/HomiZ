// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServiceProvider _$ServiceProviderFromJson(Map<String, dynamic> json) =>
    _ServiceProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      zone: json['zone'] as String?,
      notes: json['notes'] as String?,
      active: json['active'] as bool? ?? true,
    );

Map<String, dynamic> _$ServiceProviderToJson(_ServiceProvider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'specialty': instance.specialty,
      'phone': instance.phone,
      'email': instance.email,
      'zone': instance.zone,
      'notes': instance.notes,
      'active': instance.active,
    };
