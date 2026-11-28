// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'property_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PropertyDetail {

 String get id; String? get code; String get name;/// Tipo de inmueble: Casa, Departamento, Terreno, Local comercial…
 String? get type; String? get description; String? get operation; double get price; int? get rec; double? get banos; double? get m2; int? get est; bool get petsAllowed; String? get furnished; String? get address; String? get city; String? get zone; String? get status; String? get visibility; List<String> get amenities; List<PropertyPhoto> get photos; PersonRef? get broker;
/// Create a copy of PropertyDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropertyDetailCopyWith<PropertyDetail> get copyWith => _$PropertyDetailCopyWithImpl<PropertyDetail>(this as PropertyDetail, _$identity);

  /// Serializes this PropertyDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PropertyDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PropertyDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.operation, _this.operation) || other.operation == _this.operation)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.rec, _this.rec) || other.rec == _this.rec)&&(identical(other.banos, _this.banos) || other.banos == _this.banos)&&(identical(other.m2, _this.m2) || other.m2 == _this.m2)&&(identical(other.est, _this.est) || other.est == _this.est)&&(identical(other.petsAllowed, _this.petsAllowed) || other.petsAllowed == _this.petsAllowed)&&(identical(other.furnished, _this.furnished) || other.furnished == _this.furnished)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.zone, _this.zone) || other.zone == _this.zone)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility)&&const DeepCollectionEquality().equals(other.amenities, _this.amenities)&&const DeepCollectionEquality().equals(other.photos, _this.photos)&&(identical(other.broker, _this.broker) || other.broker == _this.broker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PropertyDetail;
  return Object.hashAll([runtimeType,_this.id,_this.code,_this.name,_this.type,_this.description,_this.operation,_this.price,_this.rec,_this.banos,_this.m2,_this.est,_this.petsAllowed,_this.furnished,_this.address,_this.city,_this.zone,_this.status,_this.visibility,const DeepCollectionEquality().hash(_this.amenities),const DeepCollectionEquality().hash(_this.photos),_this.broker]);
}

@override
String toString() {
  final _this = this as PropertyDetail;
  return 'PropertyDetail(id: ${_this.id}, code: ${_this.code}, name: ${_this.name}, type: ${_this.type}, description: ${_this.description}, operation: ${_this.operation}, price: ${_this.price}, rec: ${_this.rec}, banos: ${_this.banos}, m2: ${_this.m2}, est: ${_this.est}, petsAllowed: ${_this.petsAllowed}, furnished: ${_this.furnished}, address: ${_this.address}, city: ${_this.city}, zone: ${_this.zone}, status: ${_this.status}, visibility: ${_this.visibility}, amenities: ${_this.amenities}, photos: ${_this.photos}, broker: ${_this.broker})';
}


}

/// @nodoc
abstract mixin class $PropertyDetailCopyWith<$Res>  {
  factory $PropertyDetailCopyWith(PropertyDetail value, $Res Function(PropertyDetail) _then) = _$PropertyDetailCopyWithImpl;
@useResult
$Res call({
 String id, String? code, String name, String? type, String? description, String? operation, double price, int? rec, double? banos, double? m2, int? est, bool petsAllowed, String? furnished, String? address, String? city, String? zone, String? status, String? visibility, List<String> amenities, List<PropertyPhoto> photos, PersonRef? broker
});


$PersonRefCopyWith<$Res>? get broker;

}
/// @nodoc
class _$PropertyDetailCopyWithImpl<$Res>
    implements $PropertyDetailCopyWith<$Res> {
  _$PropertyDetailCopyWithImpl(this._self, this._then);

  final PropertyDetail _self;
  final $Res Function(PropertyDetail) _then;

/// Create a copy of PropertyDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = freezed,Object? name = null,Object? type = freezed,Object? description = freezed,Object? operation = freezed,Object? price = null,Object? rec = freezed,Object? banos = freezed,Object? m2 = freezed,Object? est = freezed,Object? petsAllowed = null,Object? furnished = freezed,Object? address = freezed,Object? city = freezed,Object? zone = freezed,Object? status = freezed,Object? visibility = freezed,Object? amenities = null,Object? photos = null,Object? broker = freezed,}) {
  return _then(PropertyDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,operation: freezed == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,rec: freezed == rec ? _self.rec : rec // ignore: cast_nullable_to_non_nullable
as int?,banos: freezed == banos ? _self.banos : banos // ignore: cast_nullable_to_non_nullable
as double?,m2: freezed == m2 ? _self.m2 : m2 // ignore: cast_nullable_to_non_nullable
as double?,est: freezed == est ? _self.est : est // ignore: cast_nullable_to_non_nullable
as int?,petsAllowed: null == petsAllowed ? _self.petsAllowed : petsAllowed // ignore: cast_nullable_to_non_nullable
as bool,furnished: freezed == furnished ? _self.furnished : furnished // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String?,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<PropertyPhoto>,broker: freezed == broker ? _self.broker : broker // ignore: cast_nullable_to_non_nullable
as PersonRef?,
  ));
}
/// Create a copy of PropertyDetail
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
}
}


/// Adds pattern-matching-related methods to [PropertyDetail].
extension PropertyDetailPatterns on PropertyDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PropertyDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PropertyDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PropertyDetail value)  $default,){
final _that = this;
switch (_that) {
case _PropertyDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PropertyDetail value)?  $default,){
final _that = this;
switch (_that) {
case _PropertyDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? code,  String name,  String? type,  String? description,  String? operation,  double price,  int? rec,  double? banos,  double? m2,  int? est,  bool petsAllowed,  String? furnished,  String? address,  String? city,  String? zone,  String? status,  String? visibility,  List<String> amenities,  List<PropertyPhoto> photos,  PersonRef? broker)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PropertyDetail() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.type,_that.description,_that.operation,_that.price,_that.rec,_that.banos,_that.m2,_that.est,_that.petsAllowed,_that.furnished,_that.address,_that.city,_that.zone,_that.status,_that.visibility,_that.amenities,_that.photos,_that.broker);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? code,  String name,  String? type,  String? description,  String? operation,  double price,  int? rec,  double? banos,  double? m2,  int? est,  bool petsAllowed,  String? furnished,  String? address,  String? city,  String? zone,  String? status,  String? visibility,  List<String> amenities,  List<PropertyPhoto> photos,  PersonRef? broker)  $default,) {final _that = this;
switch (_that) {
case _PropertyDetail():
return $default(_that.id,_that.code,_that.name,_that.type,_that.description,_that.operation,_that.price,_that.rec,_that.banos,_that.m2,_that.est,_that.petsAllowed,_that.furnished,_that.address,_that.city,_that.zone,_that.status,_that.visibility,_that.amenities,_that.photos,_that.broker);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? code,  String name,  String? type,  String? description,  String? operation,  double price,  int? rec,  double? banos,  double? m2,  int? est,  bool petsAllowed,  String? furnished,  String? address,  String? city,  String? zone,  String? status,  String? visibility,  List<String> amenities,  List<PropertyPhoto> photos,  PersonRef? broker)?  $default,) {final _that = this;
switch (_that) {
case _PropertyDetail() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.type,_that.description,_that.operation,_that.price,_that.rec,_that.banos,_that.m2,_that.est,_that.petsAllowed,_that.furnished,_that.address,_that.city,_that.zone,_that.status,_that.visibility,_that.amenities,_that.photos,_that.broker);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PropertyDetail extends PropertyDetail {
  const _PropertyDetail({required this.id, this.code, required this.name, this.type, this.description, this.operation, this.price = 0, this.rec, this.banos, this.m2, this.est, this.petsAllowed = false, this.furnished, this.address, this.city, this.zone, this.status, this.visibility,  List<String> amenities = const <String>[],  List<PropertyPhoto> photos = const <PropertyPhoto>[], this.broker}): _amenities = amenities,_photos = photos,super._();
  factory _PropertyDetail.fromJson(Map<String, dynamic> json) => _$PropertyDetailFromJson(json);

@override final  String id;
@override final  String? code;
@override final  String name;
/// Tipo de inmueble: Casa, Departamento, Terreno, Local comercial…
@override final  String? type;
@override final  String? description;
@override final  String? operation;
@override@JsonKey() final  double price;
@override final  int? rec;
@override final  double? banos;
@override final  double? m2;
@override final  int? est;
@override@JsonKey() final  bool petsAllowed;
@override final  String? furnished;
@override final  String? address;
@override final  String? city;
@override final  String? zone;
@override final  String? status;
@override final  String? visibility;
 final  List<String> _amenities;
@override@JsonKey() List<String> get amenities {
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_amenities);
}

 final  List<PropertyPhoto> _photos;
@override@JsonKey() List<PropertyPhoto> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override final  PersonRef? broker;

/// Create a copy of PropertyDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropertyDetailCopyWith<_PropertyDetail> get copyWith => __$PropertyDetailCopyWithImpl<_PropertyDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PropertyDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PropertyDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.price, price) || other.price == price)&&(identical(other.rec, rec) || other.rec == rec)&&(identical(other.banos, banos) || other.banos == banos)&&(identical(other.m2, m2) || other.m2 == m2)&&(identical(other.est, est) || other.est == est)&&(identical(other.petsAllowed, petsAllowed) || other.petsAllowed == petsAllowed)&&(identical(other.furnished, furnished) || other.furnished == furnished)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.status, status) || other.status == status)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&const DeepCollectionEquality().equals(other.amenities, _amenities)&&const DeepCollectionEquality().equals(other.photos, _photos)&&(identical(other.broker, broker) || other.broker == broker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,code,name,type,description,operation,price,rec,banos,m2,est,petsAllowed,furnished,address,city,zone,status,visibility,const DeepCollectionEquality().hash(_amenities),const DeepCollectionEquality().hash(_photos),broker]);
}

