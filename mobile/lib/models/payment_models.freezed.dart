// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PromissoryNote {

 String get id; int get number; String get label; double get amount;@LocalDate() DateTime get dueDate; String get status; NotePayment? get payment; String? get proofDocumentId; String? get documentId; List<NoteStamp> get stamps; NoteRef? get property; NoteRef? get client;
/// Create a copy of PromissoryNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PromissoryNoteCopyWith<PromissoryNote> get copyWith => _$PromissoryNoteCopyWithImpl<PromissoryNote>(this as PromissoryNote, _$identity);

  /// Serializes this PromissoryNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PromissoryNote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromissoryNote&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.payment, _this.payment) || other.payment == _this.payment)&&(identical(other.proofDocumentId, _this.proofDocumentId) || other.proofDocumentId == _this.proofDocumentId)&&(identical(other.documentId, _this.documentId) || other.documentId == _this.documentId)&&const DeepCollectionEquality().equals(other.stamps, _this.stamps)&&(identical(other.property, _this.property) || other.property == _this.property)&&(identical(other.client, _this.client) || other.client == _this.client));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PromissoryNote;
  return Object.hash(runtimeType,_this.id,_this.number,_this.label,_this.amount,_this.dueDate,_this.status,_this.payment,_this.proofDocumentId,_this.documentId,const DeepCollectionEquality().hash(_this.stamps),_this.property,_this.client);
}

@override
String toString() {
  final _this = this as PromissoryNote;
  return 'PromissoryNote(id: ${_this.id}, number: ${_this.number}, label: ${_this.label}, amount: ${_this.amount}, dueDate: ${_this.dueDate}, status: ${_this.status}, payment: ${_this.payment}, proofDocumentId: ${_this.proofDocumentId}, documentId: ${_this.documentId}, stamps: ${_this.stamps}, property: ${_this.property}, client: ${_this.client})';
}


}

/// @nodoc
abstract mixin class $PromissoryNoteCopyWith<$Res>  {
  factory $PromissoryNoteCopyWith(PromissoryNote value, $Res Function(PromissoryNote) _then) = _$PromissoryNoteCopyWithImpl;
@useResult
$Res call({
 String id, int number, String label, double amount,@LocalDate() DateTime dueDate, String status, NotePayment? payment, String? proofDocumentId, String? documentId, List<NoteStamp> stamps, NoteRef? property, NoteRef? client
});


$NotePaymentCopyWith<$Res>? get payment;$NoteRefCopyWith<$Res>? get property;$NoteRefCopyWith<$Res>? get client;

}
/// @nodoc
class _$PromissoryNoteCopyWithImpl<$Res>
    implements $PromissoryNoteCopyWith<$Res> {
  _$PromissoryNoteCopyWithImpl(this._self, this._then);

  final PromissoryNote _self;
  final $Res Function(PromissoryNote) _then;

/// Create a copy of PromissoryNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? label = null,Object? amount = null,Object? dueDate = null,Object? status = null,Object? payment = freezed,Object? proofDocumentId = freezed,Object? documentId = freezed,Object? stamps = null,Object? property = freezed,Object? client = freezed,}) {
  return _then(PromissoryNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,payment: freezed == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as NotePayment?,proofDocumentId: freezed == proofDocumentId ? _self.proofDocumentId : proofDocumentId // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,stamps: null == stamps ? _self.stamps : stamps // ignore: cast_nullable_to_non_nullable
as List<NoteStamp>,property: freezed == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as NoteRef?,client: freezed == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as NoteRef?,
  ));
}
/// Create a copy of PromissoryNote
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotePaymentCopyWith<$Res>? get payment {
    if (_self.payment == null) {
    return null;
  }

  return $NotePaymentCopyWith<$Res>(_self.payment!, (value) {
    return _then(_self.copyWith(payment: value));
  });
}/// Create a copy of PromissoryNote
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteRefCopyWith<$Res>? get property {
    if (_self.property == null) {
    return null;
  }

  return $NoteRefCopyWith<$Res>(_self.property!, (value) {
    return _then(_self.copyWith(property: value));
  });
}/// Create a copy of PromissoryNote
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteRefCopyWith<$Res>? get client {
    if (_self.client == null) {
    return null;
  }

  return $NoteRefCopyWith<$Res>(_self.client!, (value) {
    return _then(_self.copyWith(client: value));
  });
}
}


