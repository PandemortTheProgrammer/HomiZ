// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientDashboard {

 DashboardProperty? get property; DashboardPayment? get nextPayment; DashboardAppointment? get nextAppointment; OpenReports get openReports; int get unreadNotifications;
/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientDashboardCopyWith<ClientDashboard> get copyWith => _$ClientDashboardCopyWithImpl<ClientDashboard>(this as ClientDashboard, _$identity);

  /// Serializes this ClientDashboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClientDashboard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientDashboard&&(identical(other.property, _this.property) || other.property == _this.property)&&(identical(other.nextPayment, _this.nextPayment) || other.nextPayment == _this.nextPayment)&&(identical(other.nextAppointment, _this.nextAppointment) || other.nextAppointment == _this.nextAppointment)&&(identical(other.openReports, _this.openReports) || other.openReports == _this.openReports)&&(identical(other.unreadNotifications, _this.unreadNotifications) || other.unreadNotifications == _this.unreadNotifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClientDashboard;
  return Object.hash(runtimeType,_this.property,_this.nextPayment,_this.nextAppointment,_this.openReports,_this.unreadNotifications);
}

@override
String toString() {
  final _this = this as ClientDashboard;
  return 'ClientDashboard(property: ${_this.property}, nextPayment: ${_this.nextPayment}, nextAppointment: ${_this.nextAppointment}, openReports: ${_this.openReports}, unreadNotifications: ${_this.unreadNotifications})';
}


}

