// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cards.bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CardsEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsEvent()';
}


}

/// @nodoc
class $CardsEventCopyWith<$Res>  {
$CardsEventCopyWith(CardsEvent _, $Res Function(CardsEvent) __);
}


/// Adds pattern-matching-related methods to [CardsEvent].
extension CardsEventPatterns on CardsEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CardsStarted value)?  started,TResult Function( CardsCreateStarted value)?  createStarted,TResult Function( CardsDraftChanged value)?  draftChanged,TResult Function( CardsCreateSubmitted value)?  createSubmitted,TResult Function( CardsEditStarted value)?  editStarted,TResult Function( CardsEditCancelled value)?  editCancelled,TResult Function( CardsDraftDiscarded value)?  draftDiscarded,TResult Function( CardsEditSubmitted value)?  editSubmitted,TResult Function( CardsDeleteSubmitted value)?  deleteSubmitted,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CardsStarted() when started != null:
return started(_that);case CardsCreateStarted() when createStarted != null:
return createStarted(_that);case CardsDraftChanged() when draftChanged != null:
return draftChanged(_that);case CardsCreateSubmitted() when createSubmitted != null:
return createSubmitted(_that);case CardsEditStarted() when editStarted != null:
return editStarted(_that);case CardsEditCancelled() when editCancelled != null:
return editCancelled(_that);case CardsDraftDiscarded() when draftDiscarded != null:
return draftDiscarded(_that);case CardsEditSubmitted() when editSubmitted != null:
return editSubmitted(_that);case CardsDeleteSubmitted() when deleteSubmitted != null:
return deleteSubmitted(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CardsStarted value)  started,required TResult Function( CardsCreateStarted value)  createStarted,required TResult Function( CardsDraftChanged value)  draftChanged,required TResult Function( CardsCreateSubmitted value)  createSubmitted,required TResult Function( CardsEditStarted value)  editStarted,required TResult Function( CardsEditCancelled value)  editCancelled,required TResult Function( CardsDraftDiscarded value)  draftDiscarded,required TResult Function( CardsEditSubmitted value)  editSubmitted,required TResult Function( CardsDeleteSubmitted value)  deleteSubmitted,}){
final _that = this;
switch (_that) {
case CardsStarted():
return started(_that);case CardsCreateStarted():
return createStarted(_that);case CardsDraftChanged():
return draftChanged(_that);case CardsCreateSubmitted():
return createSubmitted(_that);case CardsEditStarted():
return editStarted(_that);case CardsEditCancelled():
return editCancelled(_that);case CardsDraftDiscarded():
return draftDiscarded(_that);case CardsEditSubmitted():
return editSubmitted(_that);case CardsDeleteSubmitted():
return deleteSubmitted(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CardsStarted value)?  started,TResult? Function( CardsCreateStarted value)?  createStarted,TResult? Function( CardsDraftChanged value)?  draftChanged,TResult? Function( CardsCreateSubmitted value)?  createSubmitted,TResult? Function( CardsEditStarted value)?  editStarted,TResult? Function( CardsEditCancelled value)?  editCancelled,TResult? Function( CardsDraftDiscarded value)?  draftDiscarded,TResult? Function( CardsEditSubmitted value)?  editSubmitted,TResult? Function( CardsDeleteSubmitted value)?  deleteSubmitted,}){
final _that = this;
switch (_that) {
case CardsStarted() when started != null:
return started(_that);case CardsCreateStarted() when createStarted != null:
return createStarted(_that);case CardsDraftChanged() when draftChanged != null:
return draftChanged(_that);case CardsCreateSubmitted() when createSubmitted != null:
return createSubmitted(_that);case CardsEditStarted() when editStarted != null:
return editStarted(_that);case CardsEditCancelled() when editCancelled != null:
return editCancelled(_that);case CardsDraftDiscarded() when draftDiscarded != null:
return draftDiscarded(_that);case CardsEditSubmitted() when editSubmitted != null:
return editSubmitted(_that);case CardsDeleteSubmitted() when deleteSubmitted != null:
return deleteSubmitted(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function()?  createStarted,TResult Function( CardDraft draft)?  draftChanged,TResult Function()?  createSubmitted,TResult Function( String cardId)?  editStarted,TResult Function()?  editCancelled,TResult Function()?  draftDiscarded,TResult Function()?  editSubmitted,TResult Function( String cardId)?  deleteSubmitted,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CardsStarted() when started != null:
return started();case CardsCreateStarted() when createStarted != null:
return createStarted();case CardsDraftChanged() when draftChanged != null:
return draftChanged(_that.draft);case CardsCreateSubmitted() when createSubmitted != null:
return createSubmitted();case CardsEditStarted() when editStarted != null:
return editStarted(_that.cardId);case CardsEditCancelled() when editCancelled != null:
return editCancelled();case CardsDraftDiscarded() when draftDiscarded != null:
return draftDiscarded();case CardsEditSubmitted() when editSubmitted != null:
return editSubmitted();case CardsDeleteSubmitted() when deleteSubmitted != null:
return deleteSubmitted(_that.cardId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function()  createStarted,required TResult Function( CardDraft draft)  draftChanged,required TResult Function()  createSubmitted,required TResult Function( String cardId)  editStarted,required TResult Function()  editCancelled,required TResult Function()  draftDiscarded,required TResult Function()  editSubmitted,required TResult Function( String cardId)  deleteSubmitted,}) {final _that = this;
switch (_that) {
case CardsStarted():
return started();case CardsCreateStarted():
return createStarted();case CardsDraftChanged():
return draftChanged(_that.draft);case CardsCreateSubmitted():
return createSubmitted();case CardsEditStarted():
return editStarted(_that.cardId);case CardsEditCancelled():
return editCancelled();case CardsDraftDiscarded():
return draftDiscarded();case CardsEditSubmitted():
return editSubmitted();case CardsDeleteSubmitted():
return deleteSubmitted(_that.cardId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function()?  createStarted,TResult? Function( CardDraft draft)?  draftChanged,TResult? Function()?  createSubmitted,TResult? Function( String cardId)?  editStarted,TResult? Function()?  editCancelled,TResult? Function()?  draftDiscarded,TResult? Function()?  editSubmitted,TResult? Function( String cardId)?  deleteSubmitted,}) {final _that = this;
switch (_that) {
case CardsStarted() when started != null:
return started();case CardsCreateStarted() when createStarted != null:
return createStarted();case CardsDraftChanged() when draftChanged != null:
return draftChanged(_that.draft);case CardsCreateSubmitted() when createSubmitted != null:
return createSubmitted();case CardsEditStarted() when editStarted != null:
return editStarted(_that.cardId);case CardsEditCancelled() when editCancelled != null:
return editCancelled();case CardsDraftDiscarded() when draftDiscarded != null:
return draftDiscarded();case CardsEditSubmitted() when editSubmitted != null:
return editSubmitted();case CardsDeleteSubmitted() when deleteSubmitted != null:
return deleteSubmitted(_that.cardId);case _:
  return null;

}
}

}

/// @nodoc


class CardsStarted implements CardsEvent {
  const CardsStarted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsEvent.started()';
}


}




/// @nodoc


class CardsCreateStarted implements CardsEvent {
  const CardsCreateStarted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsCreateStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsEvent.createStarted()';
}


}