/// Adds pattern-matching-related methods to [PromissoryNote].
extension PromissoryNotePatterns on PromissoryNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PromissoryNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PromissoryNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PromissoryNote value)  $default,){
final _that = this;
switch (_that) {
case _PromissoryNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PromissoryNote value)?  $default,){
final _that = this;
switch (_that) {
case _PromissoryNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  String label,  double amount, @LocalDate()  DateTime dueDate,  String status,  NotePayment? payment,  String? proofDocumentId,  String? documentId,  List<NoteStamp> stamps,  NoteRef? property,  NoteRef? client)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PromissoryNote() when $default != null:
return $default(_that.id,_that.number,_that.label,_that.amount,_that.dueDate,_that.status,_that.payment,_that.proofDocumentId,_that.documentId,_that.stamps,_that.property,_that.client);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  String label,  double amount, @LocalDate()  DateTime dueDate,  String status,  NotePayment? payment,  String? proofDocumentId,  String? documentId,  List<NoteStamp> stamps,  NoteRef? property,  NoteRef? client)  $default,) {final _that = this;
switch (_that) {
case _PromissoryNote():
return $default(_that.id,_that.number,_that.label,_that.amount,_that.dueDate,_that.status,_that.payment,_that.proofDocumentId,_that.documentId,_that.stamps,_that.property,_that.client);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  String label,  double amount, @LocalDate()  DateTime dueDate,  String status,  NotePayment? payment,  String? proofDocumentId,  String? documentId,  List<NoteStamp> stamps,  NoteRef? property,  NoteRef? client)?  $default,) {final _that = this;
switch (_that) {
case _PromissoryNote() when $default != null:
return $default(_that.id,_that.number,_that.label,_that.amount,_that.dueDate,_that.status,_that.payment,_that.proofDocumentId,_that.documentId,_that.stamps,_that.property,_that.client);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PromissoryNote extends PromissoryNote {
  const _PromissoryNote({required this.id, required this.number, required this.label, required this.amount, @LocalDate() required this.dueDate, required this.status, this.payment, this.proofDocumentId, this.documentId,  List<NoteStamp> stamps = const <NoteStamp>[], this.property, this.client}): _stamps = stamps,super._();
  factory _PromissoryNote.fromJson(Map<String, dynamic> json) => _$PromissoryNoteFromJson(json);

@override final  String id;
@override final  int number;
@override final  String label;
@override final  double amount;
@override@LocalDate() final  DateTime dueDate;
@override final  String status;
@override final  NotePayment? payment;
@override final  String? proofDocumentId;
@override final  String? documentId;
 final  List<NoteStamp> _stamps;
@override@JsonKey() List<NoteStamp> get stamps {
  if (_stamps is EqualUnmodifiableListView) return _stamps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stamps);
}

@override final  NoteRef? property;
@override final  NoteRef? client;

/// Create a copy of PromissoryNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PromissoryNoteCopyWith<_PromissoryNote> get copyWith => __$PromissoryNoteCopyWithImpl<_PromissoryNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PromissoryNoteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PromissoryNote&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.label, label) || other.label == label)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.proofDocumentId, proofDocumentId) || other.proofDocumentId == proofDocumentId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&const DeepCollectionEquality().equals(other.stamps, _stamps)&&(identical(other.property, property) || other.property == property)&&(identical(other.client, client) || other.client == client));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,number,label,amount,dueDate,status,payment,proofDocumentId,documentId,const DeepCollectionEquality().hash(_stamps),property,client);
}

@override
String toString() {
    return 'PromissoryNote(id: $id, number: $number, label: $label, amount: $amount, dueDate: $dueDate, status: $status, payment: $payment, proofDocumentId: $proofDocumentId, documentId: $documentId, stamps: $stamps, property: $property, client: $client)';
}


}

/// @nodoc
abstract mixin class _$PromissoryNoteCopyWith<$Res> implements $PromissoryNoteCopyWith<$Res> {
  factory _$PromissoryNoteCopyWith(_PromissoryNote value, $Res Function(_PromissoryNote) _then) = __$PromissoryNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, String label, double amount,@LocalDate() DateTime dueDate, String status, NotePayment? payment, String? proofDocumentId, String? documentId, List<NoteStamp> stamps, NoteRef? property, NoteRef? client
});


