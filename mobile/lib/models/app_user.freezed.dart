// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get id; String get name; String get email; String? get phone; String? get birthDate; String get type; String? get initials; List<String> get roles; List<String> get permissions; ClientProfile? get client;/// Entró con la contraseña temporal del correo: antes de seguir crea la suya.
 bool get mustChangePassword;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppUser;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.birthDate, _this.birthDate) || other.birthDate == _this.birthDate)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.initials, _this.initials) || other.initials == _this.initials)&&const DeepCollectionEquality().equals(other.roles, _this.roles)&&const DeepCollectionEquality().equals(other.permissions, _this.permissions)&&(identical(other.client, _this.client) || other.client == _this.client)&&(identical(other.mustChangePassword, _this.mustChangePassword) || other.mustChangePassword == _this.mustChangePassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppUser;
  return Object.hash(runtimeType,_this.id,_this.name,_this.email,_this.phone,_this.birthDate,_this.type,_this.initials,const DeepCollectionEquality().hash(_this.roles),const DeepCollectionEquality().hash(_this.permissions),_this.client,_this.mustChangePassword);
}

@override
String toString() {
  final _this = this as AppUser;
  return 'AppUser(id: ${_this.id}, name: ${_this.name}, email: ${_this.email}, phone: ${_this.phone}, birthDate: ${_this.birthDate}, type: ${_this.type}, initials: ${_this.initials}, roles: ${_this.roles}, permissions: ${_this.permissions}, client: ${_this.client}, mustChangePassword: ${_this.mustChangePassword})';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String? phone, String? birthDate, String type, String? initials, List<String> roles, List<String> permissions, ClientProfile? client, bool mustChangePassword
});


$ClientProfileCopyWith<$Res>? get client;

}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = freezed,Object? birthDate = freezed,Object? type = null,Object? initials = freezed,Object? roles = null,Object? permissions = null,Object? client = freezed,Object? mustChangePassword = null,}) {
  return _then(AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,initials: freezed == initials ? _self.initials : initials // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,client: freezed == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as ClientProfile?,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientProfileCopyWith<$Res>? get client {
    if (_self.client == null) {
    return null;
  }

  return $ClientProfileCopyWith<$Res>(_self.client!, (value) {
    return _then(_self.copyWith(client: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? phone,  String? birthDate,  String type,  String? initials,  List<String> roles,  List<String> permissions,  ClientProfile? client,  bool mustChangePassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.birthDate,_that.type,_that.initials,_that.roles,_that.permissions,_that.client,_that.mustChangePassword);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? phone,  String? birthDate,  String type,  String? initials,  List<String> roles,  List<String> permissions,  ClientProfile? client,  bool mustChangePassword)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.birthDate,_that.type,_that.initials,_that.roles,_that.permissions,_that.client,_that.mustChangePassword);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String? phone,  String? birthDate,  String type,  String? initials,  List<String> roles,  List<String> permissions,  ClientProfile? client,  bool mustChangePassword)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.birthDate,_that.type,_that.initials,_that.roles,_that.permissions,_that.client,_that.mustChangePassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser extends AppUser {
  const _AppUser({required this.id, required this.name, required this.email, this.phone, this.birthDate, required this.type, this.initials,  List<String> roles = const <String>[],  List<String> permissions = const <String>[], this.client, this.mustChangePassword = false}): _roles = roles,_permissions = permissions,super._();
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override final  String? phone;
@override final  String? birthDate;
@override final  String type;
@override final  String? initials;
 final  List<String> _roles;
@override@JsonKey() List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

 final  List<String> _permissions;
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}

@override final  ClientProfile? client;
/// Entró con la contraseña temporal del correo: antes de seguir crea la suya.
@override@JsonKey() final  bool mustChangePassword;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.type, type) || other.type == type)&&(identical(other.initials, initials) || other.initials == initials)&&const DeepCollectionEquality().equals(other.roles, _roles)&&const DeepCollectionEquality().equals(other.permissions, _permissions)&&(identical(other.client, client) || other.client == client)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,email,phone,birthDate,type,initials,const DeepCollectionEquality().hash(_roles),const DeepCollectionEquality().hash(_permissions),client,mustChangePassword);
}