/// @nodoc


class CardsDraftChanged implements CardsEvent {
  const CardsDraftChanged(this.draft);
  

 final  CardDraft draft;

/// Create a copy of CardsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsDraftChangedCopyWith<CardsDraftChanged> get copyWith => _$CardsDraftChangedCopyWithImpl<CardsDraftChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsDraftChanged&&(identical(other.draft, draft) || other.draft == draft));
}


@override
int get hashCode => Object.hash(runtimeType,draft);

@override
String toString() {
  return 'CardsEvent.draftChanged(draft: $draft)';
}


}

/// @nodoc
abstract mixin class $CardsDraftChangedCopyWith<$Res> implements $CardsEventCopyWith<$Res> {
  factory $CardsDraftChangedCopyWith(CardsDraftChanged value, $Res Function(CardsDraftChanged) _then) = _$CardsDraftChangedCopyWithImpl;
@useResult
$Res call({
 CardDraft draft
});


$CardDraftCopyWith<$Res> get draft;

}
/// @nodoc
class _$CardsDraftChangedCopyWithImpl<$Res>
    implements $CardsDraftChangedCopyWith<$Res> {
  _$CardsDraftChangedCopyWithImpl(this._self, this._then);

  final CardsDraftChanged _self;
  final $Res Function(CardsDraftChanged) _then;

/// Create a copy of CardsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? draft = null,}) {
  return _then(CardsDraftChanged(
null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as CardDraft,
  ));
}

/// Create a copy of CardsEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardDraftCopyWith<$Res> get draft {
  
  return $CardDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

/// @nodoc


class CardsCreateSubmitted implements CardsEvent {
  const CardsCreateSubmitted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsCreateSubmitted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsEvent.createSubmitted()';
}


}




/// @nodoc


class CardsEditStarted implements CardsEvent {
  const CardsEditStarted(this.cardId);
  

 final  String cardId;

/// Create a copy of CardsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsEditStartedCopyWith<CardsEditStarted> get copyWith => _$CardsEditStartedCopyWithImpl<CardsEditStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsEditStarted&&(identical(other.cardId, cardId) || other.cardId == cardId));
}


@override
int get hashCode => Object.hash(runtimeType,cardId);

@override
String toString() {
  return 'CardsEvent.editStarted(cardId: $cardId)';
}


}

