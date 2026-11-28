// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaintenanceReport {

 String get id; ReportProperty? get property; String get title; String get description; String get category; String get priority; String get subtitle; String get status; String get statusLabel; ReportProvider? get provider;@LocalDateOrNull() DateTime? get closedAt;@LocalDate() DateTime get createdAt; List<TimelineEntry> get timeline; ReportPhotos get photos;
/// Create a copy of MaintenanceReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceReportCopyWith<MaintenanceReport> get copyWith => _$MaintenanceReportCopyWithImpl<MaintenanceReport>(this as MaintenanceReport, _$identity);

  /// Serializes this MaintenanceReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MaintenanceReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceReport&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.property, _this.property) || other.property == _this.property)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.statusLabel, _this.statusLabel) || other.statusLabel == _this.statusLabel)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.closedAt, _this.closedAt) || other.closedAt == _this.closedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.timeline, _this.timeline)&&(identical(other.photos, _this.photos) || other.photos == _this.photos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MaintenanceReport;
  return Object.hash(runtimeType,_this.id,_this.property,_this.title,_this.description,_this.category,_this.priority,_this.subtitle,_this.status,_this.statusLabel,_this.provider,_this.closedAt,_this.createdAt,const DeepCollectionEquality().hash(_this.timeline),_this.photos);
}

@override
String toString() {
  final _this = this as MaintenanceReport;
  return 'MaintenanceReport(id: ${_this.id}, property: ${_this.property}, title: ${_this.title}, description: ${_this.description}, category: ${_this.category}, priority: ${_this.priority}, subtitle: ${_this.subtitle}, status: ${_this.status}, statusLabel: ${_this.statusLabel}, provider: ${_this.provider}, closedAt: ${_this.closedAt}, createdAt: ${_this.createdAt}, timeline: ${_this.timeline}, photos: ${_this.photos})';
}


}

/// @nodoc
abstract mixin class $MaintenanceReportCopyWith<$Res>  {
  factory $MaintenanceReportCopyWith(MaintenanceReport value, $Res Function(MaintenanceReport) _then) = _$MaintenanceReportCopyWithImpl;
@useResult
$Res call({
 String id, ReportProperty? property, String title, String description, String category, String priority, String subtitle, String status, String statusLabel, ReportProvider? provider,@LocalDateOrNull() DateTime? closedAt,@LocalDate() DateTime createdAt, List<TimelineEntry> timeline, ReportPhotos photos
});


$ReportPropertyCopyWith<$Res>? get property;$ReportProviderCopyWith<$Res>? get provider;$ReportPhotosCopyWith<$Res> get photos;

}
/// @nodoc
class _$MaintenanceReportCopyWithImpl<$Res>
    implements $MaintenanceReportCopyWith<$Res> {
  _$MaintenanceReportCopyWithImpl(this._self, this._then);

  final MaintenanceReport _self;
  final $Res Function(MaintenanceReport) _then;

/// Create a copy of MaintenanceReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? property = freezed,Object? title = null,Object? description = null,Object? category = null,Object? priority = null,Object? subtitle = null,Object? status = null,Object? statusLabel = null,Object? provider = freezed,Object? closedAt = freezed,Object? createdAt = null,Object? timeline = null,Object? photos = null,}) {
  return _then(MaintenanceReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,property: freezed == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as ReportProperty?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as ReportProvider?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineEntry>,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as ReportPhotos,
  ));
}
/// Create a copy of MaintenanceReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportPropertyCopyWith<$Res>? get property {
    if (_self.property == null) {
    return null;
  }

  return $ReportPropertyCopyWith<$Res>(_self.property!, (value) {
    return _then(_self.copyWith(property: value));
  });
}/// Create a copy of MaintenanceReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportProviderCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $ReportProviderCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
  });
}/// Create a copy of MaintenanceReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportPhotosCopyWith<$Res> get photos {
  
  return $ReportPhotosCopyWith<$Res>(_self.photos, (value) {
    return _then(_self.copyWith(photos: value));
  });
}
}


