// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Appointment {

 String get id; String get code; AppointmentProperty get property;@LocalDate() DateTime get scheduledAt; int get durationMin; String get status;/// Por confirmar: de quién se espera que acepte la fecha («staff» o «client»): la otra parte de quien la propuso
 String? get awaiting;/// Quien ve la cita puede aceptar la fecha (la propuso la otra parte)
 bool get canAccept; String? get note; String? get reason;/// Formulario que llenó la persona: el de la solicitud de la cita o su solicitud más reciente
/// (mismo formato que una solicitud; «linked» = salió de esa solicitud).
 Map<String, dynamic>? get lead;/// Asesor de la cita (lo ven el cliente y el personal)
 PersonRef? get broker; PersonRef? get client; String? get confirmedBy;
/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentCopyWith<Appointment> get copyWith => _$AppointmentCopyWithImpl<Appointment>(this as Appointment, _$identity);

  /// Serializes this Appointment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Appointment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Appointment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.property, _this.property) || other.property == _this.property)&&(identical(other.scheduledAt, _this.scheduledAt) || other.scheduledAt == _this.scheduledAt)&&(identical(other.durationMin, _this.durationMin) || other.durationMin == _this.durationMin)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.awaiting, _this.awaiting) || other.awaiting == _this.awaiting)&&(identical(other.canAccept, _this.canAccept) || other.canAccept == _this.canAccept)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&const DeepCollectionEquality().equals(other.lead, _this.lead)&&(identical(other.broker, _this.broker) || other.broker == _this.broker)&&(identical(other.client, _this.client) || other.client == _this.client)&&(identical(other.confirmedBy, _this.confirmedBy) || other.confirmedBy == _this.confirmedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Appointment;
  return Object.hash(runtimeType,_this.id,_this.code,_this.property,_this.scheduledAt,_this.durationMin,_this.status,_this.awaiting,_this.canAccept,_this.note,_this.reason,const DeepCollectionEquality().hash(_this.lead),_this.broker,_this.client,_this.confirmedBy);
}

@override
String toString() {
  final _this = this as Appointment;
  return 'Appointment(id: ${_this.id}, code: ${_this.code}, property: ${_this.property}, scheduledAt: ${_this.scheduledAt}, durationMin: ${_this.durationMin}, status: ${_this.status}, awaiting: ${_this.awaiting}, canAccept: ${_this.canAccept}, note: ${_this.note}, reason: ${_this.reason}, lead: ${_this.lead}, broker: ${_this.broker}, client: ${_this.client}, confirmedBy: ${_this.confirmedBy})';
}


}

