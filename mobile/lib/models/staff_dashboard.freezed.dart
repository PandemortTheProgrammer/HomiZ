// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StaffDashboard {

 List<String> get roles; StaffCounts get counts; List<PendingAppointment> get pendingAppointments; List<OverdueNote> get overdueNotes; List<NewReport> get newReports;
/// Create a copy of StaffDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffDashboardCopyWith<StaffDashboard> get copyWith => _$StaffDashboardCopyWithImpl<StaffDashboard>(this as StaffDashboard, _$identity);

  /// Serializes this StaffDashboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StaffDashboard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffDashboard&&const DeepCollectionEquality().equals(other.roles, _this.roles)&&(identical(other.counts, _this.counts) || other.counts == _this.counts)&&const DeepCollectionEquality().equals(other.pendingAppointments, _this.pendingAppointments)&&const DeepCollectionEquality().equals(other.overdueNotes, _this.overdueNotes)&&const DeepCollectionEquality().equals(other.newReports, _this.newReports));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StaffDashboard;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.roles),_this.counts,const DeepCollectionEquality().hash(_this.pendingAppointments),const DeepCollectionEquality().hash(_this.overdueNotes),const DeepCollectionEquality().hash(_this.newReports));
}

@override
String toString() {
  final _this = this as StaffDashboard;
  return 'StaffDashboard(roles: ${_this.roles}, counts: ${_this.counts}, pendingAppointments: ${_this.pendingAppointments}, overdueNotes: ${_this.overdueNotes}, newReports: ${_this.newReports})';
}


}

/// @nodoc
abstract mixin class $StaffDashboardCopyWith<$Res>  {
  factory $StaffDashboardCopyWith(StaffDashboard value, $Res Function(StaffDashboard) _then) = _$StaffDashboardCopyWithImpl;
@useResult
$Res call({
 List<String> roles, StaffCounts counts, List<PendingAppointment> pendingAppointments, List<OverdueNote> overdueNotes, List<NewReport> newReports
});


$StaffCountsCopyWith<$Res> get counts;

}
/// @nodoc
class _$StaffDashboardCopyWithImpl<$Res>
    implements $StaffDashboardCopyWith<$Res> {
  _$StaffDashboardCopyWithImpl(this._self, this._then);

  final StaffDashboard _self;
  final $Res Function(StaffDashboard) _then;

/// Create a copy of StaffDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roles = null,Object? counts = null,Object? pendingAppointments = null,Object? overdueNotes = null,Object? newReports = null,}) {
  return _then(StaffDashboard(
roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as StaffCounts,pendingAppointments: null == pendingAppointments ? _self.pendingAppointments : pendingAppointments // ignore: cast_nullable_to_non_nullable
as List<PendingAppointment>,overdueNotes: null == overdueNotes ? _self.overdueNotes : overdueNotes // ignore: cast_nullable_to_non_nullable
as List<OverdueNote>,newReports: null == newReports ? _self.newReports : newReports // ignore: cast_nullable_to_non_nullable
as List<NewReport>,
  ));
}
/// Create a copy of StaffDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffCountsCopyWith<$Res> get counts {
  
  return $StaffCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [StaffDashboard].