/// Adds pattern-matching-related methods to [MaintenanceReport].
extension MaintenanceReportPatterns on MaintenanceReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceReport value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceReport value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ReportProperty? property,  String title,  String description,  String category,  String priority,  String subtitle,  String status,  String statusLabel,  ReportProvider? provider, @LocalDateOrNull()  DateTime? closedAt, @LocalDate()  DateTime createdAt,  List<TimelineEntry> timeline,  ReportPhotos photos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceReport() when $default != null:
return $default(_that.id,_that.property,_that.title,_that.description,_that.category,_that.priority,_that.subtitle,_that.status,_that.statusLabel,_that.provider,_that.closedAt,_that.createdAt,_that.timeline,_that.photos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ReportProperty? property,  String title,  String description,  String category,  String priority,  String subtitle,  String status,  String statusLabel,  ReportProvider? provider, @LocalDateOrNull()  DateTime? closedAt, @LocalDate()  DateTime createdAt,  List<TimelineEntry> timeline,  ReportPhotos photos)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceReport():
return $default(_that.id,_that.property,_that.title,_that.description,_that.category,_that.priority,_that.subtitle,_that.status,_that.statusLabel,_that.provider,_that.closedAt,_that.createdAt,_that.timeline,_that.photos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ReportProperty? property,  String title,  String description,  String category,  String priority,  String subtitle,  String status,  String statusLabel,  ReportProvider? provider, @LocalDateOrNull()  DateTime? closedAt, @LocalDate()  DateTime createdAt,  List<TimelineEntry> timeline,  ReportPhotos photos)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceReport() when $default != null:
return $default(_that.id,_that.property,_that.title,_that.description,_that.category,_that.priority,_that.subtitle,_that.status,_that.statusLabel,_that.provider,_that.closedAt,_that.createdAt,_that.timeline,_that.photos);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaintenanceReport extends MaintenanceReport {
  const _MaintenanceReport({required this.id, this.property, required this.title, required this.description, required this.category, required this.priority, required this.subtitle, required this.status, required this.statusLabel, this.provider, @LocalDateOrNull() this.closedAt, @LocalDate() required this.createdAt,  List<TimelineEntry> timeline = const <TimelineEntry>[], this.photos = const ReportPhotos()}): _timeline = timeline,super._();
  factory _MaintenanceReport.fromJson(Map<String, dynamic> json) => _$MaintenanceReportFromJson(json);

@override final  String id;
@override final  ReportProperty? property;
@override final  String title;
@override final  String description;
@override final  String category;
@override final  String priority;
@override final  String subtitle;
@override final  String status;
@override final  String statusLabel;
@override final  ReportProvider? provider;
@override@LocalDateOrNull() final  DateTime? closedAt;
@override@LocalDate() final  DateTime createdAt;
 final  List<TimelineEntry> _timeline;
@override@JsonKey() List<TimelineEntry> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

@override@JsonKey() final  ReportPhotos photos;

/// Create a copy of MaintenanceReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceReportCopyWith<_MaintenanceReport> get copyWith => __$MaintenanceReportCopyWithImpl<_MaintenanceReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceReport&&(identical(other.id, id) || other.id == id)&&(identical(other.property, property) || other.property == property)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.timeline, _timeline)&&(identical(other.photos, photos) || other.photos == photos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,property,title,description,category,priority,subtitle,status,statusLabel,provider,closedAt,createdAt,const DeepCollectionEquality().hash(_timeline),photos);
}