@override $NotePaymentCopyWith<$Res>? get payment;@override $NoteRefCopyWith<$Res>? get property;@override $NoteRefCopyWith<$Res>? get client;

}
/// @nodoc
class __$PromissoryNoteCopyWithImpl<$Res>
    implements _$PromissoryNoteCopyWith<$Res> {
  __$PromissoryNoteCopyWithImpl(this._self, this._then);

  final _PromissoryNote _self;
  final $Res Function(_PromissoryNote) _then;

/// Create a copy of PromissoryNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? label = null,Object? amount = null,Object? dueDate = null,Object? status = null,Object? payment = freezed,Object? proofDocumentId = freezed,Object? documentId = freezed,Object? stamps = null,Object? property = freezed,Object? client = freezed,}) {
  return _then(_PromissoryNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,payment: freezed == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as NotePayment?,proofDocumentId: freezed == proofDocumentId ? _self.proofDocumentId : proofDocumentId // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,stamps: null == stamps ? _self._stamps : stamps // ignore: cast_nullable_to_non_nullable
as List<NoteStamp>,property: freezed == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as NoteRef?,client: freezed == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as NoteRef?,
  ));
}

/// Create a copy of PromissoryNote
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotePaymentCopyWith<$Res>? get payment {
    if (_self.payment == null) {
    return null;
  }

  return $NotePaymentCopyWith<$Res>(_self.payment!, (value) {
    return _then(_self.copyWith(payment: value));
  });
}/// Create a copy of PromissoryNote
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteRefCopyWith<$Res>? get property {
    if (_self.property == null) {
    return null;
  }

  return $NoteRefCopyWith<$Res>(_self.property!, (value) {
    return _then(_self.copyWith(property: value));
  });
}/// Create a copy of PromissoryNote
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteRefCopyWith<$Res>? get client {
    if (_self.client == null) {
    return null;
  }

  return $NoteRefCopyWith<$Res>(_self.client!, (value) {
    return _then(_self.copyWith(client: value));
  });
}
}


/// @nodoc
mixin _$NoteStamp {

 String get id; String get name;@LocalDate() DateTime get createdAt;
/// Create a copy of NoteStamp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteStampCopyWith<NoteStamp> get copyWith => _$NoteStampCopyWithImpl<NoteStamp>(this as NoteStamp, _$identity);

  /// Serializes this NoteStamp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NoteStamp;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteStamp&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NoteStamp;
  return Object.hash(runtimeType,_this.id,_this.name,_this.createdAt);
}