@override
String toString() {
    return 'PropertyDetail(id: $id, code: $code, name: $name, type: $type, description: $description, operation: $operation, price: $price, rec: $rec, banos: $banos, m2: $m2, est: $est, petsAllowed: $petsAllowed, furnished: $furnished, address: $address, city: $city, zone: $zone, status: $status, visibility: $visibility, amenities: $amenities, photos: $photos, broker: $broker)';
}


}

/// @nodoc
abstract mixin class _$PropertyDetailCopyWith<$Res> implements $PropertyDetailCopyWith<$Res> {
  factory _$PropertyDetailCopyWith(_PropertyDetail value, $Res Function(_PropertyDetail) _then) = __$PropertyDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String? code, String name, String? type, String? description, String? operation, double price, int? rec, double? banos, double? m2, int? est, bool petsAllowed, String? furnished, String? address, String? city, String? zone, String? status, String? visibility, List<String> amenities, List<PropertyPhoto> photos, PersonRef? broker
});


@override $PersonRefCopyWith<$Res>? get broker;

}
/// @nodoc
class __$PropertyDetailCopyWithImpl<$Res>
    implements _$PropertyDetailCopyWith<$Res> {
  __$PropertyDetailCopyWithImpl(this._self, this._then);

  final _PropertyDetail _self;
  final $Res Function(_PropertyDetail) _then;

/// Create a copy of PropertyDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = freezed,Object? name = null,Object? type = freezed,Object? description = freezed,Object? operation = freezed,Object? price = null,Object? rec = freezed,Object? banos = freezed,Object? m2 = freezed,Object? est = freezed,Object? petsAllowed = null,Object? furnished = freezed,Object? address = freezed,Object? city = freezed,Object? zone = freezed,Object? status = freezed,Object? visibility = freezed,Object? amenities = null,Object? photos = null,Object? broker = freezed,}) {
  return _then(_PropertyDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,operation: freezed == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,rec: freezed == rec ? _self.rec : rec // ignore: cast_nullable_to_non_nullable
as int?,banos: freezed == banos ? _self.banos : banos // ignore: cast_nullable_to_non_nullable
as double?,m2: freezed == m2 ? _self.m2 : m2 // ignore: cast_nullable_to_non_nullable
as double?,est: freezed == est ? _self.est : est // ignore: cast_nullable_to_non_nullable
as int?,petsAllowed: null == petsAllowed ? _self.petsAllowed : petsAllowed // ignore: cast_nullable_to_non_nullable
as bool,furnished: freezed == furnished ? _self.furnished : furnished // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String?,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<PropertyPhoto>,broker: freezed == broker ? _self.broker : broker // ignore: cast_nullable_to_non_nullable
as PersonRef?,
  ));
}

/// Create a copy of PropertyDetail
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
}
}


/// @nodoc
mixin _$PropertyPhoto {

 String? get id; String? get label; String? get url;
/// Create a copy of PropertyPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropertyPhotoCopyWith<PropertyPhoto> get copyWith => _$PropertyPhotoCopyWithImpl<PropertyPhoto>(this as PropertyPhoto, _$identity);

  /// Serializes this PropertyPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PropertyPhoto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PropertyPhoto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PropertyPhoto;
  return Object.hash(runtimeType,_this.id,_this.label,_this.url);
}