@override
String toString() {
    return 'MaintenanceReport(id: $id, property: $property, title: $title, description: $description, category: $category, priority: $priority, subtitle: $subtitle, status: $status, statusLabel: $statusLabel, provider: $provider, closedAt: $closedAt, createdAt: $createdAt, timeline: $timeline, photos: $photos)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceReportCopyWith<$Res> implements $MaintenanceReportCopyWith<$Res> {
  factory _$MaintenanceReportCopyWith(_MaintenanceReport value, $Res Function(_MaintenanceReport) _then) = __$MaintenanceReportCopyWithImpl;
@override @useResult
$Res call({
 String id, ReportProperty? property, String title, String description, String category, String priority, String subtitle, String status, String statusLabel, ReportProvider? provider,@LocalDateOrNull() DateTime? closedAt,@LocalDate() DateTime createdAt, List<TimelineEntry> timeline, ReportPhotos photos
});


@override $ReportPropertyCopyWith<$Res>? get property;@override $ReportProviderCopyWith<$Res>? get provider;@override $ReportPhotosCopyWith<$Res> get photos;

}
/// @nodoc
class __$MaintenanceReportCopyWithImpl<$Res>
    implements _$MaintenanceReportCopyWith<$Res> {
  __$MaintenanceReportCopyWithImpl(this._self, this._then);

  final _MaintenanceReport _self;
  final $Res Function(_MaintenanceReport) _then;

/// Create a copy of MaintenanceReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? property = freezed,Object? title = null,Object? description = null,Object? category = null,Object? priority = null,Object? subtitle = null,Object? status = null,Object? statusLabel = null,Object? provider = freezed,Object? closedAt = freezed,Object? createdAt = null,Object? timeline = null,Object? photos = null,}) {
  return _then(_MaintenanceReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,property: freezed == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as ReportProperty?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as ReportProvider?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineEntry>,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as ReportPhotos,
  ));
}

/// Create a copy of MaintenanceReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportPropertyCopyWith<$Res>? get property {
    if (_self.property == null) {
    return null;
  }

  return $ReportPropertyCopyWith<$Res>(_self.property!, (value) {
    return _then(_self.copyWith(property: value));
  });
}/// Create a copy of MaintenanceReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportProviderCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $ReportProviderCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
  });
}/// Create a copy of MaintenanceReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportPhotosCopyWith<$Res> get photos {
  
  return $ReportPhotosCopyWith<$Res>(_self.photos, (value) {
    return _then(_self.copyWith(photos: value));
  });
}
}


/// @nodoc
mixin _$ReportProperty {

 String get id; String? get code; String get name;
/// Create a copy of ReportProperty
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportPropertyCopyWith<ReportProperty> get copyWith => _$ReportPropertyCopyWithImpl<ReportProperty>(this as ReportProperty, _$identity);

  /// Serializes this ReportProperty to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportProperty;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportProperty&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportProperty;
  return Object.hash(runtimeType,_this.id,_this.code,_this.name);
}