extension StaffDashboardPatterns on StaffDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffDashboard value)  $default,){
final _that = this;
switch (_that) {
case _StaffDashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _StaffDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> roles,  StaffCounts counts,  List<PendingAppointment> pendingAppointments,  List<OverdueNote> overdueNotes,  List<NewReport> newReports)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffDashboard() when $default != null:
return $default(_that.roles,_that.counts,_that.pendingAppointments,_that.overdueNotes,_that.newReports);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> roles,  StaffCounts counts,  List<PendingAppointment> pendingAppointments,  List<OverdueNote> overdueNotes,  List<NewReport> newReports)  $default,) {final _that = this;
switch (_that) {
case _StaffDashboard():
return $default(_that.roles,_that.counts,_that.pendingAppointments,_that.overdueNotes,_that.newReports);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> roles,  StaffCounts counts,  List<PendingAppointment> pendingAppointments,  List<OverdueNote> overdueNotes,  List<NewReport> newReports)?  $default,) {final _that = this;
switch (_that) {
case _StaffDashboard() when $default != null:
return $default(_that.roles,_that.counts,_that.pendingAppointments,_that.overdueNotes,_that.newReports);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffDashboard implements StaffDashboard {
  const _StaffDashboard({ List<String> roles = const <String>[], this.counts = const StaffCounts(),  List<PendingAppointment> pendingAppointments = const <PendingAppointment>[],  List<OverdueNote> overdueNotes = const <OverdueNote>[],  List<NewReport> newReports = const <NewReport>[]}): _roles = roles,_pendingAppointments = pendingAppointments,_overdueNotes = overdueNotes,_newReports = newReports;
  factory _StaffDashboard.fromJson(Map<String, dynamic> json) => _$StaffDashboardFromJson(json);

 final  List<String> _roles;
@override@JsonKey() List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override@JsonKey() final  StaffCounts counts;
 final  List<PendingAppointment> _pendingAppointments;
@override@JsonKey() List<PendingAppointment> get pendingAppointments {
  if (_pendingAppointments is EqualUnmodifiableListView) return _pendingAppointments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingAppointments);
}

 final  List<OverdueNote> _overdueNotes;
@override@JsonKey() List<OverdueNote> get overdueNotes {
  if (_overdueNotes is EqualUnmodifiableListView) return _overdueNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_overdueNotes);
}

 final  List<NewReport> _newReports;
@override@JsonKey() List<NewReport> get newReports {
  if (_newReports is EqualUnmodifiableListView) return _newReports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_newReports);
}


/// Create a copy of StaffDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffDashboardCopyWith<_StaffDashboard> get copyWith => __$StaffDashboardCopyWithImpl<_StaffDashboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffDashboardToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffDashboard&&const DeepCollectionEquality().equals(other.roles, _roles)&&(identical(other.counts, counts) || other.counts == counts)&&const DeepCollectionEquality().equals(other.pendingAppointments, _pendingAppointments)&&const DeepCollectionEquality().equals(other.overdueNotes, _overdueNotes)&&const DeepCollectionEquality().equals(other.newReports, _newReports));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_roles),counts,const DeepCollectionEquality().hash(_pendingAppointments),const DeepCollectionEquality().hash(_overdueNotes),const DeepCollectionEquality().hash(_newReports));
}

@override
String toString() {
    return 'StaffDashboard(roles: $roles, counts: $counts, pendingAppointments: $pendingAppointments, overdueNotes: $overdueNotes, newReports: $newReports)';
}


}

/// @nodoc
abstract mixin class _$StaffDashboardCopyWith<$Res> implements $StaffDashboardCopyWith<$Res> {
  factory _$StaffDashboardCopyWith(_StaffDashboard value, $Res Function(_StaffDashboard) _then) = __$StaffDashboardCopyWithImpl;
@override @useResult
$Res call({
 List<String> roles, StaffCounts counts, List<PendingAppointment> pendingAppointments, List<OverdueNote> overdueNotes, List<NewReport> newReports
});


@override $StaffCountsCopyWith<$Res> get counts;

}
/// @nodoc
class __$StaffDashboardCopyWithImpl<$Res>
    implements _$StaffDashboardCopyWith<$Res> {
  __$StaffDashboardCopyWithImpl(this._self, this._then);

  final _StaffDashboard _self;
  final $Res Function(_StaffDashboard) _then;

/// Create a copy of StaffDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roles = null,Object? counts = null,Object? pendingAppointments = null,Object? overdueNotes = null,Object? newReports = null,}) {
  return _then(_StaffDashboard(
roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as StaffCounts,pendingAppointments: null == pendingAppointments ? _self._pendingAppointments : pendingAppointments // ignore: cast_nullable_to_non_nullable
as List<PendingAppointment>,overdueNotes: null == overdueNotes ? _self._overdueNotes : overdueNotes // ignore: cast_nullable_to_non_nullable
as List<OverdueNote>,newReports: null == newReports ? _self._newReports : newReports // ignore: cast_nullable_to_non_nullable
as List<NewReport>,
  ));
}

/// Create a copy of StaffDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffCountsCopyWith<$Res> get counts {
  
  return $StaffCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// @nodoc