@override
String toString() {
    return 'AppUser(id: $id, name: $name, email: $email, phone: $phone, birthDate: $birthDate, type: $type, initials: $initials, roles: $roles, permissions: $permissions, client: $client, mustChangePassword: $mustChangePassword)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String? phone, String? birthDate, String type, String? initials, List<String> roles, List<String> permissions, ClientProfile? client, bool mustChangePassword
});


@override $ClientProfileCopyWith<$Res>? get client;

}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = freezed,Object? birthDate = freezed,Object? type = null,Object? initials = freezed,Object? roles = null,Object? permissions = null,Object? client = freezed,Object? mustChangePassword = null,}) {
  return _then(_AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,initials: freezed == initials ? _self.initials : initials // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,client: freezed == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as ClientProfile?,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientProfileCopyWith<$Res>? get client {
    if (_self.client == null) {
    return null;
  }

  return $ClientProfileCopyWith<$Res>(_self.client!, (value) {
    return _then(_self.copyWith(client: value));
  });
}
}


/// @nodoc
mixin _$ClientProfile {

 String get id; String get kind; String? get budget; double? get budgetAmount; bool get hasPets; int get petsCount; int? get occupants; String? get propertyId;
/// Create a copy of ClientProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientProfileCopyWith<ClientProfile> get copyWith => _$ClientProfileCopyWithImpl<ClientProfile>(this as ClientProfile, _$identity);

  /// Serializes this ClientProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClientProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.budget, _this.budget) || other.budget == _this.budget)&&(identical(other.budgetAmount, _this.budgetAmount) || other.budgetAmount == _this.budgetAmount)&&(identical(other.hasPets, _this.hasPets) || other.hasPets == _this.hasPets)&&(identical(other.petsCount, _this.petsCount) || other.petsCount == _this.petsCount)&&(identical(other.occupants, _this.occupants) || other.occupants == _this.occupants)&&(identical(other.propertyId, _this.propertyId) || other.propertyId == _this.propertyId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClientProfile;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.budget,_this.budgetAmount,_this.hasPets,_this.petsCount,_this.occupants,_this.propertyId);
}

@override
String toString() {
  final _this = this as ClientProfile;
  return 'ClientProfile(id: ${_this.id}, kind: ${_this.kind}, budget: ${_this.budget}, budgetAmount: ${_this.budgetAmount}, hasPets: ${_this.hasPets}, petsCount: ${_this.petsCount}, occupants: ${_this.occupants}, propertyId: ${_this.propertyId})';
}


}