@override
String toString() {
  final _this = this as PropertyPhoto;
  return 'PropertyPhoto(id: ${_this.id}, label: ${_this.label}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $PropertyPhotoCopyWith<$Res>  {
  factory $PropertyPhotoCopyWith(PropertyPhoto value, $Res Function(PropertyPhoto) _then) = _$PropertyPhotoCopyWithImpl;
@useResult
$Res call({
 String? id, String? label, String? url
});




}
/// @nodoc
class _$PropertyPhotoCopyWithImpl<$Res>
    implements $PropertyPhotoCopyWith<$Res> {
  _$PropertyPhotoCopyWithImpl(this._self, this._then);

  final PropertyPhoto _self;
  final $Res Function(PropertyPhoto) _then;

/// Create a copy of PropertyPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? label = freezed,Object? url = freezed,}) {
  return _then(PropertyPhoto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PropertyPhoto].
extension PropertyPhotoPatterns on PropertyPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PropertyPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PropertyPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PropertyPhoto value)  $default,){
final _that = this;
switch (_that) {
case _PropertyPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PropertyPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _PropertyPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? label,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PropertyPhoto() when $default != null:
return $default(_that.id,_that.label,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? label,  String? url)  $default,) {final _that = this;
switch (_that) {
case _PropertyPhoto():
return $default(_that.id,_that.label,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? label,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _PropertyPhoto() when $default != null:
return $default(_that.id,_that.label,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PropertyPhoto implements PropertyPhoto {
  const _PropertyPhoto({this.id, this.label, this.url});
  factory _PropertyPhoto.fromJson(Map<String, dynamic> json) => _$PropertyPhotoFromJson(json);

@override final  String? id;
@override final  String? label;
@override final  String? url;

/// Create a copy of PropertyPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropertyPhotoCopyWith<_PropertyPhoto> get copyWith => __$PropertyPhotoCopyWithImpl<_PropertyPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PropertyPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PropertyPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,url);
}

@override
String toString() {
    return 'PropertyPhoto(id: $id, label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class _$PropertyPhotoCopyWith<$Res> implements $PropertyPhotoCopyWith<$Res> {
  factory _$PropertyPhotoCopyWith(_PropertyPhoto value, $Res Function(_PropertyPhoto) _then) = __$PropertyPhotoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? label, String? url
});




}
/// @nodoc
class __$PropertyPhotoCopyWithImpl<$Res>
    implements _$PropertyPhotoCopyWith<$Res> {
  __$PropertyPhotoCopyWithImpl(this._self, this._then);

  final _PropertyPhoto _self;
  final $Res Function(_PropertyPhoto) _then;

/// Create a copy of PropertyPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? label = freezed,Object? url = freezed,}) {
  return _then(_PropertyPhoto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Dossier {

 DossierProperty get property; DossierContract? get contract; List<DossierSection> get sections; List<DossierDocument> get documents;/// Servicios de agua y luz (números que captura administración)
 DossierUtilities? get utilities;/// Asesor de la casa (contacto mutuo: también lo ve el inquilino)
 DossierContact? get broker; PersonRef? get tenant;
/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DossierCopyWith<Dossier> get copyWith => _$DossierCopyWithImpl<Dossier>(this as Dossier, _$identity);

  /// Serializes this Dossier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Dossier;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dossier&&(identical(other.property, _this.property) || other.property == _this.property)&&(identical(other.contract, _this.contract) || other.contract == _this.contract)&&const DeepCollectionEquality().equals(other.sections, _this.sections)&&const DeepCollectionEquality().equals(other.documents, _this.documents)&&(identical(other.utilities, _this.utilities) || other.utilities == _this.utilities)&&(identical(other.broker, _this.broker) || other.broker == _this.broker)&&(identical(other.tenant, _this.tenant) || other.tenant == _this.tenant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Dossier;
  return Object.hash(runtimeType,_this.property,_this.contract,const DeepCollectionEquality().hash(_this.sections),const DeepCollectionEquality().hash(_this.documents),_this.utilities,_this.broker,_this.tenant);
}

@override
String toString() {
  final _this = this as Dossier;
  return 'Dossier(property: ${_this.property}, contract: ${_this.contract}, sections: ${_this.sections}, documents: ${_this.documents}, utilities: ${_this.utilities}, broker: ${_this.broker}, tenant: ${_this.tenant})';
}


}

/// @nodoc
abstract mixin class $DossierCopyWith<$Res>  {
  factory $DossierCopyWith(Dossier value, $Res Function(Dossier) _then) = _$DossierCopyWithImpl;
@useResult
$Res call({
 DossierProperty property, DossierContract? contract, List<DossierSection> sections, List<DossierDocument> documents, DossierUtilities? utilities, DossierContact? broker, PersonRef? tenant
});


$DossierPropertyCopyWith<$Res> get property;$DossierContractCopyWith<$Res>? get contract;$DossierUtilitiesCopyWith<$Res>? get utilities;$DossierContactCopyWith<$Res>? get broker;$PersonRefCopyWith<$Res>? get tenant;

}
/// @nodoc
class _$DossierCopyWithImpl<$Res>
    implements $DossierCopyWith<$Res> {
  _$DossierCopyWithImpl(this._self, this._then);

  final Dossier _self;
  final $Res Function(Dossier) _then;

/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? property = null,Object? contract = freezed,Object? sections = null,Object? documents = null,Object? utilities = freezed,Object? broker = freezed,Object? tenant = freezed,}) {
  return _then(Dossier(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as DossierProperty,contract: freezed == contract ? _self.contract : contract // ignore: cast_nullable_to_non_nullable
as DossierContract?,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<DossierSection>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<DossierDocument>,utilities: freezed == utilities ? _self.utilities : utilities // ignore: cast_nullable_to_non_nullable
as DossierUtilities?,broker: freezed == broker ? _self.broker : broker // ignore: cast_nullable_to_non_nullable
as DossierContact?,tenant: freezed == tenant ? _self.tenant : tenant // ignore: cast_nullable_to_non_nullable
as PersonRef?,
  ));
}
/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DossierPropertyCopyWith<$Res> get property {
  
  return $DossierPropertyCopyWith<$Res>(_self.property, (value) {
    return _then(_self.copyWith(property: value));
  });
}/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DossierContractCopyWith<$Res>? get contract {
    if (_self.contract == null) {
    return null;
  }

  return $DossierContractCopyWith<$Res>(_self.contract!, (value) {
    return _then(_self.copyWith(contract: value));
  });
}/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DossierUtilitiesCopyWith<$Res>? get utilities {
    if (_self.utilities == null) {
    return null;
  }

  return $DossierUtilitiesCopyWith<$Res>(_self.utilities!, (value) {
    return _then(_self.copyWith(utilities: value));
  });
}/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DossierContactCopyWith<$Res>? get broker {
    if (_self.broker == null) {
    return null;
  }

  return $DossierContactCopyWith<$Res>(_self.broker!, (value) {
    return _then(_self.copyWith(broker: value));
  });
}/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res>? get tenant {
    if (_self.tenant == null) {
    return null;
  }

  return $PersonRefCopyWith<$Res>(_self.tenant!, (value) {
    return _then(_self.copyWith(tenant: value));
  });
}
}


/// Adds pattern-matching-related methods to [Dossier].
extension DossierPatterns on Dossier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dossier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dossier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dossier value)  $default,){
final _that = this;
switch (_that) {
case _Dossier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dossier value)?  $default,){
final _that = this;
switch (_that) {
case _Dossier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DossierProperty property,  DossierContract? contract,  List<DossierSection> sections,  List<DossierDocument> documents,  DossierUtilities? utilities,  DossierContact? broker,  PersonRef? tenant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dossier() when $default != null:
return $default(_that.property,_that.contract,_that.sections,_that.documents,_that.utilities,_that.broker,_that.tenant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DossierProperty property,  DossierContract? contract,  List<DossierSection> sections,  List<DossierDocument> documents,  DossierUtilities? utilities,  DossierContact? broker,  PersonRef? tenant)  $default,) {final _that = this;
switch (_that) {
case _Dossier():
return $default(_that.property,_that.contract,_that.sections,_that.documents,_that.utilities,_that.broker,_that.tenant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DossierProperty property,  DossierContract? contract,  List<DossierSection> sections,  List<DossierDocument> documents,  DossierUtilities? utilities,  DossierContact? broker,  PersonRef? tenant)?  $default,) {final _that = this;
switch (_that) {
case _Dossier() when $default != null:
return $default(_that.property,_that.contract,_that.sections,_that.documents,_that.utilities,_that.broker,_that.tenant);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dossier implements Dossier {
  const _Dossier({required this.property, this.contract,  List<DossierSection> sections = const <DossierSection>[],  List<DossierDocument> documents = const <DossierDocument>[], this.utilities, this.broker, this.tenant}): _sections = sections,_documents = documents;
  factory _Dossier.fromJson(Map<String, dynamic> json) => _$DossierFromJson(json);

@override final  DossierProperty property;
@override final  DossierContract? contract;
 final  List<DossierSection> _sections;
@override@JsonKey() List<DossierSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}

 final  List<DossierDocument> _documents;
@override@JsonKey() List<DossierDocument> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

/// Servicios de agua y luz (números que captura administración)
@override final  DossierUtilities? utilities;
/// Asesor de la casa (contacto mutuo: también lo ve el inquilino)
@override final  DossierContact? broker;
@override final  PersonRef? tenant;

/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DossierCopyWith<_Dossier> get copyWith => __$DossierCopyWithImpl<_Dossier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DossierToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dossier&&(identical(other.property, property) || other.property == property)&&(identical(other.contract, contract) || other.contract == contract)&&const DeepCollectionEquality().equals(other.sections, _sections)&&const DeepCollectionEquality().equals(other.documents, _documents)&&(identical(other.utilities, utilities) || other.utilities == utilities)&&(identical(other.broker, broker) || other.broker == broker)&&(identical(other.tenant, tenant) || other.tenant == tenant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,property,contract,const DeepCollectionEquality().hash(_sections),const DeepCollectionEquality().hash(_documents),utilities,broker,tenant);
}

@override
String toString() {
    return 'Dossier(property: $property, contract: $contract, sections: $sections, documents: $documents, utilities: $utilities, broker: $broker, tenant: $tenant)';
}


}

/// @nodoc
abstract mixin class _$DossierCopyWith<$Res> implements $DossierCopyWith<$Res> {
  factory _$DossierCopyWith(_Dossier value, $Res Function(_Dossier) _then) = __$DossierCopyWithImpl;
@override @useResult
$Res call({
 DossierProperty property, DossierContract? contract, List<DossierSection> sections, List<DossierDocument> documents, DossierUtilities? utilities, DossierContact? broker, PersonRef? tenant
});


@override $DossierPropertyCopyWith<$Res> get property;@override $DossierContractCopyWith<$Res>? get contract;@override $DossierUtilitiesCopyWith<$Res>? get utilities;@override $DossierContactCopyWith<$Res>? get broker;@override $PersonRefCopyWith<$Res>? get tenant;

}
/// @nodoc
class __$DossierCopyWithImpl<$Res>
    implements _$DossierCopyWith<$Res> {
  __$DossierCopyWithImpl(this._self, this._then);

  final _Dossier _self;
  final $Res Function(_Dossier) _then;

/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? property = null,Object? contract = freezed,Object? sections = null,Object? documents = null,Object? utilities = freezed,Object? broker = freezed,Object? tenant = freezed,}) {
  return _then(_Dossier(
property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as DossierProperty,contract: freezed == contract ? _self.contract : contract // ignore: cast_nullable_to_non_nullable
as DossierContract?,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<DossierSection>,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<DossierDocument>,utilities: freezed == utilities ? _self.utilities : utilities // ignore: cast_nullable_to_non_nullable
as DossierUtilities?,broker: freezed == broker ? _self.broker : broker // ignore: cast_nullable_to_non_nullable
as DossierContact?,tenant: freezed == tenant ? _self.tenant : tenant // ignore: cast_nullable_to_non_nullable
as PersonRef?,
  ));
}

/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DossierPropertyCopyWith<$Res> get property {
  
  return $DossierPropertyCopyWith<$Res>(_self.property, (value) {
    return _then(_self.copyWith(property: value));
  });
}/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DossierContractCopyWith<$Res>? get contract {
    if (_self.contract == null) {
    return null;
  }

  return $DossierContractCopyWith<$Res>(_self.contract!, (value) {
    return _then(_self.copyWith(contract: value));
  });
}/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DossierUtilitiesCopyWith<$Res>? get utilities {
    if (_self.utilities == null) {
    return null;
  }

  return $DossierUtilitiesCopyWith<$Res>(_self.utilities!, (value) {
    return _then(_self.copyWith(utilities: value));
  });
}/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DossierContactCopyWith<$Res>? get broker {
    if (_self.broker == null) {
    return null;
  }

  return $DossierContactCopyWith<$Res>(_self.broker!, (value) {
    return _then(_self.copyWith(broker: value));
  });
}/// Create a copy of Dossier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res>? get tenant {
    if (_self.tenant == null) {
    return null;
  }

  return $PersonRefCopyWith<$Res>(_self.tenant!, (value) {
    return _then(_self.copyWith(tenant: value));
  });
}
}


