// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServiceProvider {

 String get id; String get name; String get specialty; String? get phone; String? get email; String? get zone; String? get notes; bool get active;
/// Create a copy of ServiceProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceProviderCopyWith<ServiceProvider> get copyWith => _$ServiceProviderCopyWithImpl<ServiceProvider>(this as ServiceProvider, _$identity);

  /// Serializes this ServiceProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ServiceProvider;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceProvider&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.specialty, _this.specialty) || other.specialty == _this.specialty)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.zone, _this.zone) || other.zone == _this.zone)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.active, _this.active) || other.active == _this.active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServiceProvider;
  return Object.hash(runtimeType,_this.id,_this.name,_this.specialty,_this.phone,_this.email,_this.zone,_this.notes,_this.active);
}

@override
String toString() {
  final _this = this as ServiceProvider;
  return 'ServiceProvider(id: ${_this.id}, name: ${_this.name}, specialty: ${_this.specialty}, phone: ${_this.phone}, email: ${_this.email}, zone: ${_this.zone}, notes: ${_this.notes}, active: ${_this.active})';
}


}

/// @nodoc
abstract mixin class $ServiceProviderCopyWith<$Res>  {
  factory $ServiceProviderCopyWith(ServiceProvider value, $Res Function(ServiceProvider) _then) = _$ServiceProviderCopyWithImpl;
@useResult
$Res call({
 String id, String name, String specialty, String? phone, String? email, String? zone, String? notes, bool active
});




}
/// @nodoc
class _$ServiceProviderCopyWithImpl<$Res>
    implements $ServiceProviderCopyWith<$Res> {
  _$ServiceProviderCopyWithImpl(this._self, this._then);

  final ServiceProvider _self;
  final $Res Function(ServiceProvider) _then;

/// Create a copy of ServiceProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? specialty = null,Object? phone = freezed,Object? email = freezed,Object? zone = freezed,Object? notes = freezed,Object? active = null,}) {
  return _then(ServiceProvider(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceProvider].
extension ServiceProviderPatterns on ServiceProvider {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceProvider() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceProvider value)  $default,){
final _that = this;
switch (_that) {
case _ServiceProvider():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceProvider value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceProvider() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String specialty,  String? phone,  String? email,  String? zone,  String? notes,  bool active)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceProvider() when $default != null:
return $default(_that.id,_that.name,_that.specialty,_that.phone,_that.email,_that.zone,_that.notes,_that.active);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String specialty,  String? phone,  String? email,  String? zone,  String? notes,  bool active)  $default,) {final _that = this;
switch (_that) {
case _ServiceProvider():
return $default(_that.id,_that.name,_that.specialty,_that.phone,_that.email,_that.zone,_that.notes,_that.active);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String specialty,  String? phone,  String? email,  String? zone,  String? notes,  bool active)?  $default,) {final _that = this;
switch (_that) {
case _ServiceProvider() when $default != null:
return $default(_that.id,_that.name,_that.specialty,_that.phone,_that.email,_that.zone,_that.notes,_that.active);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceProvider implements ServiceProvider {
  const _ServiceProvider({required this.id, required this.name, required this.specialty, this.phone, this.email, this.zone, this.notes, this.active = true});
  factory _ServiceProvider.fromJson(Map<String, dynamic> json) => _$ServiceProviderFromJson(json);

@override final  String id;
@override final  String name;
@override final  String specialty;
@override final  String? phone;
@override final  String? email;
@override final  String? zone;
@override final  String? notes;
@override@JsonKey() final  bool active;

/// Create a copy of ServiceProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceProviderCopyWith<_ServiceProvider> get copyWith => __$ServiceProviderCopyWithImpl<_ServiceProvider>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceProviderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceProvider&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,specialty,phone,email,zone,notes,active);
}

@override
String toString() {
    return 'ServiceProvider(id: $id, name: $name, specialty: $specialty, phone: $phone, email: $email, zone: $zone, notes: $notes, active: $active)';
}


}

/// @nodoc
abstract mixin class _$ServiceProviderCopyWith<$Res> implements $ServiceProviderCopyWith<$Res> {
  factory _$ServiceProviderCopyWith(_ServiceProvider value, $Res Function(_ServiceProvider) _then) = __$ServiceProviderCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String specialty, String? phone, String? email, String? zone, String? notes, bool active
});




}
/// @nodoc
class __$ServiceProviderCopyWithImpl<$Res>
    implements _$ServiceProviderCopyWith<$Res> {
  __$ServiceProviderCopyWithImpl(this._self, this._then);

  final _ServiceProvider _self;
  final $Res Function(_ServiceProvider) _then;

/// Create a copy of ServiceProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? specialty = null,Object? phone = freezed,Object? email = freezed,Object? zone = freezed,Object? notes = freezed,Object? active = null,}) {
  return _then(_ServiceProvider(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