/// @nodoc
abstract mixin class $AppointmentCopyWith<$Res>  {
  factory $AppointmentCopyWith(Appointment value, $Res Function(Appointment) _then) = _$AppointmentCopyWithImpl;
@useResult
$Res call({
 String id, String code, AppointmentProperty property,@LocalDate() DateTime scheduledAt, int durationMin, String status, String? awaiting, bool canAccept, String? note, String? reason, Map<String, dynamic>? lead, PersonRef? broker, PersonRef? client, String? confirmedBy
});


$AppointmentPropertyCopyWith<$Res> get property;$PersonRefCopyWith<$Res>? get broker;$PersonRefCopyWith<$Res>? get client;

}
/// @nodoc
class _$AppointmentCopyWithImpl<$Res>
    implements $AppointmentCopyWith<$Res> {
  _$AppointmentCopyWithImpl(this._self, this._then);

  final Appointment _self;
  final $Res Function(Appointment) _then;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? property = null,Object? scheduledAt = null,Object? durationMin = null,Object? status = null,Object? awaiting = freezed,Object? canAccept = null,Object? note = freezed,Object? reason = freezed,Object? lead = freezed,Object? broker = freezed,Object? client = freezed,Object? confirmedBy = freezed,}) {
  return _then(Appointment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as AppointmentProperty,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,awaiting: freezed == awaiting ? _self.awaiting : awaiting // ignore: cast_nullable_to_non_nullable
as String?,canAccept: null == canAccept ? _self.canAccept : canAccept // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,lead: freezed == lead ? _self.lead : lead // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,broker: freezed == broker ? _self.broker : broker // ignore: cast_nullable_to_non_nullable
as PersonRef?,client: freezed == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as PersonRef?,confirmedBy: freezed == confirmedBy ? _self.confirmedBy : confirmedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppointmentPropertyCopyWith<$Res> get property {
  
  return $AppointmentPropertyCopyWith<$Res>(_self.property, (value) {
    return _then(_self.copyWith(property: value));
  });
}/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res>? get broker {
    if (_self.broker == null) {
    return null;
  }

  return $PersonRefCopyWith<$Res>(_self.broker!, (value) {
    return _then(_self.copyWith(broker: value));
  });
}/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res>? get client {
    if (_self.client == null) {
    return null;
  }

  return $PersonRefCopyWith<$Res>(_self.client!, (value) {
    return _then(_self.copyWith(client: value));
  });
}
}


/// Adds pattern-matching-related methods to [Appointment].
extension AppointmentPatterns on Appointment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Appointment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Appointment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Appointment value)  $default,){
final _that = this;
switch (_that) {
case _Appointment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Appointment value)?  $default,){
final _that = this;
switch (_that) {
case _Appointment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  AppointmentProperty property, @LocalDate()  DateTime scheduledAt,  int durationMin,  String status,  String? awaiting,  bool canAccept,  String? note,  String? reason,  Map<String, dynamic>? lead,  PersonRef? broker,  PersonRef? client,  String? confirmedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that.id,_that.code,_that.property,_that.scheduledAt,_that.durationMin,_that.status,_that.awaiting,_that.canAccept,_that.note,_that.reason,_that.lead,_that.broker,_that.client,_that.confirmedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  AppointmentProperty property, @LocalDate()  DateTime scheduledAt,  int durationMin,  String status,  String? awaiting,  bool canAccept,  String? note,  String? reason,  Map<String, dynamic>? lead,  PersonRef? broker,  PersonRef? client,  String? confirmedBy)  $default,) {final _that = this;
switch (_that) {
case _Appointment():
return $default(_that.id,_that.code,_that.property,_that.scheduledAt,_that.durationMin,_that.status,_that.awaiting,_that.canAccept,_that.note,_that.reason,_that.lead,_that.broker,_that.client,_that.confirmedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  AppointmentProperty property, @LocalDate()  DateTime scheduledAt,  int durationMin,  String status,  String? awaiting,  bool canAccept,  String? note,  String? reason,  Map<String, dynamic>? lead,  PersonRef? broker,  PersonRef? client,  String? confirmedBy)?  $default,) {final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that.id,_that.code,_that.property,_that.scheduledAt,_that.durationMin,_that.status,_that.awaiting,_that.canAccept,_that.note,_that.reason,_that.lead,_that.broker,_that.client,_that.confirmedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Appointment extends Appointment {
  const _Appointment({required this.id, required this.code, required this.property, @LocalDate() required this.scheduledAt, this.durationMin = 60, required this.status, this.awaiting, this.canAccept = false, this.note, this.reason,  Map<String, dynamic>? lead, this.broker, this.client, this.confirmedBy}): _lead = lead,super._();
  factory _Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);

@override final  String id;
@override final  String code;
@override final  AppointmentProperty property;
@override@LocalDate() final  DateTime scheduledAt;
@override@JsonKey() final  int durationMin;
@override final  String status;
/// Por confirmar: de quién se espera que acepte la fecha («staff» o «client»): la otra parte de quien la propuso
@override final  String? awaiting;
/// Quien ve la cita puede aceptar la fecha (la propuso la otra parte)
@override@JsonKey() final  bool canAccept;
@override final  String? note;
@override final  String? reason;
/// Formulario que llenó la persona: el de la solicitud de la cita o su solicitud más reciente
/// (mismo formato que una solicitud; «linked» = salió de esa solicitud).
 final  Map<String, dynamic>? _lead;
/// Formulario que llenó la persona: el de la solicitud de la cita o su solicitud más reciente
/// (mismo formato que una solicitud; «linked» = salió de esa solicitud).
@override Map<String, dynamic>? get lead {
  final value = _lead;
  if (value == null) return null;
  if (_lead is EqualUnmodifiableMapView) return _lead;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Asesor de la cita (lo ven el cliente y el personal)
@override final  PersonRef? broker;
@override final  PersonRef? client;
@override final  String? confirmedBy;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentCopyWith<_Appointment> get copyWith => __$AppointmentCopyWithImpl<_Appointment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Appointment&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.property, property) || other.property == property)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.durationMin, durationMin) || other.durationMin == durationMin)&&(identical(other.status, status) || other.status == status)&&(identical(other.awaiting, awaiting) || other.awaiting == awaiting)&&(identical(other.canAccept, canAccept) || other.canAccept == canAccept)&&(identical(other.note, note) || other.note == note)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other.lead, _lead)&&(identical(other.broker, broker) || other.broker == broker)&&(identical(other.client, client) || other.client == client)&&(identical(other.confirmedBy, confirmedBy) || other.confirmedBy == confirmedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,property,scheduledAt,durationMin,status,awaiting,canAccept,note,reason,const DeepCollectionEquality().hash(_lead),broker,client,confirmedBy);
}

