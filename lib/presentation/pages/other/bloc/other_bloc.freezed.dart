// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'other_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OtherState {

 OtherStatus get status; List<OtherCardItem> get items; String? get errorMessage;
/// Create a copy of OtherState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtherStateCopyWith<OtherState> get copyWith => _$OtherStateCopyWithImpl<OtherState>(this as OtherState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtherState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(items),errorMessage);

@override
String toString() {
  return 'OtherState(status: $status, items: $items, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $OtherStateCopyWith<$Res>  {
  factory $OtherStateCopyWith(OtherState value, $Res Function(OtherState) _then) = _$OtherStateCopyWithImpl;
@useResult
$Res call({
 OtherStatus status, List<OtherCardItem> items, String? errorMessage
});




}
/// @nodoc
class _$OtherStateCopyWithImpl<$Res>
    implements $OtherStateCopyWith<$Res> {
  _$OtherStateCopyWithImpl(this._self, this._then);

  final OtherState _self;
  final $Res Function(OtherState) _then;

/// Create a copy of OtherState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? items = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OtherStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OtherCardItem>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OtherState].
extension OtherStatePatterns on OtherState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtherState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtherState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtherState value)  $default,){
final _that = this;
switch (_that) {
case _OtherState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtherState value)?  $default,){
final _that = this;
switch (_that) {
case _OtherState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OtherStatus status,  List<OtherCardItem> items,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtherState() when $default != null:
return $default(_that.status,_that.items,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OtherStatus status,  List<OtherCardItem> items,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _OtherState():
return $default(_that.status,_that.items,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OtherStatus status,  List<OtherCardItem> items,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _OtherState() when $default != null:
return $default(_that.status,_that.items,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _OtherState implements OtherState {
  const _OtherState({this.status = OtherStatus.initial, final  List<OtherCardItem> items = const <OtherCardItem>[], this.errorMessage}): _items = items;
  

@override@JsonKey() final  OtherStatus status;
 final  List<OtherCardItem> _items;
@override@JsonKey() List<OtherCardItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? errorMessage;

/// Create a copy of OtherState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtherStateCopyWith<_OtherState> get copyWith => __$OtherStateCopyWithImpl<_OtherState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtherState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_items),errorMessage);

@override
String toString() {
  return 'OtherState(status: $status, items: $items, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$OtherStateCopyWith<$Res> implements $OtherStateCopyWith<$Res> {
  factory _$OtherStateCopyWith(_OtherState value, $Res Function(_OtherState) _then) = __$OtherStateCopyWithImpl;
@override @useResult
$Res call({
 OtherStatus status, List<OtherCardItem> items, String? errorMessage
});




}
/// @nodoc
class __$OtherStateCopyWithImpl<$Res>
    implements _$OtherStateCopyWith<$Res> {
  __$OtherStateCopyWithImpl(this._self, this._then);

  final _OtherState _self;
  final $Res Function(_OtherState) _then;

/// Create a copy of OtherState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? items = null,Object? errorMessage = freezed,}) {
  return _then(_OtherState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OtherStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OtherCardItem>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