/// @nodoc
abstract mixin class $ClientDashboardCopyWith<$Res>  {
  factory $ClientDashboardCopyWith(ClientDashboard value, $Res Function(ClientDashboard) _then) = _$ClientDashboardCopyWithImpl;
@useResult
$Res call({
 DashboardProperty? property, DashboardPayment? nextPayment, DashboardAppointment? nextAppointment, OpenReports openReports, int unreadNotifications
});


$DashboardPropertyCopyWith<$Res>? get property;$DashboardPaymentCopyWith<$Res>? get nextPayment;$DashboardAppointmentCopyWith<$Res>? get nextAppointment;$OpenReportsCopyWith<$Res> get openReports;

}
/// @nodoc
class _$ClientDashboardCopyWithImpl<$Res>
    implements $ClientDashboardCopyWith<$Res> {
  _$ClientDashboardCopyWithImpl(this._self, this._then);

  final ClientDashboard _self;
  final $Res Function(ClientDashboard) _then;

/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? property = freezed,Object? nextPayment = freezed,Object? nextAppointment = freezed,Object? openReports = null,Object? unreadNotifications = null,}) {
  return _then(ClientDashboard(
property: freezed == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as DashboardProperty?,nextPayment: freezed == nextPayment ? _self.nextPayment : nextPayment // ignore: cast_nullable_to_non_nullable
as DashboardPayment?,nextAppointment: freezed == nextAppointment ? _self.nextAppointment : nextAppointment // ignore: cast_nullable_to_non_nullable
as DashboardAppointment?,openReports: null == openReports ? _self.openReports : openReports // ignore: cast_nullable_to_non_nullable
as OpenReports,unreadNotifications: null == unreadNotifications ? _self.unreadNotifications : unreadNotifications // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardPropertyCopyWith<$Res>? get property {
    if (_self.property == null) {
    return null;
  }

  return $DashboardPropertyCopyWith<$Res>(_self.property!, (value) {
    return _then(_self.copyWith(property: value));
  });
}/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardPaymentCopyWith<$Res>? get nextPayment {
    if (_self.nextPayment == null) {
    return null;
  }

  return $DashboardPaymentCopyWith<$Res>(_self.nextPayment!, (value) {
    return _then(_self.copyWith(nextPayment: value));
  });
}/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardAppointmentCopyWith<$Res>? get nextAppointment {
    if (_self.nextAppointment == null) {
    return null;
  }

  return $DashboardAppointmentCopyWith<$Res>(_self.nextAppointment!, (value) {
    return _then(_self.copyWith(nextAppointment: value));
  });
}/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenReportsCopyWith<$Res> get openReports {
  
  return $OpenReportsCopyWith<$Res>(_self.openReports, (value) {
    return _then(_self.copyWith(openReports: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClientDashboard].
extension ClientDashboardPatterns on ClientDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientDashboard value)  $default,){
final _that = this;
switch (_that) {
case _ClientDashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _ClientDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DashboardProperty? property,  DashboardPayment? nextPayment,  DashboardAppointment? nextAppointment,  OpenReports openReports,  int unreadNotifications)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientDashboard() when $default != null:
return $default(_that.property,_that.nextPayment,_that.nextAppointment,_that.openReports,_that.unreadNotifications);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DashboardProperty? property,  DashboardPayment? nextPayment,  DashboardAppointment? nextAppointment,  OpenReports openReports,  int unreadNotifications)  $default,) {final _that = this;
switch (_that) {
case _ClientDashboard():
return $default(_that.property,_that.nextPayment,_that.nextAppointment,_that.openReports,_that.unreadNotifications);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DashboardProperty? property,  DashboardPayment? nextPayment,  DashboardAppointment? nextAppointment,  OpenReports openReports,  int unreadNotifications)?  $default,) {final _that = this;
switch (_that) {
case _ClientDashboard() when $default != null:
return $default(_that.property,_that.nextPayment,_that.nextAppointment,_that.openReports,_that.unreadNotifications);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientDashboard implements ClientDashboard {
  const _ClientDashboard({this.property, this.nextPayment, this.nextAppointment, this.openReports = const OpenReports(), this.unreadNotifications = 0});
  factory _ClientDashboard.fromJson(Map<String, dynamic> json) => _$ClientDashboardFromJson(json);

@override final  DashboardProperty? property;
@override final  DashboardPayment? nextPayment;
@override final  DashboardAppointment? nextAppointment;
@override@JsonKey() final  OpenReports openReports;
@override@JsonKey() final  int unreadNotifications;

/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientDashboardCopyWith<_ClientDashboard> get copyWith => __$ClientDashboardCopyWithImpl<_ClientDashboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientDashboardToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientDashboard&&(identical(other.property, property) || other.property == property)&&(identical(other.nextPayment, nextPayment) || other.nextPayment == nextPayment)&&(identical(other.nextAppointment, nextAppointment) || other.nextAppointment == nextAppointment)&&(identical(other.openReports, openReports) || other.openReports == openReports)&&(identical(other.unreadNotifications, unreadNotifications) || other.unreadNotifications == unreadNotifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,property,nextPayment,nextAppointment,openReports,unreadNotifications);
}

@override
String toString() {
    return 'ClientDashboard(property: $property, nextPayment: $nextPayment, nextAppointment: $nextAppointment, openReports: $openReports, unreadNotifications: $unreadNotifications)';
}


}

/// @nodoc
abstract mixin class _$ClientDashboardCopyWith<$Res> implements $ClientDashboardCopyWith<$Res> {
  factory _$ClientDashboardCopyWith(_ClientDashboard value, $Res Function(_ClientDashboard) _then) = __$ClientDashboardCopyWithImpl;
@override @useResult
$Res call({
 DashboardProperty? property, DashboardPayment? nextPayment, DashboardAppointment? nextAppointment, OpenReports openReports, int unreadNotifications
});


@override $DashboardPropertyCopyWith<$Res>? get property;@override $DashboardPaymentCopyWith<$Res>? get nextPayment;@override $DashboardAppointmentCopyWith<$Res>? get nextAppointment;@override $OpenReportsCopyWith<$Res> get openReports;

}
/// @nodoc
class __$ClientDashboardCopyWithImpl<$Res>
    implements _$ClientDashboardCopyWith<$Res> {
  __$ClientDashboardCopyWithImpl(this._self, this._then);

  final _ClientDashboard _self;
  final $Res Function(_ClientDashboard) _then;

/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? property = freezed,Object? nextPayment = freezed,Object? nextAppointment = freezed,Object? openReports = null,Object? unreadNotifications = null,}) {
  return _then(_ClientDashboard(
property: freezed == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as DashboardProperty?,nextPayment: freezed == nextPayment ? _self.nextPayment : nextPayment // ignore: cast_nullable_to_non_nullable
as DashboardPayment?,nextAppointment: freezed == nextAppointment ? _self.nextAppointment : nextAppointment // ignore: cast_nullable_to_non_nullable
as DashboardAppointment?,openReports: null == openReports ? _self.openReports : openReports // ignore: cast_nullable_to_non_nullable
as OpenReports,unreadNotifications: null == unreadNotifications ? _self.unreadNotifications : unreadNotifications // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardPropertyCopyWith<$Res>? get property {
    if (_self.property == null) {
    return null;
  }

  return $DashboardPropertyCopyWith<$Res>(_self.property!, (value) {
    return _then(_self.copyWith(property: value));
  });
}/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardPaymentCopyWith<$Res>? get nextPayment {
    if (_self.nextPayment == null) {
    return null;
  }

  return $DashboardPaymentCopyWith<$Res>(_self.nextPayment!, (value) {
    return _then(_self.copyWith(nextPayment: value));
  });
}/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardAppointmentCopyWith<$Res>? get nextAppointment {
    if (_self.nextAppointment == null) {
    return null;
  }

  return $DashboardAppointmentCopyWith<$Res>(_self.nextAppointment!, (value) {
    return _then(_self.copyWith(nextAppointment: value));
  });
}/// Create a copy of ClientDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenReportsCopyWith<$Res> get openReports {
  
  return $OpenReportsCopyWith<$Res>(_self.openReports, (value) {
    return _then(_self.copyWith(openReports: value));
  });
}
}


/// @nodoc
mixin _$DashboardProperty {

 String get id; String get name; String? get zone;
/// Create a copy of DashboardProperty
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardPropertyCopyWith<DashboardProperty> get copyWith => _$DashboardPropertyCopyWithImpl<DashboardProperty>(this as DashboardProperty, _$identity);

  /// Serializes this DashboardProperty to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DashboardProperty;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardProperty&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.zone, _this.zone) || other.zone == _this.zone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DashboardProperty;
  return Object.hash(runtimeType,_this.id,_this.name,_this.zone);
}

@override
String toString() {
  final _this = this as DashboardProperty;
  return 'DashboardProperty(id: ${_this.id}, name: ${_this.name}, zone: ${_this.zone})';
}


}

/// @nodoc
abstract mixin class $DashboardPropertyCopyWith<$Res>  {
  factory $DashboardPropertyCopyWith(DashboardProperty value, $Res Function(DashboardProperty) _then) = _$DashboardPropertyCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? zone
});




}
/// @nodoc
class _$DashboardPropertyCopyWithImpl<$Res>
    implements $DashboardPropertyCopyWith<$Res> {
  _$DashboardPropertyCopyWithImpl(this._self, this._then);

  final DashboardProperty _self;
  final $Res Function(DashboardProperty) _then;

/// Create a copy of DashboardProperty
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? zone = freezed,}) {
  return _then(DashboardProperty(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardProperty].
extension DashboardPropertyPatterns on DashboardProperty {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardProperty value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardProperty() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardProperty value)  $default,){
final _that = this;
switch (_that) {
case _DashboardProperty():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardProperty value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardProperty() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? zone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardProperty() when $default != null:
return $default(_that.id,_that.name,_that.zone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? zone)  $default,) {final _that = this;
switch (_that) {
case _DashboardProperty():
return $default(_that.id,_that.name,_that.zone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? zone)?  $default,) {final _that = this;
switch (_that) {
case _DashboardProperty() when $default != null:
return $default(_that.id,_that.name,_that.zone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardProperty implements DashboardProperty {
  const _DashboardProperty({required this.id, required this.name, this.zone});
  factory _DashboardProperty.fromJson(Map<String, dynamic> json) => _$DashboardPropertyFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? zone;

/// Create a copy of DashboardProperty
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardPropertyCopyWith<_DashboardProperty> get copyWith => __$DashboardPropertyCopyWithImpl<_DashboardProperty>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardPropertyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardProperty&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.zone, zone) || other.zone == zone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,zone);
}

@override
String toString() {
    return 'DashboardProperty(id: $id, name: $name, zone: $zone)';
}


}

/// @nodoc
abstract mixin class _$DashboardPropertyCopyWith<$Res> implements $DashboardPropertyCopyWith<$Res> {
  factory _$DashboardPropertyCopyWith(_DashboardProperty value, $Res Function(_DashboardProperty) _then) = __$DashboardPropertyCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? zone
});




}
/// @nodoc
class __$DashboardPropertyCopyWithImpl<$Res>
    implements _$DashboardPropertyCopyWith<$Res> {
  __$DashboardPropertyCopyWithImpl(this._self, this._then);

  final _DashboardProperty _self;
  final $Res Function(_DashboardProperty) _then;

/// Create a copy of DashboardProperty
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? zone = freezed,}) {
  return _then(_DashboardProperty(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DashboardPayment {

 String get id; int get number; double get amount;@LocalDate() DateTime get dueDate; String get status;
/// Create a copy of DashboardPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardPaymentCopyWith<DashboardPayment> get copyWith => _$DashboardPaymentCopyWithImpl<DashboardPayment>(this as DashboardPayment, _$identity);

  /// Serializes this DashboardPayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DashboardPayment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardPayment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DashboardPayment;
  return Object.hash(runtimeType,_this.id,_this.number,_this.amount,_this.dueDate,_this.status);
}

@override
String toString() {
  final _this = this as DashboardPayment;
  return 'DashboardPayment(id: ${_this.id}, number: ${_this.number}, amount: ${_this.amount}, dueDate: ${_this.dueDate}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $DashboardPaymentCopyWith<$Res>  {
  factory $DashboardPaymentCopyWith(DashboardPayment value, $Res Function(DashboardPayment) _then) = _$DashboardPaymentCopyWithImpl;
@useResult
$Res call({
 String id, int number, double amount,@LocalDate() DateTime dueDate, String status
});




}
/// @nodoc
class _$DashboardPaymentCopyWithImpl<$Res>
    implements $DashboardPaymentCopyWith<$Res> {
  _$DashboardPaymentCopyWithImpl(this._self, this._then);

  final DashboardPayment _self;
  final $Res Function(DashboardPayment) _then;

/// Create a copy of DashboardPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? amount = null,Object? dueDate = null,Object? status = null,}) {
  return _then(DashboardPayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardPayment].
extension DashboardPaymentPatterns on DashboardPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardPayment value)  $default,){
final _that = this;
switch (_that) {
case _DashboardPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardPayment value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  double amount, @LocalDate()  DateTime dueDate,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardPayment() when $default != null:
return $default(_that.id,_that.number,_that.amount,_that.dueDate,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  double amount, @LocalDate()  DateTime dueDate,  String status)  $default,) {final _that = this;
switch (_that) {
case _DashboardPayment():
return $default(_that.id,_that.number,_that.amount,_that.dueDate,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  double amount, @LocalDate()  DateTime dueDate,  String status)?  $default,) {final _that = this;
switch (_that) {
case _DashboardPayment() when $default != null:
return $default(_that.id,_that.number,_that.amount,_that.dueDate,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardPayment implements DashboardPayment {
  const _DashboardPayment({required this.id, required this.number, required this.amount, @LocalDate() required this.dueDate, required this.status});
  factory _DashboardPayment.fromJson(Map<String, dynamic> json) => _$DashboardPaymentFromJson(json);

@override final  String id;
@override final  int number;
@override final  double amount;
@override@LocalDate() final  DateTime dueDate;
@override final  String status;

/// Create a copy of DashboardPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardPaymentCopyWith<_DashboardPayment> get copyWith => __$DashboardPaymentCopyWithImpl<_DashboardPayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardPaymentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,number,amount,dueDate,status);
}

@override
String toString() {
    return 'DashboardPayment(id: $id, number: $number, amount: $amount, dueDate: $dueDate, status: $status)';
}


}

/// @nodoc
abstract mixin class _$DashboardPaymentCopyWith<$Res> implements $DashboardPaymentCopyWith<$Res> {
  factory _$DashboardPaymentCopyWith(_DashboardPayment value, $Res Function(_DashboardPayment) _then) = __$DashboardPaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, double amount,@LocalDate() DateTime dueDate, String status
});




}
/// @nodoc
class __$DashboardPaymentCopyWithImpl<$Res>
    implements _$DashboardPaymentCopyWith<$Res> {
  __$DashboardPaymentCopyWithImpl(this._self, this._then);

  final _DashboardPayment _self;
  final $Res Function(_DashboardPayment) _then;

/// Create a copy of DashboardPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? amount = null,Object? dueDate = null,Object? status = null,}) {
  return _then(_DashboardPayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DashboardAppointment {

 String get id; String get code; String get propertyName;@LocalDate() DateTime get scheduledAt; String get status;
/// Create a copy of DashboardAppointment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardAppointmentCopyWith<DashboardAppointment> get copyWith => _$DashboardAppointmentCopyWithImpl<DashboardAppointment>(this as DashboardAppointment, _$identity);

  /// Serializes this DashboardAppointment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DashboardAppointment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardAppointment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.propertyName, _this.propertyName) || other.propertyName == _this.propertyName)&&(identical(other.scheduledAt, _this.scheduledAt) || other.scheduledAt == _this.scheduledAt)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DashboardAppointment;
  return Object.hash(runtimeType,_this.id,_this.code,_this.propertyName,_this.scheduledAt,_this.status);
}

@override
String toString() {
  final _this = this as DashboardAppointment;
  return 'DashboardAppointment(id: ${_this.id}, code: ${_this.code}, propertyName: ${_this.propertyName}, scheduledAt: ${_this.scheduledAt}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $DashboardAppointmentCopyWith<$Res>  {
  factory $DashboardAppointmentCopyWith(DashboardAppointment value, $Res Function(DashboardAppointment) _then) = _$DashboardAppointmentCopyWithImpl;
@useResult
$Res call({
 String id, String code, String propertyName,@LocalDate() DateTime scheduledAt, String status
});




}
/// @nodoc
class _$DashboardAppointmentCopyWithImpl<$Res>
    implements $DashboardAppointmentCopyWith<$Res> {
  _$DashboardAppointmentCopyWithImpl(this._self, this._then);

  final DashboardAppointment _self;
  final $Res Function(DashboardAppointment) _then;

/// Create a copy of DashboardAppointment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? propertyName = null,Object? scheduledAt = null,Object? status = null,}) {
  return _then(DashboardAppointment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardAppointment].
extension DashboardAppointmentPatterns on DashboardAppointment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardAppointment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardAppointment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardAppointment value)  $default,){
final _that = this;
switch (_that) {
case _DashboardAppointment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardAppointment value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardAppointment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String propertyName, @LocalDate()  DateTime scheduledAt,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardAppointment() when $default != null:
return $default(_that.id,_that.code,_that.propertyName,_that.scheduledAt,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String propertyName, @LocalDate()  DateTime scheduledAt,  String status)  $default,) {final _that = this;
switch (_that) {
case _DashboardAppointment():
return $default(_that.id,_that.code,_that.propertyName,_that.scheduledAt,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String propertyName, @LocalDate()  DateTime scheduledAt,  String status)?  $default,) {final _that = this;
switch (_that) {
case _DashboardAppointment() when $default != null:
return $default(_that.id,_that.code,_that.propertyName,_that.scheduledAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardAppointment implements DashboardAppointment {
  const _DashboardAppointment({required this.id, required this.code, required this.propertyName, @LocalDate() required this.scheduledAt, required this.status});
  factory _DashboardAppointment.fromJson(Map<String, dynamic> json) => _$DashboardAppointmentFromJson(json);

@override final  String id;
@override final  String code;
@override final  String propertyName;
@override@LocalDate() final  DateTime scheduledAt;
@override final  String status;

/// Create a copy of DashboardAppointment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardAppointmentCopyWith<_DashboardAppointment> get copyWith => __$DashboardAppointmentCopyWithImpl<_DashboardAppointment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardAppointmentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardAppointment&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,propertyName,scheduledAt,status);
}

@override
String toString() {
    return 'DashboardAppointment(id: $id, code: $code, propertyName: $propertyName, scheduledAt: $scheduledAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$DashboardAppointmentCopyWith<$Res> implements $DashboardAppointmentCopyWith<$Res> {
  factory _$DashboardAppointmentCopyWith(_DashboardAppointment value, $Res Function(_DashboardAppointment) _then) = __$DashboardAppointmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String propertyName,@LocalDate() DateTime scheduledAt, String status
});




}
/// @nodoc
class __$DashboardAppointmentCopyWithImpl<$Res>
    implements _$DashboardAppointmentCopyWith<$Res> {
  __$DashboardAppointmentCopyWithImpl(this._self, this._then);

  final _DashboardAppointment _self;
  final $Res Function(_DashboardAppointment) _then;

/// Create a copy of DashboardAppointment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? propertyName = null,Object? scheduledAt = null,Object? status = null,}) {
  return _then(_DashboardAppointment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OpenReports {

 int get count; LatestReport? get latest;
/// Create a copy of OpenReports
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenReportsCopyWith<OpenReports> get copyWith => _$OpenReportsCopyWithImpl<OpenReports>(this as OpenReports, _$identity);

  /// Serializes this OpenReports to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OpenReports;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenReports&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.latest, _this.latest) || other.latest == _this.latest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OpenReports;
  return Object.hash(runtimeType,_this.count,_this.latest);
}

@override
String toString() {
  final _this = this as OpenReports;
  return 'OpenReports(count: ${_this.count}, latest: ${_this.latest})';
}


}

/// @nodoc
abstract mixin class $OpenReportsCopyWith<$Res>  {
  factory $OpenReportsCopyWith(OpenReports value, $Res Function(OpenReports) _then) = _$OpenReportsCopyWithImpl;
@useResult
$Res call({
 int count, LatestReport? latest
});


$LatestReportCopyWith<$Res>? get latest;

}
/// @nodoc
class _$OpenReportsCopyWithImpl<$Res>
    implements $OpenReportsCopyWith<$Res> {
  _$OpenReportsCopyWithImpl(this._self, this._then);

  final OpenReports _self;
  final $Res Function(OpenReports) _then;

/// Create a copy of OpenReports
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? latest = freezed,}) {
  return _then(OpenReports(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,latest: freezed == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as LatestReport?,
  ));
}
/// Create a copy of OpenReports
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LatestReportCopyWith<$Res>? get latest {
    if (_self.latest == null) {
    return null;
  }

  return $LatestReportCopyWith<$Res>(_self.latest!, (value) {
    return _then(_self.copyWith(latest: value));
  });
}
}


/// Adds pattern-matching-related methods to [OpenReports].
extension OpenReportsPatterns on OpenReports {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenReports value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenReports() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenReports value)  $default,){
final _that = this;
switch (_that) {
case _OpenReports():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenReports value)?  $default,){
final _that = this;
switch (_that) {
case _OpenReports() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  LatestReport? latest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenReports() when $default != null:
return $default(_that.count,_that.latest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  LatestReport? latest)  $default,) {final _that = this;
switch (_that) {
case _OpenReports():
return $default(_that.count,_that.latest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  LatestReport? latest)?  $default,) {final _that = this;
switch (_that) {
case _OpenReports() when $default != null:
return $default(_that.count,_that.latest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenReports implements OpenReports {
  const _OpenReports({this.count = 0, this.latest});
  factory _OpenReports.fromJson(Map<String, dynamic> json) => _$OpenReportsFromJson(json);

@override@JsonKey() final  int count;
@override final  LatestReport? latest;

/// Create a copy of OpenReports
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenReportsCopyWith<_OpenReports> get copyWith => __$OpenReportsCopyWithImpl<_OpenReports>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenReportsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenReports&&(identical(other.count, count) || other.count == count)&&(identical(other.latest, latest) || other.latest == latest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,count,latest);
}

@override
String toString() {
    return 'OpenReports(count: $count, latest: $latest)';
}


}

/// @nodoc
abstract mixin class _$OpenReportsCopyWith<$Res> implements $OpenReportsCopyWith<$Res> {
  factory _$OpenReportsCopyWith(_OpenReports value, $Res Function(_OpenReports) _then) = __$OpenReportsCopyWithImpl;
@override @useResult
$Res call({
 int count, LatestReport? latest
});


@override $LatestReportCopyWith<$Res>? get latest;

}
/// @nodoc
class __$OpenReportsCopyWithImpl<$Res>
    implements _$OpenReportsCopyWith<$Res> {
  __$OpenReportsCopyWithImpl(this._self, this._then);

  final _OpenReports _self;
  final $Res Function(_OpenReports) _then;

/// Create a copy of OpenReports
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? latest = freezed,}) {
  return _then(_OpenReports(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,latest: freezed == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as LatestReport?,
  ));
}

/// Create a copy of OpenReports
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LatestReportCopyWith<$Res>? get latest {
    if (_self.latest == null) {
    return null;
  }

  return $LatestReportCopyWith<$Res>(_self.latest!, (value) {
    return _then(_self.copyWith(latest: value));
  });
}
}


/// @nodoc
mixin _$LatestReport {

 String get id; String get title; String get status;@LocalDate() DateTime get createdAt;
/// Create a copy of LatestReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LatestReportCopyWith<LatestReport> get copyWith => _$LatestReportCopyWithImpl<LatestReport>(this as LatestReport, _$identity);

  /// Serializes this LatestReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LatestReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LatestReport&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LatestReport;
  return Object.hash(runtimeType,_this.id,_this.title,_this.status,_this.createdAt);
}

@override
String toString() {
  final _this = this as LatestReport;
  return 'LatestReport(id: ${_this.id}, title: ${_this.title}, status: ${_this.status}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $LatestReportCopyWith<$Res>  {
  factory $LatestReportCopyWith(LatestReport value, $Res Function(LatestReport) _then) = _$LatestReportCopyWithImpl;
@useResult
$Res call({
 String id, String title, String status,@LocalDate() DateTime createdAt
});




}
/// @nodoc
class _$LatestReportCopyWithImpl<$Res>
    implements $LatestReportCopyWith<$Res> {
  _$LatestReportCopyWithImpl(this._self, this._then);

  final LatestReport _self;
  final $Res Function(LatestReport) _then;

/// Create a copy of LatestReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? status = null,Object? createdAt = null,}) {
  return _then(LatestReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LatestReport].
extension LatestReportPatterns on LatestReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LatestReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LatestReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LatestReport value)  $default,){
final _that = this;
switch (_that) {
case _LatestReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LatestReport value)?  $default,){
final _that = this;
switch (_that) {
case _LatestReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String status, @LocalDate()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LatestReport() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String status, @LocalDate()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _LatestReport():
return $default(_that.id,_that.title,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String status, @LocalDate()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LatestReport() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LatestReport implements LatestReport {
  const _LatestReport({required this.id, required this.title, required this.status, @LocalDate() required this.createdAt});
  factory _LatestReport.fromJson(Map<String, dynamic> json) => _$LatestReportFromJson(json);

@override final  String id;
@override final  String title;
@override final  String status;
@override@LocalDate() final  DateTime createdAt;

/// Create a copy of LatestReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LatestReportCopyWith<_LatestReport> get copyWith => __$LatestReportCopyWithImpl<_LatestReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LatestReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LatestReport&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,status,createdAt);
}

@override
String toString() {
    return 'LatestReport(id: $id, title: $title, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LatestReportCopyWith<$Res> implements $LatestReportCopyWith<$Res> {
  factory _$LatestReportCopyWith(_LatestReport value, $Res Function(_LatestReport) _then) = __$LatestReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String status,@LocalDate() DateTime createdAt
});




}
/// @nodoc
class __$LatestReportCopyWithImpl<$Res>
    implements _$LatestReportCopyWith<$Res> {
  __$LatestReportCopyWithImpl(this._self, this._then);

  final _LatestReport _self;
  final $Res Function(_LatestReport) _then;

/// Create a copy of LatestReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_LatestReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
