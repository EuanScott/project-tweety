// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_preferences.cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppPreferencesState {

 AppPreferencesStatus get status; AppPreferences? get appPreferences; String? get errorMessage;
/// Create a copy of AppPreferencesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppPreferencesStateCopyWith<AppPreferencesState> get copyWith => _$AppPreferencesStateCopyWithImpl<AppPreferencesState>(this as AppPreferencesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppPreferencesState&&(identical(other.status, status) || other.status == status)&&(identical(other.appPreferences, appPreferences) || other.appPreferences == appPreferences)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,appPreferences,errorMessage);

@override
String toString() {
  return 'AppPreferencesState(status: $status, appPreferences: $appPreferences, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AppPreferencesStateCopyWith<$Res>  {
  factory $AppPreferencesStateCopyWith(AppPreferencesState value, $Res Function(AppPreferencesState) _then) = _$AppPreferencesStateCopyWithImpl;
@useResult
$Res call({
 AppPreferencesStatus status, AppPreferences? appPreferences, String? errorMessage
});




}
/// @nodoc
class _$AppPreferencesStateCopyWithImpl<$Res>
    implements $AppPreferencesStateCopyWith<$Res> {
  _$AppPreferencesStateCopyWithImpl(this._self, this._then);

  final AppPreferencesState _self;
  final $Res Function(AppPreferencesState) _then;

/// Create a copy of AppPreferencesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? appPreferences = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppPreferencesStatus,appPreferences: freezed == appPreferences ? _self.appPreferences : appPreferences // ignore: cast_nullable_to_non_nullable
as AppPreferences?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppPreferencesState].
extension AppPreferencesStatePatterns on AppPreferencesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppPreferencesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppPreferencesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppPreferencesState value)  $default,){
final _that = this;
switch (_that) {
case _AppPreferencesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppPreferencesState value)?  $default,){
final _that = this;
switch (_that) {
case _AppPreferencesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppPreferencesStatus status,  AppPreferences? appPreferences,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppPreferencesState() when $default != null:
return $default(_that.status,_that.appPreferences,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppPreferencesStatus status,  AppPreferences? appPreferences,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AppPreferencesState():
return $default(_that.status,_that.appPreferences,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppPreferencesStatus status,  AppPreferences? appPreferences,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AppPreferencesState() when $default != null:
return $default(_that.status,_that.appPreferences,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _AppPreferencesState extends AppPreferencesState {
  const _AppPreferencesState({this.status = AppPreferencesStatus.initial, this.appPreferences, this.errorMessage}): super._();
  

@override@JsonKey() final  AppPreferencesStatus status;
@override final  AppPreferences? appPreferences;
@override final  String? errorMessage;

/// Create a copy of AppPreferencesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppPreferencesStateCopyWith<_AppPreferencesState> get copyWith => __$AppPreferencesStateCopyWithImpl<_AppPreferencesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppPreferencesState&&(identical(other.status, status) || other.status == status)&&(identical(other.appPreferences, appPreferences) || other.appPreferences == appPreferences)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,appPreferences,errorMessage);

@override
String toString() {
  return 'AppPreferencesState(status: $status, appPreferences: $appPreferences, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AppPreferencesStateCopyWith<$Res> implements $AppPreferencesStateCopyWith<$Res> {
  factory _$AppPreferencesStateCopyWith(_AppPreferencesState value, $Res Function(_AppPreferencesState) _then) = __$AppPreferencesStateCopyWithImpl;
@override @useResult
$Res call({
 AppPreferencesStatus status, AppPreferences? appPreferences, String? errorMessage
});




}
/// @nodoc
class __$AppPreferencesStateCopyWithImpl<$Res>
    implements _$AppPreferencesStateCopyWith<$Res> {
  __$AppPreferencesStateCopyWithImpl(this._self, this._then);

  final _AppPreferencesState _self;
  final $Res Function(_AppPreferencesState) _then;

/// Create a copy of AppPreferencesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? appPreferences = freezed,Object? errorMessage = freezed,}) {
  return _then(_AppPreferencesState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppPreferencesStatus,appPreferences: freezed == appPreferences ? _self.appPreferences : appPreferences // ignore: cast_nullable_to_non_nullable
as AppPreferences?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
