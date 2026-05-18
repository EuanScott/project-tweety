// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_details.bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CardDetailsState {

 CardDetailsStatus get status; String? get cardId; Card? get card; String? get errorMessage;
/// Create a copy of CardDetailsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardDetailsStateCopyWith<CardDetailsState> get copyWith => _$CardDetailsStateCopyWithImpl<CardDetailsState>(this as CardDetailsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardDetailsState&&(identical(other.status, status) || other.status == status)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.card, card) || other.card == card)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,cardId,card,errorMessage);

@override
String toString() {
  return 'CardDetailsState(status: $status, cardId: $cardId, card: $card, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $CardDetailsStateCopyWith<$Res>  {
  factory $CardDetailsStateCopyWith(CardDetailsState value, $Res Function(CardDetailsState) _then) = _$CardDetailsStateCopyWithImpl;
@useResult
$Res call({
 CardDetailsStatus status, String? cardId, Card? card, String? errorMessage
});




}
/// @nodoc
class _$CardDetailsStateCopyWithImpl<$Res>
    implements $CardDetailsStateCopyWith<$Res> {
  _$CardDetailsStateCopyWithImpl(this._self, this._then);

  final CardDetailsState _self;
  final $Res Function(CardDetailsState) _then;

/// Create a copy of CardDetailsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? cardId = freezed,Object? card = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardDetailsStatus,cardId: freezed == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String?,card: freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as Card?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardDetailsState].
extension CardDetailsStatePatterns on CardDetailsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardDetailsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardDetailsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardDetailsState value)  $default,){
final _that = this;
switch (_that) {
case _CardDetailsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardDetailsState value)?  $default,){
final _that = this;
switch (_that) {
case _CardDetailsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CardDetailsStatus status,  String? cardId,  Card? card,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardDetailsState() when $default != null:
return $default(_that.status,_that.cardId,_that.card,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CardDetailsStatus status,  String? cardId,  Card? card,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _CardDetailsState():
return $default(_that.status,_that.cardId,_that.card,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CardDetailsStatus status,  String? cardId,  Card? card,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _CardDetailsState() when $default != null:
return $default(_that.status,_that.cardId,_that.card,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _CardDetailsState extends CardDetailsState {
  const _CardDetailsState({this.status = CardDetailsStatus.initial, this.cardId, this.card, this.errorMessage}): super._();
  

@override@JsonKey() final  CardDetailsStatus status;
@override final  String? cardId;
@override final  Card? card;
@override final  String? errorMessage;

/// Create a copy of CardDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardDetailsStateCopyWith<_CardDetailsState> get copyWith => __$CardDetailsStateCopyWithImpl<_CardDetailsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardDetailsState&&(identical(other.status, status) || other.status == status)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.card, card) || other.card == card)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,cardId,card,errorMessage);

@override
String toString() {
  return 'CardDetailsState(status: $status, cardId: $cardId, card: $card, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$CardDetailsStateCopyWith<$Res> implements $CardDetailsStateCopyWith<$Res> {
  factory _$CardDetailsStateCopyWith(_CardDetailsState value, $Res Function(_CardDetailsState) _then) = __$CardDetailsStateCopyWithImpl;
@override @useResult
$Res call({
 CardDetailsStatus status, String? cardId, Card? card, String? errorMessage
});




}
/// @nodoc
class __$CardDetailsStateCopyWithImpl<$Res>
    implements _$CardDetailsStateCopyWith<$Res> {
  __$CardDetailsStateCopyWithImpl(this._self, this._then);

  final _CardDetailsState _self;
  final $Res Function(_CardDetailsState) _then;

/// Create a copy of CardDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? cardId = freezed,Object? card = freezed,Object? errorMessage = freezed,}) {
  return _then(_CardDetailsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardDetailsStatus,cardId: freezed == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String?,card: freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as Card?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