@override
String toString() {
    return 'Appointment(id: $id, code: $code, property: $property, scheduledAt: $scheduledAt, durationMin: $durationMin, status: $status, awaiting: $awaiting, canAccept: $canAccept, note: $note, reason: $reason, lead: $lead, broker: $broker, client: $client, confirmedBy: $confirmedBy)';
}


}

/// @nodoc
abstract mixin class _$AppointmentCopyWith<$Res> implements $AppointmentCopyWith<$Res> {
  factory _$AppointmentCopyWith(_Appointment value, $Res Function(_Appointment) _then) = __$AppointmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, AppointmentProperty property,@LocalDate() DateTime scheduledAt, int durationMin, String status, String? awaiting, bool canAccept, String? note, String? reason, Map<String, dynamic>? lead, PersonRef? broker, PersonRef? client, String? confirmedBy
});


@override $AppointmentPropertyCopyWith<$Res> get property;@override $PersonRefCopyWith<$Res>? get broker;@override $PersonRefCopyWith<$Res>? get client;

}
/// @nodoc
class __$AppointmentCopyWithImpl<$Res>
    implements _$AppointmentCopyWith<$Res> {
  __$AppointmentCopyWithImpl(this._self, this._then);

  final _Appointment _self;
  final $Res Function(_Appointment) _then;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? property = null,Object? scheduledAt = null,Object? durationMin = null,Object? status = null,Object? awaiting = freezed,Object? canAccept = null,Object? note = freezed,Object? reason = freezed,Object? lead = freezed,Object? broker = freezed,Object? client = freezed,Object? confirmedBy = freezed,}) {
  return _then(_Appointment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as AppointmentProperty,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,awaiting: freezed == awaiting ? _self.awaiting : awaiting // ignore: cast_nullable_to_non_nullable
as String?,canAccept: null == canAccept ? _self.canAccept : canAccept // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,lead: freezed == lead ? _self._lead : lead // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,broker: freezed == broker ? _self.broker : broker // ignore: cast_nullable_to_non_nullable
as PersonRef?,client: freezed == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as PersonRef?,confirmedBy: freezed == confirmedBy ? _self.confirmedBy : confirmedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppointmentPropertyCopyWith<$Res> get property {
  
  return $AppointmentPropertyCopyWith<$Res>(_self.property, (value) {
    return _then(_self.copyWith(property: value));
  });
}/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res>? get broker {
    if (_self.broker == null) {
    return null;
  }

  return $PersonRefCopyWith<$Res>(_self.broker!, (value) {
    return _then(_self.copyWith(broker: value));
  });
}/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res>? get client {
    if (_self.client == null) {
    return null;
  }

  return $PersonRefCopyWith<$Res>(_self.client!, (value) {
    return _then(_self.copyWith(client: value));
  });
}
}


/// @nodoc
mixin _$AppointmentProperty {

 String get id; String? get code; String get name; String? get zone; String? get address; String? get photo;/// Punto exacto: al cliente le llega cuando la cita está confirmada (o la visita ya se hizo)
 double? get lat; double? get lng; bool get exactLocation;
/// Create a copy of AppointmentProperty
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentPropertyCopyWith<AppointmentProperty> get copyWith => _$AppointmentPropertyCopyWithImpl<AppointmentProperty>(this as AppointmentProperty, _$identity);

  /// Serializes this AppointmentProperty to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppointmentProperty;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppointmentProperty&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.zone, _this.zone) || other.zone == _this.zone)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.photo, _this.photo) || other.photo == _this.photo)&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lng, _this.lng) || other.lng == _this.lng)&&(identical(other.exactLocation, _this.exactLocation) || other.exactLocation == _this.exactLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppointmentProperty;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name,_this.zone,_this.address,_this.photo,_this.lat,_this.lng,_this.exactLocation);
}

@override
String toString() {
  final _this = this as AppointmentProperty;
  return 'AppointmentProperty(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, zone: ${_this.zone}, address: ${_this.address}, photo: ${_this.photo}, lat: ${_this.lat}, lng: ${_this.lng}, exactLocation: ${_this.exactLocation})';
}


}