/// @nodoc
abstract mixin class $CardsEditStartedCopyWith<$Res> implements $CardsEventCopyWith<$Res> {
  factory $CardsEditStartedCopyWith(CardsEditStarted value, $Res Function(CardsEditStarted) _then) = _$CardsEditStartedCopyWithImpl;
@useResult
$Res call({
 String cardId
});




}
/// @nodoc
class _$CardsEditStartedCopyWithImpl<$Res>
    implements $CardsEditStartedCopyWith<$Res> {
  _$CardsEditStartedCopyWithImpl(this._self, this._then);

  final CardsEditStarted _self;
  final $Res Function(CardsEditStarted) _then;

/// Create a copy of CardsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cardId = null,}) {
  return _then(CardsEditStarted(
null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CardsEditCancelled implements CardsEvent {
  const CardsEditCancelled();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsEditCancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsEvent.editCancelled()';
}


}




/// @nodoc


class CardsDraftDiscarded implements CardsEvent {
  const CardsDraftDiscarded();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsDraftDiscarded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsEvent.draftDiscarded()';
}


}




/// @nodoc


class CardsEditSubmitted implements CardsEvent {
  const CardsEditSubmitted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsEditSubmitted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsEvent.editSubmitted()';
}


}




/// @nodoc


class CardsDeleteSubmitted implements CardsEvent {
  const CardsDeleteSubmitted(this.cardId);
  

 final  String cardId;

/// Create a copy of CardsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsDeleteSubmittedCopyWith<CardsDeleteSubmitted> get copyWith => _$CardsDeleteSubmittedCopyWithImpl<CardsDeleteSubmitted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsDeleteSubmitted&&(identical(other.cardId, cardId) || other.cardId == cardId));
}


@override
int get hashCode => Object.hash(runtimeType,cardId);

@override
String toString() {
  return 'CardsEvent.deleteSubmitted(cardId: $cardId)';
}


}