@override
String toString() {
  final _this = this as NoteStamp;
  return 'NoteStamp(id: ${_this.id}, name: ${_this.name}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $NoteStampCopyWith<$Res>  {
  factory $NoteStampCopyWith(NoteStamp value, $Res Function(NoteStamp) _then) = _$NoteStampCopyWithImpl;
@useResult
$Res call({
 String id, String name,@LocalDate() DateTime createdAt
});




}
/// @nodoc
class _$NoteStampCopyWithImpl<$Res>
    implements $NoteStampCopyWith<$Res> {
  _$NoteStampCopyWithImpl(this._self, this._then);

  final NoteStamp _self;
  final $Res Function(NoteStamp) _then;

/// Create a copy of NoteStamp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,}) {
  return _then(NoteStamp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteStamp].
extension NoteStampPatterns on NoteStamp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteStamp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteStamp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteStamp value)  $default,){
final _that = this;
switch (_that) {
case _NoteStamp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteStamp value)?  $default,){
final _that = this;
switch (_that) {
case _NoteStamp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @LocalDate()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteStamp() when $default != null:
return $default(_that.id,_that.name,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @LocalDate()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _NoteStamp():
return $default(_that.id,_that.name,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @LocalDate()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _NoteStamp() when $default != null:
return $default(_that.id,_that.name,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NoteStamp implements NoteStamp {
  const _NoteStamp({required this.id, required this.name, @LocalDate() required this.createdAt});
  factory _NoteStamp.fromJson(Map<String, dynamic> json) => _$NoteStampFromJson(json);

@override final  String id;
@override final  String name;
@override@LocalDate() final  DateTime createdAt;

/// Create a copy of NoteStamp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteStampCopyWith<_NoteStamp> get copyWith => __$NoteStampCopyWithImpl<_NoteStamp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoteStampToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteStamp&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,createdAt);
}

@override
String toString() {
    return 'NoteStamp(id: $id, name: $name, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NoteStampCopyWith<$Res> implements $NoteStampCopyWith<$Res> {
  factory _$NoteStampCopyWith(_NoteStamp value, $Res Function(_NoteStamp) _then) = __$NoteStampCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@LocalDate() DateTime createdAt
});




}
/// @nodoc
class __$NoteStampCopyWithImpl<$Res>
    implements _$NoteStampCopyWith<$Res> {
  __$NoteStampCopyWithImpl(this._self, this._then);

  final _NoteStamp _self;
  final $Res Function(_NoteStamp) _then;

/// Create a copy of NoteStamp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,}) {
  return _then(_NoteStamp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$NoteRef {

 String get id; String get name;
/// Create a copy of NoteRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteRefCopyWith<NoteRef> get copyWith => _$NoteRefCopyWithImpl<NoteRef>(this as NoteRef, _$identity);

  /// Serializes this NoteRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NoteRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NoteRef;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as NoteRef;
  return 'NoteRef(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $NoteRefCopyWith<$Res>  {
  factory $NoteRefCopyWith(NoteRef value, $Res Function(NoteRef) _then) = _$NoteRefCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$NoteRefCopyWithImpl<$Res>
    implements $NoteRefCopyWith<$Res> {
  _$NoteRefCopyWithImpl(this._self, this._then);

  final NoteRef _self;
  final $Res Function(NoteRef) _then;

/// Create a copy of NoteRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(NoteRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteRef].
extension NoteRefPatterns on NoteRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteRef value)  $default,){
final _that = this;
switch (_that) {
case _NoteRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteRef value)?  $default,){
final _that = this;
switch (_that) {
case _NoteRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteRef() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _NoteRef():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _NoteRef() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NoteRef implements NoteRef {
  const _NoteRef({required this.id, required this.name});
  factory _NoteRef.fromJson(Map<String, dynamic> json) => _$NoteRefFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of NoteRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteRefCopyWith<_NoteRef> get copyWith => __$NoteRefCopyWithImpl<_NoteRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoteRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'NoteRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$NoteRefCopyWith<$Res> implements $NoteRefCopyWith<$Res> {
  factory _$NoteRefCopyWith(_NoteRef value, $Res Function(_NoteRef) _then) = __$NoteRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$NoteRefCopyWithImpl<$Res>
    implements _$NoteRefCopyWith<$Res> {
  __$NoteRefCopyWithImpl(this._self, this._then);

  final _NoteRef _self;
  final $Res Function(_NoteRef) _then;

/// Create a copy of NoteRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_NoteRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NotePayment {

 String get id; double get amount;@LocalDate() DateTime get paidAt; String? get receiptFolio; String? get notes; String? get registeredBy;
/// Create a copy of NotePayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotePaymentCopyWith<NotePayment> get copyWith => _$NotePaymentCopyWithImpl<NotePayment>(this as NotePayment, _$identity);

  /// Serializes this NotePayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotePayment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotePayment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.paidAt, _this.paidAt) || other.paidAt == _this.paidAt)&&(identical(other.receiptFolio, _this.receiptFolio) || other.receiptFolio == _this.receiptFolio)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.registeredBy, _this.registeredBy) || other.registeredBy == _this.registeredBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotePayment;
  return Object.hash(runtimeType,_this.id,_this.amount,_this.paidAt,_this.receiptFolio,_this.notes,_this.registeredBy);
}

@override
String toString() {
  final _this = this as NotePayment;
  return 'NotePayment(id: ${_this.id}, amount: ${_this.amount}, paidAt: ${_this.paidAt}, receiptFolio: ${_this.receiptFolio}, notes: ${_this.notes}, registeredBy: ${_this.registeredBy})';
}


}

/// @nodoc
abstract mixin class $NotePaymentCopyWith<$Res>  {
  factory $NotePaymentCopyWith(NotePayment value, $Res Function(NotePayment) _then) = _$NotePaymentCopyWithImpl;
@useResult
$Res call({
 String id, double amount,@LocalDate() DateTime paidAt, String? receiptFolio, String? notes, String? registeredBy
});




}
/// @nodoc
class _$NotePaymentCopyWithImpl<$Res>
    implements $NotePaymentCopyWith<$Res> {
  _$NotePaymentCopyWithImpl(this._self, this._then);

  final NotePayment _self;
  final $Res Function(NotePayment) _then;

/// Create a copy of NotePayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? paidAt = null,Object? receiptFolio = freezed,Object? notes = freezed,Object? registeredBy = freezed,}) {
  return _then(NotePayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,receiptFolio: freezed == receiptFolio ? _self.receiptFolio : receiptFolio // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,registeredBy: freezed == registeredBy ? _self.registeredBy : registeredBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotePayment].
extension NotePaymentPatterns on NotePayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotePayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotePayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotePayment value)  $default,){
final _that = this;
switch (_that) {
case _NotePayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotePayment value)?  $default,){
final _that = this;
switch (_that) {
case _NotePayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double amount, @LocalDate()  DateTime paidAt,  String? receiptFolio,  String? notes,  String? registeredBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotePayment() when $default != null:
return $default(_that.id,_that.amount,_that.paidAt,_that.receiptFolio,_that.notes,_that.registeredBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double amount, @LocalDate()  DateTime paidAt,  String? receiptFolio,  String? notes,  String? registeredBy)  $default,) {final _that = this;
switch (_that) {
case _NotePayment():
return $default(_that.id,_that.amount,_that.paidAt,_that.receiptFolio,_that.notes,_that.registeredBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double amount, @LocalDate()  DateTime paidAt,  String? receiptFolio,  String? notes,  String? registeredBy)?  $default,) {final _that = this;
switch (_that) {
case _NotePayment() when $default != null:
return $default(_that.id,_that.amount,_that.paidAt,_that.receiptFolio,_that.notes,_that.registeredBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotePayment implements NotePayment {
  const _NotePayment({required this.id, required this.amount, @LocalDate() required this.paidAt, this.receiptFolio, this.notes, this.registeredBy});
  factory _NotePayment.fromJson(Map<String, dynamic> json) => _$NotePaymentFromJson(json);

@override final  String id;
@override final  double amount;
@override@LocalDate() final  DateTime paidAt;
@override final  String? receiptFolio;
@override final  String? notes;
@override final  String? registeredBy;

/// Create a copy of NotePayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotePaymentCopyWith<_NotePayment> get copyWith => __$NotePaymentCopyWithImpl<_NotePayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotePaymentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.receiptFolio, receiptFolio) || other.receiptFolio == receiptFolio)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.registeredBy, registeredBy) || other.registeredBy == registeredBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,amount,paidAt,receiptFolio,notes,registeredBy);
}

@override
String toString() {
    return 'NotePayment(id: $id, amount: $amount, paidAt: $paidAt, receiptFolio: $receiptFolio, notes: $notes, registeredBy: $registeredBy)';
}


}

/// @nodoc
abstract mixin class _$NotePaymentCopyWith<$Res> implements $NotePaymentCopyWith<$Res> {
  factory _$NotePaymentCopyWith(_NotePayment value, $Res Function(_NotePayment) _then) = __$NotePaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, double amount,@LocalDate() DateTime paidAt, String? receiptFolio, String? notes, String? registeredBy
});




}
/// @nodoc
class __$NotePaymentCopyWithImpl<$Res>
    implements _$NotePaymentCopyWith<$Res> {
  __$NotePaymentCopyWithImpl(this._self, this._then);

  final _NotePayment _self;
  final $Res Function(_NotePayment) _then;

/// Create a copy of NotePayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? paidAt = null,Object? receiptFolio = freezed,Object? notes = freezed,Object? registeredBy = freezed,}) {
  return _then(_NotePayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,receiptFolio: freezed == receiptFolio ? _self.receiptFolio : receiptFolio // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,registeredBy: freezed == registeredBy ? _self.registeredBy : registeredBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$NotesSummary {

 int get total; int get paid; int get remaining; double get remainingAmount; NextNote? get next;
/// Create a copy of NotesSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotesSummaryCopyWith<NotesSummary> get copyWith => _$NotesSummaryCopyWithImpl<NotesSummary>(this as NotesSummary, _$identity);

  /// Serializes this NotesSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotesSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotesSummary&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.paid, _this.paid) || other.paid == _this.paid)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&(identical(other.remainingAmount, _this.remainingAmount) || other.remainingAmount == _this.remainingAmount)&&(identical(other.next, _this.next) || other.next == _this.next));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotesSummary;
  return Object.hash(runtimeType,_this.total,_this.paid,_this.remaining,_this.remainingAmount,_this.next);
}

@override
String toString() {
  final _this = this as NotesSummary;
  return 'NotesSummary(total: ${_this.total}, paid: ${_this.paid}, remaining: ${_this.remaining}, remainingAmount: ${_this.remainingAmount}, next: ${_this.next})';
}


}

/// @nodoc
abstract mixin class $NotesSummaryCopyWith<$Res>  {
  factory $NotesSummaryCopyWith(NotesSummary value, $Res Function(NotesSummary) _then) = _$NotesSummaryCopyWithImpl;
@useResult
$Res call({
 int total, int paid, int remaining, double remainingAmount, NextNote? next
});


$NextNoteCopyWith<$Res>? get next;

}
/// @nodoc
class _$NotesSummaryCopyWithImpl<$Res>
    implements $NotesSummaryCopyWith<$Res> {
  _$NotesSummaryCopyWithImpl(this._self, this._then);

  final NotesSummary _self;
  final $Res Function(NotesSummary) _then;

/// Create a copy of NotesSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? paid = null,Object? remaining = null,Object? remainingAmount = null,Object? next = freezed,}) {
  return _then(NotesSummary(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as double,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as NextNote?,
  ));
}
/// Create a copy of NotesSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NextNoteCopyWith<$Res>? get next {
    if (_self.next == null) {
    return null;
  }

  return $NextNoteCopyWith<$Res>(_self.next!, (value) {
    return _then(_self.copyWith(next: value));
  });
}
}


/// Adds pattern-matching-related methods to [NotesSummary].
extension NotesSummaryPatterns on NotesSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotesSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotesSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotesSummary value)  $default,){
final _that = this;
switch (_that) {
case _NotesSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotesSummary value)?  $default,){
final _that = this;
switch (_that) {
case _NotesSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int paid,  int remaining,  double remainingAmount,  NextNote? next)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotesSummary() when $default != null:
return $default(_that.total,_that.paid,_that.remaining,_that.remainingAmount,_that.next);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int paid,  int remaining,  double remainingAmount,  NextNote? next)  $default,) {final _that = this;
switch (_that) {
case _NotesSummary():
return $default(_that.total,_that.paid,_that.remaining,_that.remainingAmount,_that.next);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int paid,  int remaining,  double remainingAmount,  NextNote? next)?  $default,) {final _that = this;
switch (_that) {
case _NotesSummary() when $default != null:
return $default(_that.total,_that.paid,_that.remaining,_that.remainingAmount,_that.next);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotesSummary extends NotesSummary {
  const _NotesSummary({required this.total, required this.paid, required this.remaining, this.remainingAmount = 0, this.next}): super._();
  factory _NotesSummary.fromJson(Map<String, dynamic> json) => _$NotesSummaryFromJson(json);

@override final  int total;
@override final  int paid;
@override final  int remaining;
@override@JsonKey() final  double remainingAmount;
@override final  NextNote? next;

/// Create a copy of NotesSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotesSummaryCopyWith<_NotesSummary> get copyWith => __$NotesSummaryCopyWithImpl<_NotesSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotesSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotesSummary&&(identical(other.total, total) || other.total == total)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.next, next) || other.next == next));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,total,paid,remaining,remainingAmount,next);
}

@override
String toString() {
    return 'NotesSummary(total: $total, paid: $paid, remaining: $remaining, remainingAmount: $remainingAmount, next: $next)';
}


}

/// @nodoc
abstract mixin class _$NotesSummaryCopyWith<$Res> implements $NotesSummaryCopyWith<$Res> {
  factory _$NotesSummaryCopyWith(_NotesSummary value, $Res Function(_NotesSummary) _then) = __$NotesSummaryCopyWithImpl;
@override @useResult
$Res call({
 int total, int paid, int remaining, double remainingAmount, NextNote? next
});


@override $NextNoteCopyWith<$Res>? get next;

}
/// @nodoc
class __$NotesSummaryCopyWithImpl<$Res>
    implements _$NotesSummaryCopyWith<$Res> {
  __$NotesSummaryCopyWithImpl(this._self, this._then);

  final _NotesSummary _self;
  final $Res Function(_NotesSummary) _then;

/// Create a copy of NotesSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? paid = null,Object? remaining = null,Object? remainingAmount = null,Object? next = freezed,}) {
  return _then(_NotesSummary(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as double,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as NextNote?,
  ));
}

/// Create a copy of NotesSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NextNoteCopyWith<$Res>? get next {
    if (_self.next == null) {
    return null;
  }

  return $NextNoteCopyWith<$Res>(_self.next!, (value) {
    return _then(_self.copyWith(next: value));
  });
}
}


/// @nodoc
mixin _$NextNote {

 int get number;@LocalDate() DateTime get dueDate; double get amount;
/// Create a copy of NextNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NextNoteCopyWith<NextNote> get copyWith => _$NextNoteCopyWithImpl<NextNote>(this as NextNote, _$identity);

  /// Serializes this NextNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NextNote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NextNote&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.amount, _this.amount) || other.amount == _this.amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NextNote;
  return Object.hash(runtimeType,_this.number,_this.dueDate,_this.amount);
}

@override
String toString() {
  final _this = this as NextNote;
  return 'NextNote(number: ${_this.number}, dueDate: ${_this.dueDate}, amount: ${_this.amount})';
}


}

/// @nodoc
abstract mixin class $NextNoteCopyWith<$Res>  {
  factory $NextNoteCopyWith(NextNote value, $Res Function(NextNote) _then) = _$NextNoteCopyWithImpl;
@useResult
$Res call({
 int number,@LocalDate() DateTime dueDate, double amount
});




}
/// @nodoc
class _$NextNoteCopyWithImpl<$Res>
    implements $NextNoteCopyWith<$Res> {
  _$NextNoteCopyWithImpl(this._self, this._then);

  final NextNote _self;
  final $Res Function(NextNote) _then;

/// Create a copy of NextNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? dueDate = null,Object? amount = null,}) {
  return _then(NextNote(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [NextNote].
extension NextNotePatterns on NextNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NextNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NextNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NextNote value)  $default,){
final _that = this;
switch (_that) {
case _NextNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NextNote value)?  $default,){
final _that = this;
switch (_that) {
case _NextNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number, @LocalDate()  DateTime dueDate,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NextNote() when $default != null:
return $default(_that.number,_that.dueDate,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number, @LocalDate()  DateTime dueDate,  double amount)  $default,) {final _that = this;
switch (_that) {
case _NextNote():
return $default(_that.number,_that.dueDate,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number, @LocalDate()  DateTime dueDate,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _NextNote() when $default != null:
return $default(_that.number,_that.dueDate,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NextNote implements NextNote {
  const _NextNote({required this.number, @LocalDate() required this.dueDate, required this.amount});
  factory _NextNote.fromJson(Map<String, dynamic> json) => _$NextNoteFromJson(json);

@override final  int number;
@override@LocalDate() final  DateTime dueDate;
@override final  double amount;

/// Create a copy of NextNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NextNoteCopyWith<_NextNote> get copyWith => __$NextNoteCopyWithImpl<_NextNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NextNoteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NextNote&&(identical(other.number, number) || other.number == number)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,number,dueDate,amount);
}

@override
String toString() {
    return 'NextNote(number: $number, dueDate: $dueDate, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$NextNoteCopyWith<$Res> implements $NextNoteCopyWith<$Res> {
  factory _$NextNoteCopyWith(_NextNote value, $Res Function(_NextNote) _then) = __$NextNoteCopyWithImpl;
@override @useResult
$Res call({
 int number,@LocalDate() DateTime dueDate, double amount
});




}
/// @nodoc
class __$NextNoteCopyWithImpl<$Res>
    implements _$NextNoteCopyWith<$Res> {
  __$NextNoteCopyWithImpl(this._self, this._then);

  final _NextNote _self;
  final $Res Function(_NextNote) _then;

/// Create a copy of NextNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? dueDate = null,Object? amount = null,}) {
  return _then(_NextNote(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Receipt {

 String get id; String get kind; String get concept; String? get periodLabel; double get amount;@LocalDateOrNull() DateTime? get dueDate;@LocalDateOrNull() DateTime? get paidAt; String get status; String? get documentId;
/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptCopyWith<Receipt> get copyWith => _$ReceiptCopyWithImpl<Receipt>(this as Receipt, _$identity);

  /// Serializes this Receipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Receipt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Receipt&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.concept, _this.concept) || other.concept == _this.concept)&&(identical(other.periodLabel, _this.periodLabel) || other.periodLabel == _this.periodLabel)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.paidAt, _this.paidAt) || other.paidAt == _this.paidAt)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.documentId, _this.documentId) || other.documentId == _this.documentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Receipt;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.concept,_this.periodLabel,_this.amount,_this.dueDate,_this.paidAt,_this.status,_this.documentId);
}

@override
String toString() {
  final _this = this as Receipt;
  return 'Receipt(id: ${_this.id}, kind: ${_this.kind}, concept: ${_this.concept}, periodLabel: ${_this.periodLabel}, amount: ${_this.amount}, dueDate: ${_this.dueDate}, paidAt: ${_this.paidAt}, status: ${_this.status}, documentId: ${_this.documentId})';
}


}

/// @nodoc
abstract mixin class $ReceiptCopyWith<$Res>  {
  factory $ReceiptCopyWith(Receipt value, $Res Function(Receipt) _then) = _$ReceiptCopyWithImpl;
@useResult
$Res call({
 String id, String kind, String concept, String? periodLabel, double amount,@LocalDateOrNull() DateTime? dueDate,@LocalDateOrNull() DateTime? paidAt, String status, String? documentId
});




}
/// @nodoc
class _$ReceiptCopyWithImpl<$Res>
    implements $ReceiptCopyWith<$Res> {
  _$ReceiptCopyWithImpl(this._self, this._then);

  final Receipt _self;
  final $Res Function(Receipt) _then;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? concept = null,Object? periodLabel = freezed,Object? amount = null,Object? dueDate = freezed,Object? paidAt = freezed,Object? status = null,Object? documentId = freezed,}) {
  return _then(Receipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,concept: null == concept ? _self.concept : concept // ignore: cast_nullable_to_non_nullable
as String,periodLabel: freezed == periodLabel ? _self.periodLabel : periodLabel // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Receipt].
extension ReceiptPatterns on Receipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Receipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Receipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Receipt value)  $default,){
final _that = this;
switch (_that) {
case _Receipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Receipt value)?  $default,){
final _that = this;
switch (_that) {
case _Receipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind,  String concept,  String? periodLabel,  double amount, @LocalDateOrNull()  DateTime? dueDate, @LocalDateOrNull()  DateTime? paidAt,  String status,  String? documentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.kind,_that.concept,_that.periodLabel,_that.amount,_that.dueDate,_that.paidAt,_that.status,_that.documentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind,  String concept,  String? periodLabel,  double amount, @LocalDateOrNull()  DateTime? dueDate, @LocalDateOrNull()  DateTime? paidAt,  String status,  String? documentId)  $default,) {final _that = this;
switch (_that) {
case _Receipt():
return $default(_that.id,_that.kind,_that.concept,_that.periodLabel,_that.amount,_that.dueDate,_that.paidAt,_that.status,_that.documentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind,  String concept,  String? periodLabel,  double amount, @LocalDateOrNull()  DateTime? dueDate, @LocalDateOrNull()  DateTime? paidAt,  String status,  String? documentId)?  $default,) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.kind,_that.concept,_that.periodLabel,_that.amount,_that.dueDate,_that.paidAt,_that.status,_that.documentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Receipt implements Receipt {
  const _Receipt({required this.id, required this.kind, required this.concept, this.periodLabel, required this.amount, @LocalDateOrNull() this.dueDate, @LocalDateOrNull() this.paidAt, required this.status, this.documentId});
  factory _Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);

@override final  String id;
@override final  String kind;
@override final  String concept;
@override final  String? periodLabel;
@override final  double amount;
@override@LocalDateOrNull() final  DateTime? dueDate;
@override@LocalDateOrNull() final  DateTime? paidAt;
@override final  String status;
@override final  String? documentId;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptCopyWith<_Receipt> get copyWith => __$ReceiptCopyWithImpl<_Receipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Receipt&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.concept, concept) || other.concept == concept)&&(identical(other.periodLabel, periodLabel) || other.periodLabel == periodLabel)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.documentId, documentId) || other.documentId == documentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,concept,periodLabel,amount,dueDate,paidAt,status,documentId);
}

@override
String toString() {
    return 'Receipt(id: $id, kind: $kind, concept: $concept, periodLabel: $periodLabel, amount: $amount, dueDate: $dueDate, paidAt: $paidAt, status: $status, documentId: $documentId)';
}


}

/// @nodoc
abstract mixin class _$ReceiptCopyWith<$Res> implements $ReceiptCopyWith<$Res> {
  factory _$ReceiptCopyWith(_Receipt value, $Res Function(_Receipt) _then) = __$ReceiptCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind, String concept, String? periodLabel, double amount,@LocalDateOrNull() DateTime? dueDate,@LocalDateOrNull() DateTime? paidAt, String status, String? documentId
});




}
/// @nodoc
class __$ReceiptCopyWithImpl<$Res>
    implements _$ReceiptCopyWith<$Res> {
  __$ReceiptCopyWithImpl(this._self, this._then);

  final _Receipt _self;
  final $Res Function(_Receipt) _then;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? concept = null,Object? periodLabel = freezed,Object? amount = null,Object? dueDate = freezed,Object? paidAt = freezed,Object? status = null,Object? documentId = freezed,}) {
  return _then(_Receipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,concept: null == concept ? _self.concept : concept // ignore: cast_nullable_to_non_nullable
as String,periodLabel: freezed == periodLabel ? _self.periodLabel : periodLabel // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