@override
String toString() {
  final _this = this as ReportProperty;
  return 'ReportProperty(id: ${_this.id}, code: ${_this.code}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $ReportPropertyCopyWith<$Res>  {
  factory $ReportPropertyCopyWith(ReportProperty value, $Res Function(ReportProperty) _then) = _$ReportPropertyCopyWithImpl;
@useResult
$Res call({
 String id, String? code, String name
});




}
/// @nodoc
class _$ReportPropertyCopyWithImpl<$Res>
    implements $ReportPropertyCopyWith<$Res> {
  _$ReportPropertyCopyWithImpl(this._self, this._then);

  final ReportProperty _self;
  final $Res Function(ReportProperty) _then;

/// Create a copy of ReportProperty
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = freezed,Object? name = null,}) {
  return _then(ReportProperty(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportProperty].
extension ReportPropertyPatterns on ReportProperty {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportProperty value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportProperty() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportProperty value)  $default,){
final _that = this;
switch (_that) {
case _ReportProperty():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportProperty value)?  $default,){
final _that = this;
switch (_that) {
case _ReportProperty() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? code,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportProperty() when $default != null:
return $default(_that.id,_that.code,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? code,  String name)  $default,) {final _that = this;
switch (_that) {
case _ReportProperty():
return $default(_that.id,_that.code,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? code,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ReportProperty() when $default != null:
return $default(_that.id,_that.code,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportProperty implements ReportProperty {
  const _ReportProperty({required this.id, this.code, required this.name});
  factory _ReportProperty.fromJson(Map<String, dynamic> json) => _$ReportPropertyFromJson(json);

@override final  String id;
@override final  String? code;
@override final  String name;

/// Create a copy of ReportProperty
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportPropertyCopyWith<_ReportProperty> get copyWith => __$ReportPropertyCopyWithImpl<_ReportProperty>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportPropertyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportProperty&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,name);
}

@override
String toString() {
    return 'ReportProperty(id: $id, code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ReportPropertyCopyWith<$Res> implements $ReportPropertyCopyWith<$Res> {
  factory _$ReportPropertyCopyWith(_ReportProperty value, $Res Function(_ReportProperty) _then) = __$ReportPropertyCopyWithImpl;
@override @useResult
$Res call({
 String id, String? code, String name
});




}
/// @nodoc
class __$ReportPropertyCopyWithImpl<$Res>
    implements _$ReportPropertyCopyWith<$Res> {
  __$ReportPropertyCopyWithImpl(this._self, this._then);

  final _ReportProperty _self;
  final $Res Function(_ReportProperty) _then;

/// Create a copy of ReportProperty
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = freezed,Object? name = null,}) {
  return _then(_ReportProperty(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ReportProvider {

 String get id; String get name; String? get specialty; String? get phone;
/// Create a copy of ReportProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportProviderCopyWith<ReportProvider> get copyWith => _$ReportProviderCopyWithImpl<ReportProvider>(this as ReportProvider, _$identity);

  /// Serializes this ReportProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportProvider;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportProvider&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.specialty, _this.specialty) || other.specialty == _this.specialty)&&(identical(other.phone, _this.phone) || other.phone == _this.phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportProvider;
  return Object.hash(runtimeType,_this.id,_this.name,_this.specialty,_this.phone);
}

@override
String toString() {
  final _this = this as ReportProvider;
  return 'ReportProvider(id: ${_this.id}, name: ${_this.name}, specialty: ${_this.specialty}, phone: ${_this.phone})';
}


}

/// @nodoc
abstract mixin class $ReportProviderCopyWith<$Res>  {
  factory $ReportProviderCopyWith(ReportProvider value, $Res Function(ReportProvider) _then) = _$ReportProviderCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? specialty, String? phone
});




}
/// @nodoc
class _$ReportProviderCopyWithImpl<$Res>
    implements $ReportProviderCopyWith<$Res> {
  _$ReportProviderCopyWithImpl(this._self, this._then);

  final ReportProvider _self;
  final $Res Function(ReportProvider) _then;

/// Create a copy of ReportProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? specialty = freezed,Object? phone = freezed,}) {
  return _then(ReportProvider(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialty: freezed == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportProvider].
extension ReportProviderPatterns on ReportProvider {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportProvider() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportProvider value)  $default,){
final _that = this;
switch (_that) {
case _ReportProvider():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportProvider value)?  $default,){
final _that = this;
switch (_that) {
case _ReportProvider() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? specialty,  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportProvider() when $default != null:
return $default(_that.id,_that.name,_that.specialty,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? specialty,  String? phone)  $default,) {final _that = this;
switch (_that) {
case _ReportProvider():
return $default(_that.id,_that.name,_that.specialty,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? specialty,  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _ReportProvider() when $default != null:
return $default(_that.id,_that.name,_that.specialty,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportProvider implements ReportProvider {
  const _ReportProvider({required this.id, required this.name, this.specialty, this.phone});
  factory _ReportProvider.fromJson(Map<String, dynamic> json) => _$ReportProviderFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? specialty;
@override final  String? phone;

/// Create a copy of ReportProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportProviderCopyWith<_ReportProvider> get copyWith => __$ReportProviderCopyWithImpl<_ReportProvider>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportProviderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportProvider&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,specialty,phone);
}

@override
String toString() {
    return 'ReportProvider(id: $id, name: $name, specialty: $specialty, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$ReportProviderCopyWith<$Res> implements $ReportProviderCopyWith<$Res> {
  factory _$ReportProviderCopyWith(_ReportProvider value, $Res Function(_ReportProvider) _then) = __$ReportProviderCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? specialty, String? phone
});




}
/// @nodoc
class __$ReportProviderCopyWithImpl<$Res>
    implements _$ReportProviderCopyWith<$Res> {
  __$ReportProviderCopyWithImpl(this._self, this._then);

  final _ReportProvider _self;
  final $Res Function(_ReportProvider) _then;

/// Create a copy of ReportProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? specialty = freezed,Object? phone = freezed,}) {
  return _then(_ReportProvider(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialty: freezed == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TimelineEntry {

 String get id; String get status; String get statusLabel; String? get comment; String? get author;@LocalDate() DateTime get createdAt;
/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineEntryCopyWith<TimelineEntry> get copyWith => _$TimelineEntryCopyWithImpl<TimelineEntry>(this as TimelineEntry, _$identity);

  /// Serializes this TimelineEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TimelineEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.statusLabel, _this.statusLabel) || other.statusLabel == _this.statusLabel)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TimelineEntry;
  return Object.hash(runtimeType,_this.id,_this.status,_this.statusLabel,_this.comment,_this.author,_this.createdAt);
}

@override
String toString() {
  final _this = this as TimelineEntry;
  return 'TimelineEntry(id: ${_this.id}, status: ${_this.status}, statusLabel: ${_this.statusLabel}, comment: ${_this.comment}, author: ${_this.author}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $TimelineEntryCopyWith<$Res>  {
  factory $TimelineEntryCopyWith(TimelineEntry value, $Res Function(TimelineEntry) _then) = _$TimelineEntryCopyWithImpl;
@useResult
$Res call({
 String id, String status, String statusLabel, String? comment, String? author,@LocalDate() DateTime createdAt
});




}
/// @nodoc
class _$TimelineEntryCopyWithImpl<$Res>
    implements $TimelineEntryCopyWith<$Res> {
  _$TimelineEntryCopyWithImpl(this._self, this._then);

  final TimelineEntry _self;
  final $Res Function(TimelineEntry) _then;

/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? statusLabel = null,Object? comment = freezed,Object? author = freezed,Object? createdAt = null,}) {
  return _then(TimelineEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelineEntry].
extension TimelineEntryPatterns on TimelineEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelineEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelineEntry value)  $default,){
final _that = this;
switch (_that) {
case _TimelineEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelineEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  String statusLabel,  String? comment,  String? author, @LocalDate()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
return $default(_that.id,_that.status,_that.statusLabel,_that.comment,_that.author,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  String statusLabel,  String? comment,  String? author, @LocalDate()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TimelineEntry():
return $default(_that.id,_that.status,_that.statusLabel,_that.comment,_that.author,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  String statusLabel,  String? comment,  String? author, @LocalDate()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
return $default(_that.id,_that.status,_that.statusLabel,_that.comment,_that.author,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimelineEntry implements TimelineEntry {
  const _TimelineEntry({required this.id, required this.status, required this.statusLabel, this.comment, this.author, @LocalDate() required this.createdAt});
  factory _TimelineEntry.fromJson(Map<String, dynamic> json) => _$TimelineEntryFromJson(json);

@override final  String id;
@override final  String status;
@override final  String statusLabel;
@override final  String? comment;
@override final  String? author;
@override@LocalDate() final  DateTime createdAt;

/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelineEntryCopyWith<_TimelineEntry> get copyWith => __$TimelineEntryCopyWithImpl<_TimelineEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelineEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelineEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.author, author) || other.author == author)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,status,statusLabel,comment,author,createdAt);
}

@override
String toString() {
    return 'TimelineEntry(id: $id, status: $status, statusLabel: $statusLabel, comment: $comment, author: $author, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TimelineEntryCopyWith<$Res> implements $TimelineEntryCopyWith<$Res> {
  factory _$TimelineEntryCopyWith(_TimelineEntry value, $Res Function(_TimelineEntry) _then) = __$TimelineEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, String statusLabel, String? comment, String? author,@LocalDate() DateTime createdAt
});




}
/// @nodoc
class __$TimelineEntryCopyWithImpl<$Res>
    implements _$TimelineEntryCopyWith<$Res> {
  __$TimelineEntryCopyWithImpl(this._self, this._then);

  final _TimelineEntry _self;
  final $Res Function(_TimelineEntry) _then;

/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? statusLabel = null,Object? comment = freezed,Object? author = freezed,Object? createdAt = null,}) {
  return _then(_TimelineEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ReportPhotos {

 List<ReportPhoto> get before; List<ReportPhoto> get after;
/// Create a copy of ReportPhotos
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportPhotosCopyWith<ReportPhotos> get copyWith => _$ReportPhotosCopyWithImpl<ReportPhotos>(this as ReportPhotos, _$identity);

  /// Serializes this ReportPhotos to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportPhotos;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportPhotos&&const DeepCollectionEquality().equals(other.before, _this.before)&&const DeepCollectionEquality().equals(other.after, _this.after));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportPhotos;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.before),const DeepCollectionEquality().hash(_this.after));
}

@override
String toString() {
  final _this = this as ReportPhotos;
  return 'ReportPhotos(before: ${_this.before}, after: ${_this.after})';
}


}

/// @nodoc
abstract mixin class $ReportPhotosCopyWith<$Res>  {
  factory $ReportPhotosCopyWith(ReportPhotos value, $Res Function(ReportPhotos) _then) = _$ReportPhotosCopyWithImpl;
@useResult
$Res call({
 List<ReportPhoto> before, List<ReportPhoto> after
});




}
/// @nodoc
class _$ReportPhotosCopyWithImpl<$Res>
    implements $ReportPhotosCopyWith<$Res> {
  _$ReportPhotosCopyWithImpl(this._self, this._then);

  final ReportPhotos _self;
  final $Res Function(ReportPhotos) _then;

/// Create a copy of ReportPhotos
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? before = null,Object? after = null,}) {
  return _then(ReportPhotos(
before: null == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as List<ReportPhoto>,after: null == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as List<ReportPhoto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportPhotos].
extension ReportPhotosPatterns on ReportPhotos {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportPhotos value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportPhotos() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportPhotos value)  $default,){
final _that = this;
switch (_that) {
case _ReportPhotos():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportPhotos value)?  $default,){
final _that = this;
switch (_that) {
case _ReportPhotos() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ReportPhoto> before,  List<ReportPhoto> after)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportPhotos() when $default != null:
return $default(_that.before,_that.after);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ReportPhoto> before,  List<ReportPhoto> after)  $default,) {final _that = this;
switch (_that) {
case _ReportPhotos():
return $default(_that.before,_that.after);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ReportPhoto> before,  List<ReportPhoto> after)?  $default,) {final _that = this;
switch (_that) {
case _ReportPhotos() when $default != null:
return $default(_that.before,_that.after);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportPhotos implements ReportPhotos {
  const _ReportPhotos({ List<ReportPhoto> before = const <ReportPhoto>[],  List<ReportPhoto> after = const <ReportPhoto>[]}): _before = before,_after = after;
  factory _ReportPhotos.fromJson(Map<String, dynamic> json) => _$ReportPhotosFromJson(json);

 final  List<ReportPhoto> _before;
@override@JsonKey() List<ReportPhoto> get before {
  if (_before is EqualUnmodifiableListView) return _before;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_before);
}

 final  List<ReportPhoto> _after;
@override@JsonKey() List<ReportPhoto> get after {
  if (_after is EqualUnmodifiableListView) return _after;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_after);
}


/// Create a copy of ReportPhotos
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportPhotosCopyWith<_ReportPhotos> get copyWith => __$ReportPhotosCopyWithImpl<_ReportPhotos>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportPhotosToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportPhotos&&const DeepCollectionEquality().equals(other.before, _before)&&const DeepCollectionEquality().equals(other.after, _after));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_before),const DeepCollectionEquality().hash(_after));
}

@override
String toString() {
    return 'ReportPhotos(before: $before, after: $after)';
}


}

/// @nodoc
abstract mixin class _$ReportPhotosCopyWith<$Res> implements $ReportPhotosCopyWith<$Res> {
  factory _$ReportPhotosCopyWith(_ReportPhotos value, $Res Function(_ReportPhotos) _then) = __$ReportPhotosCopyWithImpl;
@override @useResult
$Res call({
 List<ReportPhoto> before, List<ReportPhoto> after
});




}
/// @nodoc
class __$ReportPhotosCopyWithImpl<$Res>
    implements _$ReportPhotosCopyWith<$Res> {
  __$ReportPhotosCopyWithImpl(this._self, this._then);

  final _ReportPhotos _self;
  final $Res Function(_ReportPhotos) _then;

/// Create a copy of ReportPhotos
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? before = null,Object? after = null,}) {
  return _then(_ReportPhotos(
before: null == before ? _self._before : before // ignore: cast_nullable_to_non_nullable
as List<ReportPhoto>,after: null == after ? _self._after : after // ignore: cast_nullable_to_non_nullable
as List<ReportPhoto>,
  ));
}


}


/// @nodoc
mixin _$ReportPhoto {

 String get id; String get url;
/// Create a copy of ReportPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportPhotoCopyWith<ReportPhoto> get copyWith => _$ReportPhotoCopyWithImpl<ReportPhoto>(this as ReportPhoto, _$identity);

  /// Serializes this ReportPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportPhoto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportPhoto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportPhoto;
  return Object.hash(runtimeType,_this.id,_this.url);
}

@override
String toString() {
  final _this = this as ReportPhoto;
  return 'ReportPhoto(id: ${_this.id}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $ReportPhotoCopyWith<$Res>  {
  factory $ReportPhotoCopyWith(ReportPhoto value, $Res Function(ReportPhoto) _then) = _$ReportPhotoCopyWithImpl;
@useResult
$Res call({
 String id, String url
});




}
/// @nodoc
class _$ReportPhotoCopyWithImpl<$Res>
    implements $ReportPhotoCopyWith<$Res> {
  _$ReportPhotoCopyWithImpl(this._self, this._then);

  final ReportPhoto _self;
  final $Res Function(ReportPhoto) _then;

/// Create a copy of ReportPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,}) {
  return _then(ReportPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportPhoto].
extension ReportPhotoPatterns on ReportPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportPhoto value)  $default,){
final _that = this;
switch (_that) {
case _ReportPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _ReportPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportPhoto() when $default != null:
return $default(_that.id,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url)  $default,) {final _that = this;
switch (_that) {
case _ReportPhoto():
return $default(_that.id,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url)?  $default,) {final _that = this;
switch (_that) {
case _ReportPhoto() when $default != null:
return $default(_that.id,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportPhoto implements ReportPhoto {
  const _ReportPhoto({required this.id, required this.url});
  factory _ReportPhoto.fromJson(Map<String, dynamic> json) => _$ReportPhotoFromJson(json);

@override final  String id;
@override final  String url;

/// Create a copy of ReportPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportPhotoCopyWith<_ReportPhoto> get copyWith => __$ReportPhotoCopyWithImpl<_ReportPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,url);
}

@override
String toString() {
    return 'ReportPhoto(id: $id, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ReportPhotoCopyWith<$Res> implements $ReportPhotoCopyWith<$Res> {
  factory _$ReportPhotoCopyWith(_ReportPhoto value, $Res Function(_ReportPhoto) _then) = __$ReportPhotoCopyWithImpl;
@override @useResult
$Res call({
 String id, String url
});




}
/// @nodoc
class __$ReportPhotoCopyWithImpl<$Res>
    implements _$ReportPhotoCopyWith<$Res> {
  __$ReportPhotoCopyWithImpl(this._self, this._then);

  final _ReportPhoto _self;
  final $Res Function(_ReportPhoto) _then;

/// Create a copy of ReportPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,}) {
  return _then(_ReportPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