/// @nodoc
abstract mixin class $CardsDeleteSubmittedCopyWith<$Res> implements $CardsEventCopyWith<$Res> {
  factory $CardsDeleteSubmittedCopyWith(CardsDeleteSubmitted value, $Res Function(CardsDeleteSubmitted) _then) = _$CardsDeleteSubmittedCopyWithImpl;
@useResult
$Res call({
 String cardId
});




}
/// @nodoc
class _$CardsDeleteSubmittedCopyWithImpl<$Res>
    implements $CardsDeleteSubmittedCopyWith<$Res> {
  _$CardsDeleteSubmittedCopyWithImpl(this._self, this._then);

  final CardsDeleteSubmitted _self;
  final $Res Function(CardsDeleteSubmitted) _then;

/// Create a copy of CardsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cardId = null,}) {
  return _then(CardsDeleteSubmitted(
null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CardsDetail {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsDetail);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsDetail()';
}


}

/// @nodoc
class $CardsDetailCopyWith<$Res>  {
$CardsDetailCopyWith(CardsDetail _, $Res Function(CardsDetail) __);
}


/// Adds pattern-matching-related methods to [CardsDetail].
extension CardsDetailPatterns on CardsDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CardsDetailLoading value)?  loading,TResult Function( CardsDetailSuccess value)?  success,TResult Function( CardsDetailMissing value)?  missing,TResult Function( CardsDetailFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CardsDetailLoading() when loading != null:
return loading(_that);case CardsDetailSuccess() when success != null:
return success(_that);case CardsDetailMissing() when missing != null:
return missing(_that);case CardsDetailFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CardsDetailLoading value)  loading,required TResult Function( CardsDetailSuccess value)  success,required TResult Function( CardsDetailMissing value)  missing,required TResult Function( CardsDetailFailure value)  failure,}){
final _that = this;
switch (_that) {
case CardsDetailLoading():
return loading(_that);case CardsDetailSuccess():
return success(_that);case CardsDetailMissing():
return missing(_that);case CardsDetailFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CardsDetailLoading value)?  loading,TResult? Function( CardsDetailSuccess value)?  success,TResult? Function( CardsDetailMissing value)?  missing,TResult? Function( CardsDetailFailure value)?  failure,}){
final _that = this;
switch (_that) {
case CardsDetailLoading() when loading != null:
return loading(_that);case CardsDetailSuccess() when success != null:
return success(_that);case CardsDetailMissing() when missing != null:
return missing(_that);case CardsDetailFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( Card card)?  success,TResult Function()?  missing,TResult Function( String errorMessage)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CardsDetailLoading() when loading != null:
return loading();case CardsDetailSuccess() when success != null:
return success(_that.card);case CardsDetailMissing() when missing != null:
return missing();case CardsDetailFailure() when failure != null:
return failure(_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( Card card)  success,required TResult Function()  missing,required TResult Function( String errorMessage)  failure,}) {final _that = this;
switch (_that) {
case CardsDetailLoading():
return loading();case CardsDetailSuccess():
return success(_that.card);case CardsDetailMissing():
return missing();case CardsDetailFailure():
return failure(_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( Card card)?  success,TResult? Function()?  missing,TResult? Function( String errorMessage)?  failure,}) {final _that = this;
switch (_that) {
case CardsDetailLoading() when loading != null:
return loading();case CardsDetailSuccess() when success != null:
return success(_that.card);case CardsDetailMissing() when missing != null:
return missing();case CardsDetailFailure() when failure != null:
return failure(_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class CardsDetailLoading implements CardsDetail {
  const CardsDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsDetail.loading()';
}


}




/// @nodoc


class CardsDetailSuccess implements CardsDetail {
  const CardsDetailSuccess(this.card);
  

 final  Card card;

/// Create a copy of CardsDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsDetailSuccessCopyWith<CardsDetailSuccess> get copyWith => _$CardsDetailSuccessCopyWithImpl<CardsDetailSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsDetailSuccess&&(identical(other.card, card) || other.card == card));
}


@override
int get hashCode => Object.hash(runtimeType,card);

@override
String toString() {
  return 'CardsDetail.success(card: $card)';
}


}

/// @nodoc
abstract mixin class $CardsDetailSuccessCopyWith<$Res> implements $CardsDetailCopyWith<$Res> {
  factory $CardsDetailSuccessCopyWith(CardsDetailSuccess value, $Res Function(CardsDetailSuccess) _then) = _$CardsDetailSuccessCopyWithImpl;
@useResult
$Res call({
 Card card
});


$CardCopyWith<$Res> get card;

}
/// @nodoc
class _$CardsDetailSuccessCopyWithImpl<$Res>
    implements $CardsDetailSuccessCopyWith<$Res> {
  _$CardsDetailSuccessCopyWithImpl(this._self, this._then);

  final CardsDetailSuccess _self;
  final $Res Function(CardsDetailSuccess) _then;

/// Create a copy of CardsDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? card = null,}) {
  return _then(CardsDetailSuccess(
null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as Card,
  ));
}

/// Create a copy of CardsDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardCopyWith<$Res> get card {
  
  return $CardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}

/// @nodoc


class CardsDetailMissing implements CardsDetail {
  const CardsDetailMissing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsDetailMissing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardsDetail.missing()';
}


}




/// @nodoc


class CardsDetailFailure implements CardsDetail {
  const CardsDetailFailure(this.errorMessage);
  

 final  String errorMessage;

/// Create a copy of CardsDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsDetailFailureCopyWith<CardsDetailFailure> get copyWith => _$CardsDetailFailureCopyWithImpl<CardsDetailFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsDetailFailure&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,errorMessage);

@override
String toString() {
  return 'CardsDetail.failure(errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $CardsDetailFailureCopyWith<$Res> implements $CardsDetailCopyWith<$Res> {
  factory $CardsDetailFailureCopyWith(CardsDetailFailure value, $Res Function(CardsDetailFailure) _then) = _$CardsDetailFailureCopyWithImpl;
@useResult
$Res call({
 String errorMessage
});




}
/// @nodoc
class _$CardsDetailFailureCopyWithImpl<$Res>
    implements $CardsDetailFailureCopyWith<$Res> {
  _$CardsDetailFailureCopyWithImpl(this._self, this._then);

  final CardsDetailFailure _self;
  final $Res Function(CardsDetailFailure) _then;

/// Create a copy of CardsDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errorMessage = null,}) {
  return _then(CardsDetailFailure(
null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CardsState {

 CardsStatus get status; List<Card> get items; String? get errorMessage; CardDraft get draft; CardDraft? get initialDraft; Set<CardDraftField> get invalidDraftFields; bool get hasSubmittedCreate; CardsCreateStatus get createStatus; bool get createError; String? get createdCardId; String? get editingCardId; bool get hasSubmittedEdit; CardsEditStatus get editStatus; bool get editError; String? get missingEditCardId; String? get updatedCardId; CardsDeleteStatus get deleteStatus; String? get deletingCardId; String? get deleteErrorCardId; String? get deletedCardId;
/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsStateCopyWith<CardsState> get copyWith => _$CardsStateCopyWithImpl<CardsState>(this as CardsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.initialDraft, initialDraft) || other.initialDraft == initialDraft)&&const DeepCollectionEquality().equals(other.invalidDraftFields, invalidDraftFields)&&(identical(other.hasSubmittedCreate, hasSubmittedCreate) || other.hasSubmittedCreate == hasSubmittedCreate)&&(identical(other.createStatus, createStatus) || other.createStatus == createStatus)&&(identical(other.createError, createError) || other.createError == createError)&&(identical(other.createdCardId, createdCardId) || other.createdCardId == createdCardId)&&(identical(other.editingCardId, editingCardId) || other.editingCardId == editingCardId)&&(identical(other.hasSubmittedEdit, hasSubmittedEdit) || other.hasSubmittedEdit == hasSubmittedEdit)&&(identical(other.editStatus, editStatus) || other.editStatus == editStatus)&&(identical(other.editError, editError) || other.editError == editError)&&(identical(other.missingEditCardId, missingEditCardId) || other.missingEditCardId == missingEditCardId)&&(identical(other.updatedCardId, updatedCardId) || other.updatedCardId == updatedCardId)&&(identical(other.deleteStatus, deleteStatus) || other.deleteStatus == deleteStatus)&&(identical(other.deletingCardId, deletingCardId) || other.deletingCardId == deletingCardId)&&(identical(other.deleteErrorCardId, deleteErrorCardId) || other.deleteErrorCardId == deleteErrorCardId)&&(identical(other.deletedCardId, deletedCardId) || other.deletedCardId == deletedCardId));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,const DeepCollectionEquality().hash(items),errorMessage,draft,initialDraft,const DeepCollectionEquality().hash(invalidDraftFields),hasSubmittedCreate,createStatus,createError,createdCardId,editingCardId,hasSubmittedEdit,editStatus,editError,missingEditCardId,updatedCardId,deleteStatus,deletingCardId,deleteErrorCardId,deletedCardId]);

@override
String toString() {
  return 'CardsState(status: $status, items: $items, errorMessage: $errorMessage, draft: $draft, initialDraft: $initialDraft, invalidDraftFields: $invalidDraftFields, hasSubmittedCreate: $hasSubmittedCreate, createStatus: $createStatus, createError: $createError, createdCardId: $createdCardId, editingCardId: $editingCardId, hasSubmittedEdit: $hasSubmittedEdit, editStatus: $editStatus, editError: $editError, missingEditCardId: $missingEditCardId, updatedCardId: $updatedCardId, deleteStatus: $deleteStatus, deletingCardId: $deletingCardId, deleteErrorCardId: $deleteErrorCardId, deletedCardId: $deletedCardId)';
}


}

/// @nodoc
abstract mixin class $CardsStateCopyWith<$Res>  {
  factory $CardsStateCopyWith(CardsState value, $Res Function(CardsState) _then) = _$CardsStateCopyWithImpl;
@useResult
$Res call({
 CardsStatus status, List<Card> items, String? errorMessage, CardDraft draft, CardDraft? initialDraft, Set<CardDraftField> invalidDraftFields, bool hasSubmittedCreate, CardsCreateStatus createStatus, bool createError, String? createdCardId, String? editingCardId, bool hasSubmittedEdit, CardsEditStatus editStatus, bool editError, String? missingEditCardId, String? updatedCardId, CardsDeleteStatus deleteStatus, String? deletingCardId, String? deleteErrorCardId, String? deletedCardId
});


$CardDraftCopyWith<$Res> get draft;$CardDraftCopyWith<$Res>? get initialDraft;

}
/// @nodoc
class _$CardsStateCopyWithImpl<$Res>
    implements $CardsStateCopyWith<$Res> {
  _$CardsStateCopyWithImpl(this._self, this._then);

  final CardsState _self;
  final $Res Function(CardsState) _then;

/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? items = null,Object? errorMessage = freezed,Object? draft = null,Object? initialDraft = freezed,Object? invalidDraftFields = null,Object? hasSubmittedCreate = null,Object? createStatus = null,Object? createError = null,Object? createdCardId = freezed,Object? editingCardId = freezed,Object? hasSubmittedEdit = null,Object? editStatus = null,Object? editError = null,Object? missingEditCardId = freezed,Object? updatedCardId = freezed,Object? deleteStatus = null,Object? deletingCardId = freezed,Object? deleteErrorCardId = freezed,Object? deletedCardId = freezed,}) {
  return _then(CardsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardsStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Card>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as CardDraft,initialDraft: freezed == initialDraft ? _self.initialDraft : initialDraft // ignore: cast_nullable_to_non_nullable
as CardDraft?,invalidDraftFields: null == invalidDraftFields ? _self.invalidDraftFields : invalidDraftFields // ignore: cast_nullable_to_non_nullable
as Set<CardDraftField>,hasSubmittedCreate: null == hasSubmittedCreate ? _self.hasSubmittedCreate : hasSubmittedCreate // ignore: cast_nullable_to_non_nullable
as bool,createStatus: null == createStatus ? _self.createStatus : createStatus // ignore: cast_nullable_to_non_nullable
as CardsCreateStatus,createError: null == createError ? _self.createError : createError // ignore: cast_nullable_to_non_nullable
as bool,createdCardId: freezed == createdCardId ? _self.createdCardId : createdCardId // ignore: cast_nullable_to_non_nullable
as String?,editingCardId: freezed == editingCardId ? _self.editingCardId : editingCardId // ignore: cast_nullable_to_non_nullable
as String?,hasSubmittedEdit: null == hasSubmittedEdit ? _self.hasSubmittedEdit : hasSubmittedEdit // ignore: cast_nullable_to_non_nullable
as bool,editStatus: null == editStatus ? _self.editStatus : editStatus // ignore: cast_nullable_to_non_nullable
as CardsEditStatus,editError: null == editError ? _self.editError : editError // ignore: cast_nullable_to_non_nullable
as bool,missingEditCardId: freezed == missingEditCardId ? _self.missingEditCardId : missingEditCardId // ignore: cast_nullable_to_non_nullable
as String?,updatedCardId: freezed == updatedCardId ? _self.updatedCardId : updatedCardId // ignore: cast_nullable_to_non_nullable
as String?,deleteStatus: null == deleteStatus ? _self.deleteStatus : deleteStatus // ignore: cast_nullable_to_non_nullable
as CardsDeleteStatus,deletingCardId: freezed == deletingCardId ? _self.deletingCardId : deletingCardId // ignore: cast_nullable_to_non_nullable
as String?,deleteErrorCardId: freezed == deleteErrorCardId ? _self.deleteErrorCardId : deleteErrorCardId // ignore: cast_nullable_to_non_nullable
as String?,deletedCardId: freezed == deletedCardId ? _self.deletedCardId : deletedCardId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardDraftCopyWith<$Res> get draft {
  
  return $CardDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardDraftCopyWith<$Res>? get initialDraft {
    if (_self.initialDraft == null) {
    return null;
  }

  return $CardDraftCopyWith<$Res>(_self.initialDraft!, (value) {
    return _then(_self.copyWith(initialDraft: value));
  });
}
}


/// Adds pattern-matching-related methods to [CardsState].
extension CardsStatePatterns on CardsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardsState value)  $default,){
final _that = this;
switch (_that) {
case _CardsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardsState value)?  $default,){
final _that = this;
switch (_that) {
case _CardsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CardsStatus status,  List<Card> items,  String? errorMessage,  CardDraft draft,  CardDraft? initialDraft,  Set<CardDraftField> invalidDraftFields,  bool hasSubmittedCreate,  CardsCreateStatus createStatus,  bool createError,  String? createdCardId,  String? editingCardId,  bool hasSubmittedEdit,  CardsEditStatus editStatus,  bool editError,  String? missingEditCardId,  String? updatedCardId,  CardsDeleteStatus deleteStatus,  String? deletingCardId,  String? deleteErrorCardId,  String? deletedCardId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardsState() when $default != null:
return $default(_that.status,_that.items,_that.errorMessage,_that.draft,_that.initialDraft,_that.invalidDraftFields,_that.hasSubmittedCreate,_that.createStatus,_that.createError,_that.createdCardId,_that.editingCardId,_that.hasSubmittedEdit,_that.editStatus,_that.editError,_that.missingEditCardId,_that.updatedCardId,_that.deleteStatus,_that.deletingCardId,_that.deleteErrorCardId,_that.deletedCardId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CardsStatus status,  List<Card> items,  String? errorMessage,  CardDraft draft,  CardDraft? initialDraft,  Set<CardDraftField> invalidDraftFields,  bool hasSubmittedCreate,  CardsCreateStatus createStatus,  bool createError,  String? createdCardId,  String? editingCardId,  bool hasSubmittedEdit,  CardsEditStatus editStatus,  bool editError,  String? missingEditCardId,  String? updatedCardId,  CardsDeleteStatus deleteStatus,  String? deletingCardId,  String? deleteErrorCardId,  String? deletedCardId)  $default,) {final _that = this;
switch (_that) {
case _CardsState():
return $default(_that.status,_that.items,_that.errorMessage,_that.draft,_that.initialDraft,_that.invalidDraftFields,_that.hasSubmittedCreate,_that.createStatus,_that.createError,_that.createdCardId,_that.editingCardId,_that.hasSubmittedEdit,_that.editStatus,_that.editError,_that.missingEditCardId,_that.updatedCardId,_that.deleteStatus,_that.deletingCardId,_that.deleteErrorCardId,_that.deletedCardId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CardsStatus status,  List<Card> items,  String? errorMessage,  CardDraft draft,  CardDraft? initialDraft,  Set<CardDraftField> invalidDraftFields,  bool hasSubmittedCreate,  CardsCreateStatus createStatus,  bool createError,  String? createdCardId,  String? editingCardId,  bool hasSubmittedEdit,  CardsEditStatus editStatus,  bool editError,  String? missingEditCardId,  String? updatedCardId,  CardsDeleteStatus deleteStatus,  String? deletingCardId,  String? deleteErrorCardId,  String? deletedCardId)?  $default,) {final _that = this;
switch (_that) {
case _CardsState() when $default != null:
return $default(_that.status,_that.items,_that.errorMessage,_that.draft,_that.initialDraft,_that.invalidDraftFields,_that.hasSubmittedCreate,_that.createStatus,_that.createError,_that.createdCardId,_that.editingCardId,_that.hasSubmittedEdit,_that.editStatus,_that.editError,_that.missingEditCardId,_that.updatedCardId,_that.deleteStatus,_that.deletingCardId,_that.deleteErrorCardId,_that.deletedCardId);case _:
  return null;

}
}

}

/// @nodoc


class _CardsState extends CardsState {
  const _CardsState({this.status = CardsStatus.initial,  List<Card> items = const <Card>[], this.errorMessage, this.draft = const CardDraft(title: '', description: ''), this.initialDraft,  Set<CardDraftField> invalidDraftFields = const <CardDraftField>{}, this.hasSubmittedCreate = false, this.createStatus = CardsCreateStatus.idle, this.createError = false, this.createdCardId, this.editingCardId, this.hasSubmittedEdit = false, this.editStatus = CardsEditStatus.idle, this.editError = false, this.missingEditCardId, this.updatedCardId, this.deleteStatus = CardsDeleteStatus.idle, this.deletingCardId, this.deleteErrorCardId, this.deletedCardId}): _items = items,_invalidDraftFields = invalidDraftFields,super._();
  

@override@JsonKey() final  CardsStatus status;
 final  List<Card> _items;
@override@JsonKey() List<Card> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? errorMessage;
@override@JsonKey() final  CardDraft draft;
@override final  CardDraft? initialDraft;
 final  Set<CardDraftField> _invalidDraftFields;
@override@JsonKey() Set<CardDraftField> get invalidDraftFields {
  if (_invalidDraftFields is EqualUnmodifiableSetView) return _invalidDraftFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_invalidDraftFields);
}

@override@JsonKey() final  bool hasSubmittedCreate;
@override@JsonKey() final  CardsCreateStatus createStatus;
@override@JsonKey() final  bool createError;
@override final  String? createdCardId;
@override final  String? editingCardId;
@override@JsonKey() final  bool hasSubmittedEdit;
@override@JsonKey() final  CardsEditStatus editStatus;
@override@JsonKey() final  bool editError;
@override final  String? missingEditCardId;
@override final  String? updatedCardId;
@override@JsonKey() final  CardsDeleteStatus deleteStatus;
@override final  String? deletingCardId;
@override final  String? deleteErrorCardId;
@override final  String? deletedCardId;

/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardsStateCopyWith<_CardsState> get copyWith => __$CardsStateCopyWithImpl<_CardsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.initialDraft, initialDraft) || other.initialDraft == initialDraft)&&const DeepCollectionEquality().equals(other._invalidDraftFields, _invalidDraftFields)&&(identical(other.hasSubmittedCreate, hasSubmittedCreate) || other.hasSubmittedCreate == hasSubmittedCreate)&&(identical(other.createStatus, createStatus) || other.createStatus == createStatus)&&(identical(other.createError, createError) || other.createError == createError)&&(identical(other.createdCardId, createdCardId) || other.createdCardId == createdCardId)&&(identical(other.editingCardId, editingCardId) || other.editingCardId == editingCardId)&&(identical(other.hasSubmittedEdit, hasSubmittedEdit) || other.hasSubmittedEdit == hasSubmittedEdit)&&(identical(other.editStatus, editStatus) || other.editStatus == editStatus)&&(identical(other.editError, editError) || other.editError == editError)&&(identical(other.missingEditCardId, missingEditCardId) || other.missingEditCardId == missingEditCardId)&&(identical(other.updatedCardId, updatedCardId) || other.updatedCardId == updatedCardId)&&(identical(other.deleteStatus, deleteStatus) || other.deleteStatus == deleteStatus)&&(identical(other.deletingCardId, deletingCardId) || other.deletingCardId == deletingCardId)&&(identical(other.deleteErrorCardId, deleteErrorCardId) || other.deleteErrorCardId == deleteErrorCardId)&&(identical(other.deletedCardId, deletedCardId) || other.deletedCardId == deletedCardId));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,const DeepCollectionEquality().hash(_items),errorMessage,draft,initialDraft,const DeepCollectionEquality().hash(_invalidDraftFields),hasSubmittedCreate,createStatus,createError,createdCardId,editingCardId,hasSubmittedEdit,editStatus,editError,missingEditCardId,updatedCardId,deleteStatus,deletingCardId,deleteErrorCardId,deletedCardId]);