/// @nodoc
mixin _$DossierContact {

 String get name; String? get phone; String? get email;
/// Create a copy of DossierContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DossierContactCopyWith<DossierContact> get copyWith => _$DossierContactCopyWithImpl<DossierContact>(this as DossierContact, _$identity);

  /// Serializes this DossierContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DossierContact;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DossierContact&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DossierContact;
  return Object.hash(runtimeType,_this.name,_this.phone,_this.email);
}

@override
String toString() {
  final _this = this as DossierContact;
  return 'DossierContact(name: ${_this.name}, phone: ${_this.phone}, email: ${_this.email})';
}


}

/// @nodoc
abstract mixin class $DossierContactCopyWith<$Res>  {
  factory $DossierContactCopyWith(DossierContact value, $Res Function(DossierContact) _then) = _$DossierContactCopyWithImpl;
@useResult
$Res call({
 String name, String? phone, String? email
});




}
/// @nodoc
class _$DossierContactCopyWithImpl<$Res>
    implements $DossierContactCopyWith<$Res> {
  _$DossierContactCopyWithImpl(this._self, this._then);

  final DossierContact _self;
  final $Res Function(DossierContact) _then;

/// Create a copy of DossierContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? phone = freezed,Object? email = freezed,}) {
  return _then(DossierContact(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DossierContact].
extension DossierContactPatterns on DossierContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DossierContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DossierContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DossierContact value)  $default,){
final _that = this;
switch (_that) {
case _DossierContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DossierContact value)?  $default,){
final _that = this;
switch (_that) {
case _DossierContact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? phone,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DossierContact() when $default != null:
return $default(_that.name,_that.phone,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? phone,  String? email)  $default,) {final _that = this;
switch (_that) {
case _DossierContact():
return $default(_that.name,_that.phone,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? phone,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _DossierContact() when $default != null:
return $default(_that.name,_that.phone,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DossierContact implements DossierContact {
  const _DossierContact({required this.name, this.phone, this.email});
  factory _DossierContact.fromJson(Map<String, dynamic> json) => _$DossierContactFromJson(json);

@override final  String name;
@override final  String? phone;
@override final  String? email;

/// Create a copy of DossierContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DossierContactCopyWith<_DossierContact> get copyWith => __$DossierContactCopyWithImpl<_DossierContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DossierContactToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DossierContact&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,phone,email);
}

@override
String toString() {
    return 'DossierContact(name: $name, phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class _$DossierContactCopyWith<$Res> implements $DossierContactCopyWith<$Res> {
  factory _$DossierContactCopyWith(_DossierContact value, $Res Function(_DossierContact) _then) = __$DossierContactCopyWithImpl;
@override @useResult
$Res call({
 String name, String? phone, String? email
});




}
/// @nodoc
class __$DossierContactCopyWithImpl<$Res>
    implements _$DossierContactCopyWith<$Res> {
  __$DossierContactCopyWithImpl(this._self, this._then);

  final _DossierContact _self;
  final $Res Function(_DossierContact) _then;

/// Create a copy of DossierContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? phone = freezed,Object? email = freezed,}) {
  return _then(_DossierContact(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DossierUtilities {

 int get reminderDay; UtilityService? get electricity; UtilityService? get water;
/// Create a copy of DossierUtilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DossierUtilitiesCopyWith<DossierUtilities> get copyWith => _$DossierUtilitiesCopyWithImpl<DossierUtilities>(this as DossierUtilities, _$identity);

  /// Serializes this DossierUtilities to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DossierUtilities;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DossierUtilities&&(identical(other.reminderDay, _this.reminderDay) || other.reminderDay == _this.reminderDay)&&(identical(other.electricity, _this.electricity) || other.electricity == _this.electricity)&&(identical(other.water, _this.water) || other.water == _this.water));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DossierUtilities;
  return Object.hash(runtimeType,_this.reminderDay,_this.electricity,_this.water);
}

@override
String toString() {
  final _this = this as DossierUtilities;
  return 'DossierUtilities(reminderDay: ${_this.reminderDay}, electricity: ${_this.electricity}, water: ${_this.water})';
}


}

/// @nodoc
abstract mixin class $DossierUtilitiesCopyWith<$Res>  {
  factory $DossierUtilitiesCopyWith(DossierUtilities value, $Res Function(DossierUtilities) _then) = _$DossierUtilitiesCopyWithImpl;
@useResult
$Res call({
 int reminderDay, UtilityService? electricity, UtilityService? water
});


$UtilityServiceCopyWith<$Res>? get electricity;$UtilityServiceCopyWith<$Res>? get water;

}
/// @nodoc
class _$DossierUtilitiesCopyWithImpl<$Res>
    implements $DossierUtilitiesCopyWith<$Res> {
  _$DossierUtilitiesCopyWithImpl(this._self, this._then);

  final DossierUtilities _self;
  final $Res Function(DossierUtilities) _then;

/// Create a copy of DossierUtilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reminderDay = null,Object? electricity = freezed,Object? water = freezed,}) {
  return _then(DossierUtilities(
reminderDay: null == reminderDay ? _self.reminderDay : reminderDay // ignore: cast_nullable_to_non_nullable
as int,electricity: freezed == electricity ? _self.electricity : electricity // ignore: cast_nullable_to_non_nullable
as UtilityService?,water: freezed == water ? _self.water : water // ignore: cast_nullable_to_non_nullable
as UtilityService?,
  ));
}
/// Create a copy of DossierUtilities
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UtilityServiceCopyWith<$Res>? get electricity {
    if (_self.electricity == null) {
    return null;
  }

  return $UtilityServiceCopyWith<$Res>(_self.electricity!, (value) {
    return _then(_self.copyWith(electricity: value));
  });
}/// Create a copy of DossierUtilities
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UtilityServiceCopyWith<$Res>? get water {
    if (_self.water == null) {
    return null;
  }

  return $UtilityServiceCopyWith<$Res>(_self.water!, (value) {
    return _then(_self.copyWith(water: value));
  });
}
}


/// Adds pattern-matching-related methods to [DossierUtilities].
extension DossierUtilitiesPatterns on DossierUtilities {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DossierUtilities value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DossierUtilities() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DossierUtilities value)  $default,){
final _that = this;
switch (_that) {
case _DossierUtilities():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DossierUtilities value)?  $default,){
final _that = this;
switch (_that) {
case _DossierUtilities() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int reminderDay,  UtilityService? electricity,  UtilityService? water)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DossierUtilities() when $default != null:
return $default(_that.reminderDay,_that.electricity,_that.water);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int reminderDay,  UtilityService? electricity,  UtilityService? water)  $default,) {final _that = this;
switch (_that) {
case _DossierUtilities():
return $default(_that.reminderDay,_that.electricity,_that.water);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int reminderDay,  UtilityService? electricity,  UtilityService? water)?  $default,) {final _that = this;
switch (_that) {
case _DossierUtilities() when $default != null:
return $default(_that.reminderDay,_that.electricity,_that.water);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DossierUtilities implements DossierUtilities {
  const _DossierUtilities({this.reminderDay = 1, this.electricity, this.water});
  factory _DossierUtilities.fromJson(Map<String, dynamic> json) => _$DossierUtilitiesFromJson(json);

@override@JsonKey() final  int reminderDay;
@override final  UtilityService? electricity;
@override final  UtilityService? water;

/// Create a copy of DossierUtilities
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DossierUtilitiesCopyWith<_DossierUtilities> get copyWith => __$DossierUtilitiesCopyWithImpl<_DossierUtilities>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DossierUtilitiesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DossierUtilities&&(identical(other.reminderDay, reminderDay) || other.reminderDay == reminderDay)&&(identical(other.electricity, electricity) || other.electricity == electricity)&&(identical(other.water, water) || other.water == water));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reminderDay,electricity,water);
}

@override
String toString() {
    return 'DossierUtilities(reminderDay: $reminderDay, electricity: $electricity, water: $water)';
}


}

/// @nodoc
abstract mixin class _$DossierUtilitiesCopyWith<$Res> implements $DossierUtilitiesCopyWith<$Res> {
  factory _$DossierUtilitiesCopyWith(_DossierUtilities value, $Res Function(_DossierUtilities) _then) = __$DossierUtilitiesCopyWithImpl;
@override @useResult
$Res call({
 int reminderDay, UtilityService? electricity, UtilityService? water
});


@override $UtilityServiceCopyWith<$Res>? get electricity;@override $UtilityServiceCopyWith<$Res>? get water;

}
/// @nodoc
class __$DossierUtilitiesCopyWithImpl<$Res>
    implements _$DossierUtilitiesCopyWith<$Res> {
  __$DossierUtilitiesCopyWithImpl(this._self, this._then);

  final _DossierUtilities _self;
  final $Res Function(_DossierUtilities) _then;

/// Create a copy of DossierUtilities
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reminderDay = null,Object? electricity = freezed,Object? water = freezed,}) {
  return _then(_DossierUtilities(
reminderDay: null == reminderDay ? _self.reminderDay : reminderDay // ignore: cast_nullable_to_non_nullable
as int,electricity: freezed == electricity ? _self.electricity : electricity // ignore: cast_nullable_to_non_nullable
as UtilityService?,water: freezed == water ? _self.water : water // ignore: cast_nullable_to_non_nullable
as UtilityService?,
  ));
}

/// Create a copy of DossierUtilities
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UtilityServiceCopyWith<$Res>? get electricity {
    if (_self.electricity == null) {
    return null;
  }

  return $UtilityServiceCopyWith<$Res>(_self.electricity!, (value) {
    return _then(_self.copyWith(electricity: value));
  });
}/// Create a copy of DossierUtilities
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UtilityServiceCopyWith<$Res>? get water {
    if (_self.water == null) {
    return null;
  }

  return $UtilityServiceCopyWith<$Res>(_self.water!, (value) {
    return _then(_self.copyWith(water: value));
  });
}
}


/// @nodoc
mixin _$UtilityService {

 String get company; String get serviceNumber; String? get app; String? get url;
/// Create a copy of UtilityService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UtilityServiceCopyWith<UtilityService> get copyWith => _$UtilityServiceCopyWithImpl<UtilityService>(this as UtilityService, _$identity);

  /// Serializes this UtilityService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UtilityService;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UtilityService&&(identical(other.company, _this.company) || other.company == _this.company)&&(identical(other.serviceNumber, _this.serviceNumber) || other.serviceNumber == _this.serviceNumber)&&(identical(other.app, _this.app) || other.app == _this.app)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UtilityService;
  return Object.hash(runtimeType,_this.company,_this.serviceNumber,_this.app,_this.url);
}

@override
String toString() {
  final _this = this as UtilityService;
  return 'UtilityService(company: ${_this.company}, serviceNumber: ${_this.serviceNumber}, app: ${_this.app}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $UtilityServiceCopyWith<$Res>  {
  factory $UtilityServiceCopyWith(UtilityService value, $Res Function(UtilityService) _then) = _$UtilityServiceCopyWithImpl;
@useResult
$Res call({
 String company, String serviceNumber, String? app, String? url
});




}
/// @nodoc
class _$UtilityServiceCopyWithImpl<$Res>
    implements $UtilityServiceCopyWith<$Res> {
  _$UtilityServiceCopyWithImpl(this._self, this._then);

  final UtilityService _self;
  final $Res Function(UtilityService) _then;

/// Create a copy of UtilityService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? company = null,Object? serviceNumber = null,Object? app = freezed,Object? url = freezed,}) {
  return _then(UtilityService(
company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,serviceNumber: null == serviceNumber ? _self.serviceNumber : serviceNumber // ignore: cast_nullable_to_non_nullable
as String,app: freezed == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UtilityService].
extension UtilityServicePatterns on UtilityService {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UtilityService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UtilityService() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UtilityService value)  $default,){
final _that = this;
switch (_that) {
case _UtilityService():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UtilityService value)?  $default,){
final _that = this;
switch (_that) {
case _UtilityService() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String company,  String serviceNumber,  String? app,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UtilityService() when $default != null:
return $default(_that.company,_that.serviceNumber,_that.app,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String company,  String serviceNumber,  String? app,  String? url)  $default,) {final _that = this;
switch (_that) {
case _UtilityService():
return $default(_that.company,_that.serviceNumber,_that.app,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String company,  String serviceNumber,  String? app,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _UtilityService() when $default != null:
return $default(_that.company,_that.serviceNumber,_that.app,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UtilityService implements UtilityService {
  const _UtilityService({required this.company, required this.serviceNumber, this.app, this.url});
  factory _UtilityService.fromJson(Map<String, dynamic> json) => _$UtilityServiceFromJson(json);

@override final  String company;
@override final  String serviceNumber;
@override final  String? app;
@override final  String? url;

/// Create a copy of UtilityService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UtilityServiceCopyWith<_UtilityService> get copyWith => __$UtilityServiceCopyWithImpl<_UtilityService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UtilityServiceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UtilityService&&(identical(other.company, company) || other.company == company)&&(identical(other.serviceNumber, serviceNumber) || other.serviceNumber == serviceNumber)&&(identical(other.app, app) || other.app == app)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,company,serviceNumber,app,url);
}

@override
String toString() {
    return 'UtilityService(company: $company, serviceNumber: $serviceNumber, app: $app, url: $url)';
}


}

/// @nodoc
abstract mixin class _$UtilityServiceCopyWith<$Res> implements $UtilityServiceCopyWith<$Res> {
  factory _$UtilityServiceCopyWith(_UtilityService value, $Res Function(_UtilityService) _then) = __$UtilityServiceCopyWithImpl;
@override @useResult
$Res call({
 String company, String serviceNumber, String? app, String? url
});




}
/// @nodoc
class __$UtilityServiceCopyWithImpl<$Res>
    implements _$UtilityServiceCopyWith<$Res> {
  __$UtilityServiceCopyWithImpl(this._self, this._then);

  final _UtilityService _self;
  final $Res Function(_UtilityService) _then;

/// Create a copy of UtilityService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? company = null,Object? serviceNumber = null,Object? app = freezed,Object? url = freezed,}) {
  return _then(_UtilityService(
company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,serviceNumber: null == serviceNumber ? _self.serviceNumber : serviceNumber // ignore: cast_nullable_to_non_nullable
as String,app: freezed == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DossierProperty {

 String get id; String get name; String? get zone; String? get address; String? get city; int? get rec; double? get banos; double? get m2; List<String> get amenities; String? get status; DossierBroker? get broker;
/// Create a copy of DossierProperty
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DossierPropertyCopyWith<DossierProperty> get copyWith => _$DossierPropertyCopyWithImpl<DossierProperty>(this as DossierProperty, _$identity);

  /// Serializes this DossierProperty to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DossierProperty;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DossierProperty&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.zone, _this.zone) || other.zone == _this.zone)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.rec, _this.rec) || other.rec == _this.rec)&&(identical(other.banos, _this.banos) || other.banos == _this.banos)&&(identical(other.m2, _this.m2) || other.m2 == _this.m2)&&const DeepCollectionEquality().equals(other.amenities, _this.amenities)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.broker, _this.broker) || other.broker == _this.broker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DossierProperty;
  return Object.hash(runtimeType,_this.id,_this.name,_this.zone,_this.address,_this.city,_this.rec,_this.banos,_this.m2,const DeepCollectionEquality().hash(_this.amenities),_this.status,_this.broker);
}

@override
String toString() {
  final _this = this as DossierProperty;
  return 'DossierProperty(id: ${_this.id}, name: ${_this.name}, zone: ${_this.zone}, address: ${_this.address}, city: ${_this.city}, rec: ${_this.rec}, banos: ${_this.banos}, m2: ${_this.m2}, amenities: ${_this.amenities}, status: ${_this.status}, broker: ${_this.broker})';
}


}

/// @nodoc
abstract mixin class $DossierPropertyCopyWith<$Res>  {
  factory $DossierPropertyCopyWith(DossierProperty value, $Res Function(DossierProperty) _then) = _$DossierPropertyCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? zone, String? address, String? city, int? rec, double? banos, double? m2, List<String> amenities, String? status, DossierBroker? broker
});


$DossierBrokerCopyWith<$Res>? get broker;

}
/// @nodoc
class _$DossierPropertyCopyWithImpl<$Res>
    implements $DossierPropertyCopyWith<$Res> {
  _$DossierPropertyCopyWithImpl(this._self, this._then);

  final DossierProperty _self;
  final $Res Function(DossierProperty) _then;

/// Create a copy of DossierProperty
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? zone = freezed,Object? address = freezed,Object? city = freezed,Object? rec = freezed,Object? banos = freezed,Object? m2 = freezed,Object? amenities = null,Object? status = freezed,Object? broker = freezed,}) {
  return _then(DossierProperty(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,rec: freezed == rec ? _self.rec : rec // ignore: cast_nullable_to_non_nullable
as int?,banos: freezed == banos ? _self.banos : banos // ignore: cast_nullable_to_non_nullable
as double?,m2: freezed == m2 ? _self.m2 : m2 // ignore: cast_nullable_to_non_nullable
as double?,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,broker: freezed == broker ? _self.broker : broker // ignore: cast_nullable_to_non_nullable
as DossierBroker?,
  ));
}
/// Create a copy of DossierProperty
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DossierBrokerCopyWith<$Res>? get broker {
    if (_self.broker == null) {
    return null;
  }

  return $DossierBrokerCopyWith<$Res>(_self.broker!, (value) {
    return _then(_self.copyWith(broker: value));
  });
}
}


/// Adds pattern-matching-related methods to [DossierProperty].
extension DossierPropertyPatterns on DossierProperty {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DossierProperty value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DossierProperty() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DossierProperty value)  $default,){
final _that = this;
switch (_that) {
case _DossierProperty():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DossierProperty value)?  $default,){
final _that = this;
switch (_that) {
case _DossierProperty() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? zone,  String? address,  String? city,  int? rec,  double? banos,  double? m2,  List<String> amenities,  String? status,  DossierBroker? broker)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DossierProperty() when $default != null:
return $default(_that.id,_that.name,_that.zone,_that.address,_that.city,_that.rec,_that.banos,_that.m2,_that.amenities,_that.status,_that.broker);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? zone,  String? address,  String? city,  int? rec,  double? banos,  double? m2,  List<String> amenities,  String? status,  DossierBroker? broker)  $default,) {final _that = this;
switch (_that) {
case _DossierProperty():
return $default(_that.id,_that.name,_that.zone,_that.address,_that.city,_that.rec,_that.banos,_that.m2,_that.amenities,_that.status,_that.broker);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? zone,  String? address,  String? city,  int? rec,  double? banos,  double? m2,  List<String> amenities,  String? status,  DossierBroker? broker)?  $default,) {final _that = this;
switch (_that) {
case _DossierProperty() when $default != null:
return $default(_that.id,_that.name,_that.zone,_that.address,_that.city,_that.rec,_that.banos,_that.m2,_that.amenities,_that.status,_that.broker);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DossierProperty implements DossierProperty {
  const _DossierProperty({required this.id, required this.name, this.zone, this.address, this.city, this.rec, this.banos, this.m2,  List<String> amenities = const <String>[], this.status, this.broker}): _amenities = amenities;
  factory _DossierProperty.fromJson(Map<String, dynamic> json) => _$DossierPropertyFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? zone;
@override final  String? address;
@override final  String? city;
@override final  int? rec;
@override final  double? banos;
@override final  double? m2;
 final  List<String> _amenities;
@override@JsonKey() List<String> get amenities {
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_amenities);
}

@override final  String? status;
@override final  DossierBroker? broker;

/// Create a copy of DossierProperty
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DossierPropertyCopyWith<_DossierProperty> get copyWith => __$DossierPropertyCopyWithImpl<_DossierProperty>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DossierPropertyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DossierProperty&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.rec, rec) || other.rec == rec)&&(identical(other.banos, banos) || other.banos == banos)&&(identical(other.m2, m2) || other.m2 == m2)&&const DeepCollectionEquality().equals(other.amenities, _amenities)&&(identical(other.status, status) || other.status == status)&&(identical(other.broker, broker) || other.broker == broker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,zone,address,city,rec,banos,m2,const DeepCollectionEquality().hash(_amenities),status,broker);
}

@override
String toString() {
    return 'DossierProperty(id: $id, name: $name, zone: $zone, address: $address, city: $city, rec: $rec, banos: $banos, m2: $m2, amenities: $amenities, status: $status, broker: $broker)';
}


}

