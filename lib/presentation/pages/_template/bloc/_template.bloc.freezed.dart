// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '_template.bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TemplateState {

 TemplateStatus get status; String? get errorMessage;
/// Create a copy of TemplateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateStateCopyWith<TemplateState> get copyWith => _$TemplateStateCopyWithImpl<TemplateState>(this as TemplateState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage);

@override
String toString() {
  return 'TemplateState(status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $TemplateStateCopyWith<$Res>  {
  factory $TemplateStateCopyWith(TemplateState value, $Res Function(TemplateState) _then) = _$TemplateStateCopyWithImpl;
@useResult
$Res call({
 TemplateStatus status, String? errorMessage
});




}
/// @nodoc
class _$TemplateStateCopyWithImpl<$Res>
    implements $TemplateStateCopyWith<$Res> {
  _$TemplateStateCopyWithImpl(this._self, this._then);

  final TemplateState _self;
  final $Res Function(TemplateState) _then;

/// Create a copy of TemplateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TemplateStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateState].
extension TemplateStatePatterns on TemplateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateState value)  $default,){
final _that = this;
switch (_that) {
case _TemplateState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateState value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TemplateStatus status,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateState() when $default != null:
return $default(_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TemplateStatus status,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _TemplateState():
return $default(_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TemplateStatus status,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _TemplateState() when $default != null:
return $default(_that.status,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _TemplateState extends TemplateState {
  const _TemplateState({this.status = TemplateStatus.initial, this.errorMessage}): super._();
  

@override@JsonKey() final  TemplateStatus status;
@override final  String? errorMessage;

/// Create a copy of TemplateState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateStateCopyWith<_TemplateState> get copyWith => __$TemplateStateCopyWithImpl<_TemplateState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage);

@override
String toString() {
  return 'TemplateState(status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$TemplateStateCopyWith<$Res> implements $TemplateStateCopyWith<$Res> {
  factory _$TemplateStateCopyWith(_TemplateState value, $Res Function(_TemplateState) _then) = __$TemplateStateCopyWithImpl;
@override @useResult
$Res call({
 TemplateStatus status, String? errorMessage
});




}
/// @nodoc
class __$TemplateStateCopyWithImpl<$Res>
    implements _$TemplateStateCopyWith<$Res> {
  __$TemplateStateCopyWithImpl(this._self, this._then);

  final _TemplateState _self;
  final $Res Function(_TemplateState) _then;

/// Create a copy of TemplateState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_TemplateState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TemplateStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