@override
String toString() {
  return 'CardsState(status: $status, items: $items, errorMessage: $errorMessage, draft: $draft, initialDraft: $initialDraft, invalidDraftFields: $invalidDraftFields, hasSubmittedCreate: $hasSubmittedCreate, createStatus: $createStatus, createError: $createError, createdCardId: $createdCardId, editingCardId: $editingCardId, hasSubmittedEdit: $hasSubmittedEdit, editStatus: $editStatus, editError: $editError, missingEditCardId: $missingEditCardId, updatedCardId: $updatedCardId, deleteStatus: $deleteStatus, deletingCardId: $deletingCardId, deleteErrorCardId: $deleteErrorCardId, deletedCardId: $deletedCardId)';
}


}

/// @nodoc
abstract mixin class _$CardsStateCopyWith<$Res> implements $CardsStateCopyWith<$Res> {
  factory _$CardsStateCopyWith(_CardsState value, $Res Function(_CardsState) _then) = __$CardsStateCopyWithImpl;
@override @useResult
$Res call({
 CardsStatus status, List<Card> items, String? errorMessage, CardDraft draft, CardDraft? initialDraft, Set<CardDraftField> invalidDraftFields, bool hasSubmittedCreate, CardsCreateStatus createStatus, bool createError, String? createdCardId, String? editingCardId, bool hasSubmittedEdit, CardsEditStatus editStatus, bool editError, String? missingEditCardId, String? updatedCardId, CardsDeleteStatus deleteStatus, String? deletingCardId, String? deleteErrorCardId, String? deletedCardId
});


@override $CardDraftCopyWith<$Res> get draft;@override $CardDraftCopyWith<$Res>? get initialDraft;

}
/// @nodoc
class __$CardsStateCopyWithImpl<$Res>
    implements _$CardsStateCopyWith<$Res> {
  __$CardsStateCopyWithImpl(this._self, this._then);

  final _CardsState _self;
  final $Res Function(_CardsState) _then;

/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? items = null,Object? errorMessage = freezed,Object? draft = null,Object? initialDraft = freezed,Object? invalidDraftFields = null,Object? hasSubmittedCreate = null,Object? createStatus = null,Object? createError = null,Object? createdCardId = freezed,Object? editingCardId = freezed,Object? hasSubmittedEdit = null,Object? editStatus = null,Object? editError = null,Object? missingEditCardId = freezed,Object? updatedCardId = freezed,Object? deleteStatus = null,Object? deletingCardId = freezed,Object? deleteErrorCardId = freezed,Object? deletedCardId = freezed,}) {
  return _then(_CardsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardsStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Card>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as CardDraft,initialDraft: freezed == initialDraft ? _self.initialDraft : initialDraft // ignore: cast_nullable_to_non_nullable
as CardDraft?,invalidDraftFields: null == invalidDraftFields ? _self._invalidDraftFields : invalidDraftFields // ignore: cast_nullable_to_non_nullable
as Set<CardDraftField>,hasSubmittedCreate: null == hasSubmittedCreate ? _self.hasSubmittedCreate : hasSubmittedCreate // ignore: cast_nullable_to_non_nullable
as bool,createStatus: null == createStatus ? _self.createStatus : createStatus // ignore: cast_nullable_to_non_nullable
as CardsCreateStatus,createError: null == createError ? _self.createError : createError // ignore: cast_nullable_to_non_nullable
as bool,createdCardId: freezed == createdCardId ? _self.createdCardId : createdCardId // ignore: cast_nullable_to_non_nullable
as String?,editingCardId: freezed == editingCardId ? _self.editingCardId : editingCardId // ignore: cast_nullable_to_non_nullable
as String?,hasSubmittedEdit: null == hasSubmittedEdit ? _self.hasSubmittedEdit : hasSubmittedEdit // ignore: cast_nullable_to_non_nullable
as bool,editStatus: null == editStatus ? _self.editStatus : editStatus // ignore: cast_nullable_to_non_nullable
as CardsEditStatus,editError: null == editError ? _self.editError : editError // ignore: cast_nullable_to_non_nullable
as bool,missingEditCardId: freezed == missingEditCardId ? _self.missingEditCardId : missingEditCardId // ignore: cast_nullable_to_non_nullable
as String?,updatedCardId: freezed == updatedCardId ? _self.updatedCardId : updatedCardId // ignore: cast_nullable_to_non_nullable
as String?,deleteStatus: null == deleteStatus ? _self.deleteStatus : deleteStatus // ignore: cast_nullable_to_non_nullable
as CardsDeleteStatus,deletingCardId: freezed == deletingCardId ? _self.deletingCardId : deletingCardId // ignore: cast_nullable_to_non_nullable
as String?,deleteErrorCardId: freezed == deleteErrorCardId ? _self.deleteErrorCardId : deleteErrorCardId // ignore: cast_nullable_to_non_nullable
as String?,deletedCardId: freezed == deletedCardId ? _self.deletedCardId : deletedCardId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardDraftCopyWith<$Res> get draft {
  
  return $CardDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardDraftCopyWith<$Res>? get initialDraft {
    if (_self.initialDraft == null) {
    return null;
  }

  return $CardDraftCopyWith<$Res>(_self.initialDraft!, (value) {
    return _then(_self.copyWith(initialDraft: value));
  });
}
}

// dart format on