/// @nodoc
abstract mixin class $AppointmentPropertyCopyWith<$Res>  {
  factory $AppointmentPropertyCopyWith(AppointmentProperty value, $Res Function(AppointmentProperty) _then) = _$AppointmentPropertyCopyWithImpl;
@useResult
$Res call({
 String id, String? code, String name, String? zone, String? address, String? photo, double? lat, double? lng, bool exactLocation
});




}
/// @nodoc
class _$AppointmentPropertyCopyWithImpl<$Res>
    implements $AppointmentPropertyCopyWith<$Res> {
  _$AppointmentPropertyCopyWithImpl(this._self, this._then);

  final AppointmentProperty _self;
  final $Res Function(AppointmentProperty) _then;

/// Create a copy of AppointmentProperty
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = freezed,Object? name = null,Object? zone = freezed,Object? address = freezed,Object? photo = freezed,Object? lat = freezed,Object? lng = freezed,Object? exactLocation = null,}) {
  return _then(AppointmentProperty(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,exactLocation: null == exactLocation ? _self.exactLocation : exactLocation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppointmentProperty].
extension AppointmentPropertyPatterns on AppointmentProperty {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppointmentProperty value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppointmentProperty() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppointmentProperty value)  $default,){
final _that = this;
switch (_that) {
case _AppointmentProperty():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppointmentProperty value)?  $default,){
final _that = this;
switch (_that) {
case _AppointmentProperty() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? code,  String name,  String? zone,  String? address,  String? photo,  double? lat,  double? lng,  bool exactLocation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppointmentProperty() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.zone,_that.address,_that.photo,_that.lat,_that.lng,_that.exactLocation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? code,  String name,  String? zone,  String? address,  String? photo,  double? lat,  double? lng,  bool exactLocation)  $default,) {final _that = this;
switch (_that) {
case _AppointmentProperty():
return $default(_that.id,_that.code,_that.name,_that.zone,_that.address,_that.photo,_that.lat,_that.lng,_that.exactLocation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? code,  String name,  String? zone,  String? address,  String? photo,  double? lat,  double? lng,  bool exactLocation)?  $default,) {final _that = this;
switch (_that) {
case _AppointmentProperty() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.zone,_that.address,_that.photo,_that.lat,_that.lng,_that.exactLocation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppointmentProperty extends AppointmentProperty {
  const _AppointmentProperty({required this.id, this.code, required this.name, this.zone, this.address, this.photo, this.lat, this.lng, this.exactLocation = true}): super._();
  factory _AppointmentProperty.fromJson(Map<String, dynamic> json) => _$AppointmentPropertyFromJson(json);

@override final  String id;
@override final  String? code;
@override final  String name;
@override final  String? zone;
@override final  String? address;
@override final  String? photo;
/// Punto exacto: al cliente le llega cuando la cita está confirmada (o la visita ya se hizo)
@override final  double? lat;
@override final  double? lng;
@override@JsonKey() final  bool exactLocation;

/// Create a copy of AppointmentProperty
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentPropertyCopyWith<_AppointmentProperty> get copyWith => __$AppointmentPropertyCopyWithImpl<_AppointmentProperty>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentPropertyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppointmentProperty&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.address, address) || other.address == address)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.exactLocation, exactLocation) || other.exactLocation == exactLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name,zone,address,photo,lat,lng,exactLocation);
}

@override
String toString() {
    return 'AppointmentProperty(id: $id, code: $code, name: $name, zone: $zone, address: $address, photo: $photo, lat: $lat, lng: $lng, exactLocation: $exactLocation)';
}


}