/// @nodoc
abstract mixin class _$DossierPropertyCopyWith<$Res> implements $DossierPropertyCopyWith<$Res> {
  factory _$DossierPropertyCopyWith(_DossierProperty value, $Res Function(_DossierProperty) _then) = __$DossierPropertyCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? zone, String? address, String? city, int? rec, double? banos, double? m2, List<String> amenities, String? status, DossierBroker? broker
});


@override $DossierBrokerCopyWith<$Res>? get broker;

}
/// @nodoc
class __$DossierPropertyCopyWithImpl<$Res>
    implements _$DossierPropertyCopyWith<$Res> {
  __$DossierPropertyCopyWithImpl(this._self, this._then);

  final _DossierProperty _self;
  final $Res Function(_DossierProperty) _then;

/// Create a copy of DossierProperty
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? zone = freezed,Object? address = freezed,Object? city = freezed,Object? rec = freezed,Object? banos = freezed,Object? m2 = freezed,Object? amenities = null,Object? status = freezed,Object? broker = freezed,}) {
  return _then(_DossierProperty(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,rec: freezed == rec ? _self.rec : rec // ignore: cast_nullable_to_non_nullable
as int?,banos: freezed == banos ? _self.banos : banos // ignore: cast_nullable_to_non_nullable
as double?,m2: freezed == m2 ? _self.m2 : m2 // ignore: cast_nullable_to_non_nullable
as double?,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,broker: freezed == broker ? _self.broker : broker // ignore: cast_nullable_to_non_nullable
as DossierBroker?,
  ));
}