/// @nodoc
abstract mixin class $ClientProfileCopyWith<$Res>  {
  factory $ClientProfileCopyWith(ClientProfile value, $Res Function(ClientProfile) _then) = _$ClientProfileCopyWithImpl;
@useResult
$Res call({
 String id, String kind, String? budget, double? budgetAmount, bool hasPets, int petsCount, int? occupants, String? propertyId
});




}
/// @nodoc
class _$ClientProfileCopyWithImpl<$Res>
    implements $ClientProfileCopyWith<$Res> {
  _$ClientProfileCopyWithImpl(this._self, this._then);

  final ClientProfile _self;
  final $Res Function(ClientProfile) _then;

/// Create a copy of ClientProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? budget = freezed,Object? budgetAmount = freezed,Object? hasPets = null,Object? petsCount = null,Object? occupants = freezed,Object? propertyId = freezed,}) {
  return _then(ClientProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as String?,budgetAmount: freezed == budgetAmount ? _self.budgetAmount : budgetAmount // ignore: cast_nullable_to_non_nullable
as double?,hasPets: null == hasPets ? _self.hasPets : hasPets // ignore: cast_nullable_to_non_nullable
as bool,petsCount: null == petsCount ? _self.petsCount : petsCount // ignore: cast_nullable_to_non_nullable
as int,occupants: freezed == occupants ? _self.occupants : occupants // ignore: cast_nullable_to_non_nullable
as int?,propertyId: freezed == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientProfile].
extension ClientProfilePatterns on ClientProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientProfile value)  $default,){
final _that = this;
switch (_that) {
case _ClientProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ClientProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind,  String? budget,  double? budgetAmount,  bool hasPets,  int petsCount,  int? occupants,  String? propertyId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientProfile() when $default != null:
return $default(_that.id,_that.kind,_that.budget,_that.budgetAmount,_that.hasPets,_that.petsCount,_that.occupants,_that.propertyId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind,  String? budget,  double? budgetAmount,  bool hasPets,  int petsCount,  int? occupants,  String? propertyId)  $default,) {final _that = this;
switch (_that) {
case _ClientProfile():
return $default(_that.id,_that.kind,_that.budget,_that.budgetAmount,_that.hasPets,_that.petsCount,_that.occupants,_that.propertyId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind,  String? budget,  double? budgetAmount,  bool hasPets,  int petsCount,  int? occupants,  String? propertyId)?  $default,) {final _that = this;
switch (_that) {
case _ClientProfile() when $default != null:
return $default(_that.id,_that.kind,_that.budget,_that.budgetAmount,_that.hasPets,_that.petsCount,_that.occupants,_that.propertyId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientProfile implements ClientProfile {
  const _ClientProfile({required this.id, required this.kind, this.budget, this.budgetAmount, this.hasPets = false, this.petsCount = 0, this.occupants, this.propertyId});
  factory _ClientProfile.fromJson(Map<String, dynamic> json) => _$ClientProfileFromJson(json);

@override final  String id;
@override final  String kind;
@override final  String? budget;
@override final  double? budgetAmount;
@override@JsonKey() final  bool hasPets;
@override@JsonKey() final  int petsCount;
@override final  int? occupants;
@override final  String? propertyId;

/// Create a copy of ClientProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientProfileCopyWith<_ClientProfile> get copyWith => __$ClientProfileCopyWithImpl<_ClientProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.budgetAmount, budgetAmount) || other.budgetAmount == budgetAmount)&&(identical(other.hasPets, hasPets) || other.hasPets == hasPets)&&(identical(other.petsCount, petsCount) || other.petsCount == petsCount)&&(identical(other.occupants, occupants) || other.occupants == occupants)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,budget,budgetAmount,hasPets,petsCount,occupants,propertyId);
}

@override
String toString() {
    return 'ClientProfile(id: $id, kind: $kind, budget: $budget, budgetAmount: $budgetAmount, hasPets: $hasPets, petsCount: $petsCount, occupants: $occupants, propertyId: $propertyId)';
}


}

/// @nodoc
abstract mixin class _$ClientProfileCopyWith<$Res> implements $ClientProfileCopyWith<$Res> {
  factory _$ClientProfileCopyWith(_ClientProfile value, $Res Function(_ClientProfile) _then) = __$ClientProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind, String? budget, double? budgetAmount, bool hasPets, int petsCount, int? occupants, String? propertyId
});




}
/// @nodoc
class __$ClientProfileCopyWithImpl<$Res>
    implements _$ClientProfileCopyWith<$Res> {
  __$ClientProfileCopyWithImpl(this._self, this._then);

  final _ClientProfile _self;
  final $Res Function(_ClientProfile) _then;

/// Create a copy of ClientProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? budget = freezed,Object? budgetAmount = freezed,Object? hasPets = null,Object? petsCount = null,Object? occupants = freezed,Object? propertyId = freezed,}) {
  return _then(_ClientProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as String?,budgetAmount: freezed == budgetAmount ? _self.budgetAmount : budgetAmount // ignore: cast_nullable_to_non_nullable
as double?,hasPets: null == hasPets ? _self.hasPets : hasPets // ignore: cast_nullable_to_non_nullable
as bool,petsCount: null == petsCount ? _self.petsCount : petsCount // ignore: cast_nullable_to_non_nullable
as int,occupants: freezed == occupants ? _self.occupants : occupants // ignore: cast_nullable_to_non_nullable
as int?,propertyId: freezed == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
