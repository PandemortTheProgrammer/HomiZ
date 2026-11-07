// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  birthDate: json['birthDate'] as String?,
  type: json['type'] as String,
  initials: json['initials'] as String?,
  roles:
      (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  client: json['client'] == null
      ? null
      : ClientProfile.fromJson(json['client'] as Map<String, dynamic>),
  mustChangePassword: json['mustChangePassword'] as bool? ?? false,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'birthDate': instance.birthDate,
  'type': instance.type,
  'initials': instance.initials,
  'roles': instance.roles,
  'permissions': instance.permissions,
  'client': instance.client,
  'mustChangePassword': instance.mustChangePassword,
};

_ClientProfile _$ClientProfileFromJson(Map<String, dynamic> json) =>
    _ClientProfile(
      id: json['id'] as String,
      kind: json['kind'] as String,
      budget: json['budget'] as String?,
      budgetAmount: (json['budgetAmount'] as num?)?.toDouble(),
      hasPets: json['hasPets'] as bool? ?? false,
      petsCount: (json['petsCount'] as num?)?.toInt() ?? 0,
      occupants: (json['occupants'] as num?)?.toInt(),
      propertyId: json['propertyId'] as String?,
    );

Map<String, dynamic> _$ClientProfileToJson(_ClientProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'budget': instance.budget,
      'budgetAmount': instance.budgetAmount,
      'hasPets': instance.hasPets,
      'petsCount': instance.petsCount,
      'occupants': instance.occupants,
      'propertyId': instance.propertyId,
    };