mixin _$StaffCounts {

 int get appointmentsToConfirm; int get appointmentsToday; int get overdueNotes; int get upcomingNotes; int get newReports; int get openReports; int get overdueReceipts; int get pendingExpenses; int get upcomingMaintenance; int get newLeads;
/// Create a copy of StaffCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffCountsCopyWith<StaffCounts> get copyWith => _$StaffCountsCopyWithImpl<StaffCounts>(this as StaffCounts, _$identity);

  /// Serializes this StaffCounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StaffCounts;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffCounts&&(identical(other.appointmentsToConfirm, _this.appointmentsToConfirm) || other.appointmentsToConfirm == _this.appointmentsToConfirm)&&(identical(other.appointmentsToday, _this.appointmentsToday) || other.appointmentsToday == _this.appointmentsToday)&&(identical(other.overdueNotes, _this.overdueNotes) || other.overdueNotes == _this.overdueNotes)&&(identical(other.upcomingNotes, _this.upcomingNotes) || other.upcomingNotes == _this.upcomingNotes)&&(identical(other.newReports, _this.newReports) || other.newReports == _this.newReports)&&(identical(other.openReports, _this.openReports) || other.openReports == _this.openReports)&&(identical(other.overdueReceipts, _this.overdueReceipts) || other.overdueReceipts == _this.overdueReceipts)&&(identical(other.pendingExpenses, _this.pendingExpenses) || other.pendingExpenses == _this.pendingExpenses)&&(identical(other.upcomingMaintenance, _this.upcomingMaintenance) || other.upcomingMaintenance == _this.upcomingMaintenance)&&(identical(other.newLeads, _this.newLeads) || other.newLeads == _this.newLeads));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StaffCounts;
  return Object.hash(runtimeType,_this.appointmentsToConfirm,_this.appointmentsToday,_this.overdueNotes,_this.upcomingNotes,_this.newReports,_this.openReports,_this.overdueReceipts,_this.pendingExpenses,_this.upcomingMaintenance,_this.newLeads);
}

@override
String toString() {
  final _this = this as StaffCounts;
  return 'StaffCounts(appointmentsToConfirm: ${_this.appointmentsToConfirm}, appointmentsToday: ${_this.appointmentsToday}, overdueNotes: ${_this.overdueNotes}, upcomingNotes: ${_this.upcomingNotes}, newReports: ${_this.newReports}, openReports: ${_this.openReports}, overdueReceipts: ${_this.overdueReceipts}, pendingExpenses: ${_this.pendingExpenses}, upcomingMaintenance: ${_this.upcomingMaintenance}, newLeads: ${_this.newLeads})';
}


}