/// Create a copy of DossierProperty
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DossierBrokerCopyWith<$Res>? get broker {
    if (_self.broker == null) {
    return null;
  }

  return $DossierBrokerCopyWith<$Res>(_self.broker!, (value) {
    return _then(_self.copyWith(broker: value));
  });
}
}


/// @nodoc
mixin _$DossierBroker {

 String? get name; String? get phone;
/// Create a copy of DossierBroker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DossierBrokerCopyWith<DossierBroker> get copyWith => _$DossierBrokerCopyWithImpl<DossierBroker>(this as DossierBroker, _$identity);

  /// Serializes this DossierBroker to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DossierBroker;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DossierBroker&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DossierBroker;
  return Object.hash(runtimeType,_this.name,_this.phone);
}

@override
String toString() {
  final _this = this as DossierBroker;
  return 'DossierBroker(name: ${_this.name}, phone: ${_this.phone})';
}


}

/// @nodoc
abstract mixin class $DossierBrokerCopyWith<$Res>  {
  factory $DossierBrokerCopyWith(DossierBroker value, $Res Function(DossierBroker) _then) = _$DossierBrokerCopyWithImpl;
@useResult
$Res call({
 String? name, String? phone
});




}
/// @nodoc
class _$DossierBrokerCopyWithImpl<$Res>
    implements $DossierBrokerCopyWith<$Res> {
  _$DossierBrokerCopyWithImpl(this._self, this._then);

  final DossierBroker _self;
  final $Res Function(DossierBroker) _then;

/// Create a copy of DossierBroker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? phone = freezed,}) {
  return _then(DossierBroker(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DossierBroker].
extension DossierBrokerPatterns on DossierBroker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DossierBroker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DossierBroker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DossierBroker value)  $default,){
final _that = this;
switch (_that) {
case _DossierBroker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DossierBroker value)?  $default,){
final _that = this;
switch (_that) {
case _DossierBroker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DossierBroker() when $default != null:
return $default(_that.name,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? phone)  $default,) {final _that = this;
switch (_that) {
case _DossierBroker():
return $default(_that.name,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _DossierBroker() when $default != null:
return $default(_that.name,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DossierBroker implements DossierBroker {
  const _DossierBroker({this.name, this.phone});
  factory _DossierBroker.fromJson(Map<String, dynamic> json) => _$DossierBrokerFromJson(json);

@override final  String? name;
@override final  String? phone;

/// Create a copy of DossierBroker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DossierBrokerCopyWith<_DossierBroker> get copyWith => __$DossierBrokerCopyWithImpl<_DossierBroker>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DossierBrokerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DossierBroker&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,phone);
}

@override
String toString() {
    return 'DossierBroker(name: $name, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$DossierBrokerCopyWith<$Res> implements $DossierBrokerCopyWith<$Res> {
  factory _$DossierBrokerCopyWith(_DossierBroker value, $Res Function(_DossierBroker) _then) = __$DossierBrokerCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? phone
});




}
/// @nodoc
class __$DossierBrokerCopyWithImpl<$Res>
    implements _$DossierBrokerCopyWith<$Res> {
  __$DossierBrokerCopyWithImpl(this._self, this._then);

  final _DossierBroker _self;
  final $Res Function(_DossierBroker) _then;

/// Create a copy of DossierBroker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? phone = freezed,}) {
  return _then(_DossierBroker(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DossierContract {

 String get id;@LocalDate() DateTime get startDate;@LocalDate() DateTime get endDate; double get monthlyRent; int get paymentDay; double? get deposit; String get status;
/// Create a copy of DossierContract
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DossierContractCopyWith<DossierContract> get copyWith => _$DossierContractCopyWithImpl<DossierContract>(this as DossierContract, _$identity);

  /// Serializes this DossierContract to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DossierContract;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DossierContract&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&(identical(other.monthlyRent, _this.monthlyRent) || other.monthlyRent == _this.monthlyRent)&&(identical(other.paymentDay, _this.paymentDay) || other.paymentDay == _this.paymentDay)&&(identical(other.deposit, _this.deposit) || other.deposit == _this.deposit)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DossierContract;
  return Object.hash(runtimeType,_this.id,_this.startDate,_this.endDate,_this.monthlyRent,_this.paymentDay,_this.deposit,_this.status);
}

@override
String toString() {
  final _this = this as DossierContract;
  return 'DossierContract(id: ${_this.id}, startDate: ${_this.startDate}, endDate: ${_this.endDate}, monthlyRent: ${_this.monthlyRent}, paymentDay: ${_this.paymentDay}, deposit: ${_this.deposit}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $DossierContractCopyWith<$Res>  {
  factory $DossierContractCopyWith(DossierContract value, $Res Function(DossierContract) _then) = _$DossierContractCopyWithImpl;
@useResult
$Res call({
 String id,@LocalDate() DateTime startDate,@LocalDate() DateTime endDate, double monthlyRent, int paymentDay, double? deposit, String status
});




}
/// @nodoc
class _$DossierContractCopyWithImpl<$Res>
    implements $DossierContractCopyWith<$Res> {
  _$DossierContractCopyWithImpl(this._self, this._then);

  final DossierContract _self;
  final $Res Function(DossierContract) _then;

/// Create a copy of DossierContract
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startDate = null,Object? endDate = null,Object? monthlyRent = null,Object? paymentDay = null,Object? deposit = freezed,Object? status = null,}) {
  return _then(DossierContract(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,monthlyRent: null == monthlyRent ? _self.monthlyRent : monthlyRent // ignore: cast_nullable_to_non_nullable
as double,paymentDay: null == paymentDay ? _self.paymentDay : paymentDay // ignore: cast_nullable_to_non_nullable
as int,deposit: freezed == deposit ? _self.deposit : deposit // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DossierContract].
extension DossierContractPatterns on DossierContract {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DossierContract value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DossierContract() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DossierContract value)  $default,){
final _that = this;
switch (_that) {
case _DossierContract():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DossierContract value)?  $default,){
final _that = this;
switch (_that) {
case _DossierContract() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @LocalDate()  DateTime startDate, @LocalDate()  DateTime endDate,  double monthlyRent,  int paymentDay,  double? deposit,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DossierContract() when $default != null:
return $default(_that.id,_that.startDate,_that.endDate,_that.monthlyRent,_that.paymentDay,_that.deposit,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @LocalDate()  DateTime startDate, @LocalDate()  DateTime endDate,  double monthlyRent,  int paymentDay,  double? deposit,  String status)  $default,) {final _that = this;
switch (_that) {
case _DossierContract():
return $default(_that.id,_that.startDate,_that.endDate,_that.monthlyRent,_that.paymentDay,_that.deposit,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @LocalDate()  DateTime startDate, @LocalDate()  DateTime endDate,  double monthlyRent,  int paymentDay,  double? deposit,  String status)?  $default,) {final _that = this;
switch (_that) {
case _DossierContract() when $default != null:
return $default(_that.id,_that.startDate,_that.endDate,_that.monthlyRent,_that.paymentDay,_that.deposit,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DossierContract implements DossierContract {
  const _DossierContract({required this.id, @LocalDate() required this.startDate, @LocalDate() required this.endDate, required this.monthlyRent, required this.paymentDay, this.deposit, required this.status});
  factory _DossierContract.fromJson(Map<String, dynamic> json) => _$DossierContractFromJson(json);

@override final  String id;
@override@LocalDate() final  DateTime startDate;
@override@LocalDate() final  DateTime endDate;
@override final  double monthlyRent;
@override final  int paymentDay;
@override final  double? deposit;
@override final  String status;

/// Create a copy of DossierContract
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DossierContractCopyWith<_DossierContract> get copyWith => __$DossierContractCopyWithImpl<_DossierContract>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DossierContractToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DossierContract&&(identical(other.id, id) || other.id == id)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.monthlyRent, monthlyRent) || other.monthlyRent == monthlyRent)&&(identical(other.paymentDay, paymentDay) || other.paymentDay == paymentDay)&&(identical(other.deposit, deposit) || other.deposit == deposit)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,startDate,endDate,monthlyRent,paymentDay,deposit,status);
}

@override
String toString() {
    return 'DossierContract(id: $id, startDate: $startDate, endDate: $endDate, monthlyRent: $monthlyRent, paymentDay: $paymentDay, deposit: $deposit, status: $status)';
}


}

/// @nodoc
abstract mixin class _$DossierContractCopyWith<$Res> implements $DossierContractCopyWith<$Res> {
  factory _$DossierContractCopyWith(_DossierContract value, $Res Function(_DossierContract) _then) = __$DossierContractCopyWithImpl;
@override @useResult
$Res call({
 String id,@LocalDate() DateTime startDate,@LocalDate() DateTime endDate, double monthlyRent, int paymentDay, double? deposit, String status
});




}
/// @nodoc
class __$DossierContractCopyWithImpl<$Res>
    implements _$DossierContractCopyWith<$Res> {
  __$DossierContractCopyWithImpl(this._self, this._then);

  final _DossierContract _self;
  final $Res Function(_DossierContract) _then;

/// Create a copy of DossierContract
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startDate = null,Object? endDate = null,Object? monthlyRent = null,Object? paymentDay = null,Object? deposit = freezed,Object? status = null,}) {
  return _then(_DossierContract(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,monthlyRent: null == monthlyRent ? _self.monthlyRent : monthlyRent // ignore: cast_nullable_to_non_nullable
as double,paymentDay: null == paymentDay ? _self.paymentDay : paymentDay // ignore: cast_nullable_to_non_nullable
as int,deposit: freezed == deposit ? _self.deposit : deposit // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DossierSection {

 String get key; String get title; String? get subtitle; List<String> get documentIds;
/// Create a copy of DossierSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DossierSectionCopyWith<DossierSection> get copyWith => _$DossierSectionCopyWithImpl<DossierSection>(this as DossierSection, _$identity);

  /// Serializes this DossierSection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DossierSection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DossierSection&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle)&&const DeepCollectionEquality().equals(other.documentIds, _this.documentIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DossierSection;
  return Object.hash(runtimeType,_this.key,_this.title,_this.subtitle,const DeepCollectionEquality().hash(_this.documentIds));
}

@override
String toString() {
  final _this = this as DossierSection;
  return 'DossierSection(key: ${_this.key}, title: ${_this.title}, subtitle: ${_this.subtitle}, documentIds: ${_this.documentIds})';
}


}

/// @nodoc
abstract mixin class $DossierSectionCopyWith<$Res>  {
  factory $DossierSectionCopyWith(DossierSection value, $Res Function(DossierSection) _then) = _$DossierSectionCopyWithImpl;
@useResult
$Res call({
 String key, String title, String? subtitle, List<String> documentIds
});




}
/// @nodoc
class _$DossierSectionCopyWithImpl<$Res>
    implements $DossierSectionCopyWith<$Res> {
  _$DossierSectionCopyWithImpl(this._self, this._then);

  final DossierSection _self;
  final $Res Function(DossierSection) _then;

/// Create a copy of DossierSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? title = null,Object? subtitle = freezed,Object? documentIds = null,}) {
  return _then(DossierSection(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,documentIds: null == documentIds ? _self.documentIds : documentIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DossierSection].
extension DossierSectionPatterns on DossierSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DossierSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DossierSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DossierSection value)  $default,){
final _that = this;
switch (_that) {
case _DossierSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DossierSection value)?  $default,){
final _that = this;
switch (_that) {
case _DossierSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String title,  String? subtitle,  List<String> documentIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DossierSection() when $default != null:
return $default(_that.key,_that.title,_that.subtitle,_that.documentIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String title,  String? subtitle,  List<String> documentIds)  $default,) {final _that = this;
switch (_that) {
case _DossierSection():
return $default(_that.key,_that.title,_that.subtitle,_that.documentIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String title,  String? subtitle,  List<String> documentIds)?  $default,) {final _that = this;
switch (_that) {
case _DossierSection() when $default != null:
return $default(_that.key,_that.title,_that.subtitle,_that.documentIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DossierSection implements DossierSection {
  const _DossierSection({required this.key, required this.title, this.subtitle,  List<String> documentIds = const <String>[]}): _documentIds = documentIds;
  factory _DossierSection.fromJson(Map<String, dynamic> json) => _$DossierSectionFromJson(json);

@override final  String key;
@override final  String title;
@override final  String? subtitle;
 final  List<String> _documentIds;
@override@JsonKey() List<String> get documentIds {
  if (_documentIds is EqualUnmodifiableListView) return _documentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documentIds);
}


/// Create a copy of DossierSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DossierSectionCopyWith<_DossierSection> get copyWith => __$DossierSectionCopyWithImpl<_DossierSection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DossierSectionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DossierSection&&(identical(other.key, key) || other.key == key)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&const DeepCollectionEquality().equals(other.documentIds, _documentIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,title,subtitle,const DeepCollectionEquality().hash(_documentIds));
}

@override
String toString() {
    return 'DossierSection(key: $key, title: $title, subtitle: $subtitle, documentIds: $documentIds)';
}


}

/// @nodoc
abstract mixin class _$DossierSectionCopyWith<$Res> implements $DossierSectionCopyWith<$Res> {
  factory _$DossierSectionCopyWith(_DossierSection value, $Res Function(_DossierSection) _then) = __$DossierSectionCopyWithImpl;
@override @useResult
$Res call({
 String key, String title, String? subtitle, List<String> documentIds
});




}
/// @nodoc
class __$DossierSectionCopyWithImpl<$Res>
    implements _$DossierSectionCopyWith<$Res> {
  __$DossierSectionCopyWithImpl(this._self, this._then);

  final _DossierSection _self;
  final $Res Function(_DossierSection) _then;

/// Create a copy of DossierSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? title = null,Object? subtitle = freezed,Object? documentIds = null,}) {
  return _then(_DossierSection(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,documentIds: null == documentIds ? _self._documentIds : documentIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$DossierDocument {

 String get id; String get type; String get name; String? get description; String? get mime; int? get size;@LocalDateOrNull() DateTime? get createdAt; bool? get visibleToClient;
/// Create a copy of DossierDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DossierDocumentCopyWith<DossierDocument> get copyWith => _$DossierDocumentCopyWithImpl<DossierDocument>(this as DossierDocument, _$identity);

  /// Serializes this DossierDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DossierDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DossierDocument&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.mime, _this.mime) || other.mime == _this.mime)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.visibleToClient, _this.visibleToClient) || other.visibleToClient == _this.visibleToClient));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DossierDocument;
  return Object.hash(runtimeType,_this.id,_this.type,_this.name,_this.description,_this.mime,_this.size,_this.createdAt,_this.visibleToClient);
}

@override
String toString() {
  final _this = this as DossierDocument;
  return 'DossierDocument(id: ${_this.id}, type: ${_this.type}, name: ${_this.name}, description: ${_this.description}, mime: ${_this.mime}, size: ${_this.size}, createdAt: ${_this.createdAt}, visibleToClient: ${_this.visibleToClient})';
}


}

/// @nodoc
abstract mixin class $DossierDocumentCopyWith<$Res>  {
  factory $DossierDocumentCopyWith(DossierDocument value, $Res Function(DossierDocument) _then) = _$DossierDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String type, String name, String? description, String? mime, int? size,@LocalDateOrNull() DateTime? createdAt, bool? visibleToClient
});




}
/// @nodoc
class _$DossierDocumentCopyWithImpl<$Res>
    implements $DossierDocumentCopyWith<$Res> {
  _$DossierDocumentCopyWithImpl(this._self, this._then);

  final DossierDocument _self;
  final $Res Function(DossierDocument) _then;

/// Create a copy of DossierDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? description = freezed,Object? mime = freezed,Object? size = freezed,Object? createdAt = freezed,Object? visibleToClient = freezed,}) {
  return _then(DossierDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,mime: freezed == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,visibleToClient: freezed == visibleToClient ? _self.visibleToClient : visibleToClient // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [DossierDocument].
extension DossierDocumentPatterns on DossierDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DossierDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DossierDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DossierDocument value)  $default,){
final _that = this;
switch (_that) {
case _DossierDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DossierDocument value)?  $default,){
final _that = this;
switch (_that) {
case _DossierDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String name,  String? description,  String? mime,  int? size, @LocalDateOrNull()  DateTime? createdAt,  bool? visibleToClient)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DossierDocument() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.description,_that.mime,_that.size,_that.createdAt,_that.visibleToClient);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String name,  String? description,  String? mime,  int? size, @LocalDateOrNull()  DateTime? createdAt,  bool? visibleToClient)  $default,) {final _that = this;
switch (_that) {
case _DossierDocument():
return $default(_that.id,_that.type,_that.name,_that.description,_that.mime,_that.size,_that.createdAt,_that.visibleToClient);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String name,  String? description,  String? mime,  int? size, @LocalDateOrNull()  DateTime? createdAt,  bool? visibleToClient)?  $default,) {final _that = this;
switch (_that) {
case _DossierDocument() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.description,_that.mime,_that.size,_that.createdAt,_that.visibleToClient);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DossierDocument implements DossierDocument {
  const _DossierDocument({required this.id, required this.type, required this.name, this.description, this.mime, this.size, @LocalDateOrNull() this.createdAt, this.visibleToClient});
  factory _DossierDocument.fromJson(Map<String, dynamic> json) => _$DossierDocumentFromJson(json);

@override final  String id;
@override final  String type;
@override final  String name;
@override final  String? description;
@override final  String? mime;
@override final  int? size;
@override@LocalDateOrNull() final  DateTime? createdAt;
@override final  bool? visibleToClient;

/// Create a copy of DossierDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DossierDocumentCopyWith<_DossierDocument> get copyWith => __$DossierDocumentCopyWithImpl<_DossierDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DossierDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DossierDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.size, size) || other.size == size)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.visibleToClient, visibleToClient) || other.visibleToClient == visibleToClient));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,name,description,mime,size,createdAt,visibleToClient);
}

@override
String toString() {
    return 'DossierDocument(id: $id, type: $type, name: $name, description: $description, mime: $mime, size: $size, createdAt: $createdAt, visibleToClient: $visibleToClient)';
}


}

/// @nodoc
abstract mixin class _$DossierDocumentCopyWith<$Res> implements $DossierDocumentCopyWith<$Res> {
  factory _$DossierDocumentCopyWith(_DossierDocument value, $Res Function(_DossierDocument) _then) = __$DossierDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String name, String? description, String? mime, int? size,@LocalDateOrNull() DateTime? createdAt, bool? visibleToClient
});




}
/// @nodoc
class __$DossierDocumentCopyWithImpl<$Res>
    implements _$DossierDocumentCopyWith<$Res> {
  __$DossierDocumentCopyWithImpl(this._self, this._then);

  final _DossierDocument _self;
  final $Res Function(_DossierDocument) _then;

/// Create a copy of DossierDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? description = freezed,Object? mime = freezed,Object? size = freezed,Object? createdAt = freezed,Object? visibleToClient = freezed,}) {
  return _then(_DossierDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,mime: freezed == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,visibleToClient: freezed == visibleToClient ? _self.visibleToClient : visibleToClient // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