/// @nodoc
abstract mixin class _$AppointmentPropertyCopyWith<$Res> implements $AppointmentPropertyCopyWith<$Res> {
  factory _$AppointmentPropertyCopyWith(_AppointmentProperty value, $Res Function(_AppointmentProperty) _then) = __$AppointmentPropertyCopyWithImpl;
@override @useResult
$Res call({
 String id, String? code, String name, String? zone, String? address, String? photo, double? lat, double? lng, bool exactLocation
});




}
/// @nodoc
class __$AppointmentPropertyCopyWithImpl<$Res>
    implements _$AppointmentPropertyCopyWith<$Res> {
  __$AppointmentPropertyCopyWithImpl(this._self, this._then);

  final _AppointmentProperty _self;
  final $Res Function(_AppointmentProperty) _then;

/// Create a copy of AppointmentProperty
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = freezed,Object? name = null,Object? zone = freezed,Object? address = freezed,Object? photo = freezed,Object? lat = freezed,Object? lng = freezed,Object? exactLocation = null,}) {
  return _then(_AppointmentProperty(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,exactLocation: null == exactLocation ? _self.exactLocation : exactLocation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PersonRef {

 String get id; String get name; String? get phone; String? get email; String? get code; String? get kind;
/// Create a copy of PersonRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonRefCopyWith<PersonRef> get copyWith => _$PersonRefCopyWithImpl<PersonRef>(this as PersonRef, _$identity);

  /// Serializes this PersonRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PersonRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.kind, _this.kind) || other.kind == _this.kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PersonRef;
  return Object.hash(runtimeType,_this.id,_this.name,_this.phone,_this.email,_this.code,_this.kind);
}

@override
String toString() {
  final _this = this as PersonRef;
  return 'PersonRef(id: ${_this.id}, name: ${_this.name}, phone: ${_this.phone}, email: ${_this.email}, code: ${_this.code}, kind: ${_this.kind})';
}


}

/// @nodoc
abstract mixin class $PersonRefCopyWith<$Res>  {
  factory $PersonRefCopyWith(PersonRef value, $Res Function(PersonRef) _then) = _$PersonRefCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? phone, String? email, String? code, String? kind
});




}
/// @nodoc
class _$PersonRefCopyWithImpl<$Res>
    implements $PersonRefCopyWith<$Res> {
  _$PersonRefCopyWithImpl(this._self, this._then);

  final PersonRef _self;
  final $Res Function(PersonRef) _then;

/// Create a copy of PersonRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phone = freezed,Object? email = freezed,Object? code = freezed,Object? kind = freezed,}) {
  return _then(PersonRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonRef].
extension PersonRefPatterns on PersonRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonRef value)  $default,){
final _that = this;
switch (_that) {
case _PersonRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonRef value)?  $default,){
final _that = this;
switch (_that) {
case _PersonRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? phone,  String? email,  String? code,  String? kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonRef() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.email,_that.code,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? phone,  String? email,  String? code,  String? kind)  $default,) {final _that = this;
switch (_that) {
case _PersonRef():
return $default(_that.id,_that.name,_that.phone,_that.email,_that.code,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? phone,  String? email,  String? code,  String? kind)?  $default,) {final _that = this;
switch (_that) {
case _PersonRef() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.email,_that.code,_that.kind);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonRef implements PersonRef {
  const _PersonRef({required this.id, required this.name, this.phone, this.email, this.code, this.kind});
  factory _PersonRef.fromJson(Map<String, dynamic> json) => _$PersonRefFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? phone;
@override final  String? email;
@override final  String? code;
@override final  String? kind;

/// Create a copy of PersonRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonRefCopyWith<_PersonRef> get copyWith => __$PersonRefCopyWithImpl<_PersonRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,phone,email,code,kind);
}

@override
String toString() {
    return 'PersonRef(id: $id, name: $name, phone: $phone, email: $email, code: $code, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$PersonRefCopyWith<$Res> implements $PersonRefCopyWith<$Res> {
  factory _$PersonRefCopyWith(_PersonRef value, $Res Function(_PersonRef) _then) = __$PersonRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? phone, String? email, String? code, String? kind
});




}
/// @nodoc
class __$PersonRefCopyWithImpl<$Res>
    implements _$PersonRefCopyWith<$Res> {
  __$PersonRefCopyWithImpl(this._self, this._then);

  final _PersonRef _self;
  final $Res Function(_PersonRef) _then;

/// Create a copy of PersonRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phone = freezed,Object? email = freezed,Object? code = freezed,Object? kind = freezed,}) {
  return _then(_PersonRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AppointmentMessage {

 String get id; bool get mine; String get sender; bool get fromStaff; String get body;@LocalDate() DateTime get createdAt;
/// Create a copy of AppointmentMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentMessageCopyWith<AppointmentMessage> get copyWith => _$AppointmentMessageCopyWithImpl<AppointmentMessage>(this as AppointmentMessage, _$identity);

  /// Serializes this AppointmentMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppointmentMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppointmentMessage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.mine, _this.mine) || other.mine == _this.mine)&&(identical(other.sender, _this.sender) || other.sender == _this.sender)&&(identical(other.fromStaff, _this.fromStaff) || other.fromStaff == _this.fromStaff)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppointmentMessage;
  return Object.hash(runtimeType,_this.id,_this.mine,_this.sender,_this.fromStaff,_this.body,_this.createdAt);
}

@override
String toString() {
  final _this = this as AppointmentMessage;
  return 'AppointmentMessage(id: ${_this.id}, mine: ${_this.mine}, sender: ${_this.sender}, fromStaff: ${_this.fromStaff}, body: ${_this.body}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $AppointmentMessageCopyWith<$Res>  {
  factory $AppointmentMessageCopyWith(AppointmentMessage value, $Res Function(AppointmentMessage) _then) = _$AppointmentMessageCopyWithImpl;
@useResult
$Res call({
 String id, bool mine, String sender, bool fromStaff, String body,@LocalDate() DateTime createdAt
});




}
/// @nodoc
class _$AppointmentMessageCopyWithImpl<$Res>
    implements $AppointmentMessageCopyWith<$Res> {
  _$AppointmentMessageCopyWithImpl(this._self, this._then);

  final AppointmentMessage _self;
  final $Res Function(AppointmentMessage) _then;

/// Create a copy of AppointmentMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? mine = null,Object? sender = null,Object? fromStaff = null,Object? body = null,Object? createdAt = null,}) {
  return _then(AppointmentMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mine: null == mine ? _self.mine : mine // ignore: cast_nullable_to_non_nullable
as bool,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,fromStaff: null == fromStaff ? _self.fromStaff : fromStaff // ignore: cast_nullable_to_non_nullable
as bool,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppointmentMessage].
extension AppointmentMessagePatterns on AppointmentMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppointmentMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppointmentMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppointmentMessage value)  $default,){
final _that = this;
switch (_that) {
case _AppointmentMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppointmentMessage value)?  $default,){
final _that = this;
switch (_that) {
case _AppointmentMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool mine,  String sender,  bool fromStaff,  String body, @LocalDate()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppointmentMessage() when $default != null:
return $default(_that.id,_that.mine,_that.sender,_that.fromStaff,_that.body,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool mine,  String sender,  bool fromStaff,  String body, @LocalDate()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AppointmentMessage():
return $default(_that.id,_that.mine,_that.sender,_that.fromStaff,_that.body,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool mine,  String sender,  bool fromStaff,  String body, @LocalDate()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AppointmentMessage() when $default != null:
return $default(_that.id,_that.mine,_that.sender,_that.fromStaff,_that.body,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppointmentMessage implements AppointmentMessage {
  const _AppointmentMessage({required this.id, required this.mine, required this.sender, required this.fromStaff, required this.body, @LocalDate() required this.createdAt});
  factory _AppointmentMessage.fromJson(Map<String, dynamic> json) => _$AppointmentMessageFromJson(json);

@override final  String id;
@override final  bool mine;
@override final  String sender;
@override final  bool fromStaff;
@override final  String body;
@override@LocalDate() final  DateTime createdAt;

/// Create a copy of AppointmentMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentMessageCopyWith<_AppointmentMessage> get copyWith => __$AppointmentMessageCopyWithImpl<_AppointmentMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentMessageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppointmentMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.mine, mine) || other.mine == mine)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.fromStaff, fromStaff) || other.fromStaff == fromStaff)&&(identical(other.body, body) || other.body == body)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,mine,sender,fromStaff,body,createdAt);
}

@override
String toString() {
    return 'AppointmentMessage(id: $id, mine: $mine, sender: $sender, fromStaff: $fromStaff, body: $body, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AppointmentMessageCopyWith<$Res> implements $AppointmentMessageCopyWith<$Res> {
  factory _$AppointmentMessageCopyWith(_AppointmentMessage value, $Res Function(_AppointmentMessage) _then) = __$AppointmentMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, bool mine, String sender, bool fromStaff, String body,@LocalDate() DateTime createdAt
});




}
/// @nodoc
class __$AppointmentMessageCopyWithImpl<$Res>
    implements _$AppointmentMessageCopyWith<$Res> {
  __$AppointmentMessageCopyWithImpl(this._self, this._then);

  final _AppointmentMessage _self;
  final $Res Function(_AppointmentMessage) _then;

/// Create a copy of AppointmentMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? mine = null,Object? sender = null,Object? fromStaff = null,Object? body = null,Object? createdAt = null,}) {
  return _then(_AppointmentMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mine: null == mine ? _self.mine : mine // ignore: cast_nullable_to_non_nullable
as bool,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,fromStaff: null == fromStaff ? _self.fromStaff : fromStaff // ignore: cast_nullable_to_non_nullable
as bool,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