/// @nodoc
abstract mixin class $StaffCountsCopyWith<$Res>  {
  factory $StaffCountsCopyWith(StaffCounts value, $Res Function(StaffCounts) _then) = _$StaffCountsCopyWithImpl;
@useResult
$Res call({
 int appointmentsToConfirm, int appointmentsToday, int overdueNotes, int upcomingNotes, int newReports, int openReports, int overdueReceipts, int pendingExpenses, int upcomingMaintenance, int newLeads
});




}
/// @nodoc
class _$StaffCountsCopyWithImpl<$Res>
    implements $StaffCountsCopyWith<$Res> {
  _$StaffCountsCopyWithImpl(this._self, this._then);

  final StaffCounts _self;
  final $Res Function(StaffCounts) _then;

/// Create a copy of StaffCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appointmentsToConfirm = null,Object? appointmentsToday = null,Object? overdueNotes = null,Object? upcomingNotes = null,Object? newReports = null,Object? openReports = null,Object? overdueReceipts = null,Object? pendingExpenses = null,Object? upcomingMaintenance = null,Object? newLeads = null,}) {
  return _then(StaffCounts(
appointmentsToConfirm: null == appointmentsToConfirm ? _self.appointmentsToConfirm : appointmentsToConfirm // ignore: cast_nullable_to_non_nullable
as int,appointmentsToday: null == appointmentsToday ? _self.appointmentsToday : appointmentsToday // ignore: cast_nullable_to_non_nullable
as int,overdueNotes: null == overdueNotes ? _self.overdueNotes : overdueNotes // ignore: cast_nullable_to_non_nullable
as int,upcomingNotes: null == upcomingNotes ? _self.upcomingNotes : upcomingNotes // ignore: cast_nullable_to_non_nullable
as int,newReports: null == newReports ? _self.newReports : newReports // ignore: cast_nullable_to_non_nullable
as int,openReports: null == openReports ? _self.openReports : openReports // ignore: cast_nullable_to_non_nullable
as int,overdueReceipts: null == overdueReceipts ? _self.overdueReceipts : overdueReceipts // ignore: cast_nullable_to_non_nullable
as int,pendingExpenses: null == pendingExpenses ? _self.pendingExpenses : pendingExpenses // ignore: cast_nullable_to_non_nullable
as int,upcomingMaintenance: null == upcomingMaintenance ? _self.upcomingMaintenance : upcomingMaintenance // ignore: cast_nullable_to_non_nullable
as int,newLeads: null == newLeads ? _self.newLeads : newLeads // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffCounts].
extension StaffCountsPatterns on StaffCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffCounts value)  $default,){
final _that = this;
switch (_that) {
case _StaffCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffCounts value)?  $default,){
final _that = this;
switch (_that) {
case _StaffCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int appointmentsToConfirm,  int appointmentsToday,  int overdueNotes,  int upcomingNotes,  int newReports,  int openReports,  int overdueReceipts,  int pendingExpenses,  int upcomingMaintenance,  int newLeads)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffCounts() when $default != null:
return $default(_that.appointmentsToConfirm,_that.appointmentsToday,_that.overdueNotes,_that.upcomingNotes,_that.newReports,_that.openReports,_that.overdueReceipts,_that.pendingExpenses,_that.upcomingMaintenance,_that.newLeads);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int appointmentsToConfirm,  int appointmentsToday,  int overdueNotes,  int upcomingNotes,  int newReports,  int openReports,  int overdueReceipts,  int pendingExpenses,  int upcomingMaintenance,  int newLeads)  $default,) {final _that = this;
switch (_that) {
case _StaffCounts():
return $default(_that.appointmentsToConfirm,_that.appointmentsToday,_that.overdueNotes,_that.upcomingNotes,_that.newReports,_that.openReports,_that.overdueReceipts,_that.pendingExpenses,_that.upcomingMaintenance,_that.newLeads);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int appointmentsToConfirm,  int appointmentsToday,  int overdueNotes,  int upcomingNotes,  int newReports,  int openReports,  int overdueReceipts,  int pendingExpenses,  int upcomingMaintenance,  int newLeads)?  $default,) {final _that = this;
switch (_that) {
case _StaffCounts() when $default != null:
return $default(_that.appointmentsToConfirm,_that.appointmentsToday,_that.overdueNotes,_that.upcomingNotes,_that.newReports,_that.openReports,_that.overdueReceipts,_that.pendingExpenses,_that.upcomingMaintenance,_that.newLeads);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffCounts implements StaffCounts {
  const _StaffCounts({this.appointmentsToConfirm = 0, this.appointmentsToday = 0, this.overdueNotes = 0, this.upcomingNotes = 0, this.newReports = 0, this.openReports = 0, this.overdueReceipts = 0, this.pendingExpenses = 0, this.upcomingMaintenance = 0, this.newLeads = 0});
  factory _StaffCounts.fromJson(Map<String, dynamic> json) => _$StaffCountsFromJson(json);

@override@JsonKey() final  int appointmentsToConfirm;
@override@JsonKey() final  int appointmentsToday;
@override@JsonKey() final  int overdueNotes;
@override@JsonKey() final  int upcomingNotes;
@override@JsonKey() final  int newReports;
@override@JsonKey() final  int openReports;
@override@JsonKey() final  int overdueReceipts;
@override@JsonKey() final  int pendingExpenses;
@override@JsonKey() final  int upcomingMaintenance;
@override@JsonKey() final  int newLeads;

/// Create a copy of StaffCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffCountsCopyWith<_StaffCounts> get copyWith => __$StaffCountsCopyWithImpl<_StaffCounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffCountsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffCounts&&(identical(other.appointmentsToConfirm, appointmentsToConfirm) || other.appointmentsToConfirm == appointmentsToConfirm)&&(identical(other.appointmentsToday, appointmentsToday) || other.appointmentsToday == appointmentsToday)&&(identical(other.overdueNotes, overdueNotes) || other.overdueNotes == overdueNotes)&&(identical(other.upcomingNotes, upcomingNotes) || other.upcomingNotes == upcomingNotes)&&(identical(other.newReports, newReports) || other.newReports == newReports)&&(identical(other.openReports, openReports) || other.openReports == openReports)&&(identical(other.overdueReceipts, overdueReceipts) || other.overdueReceipts == overdueReceipts)&&(identical(other.pendingExpenses, pendingExpenses) || other.pendingExpenses == pendingExpenses)&&(identical(other.upcomingMaintenance, upcomingMaintenance) || other.upcomingMaintenance == upcomingMaintenance)&&(identical(other.newLeads, newLeads) || other.newLeads == newLeads));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,appointmentsToConfirm,appointmentsToday,overdueNotes,upcomingNotes,newReports,openReports,overdueReceipts,pendingExpenses,upcomingMaintenance,newLeads);
}

@override
String toString() {
    return 'StaffCounts(appointmentsToConfirm: $appointmentsToConfirm, appointmentsToday: $appointmentsToday, overdueNotes: $overdueNotes, upcomingNotes: $upcomingNotes, newReports: $newReports, openReports: $openReports, overdueReceipts: $overdueReceipts, pendingExpenses: $pendingExpenses, upcomingMaintenance: $upcomingMaintenance, newLeads: $newLeads)';
}


}

/// @nodoc
abstract mixin class _$StaffCountsCopyWith<$Res> implements $StaffCountsCopyWith<$Res> {
  factory _$StaffCountsCopyWith(_StaffCounts value, $Res Function(_StaffCounts) _then) = __$StaffCountsCopyWithImpl;
@override @useResult
$Res call({
 int appointmentsToConfirm, int appointmentsToday, int overdueNotes, int upcomingNotes, int newReports, int openReports, int overdueReceipts, int pendingExpenses, int upcomingMaintenance, int newLeads
});




}
/// @nodoc
class __$StaffCountsCopyWithImpl<$Res>
    implements _$StaffCountsCopyWith<$Res> {
  __$StaffCountsCopyWithImpl(this._self, this._then);

  final _StaffCounts _self;
  final $Res Function(_StaffCounts) _then;

/// Create a copy of StaffCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appointmentsToConfirm = null,Object? appointmentsToday = null,Object? overdueNotes = null,Object? upcomingNotes = null,Object? newReports = null,Object? openReports = null,Object? overdueReceipts = null,Object? pendingExpenses = null,Object? upcomingMaintenance = null,Object? newLeads = null,}) {
  return _then(_StaffCounts(
appointmentsToConfirm: null == appointmentsToConfirm ? _self.appointmentsToConfirm : appointmentsToConfirm // ignore: cast_nullable_to_non_nullable
as int,appointmentsToday: null == appointmentsToday ? _self.appointmentsToday : appointmentsToday // ignore: cast_nullable_to_non_nullable
as int,overdueNotes: null == overdueNotes ? _self.overdueNotes : overdueNotes // ignore: cast_nullable_to_non_nullable
as int,upcomingNotes: null == upcomingNotes ? _self.upcomingNotes : upcomingNotes // ignore: cast_nullable_to_non_nullable
as int,newReports: null == newReports ? _self.newReports : newReports // ignore: cast_nullable_to_non_nullable
as int,openReports: null == openReports ? _self.openReports : openReports // ignore: cast_nullable_to_non_nullable
as int,overdueReceipts: null == overdueReceipts ? _self.overdueReceipts : overdueReceipts // ignore: cast_nullable_to_non_nullable
as int,pendingExpenses: null == pendingExpenses ? _self.pendingExpenses : pendingExpenses // ignore: cast_nullable_to_non_nullable
as int,upcomingMaintenance: null == upcomingMaintenance ? _self.upcomingMaintenance : upcomingMaintenance // ignore: cast_nullable_to_non_nullable
as int,newLeads: null == newLeads ? _self.newLeads : newLeads // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PendingAppointment {

 String get id; String get code; String get clientName; String get propertyName;@LocalDate() DateTime get scheduledAt;
/// Create a copy of PendingAppointment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingAppointmentCopyWith<PendingAppointment> get copyWith => _$PendingAppointmentCopyWithImpl<PendingAppointment>(this as PendingAppointment, _$identity);

  /// Serializes this PendingAppointment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PendingAppointment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingAppointment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.clientName, _this.clientName) || other.clientName == _this.clientName)&&(identical(other.propertyName, _this.propertyName) || other.propertyName == _this.propertyName)&&(identical(other.scheduledAt, _this.scheduledAt) || other.scheduledAt == _this.scheduledAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PendingAppointment;
  return Object.hash(runtimeType,_this.id,_this.code,_this.clientName,_this.propertyName,_this.scheduledAt);
}

@override
String toString() {
  final _this = this as PendingAppointment;
  return 'PendingAppointment(id: ${_this.id}, code: ${_this.code}, clientName: ${_this.clientName}, propertyName: ${_this.propertyName}, scheduledAt: ${_this.scheduledAt})';
}


}

/// @nodoc
abstract mixin class $PendingAppointmentCopyWith<$Res>  {
  factory $PendingAppointmentCopyWith(PendingAppointment value, $Res Function(PendingAppointment) _then) = _$PendingAppointmentCopyWithImpl;
@useResult
$Res call({
 String id, String code, String clientName, String propertyName,@LocalDate() DateTime scheduledAt
});




}
/// @nodoc
class _$PendingAppointmentCopyWithImpl<$Res>
    implements $PendingAppointmentCopyWith<$Res> {
  _$PendingAppointmentCopyWithImpl(this._self, this._then);

  final PendingAppointment _self;
  final $Res Function(PendingAppointment) _then;

/// Create a copy of PendingAppointment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? clientName = null,Object? propertyName = null,Object? scheduledAt = null,}) {
  return _then(PendingAppointment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingAppointment].
extension PendingAppointmentPatterns on PendingAppointment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingAppointment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingAppointment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingAppointment value)  $default,){
final _that = this;
switch (_that) {
case _PendingAppointment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingAppointment value)?  $default,){
final _that = this;
switch (_that) {
case _PendingAppointment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String clientName,  String propertyName, @LocalDate()  DateTime scheduledAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingAppointment() when $default != null:
return $default(_that.id,_that.code,_that.clientName,_that.propertyName,_that.scheduledAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String clientName,  String propertyName, @LocalDate()  DateTime scheduledAt)  $default,) {final _that = this;
switch (_that) {
case _PendingAppointment():
return $default(_that.id,_that.code,_that.clientName,_that.propertyName,_that.scheduledAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String clientName,  String propertyName, @LocalDate()  DateTime scheduledAt)?  $default,) {final _that = this;
switch (_that) {
case _PendingAppointment() when $default != null:
return $default(_that.id,_that.code,_that.clientName,_that.propertyName,_that.scheduledAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingAppointment implements PendingAppointment {
  const _PendingAppointment({required this.id, required this.code, required this.clientName, required this.propertyName, @LocalDate() required this.scheduledAt});
  factory _PendingAppointment.fromJson(Map<String, dynamic> json) => _$PendingAppointmentFromJson(json);

@override final  String id;
@override final  String code;
@override final  String clientName;
@override final  String propertyName;
@override@LocalDate() final  DateTime scheduledAt;

/// Create a copy of PendingAppointment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingAppointmentCopyWith<_PendingAppointment> get copyWith => __$PendingAppointmentCopyWithImpl<_PendingAppointment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingAppointmentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingAppointment&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,clientName,propertyName,scheduledAt);
}

@override
String toString() {
    return 'PendingAppointment(id: $id, code: $code, clientName: $clientName, propertyName: $propertyName, scheduledAt: $scheduledAt)';
}


}

/// @nodoc
abstract mixin class _$PendingAppointmentCopyWith<$Res> implements $PendingAppointmentCopyWith<$Res> {
  factory _$PendingAppointmentCopyWith(_PendingAppointment value, $Res Function(_PendingAppointment) _then) = __$PendingAppointmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String clientName, String propertyName,@LocalDate() DateTime scheduledAt
});




}
/// @nodoc
class __$PendingAppointmentCopyWithImpl<$Res>
    implements _$PendingAppointmentCopyWith<$Res> {
  __$PendingAppointmentCopyWithImpl(this._self, this._then);

  final _PendingAppointment _self;
  final $Res Function(_PendingAppointment) _then;

/// Create a copy of PendingAppointment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? clientName = null,Object? propertyName = null,Object? scheduledAt = null,}) {
  return _then(_PendingAppointment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$OverdueNote {

 String get id; int get number; double get amount;@LocalDate() DateTime get dueDate; String get clientName; String get propertyName; String? get propertyId;
/// Create a copy of OverdueNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverdueNoteCopyWith<OverdueNote> get copyWith => _$OverdueNoteCopyWithImpl<OverdueNote>(this as OverdueNote, _$identity);

  /// Serializes this OverdueNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OverdueNote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OverdueNote&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.clientName, _this.clientName) || other.clientName == _this.clientName)&&(identical(other.propertyName, _this.propertyName) || other.propertyName == _this.propertyName)&&(identical(other.propertyId, _this.propertyId) || other.propertyId == _this.propertyId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OverdueNote;
  return Object.hash(runtimeType,_this.id,_this.number,_this.amount,_this.dueDate,_this.clientName,_this.propertyName,_this.propertyId);
}

@override
String toString() {
  final _this = this as OverdueNote;
  return 'OverdueNote(id: ${_this.id}, number: ${_this.number}, amount: ${_this.amount}, dueDate: ${_this.dueDate}, clientName: ${_this.clientName}, propertyName: ${_this.propertyName}, propertyId: ${_this.propertyId})';
}


}

/// @nodoc
abstract mixin class $OverdueNoteCopyWith<$Res>  {
  factory $OverdueNoteCopyWith(OverdueNote value, $Res Function(OverdueNote) _then) = _$OverdueNoteCopyWithImpl;
@useResult
$Res call({
 String id, int number, double amount,@LocalDate() DateTime dueDate, String clientName, String propertyName, String? propertyId
});




}
/// @nodoc
class _$OverdueNoteCopyWithImpl<$Res>
    implements $OverdueNoteCopyWith<$Res> {
  _$OverdueNoteCopyWithImpl(this._self, this._then);

  final OverdueNote _self;
  final $Res Function(OverdueNote) _then;

/// Create a copy of OverdueNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? amount = null,Object? dueDate = null,Object? clientName = null,Object? propertyName = null,Object? propertyId = freezed,}) {
  return _then(OverdueNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,propertyId: freezed == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OverdueNote].
extension OverdueNotePatterns on OverdueNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OverdueNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OverdueNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OverdueNote value)  $default,){
final _that = this;
switch (_that) {
case _OverdueNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OverdueNote value)?  $default,){
final _that = this;
switch (_that) {
case _OverdueNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  double amount, @LocalDate()  DateTime dueDate,  String clientName,  String propertyName,  String? propertyId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OverdueNote() when $default != null:
return $default(_that.id,_that.number,_that.amount,_that.dueDate,_that.clientName,_that.propertyName,_that.propertyId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  double amount, @LocalDate()  DateTime dueDate,  String clientName,  String propertyName,  String? propertyId)  $default,) {final _that = this;
switch (_that) {
case _OverdueNote():
return $default(_that.id,_that.number,_that.amount,_that.dueDate,_that.clientName,_that.propertyName,_that.propertyId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  double amount, @LocalDate()  DateTime dueDate,  String clientName,  String propertyName,  String? propertyId)?  $default,) {final _that = this;
switch (_that) {
case _OverdueNote() when $default != null:
return $default(_that.id,_that.number,_that.amount,_that.dueDate,_that.clientName,_that.propertyName,_that.propertyId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OverdueNote implements OverdueNote {
  const _OverdueNote({required this.id, required this.number, required this.amount, @LocalDate() required this.dueDate, required this.clientName, required this.propertyName, this.propertyId});
  factory _OverdueNote.fromJson(Map<String, dynamic> json) => _$OverdueNoteFromJson(json);

@override final  String id;
@override final  int number;
@override final  double amount;
@override@LocalDate() final  DateTime dueDate;
@override final  String clientName;
@override final  String propertyName;
@override final  String? propertyId;

/// Create a copy of OverdueNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OverdueNoteCopyWith<_OverdueNote> get copyWith => __$OverdueNoteCopyWithImpl<_OverdueNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OverdueNoteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OverdueNote&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,number,amount,dueDate,clientName,propertyName,propertyId);
}

@override
String toString() {
    return 'OverdueNote(id: $id, number: $number, amount: $amount, dueDate: $dueDate, clientName: $clientName, propertyName: $propertyName, propertyId: $propertyId)';
}


}

/// @nodoc
abstract mixin class _$OverdueNoteCopyWith<$Res> implements $OverdueNoteCopyWith<$Res> {
  factory _$OverdueNoteCopyWith(_OverdueNote value, $Res Function(_OverdueNote) _then) = __$OverdueNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, double amount,@LocalDate() DateTime dueDate, String clientName, String propertyName, String? propertyId
});




}
/// @nodoc
class __$OverdueNoteCopyWithImpl<$Res>
    implements _$OverdueNoteCopyWith<$Res> {
  __$OverdueNoteCopyWithImpl(this._self, this._then);

  final _OverdueNote _self;
  final $Res Function(_OverdueNote) _then;

/// Create a copy of OverdueNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? amount = null,Object? dueDate = null,Object? clientName = null,Object? propertyName = null,Object? propertyId = freezed,}) {
  return _then(_OverdueNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,propertyId: freezed == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$NewReport {

 String get id; String get title; String get priority; String get status; String get propertyName; String? get propertyId;@LocalDate() DateTime get createdAt;
/// Create a copy of NewReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewReportCopyWith<NewReport> get copyWith => _$NewReportCopyWithImpl<NewReport>(this as NewReport, _$identity);

  /// Serializes this NewReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NewReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewReport&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.propertyName, _this.propertyName) || other.propertyName == _this.propertyName)&&(identical(other.propertyId, _this.propertyId) || other.propertyId == _this.propertyId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NewReport;
  return Object.hash(runtimeType,_this.id,_this.title,_this.priority,_this.status,_this.propertyName,_this.propertyId,_this.createdAt);
}

@override
String toString() {
  final _this = this as NewReport;
  return 'NewReport(id: ${_this.id}, title: ${_this.title}, priority: ${_this.priority}, status: ${_this.status}, propertyName: ${_this.propertyName}, propertyId: ${_this.propertyId}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $NewReportCopyWith<$Res>  {
  factory $NewReportCopyWith(NewReport value, $Res Function(NewReport) _then) = _$NewReportCopyWithImpl;
@useResult
$Res call({
 String id, String title, String priority, String status, String propertyName, String? propertyId,@LocalDate() DateTime createdAt
});




}
/// @nodoc
class _$NewReportCopyWithImpl<$Res>
    implements $NewReportCopyWith<$Res> {
  _$NewReportCopyWithImpl(this._self, this._then);

  final NewReport _self;
  final $Res Function(NewReport) _then;

/// Create a copy of NewReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? priority = null,Object? status = null,Object? propertyName = null,Object? propertyId = freezed,Object? createdAt = null,}) {
  return _then(NewReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,propertyId: freezed == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NewReport].
extension NewReportPatterns on NewReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewReport value)  $default,){
final _that = this;
switch (_that) {
case _NewReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewReport value)?  $default,){
final _that = this;
switch (_that) {
case _NewReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String priority,  String status,  String propertyName,  String? propertyId, @LocalDate()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewReport() when $default != null:
return $default(_that.id,_that.title,_that.priority,_that.status,_that.propertyName,_that.propertyId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String priority,  String status,  String propertyName,  String? propertyId, @LocalDate()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _NewReport():
return $default(_that.id,_that.title,_that.priority,_that.status,_that.propertyName,_that.propertyId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String priority,  String status,  String propertyName,  String? propertyId, @LocalDate()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _NewReport() when $default != null:
return $default(_that.id,_that.title,_that.priority,_that.status,_that.propertyName,_that.propertyId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NewReport implements NewReport {
  const _NewReport({required this.id, required this.title, required this.priority, required this.status, required this.propertyName, this.propertyId, @LocalDate() required this.createdAt});
  factory _NewReport.fromJson(Map<String, dynamic> json) => _$NewReportFromJson(json);

@override final  String id;
@override final  String title;
@override final  String priority;
@override final  String status;
@override final  String propertyName;
@override final  String? propertyId;
@override@LocalDate() final  DateTime createdAt;

/// Create a copy of NewReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewReportCopyWith<_NewReport> get copyWith => __$NewReportCopyWithImpl<_NewReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NewReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewReport&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,priority,status,propertyName,propertyId,createdAt);
}

@override
String toString() {
    return 'NewReport(id: $id, title: $title, priority: $priority, status: $status, propertyName: $propertyName, propertyId: $propertyId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NewReportCopyWith<$Res> implements $NewReportCopyWith<$Res> {
  factory _$NewReportCopyWith(_NewReport value, $Res Function(_NewReport) _then) = __$NewReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String priority, String status, String propertyName, String? propertyId,@LocalDate() DateTime createdAt
});




}
/// @nodoc
class __$NewReportCopyWithImpl<$Res>
    implements _$NewReportCopyWith<$Res> {
  __$NewReportCopyWithImpl(this._self, this._then);

  final _NewReport _self;
  final $Res Function(_NewReport) _then;

/// Create a copy of NewReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? priority = null,Object? status = null,Object? propertyName = null,Object? propertyId = freezed,Object? createdAt = null,}) {
  return _then(_NewReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,propertyId: freezed == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
