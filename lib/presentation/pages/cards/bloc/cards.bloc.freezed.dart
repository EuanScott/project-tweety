// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cards.bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
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
  return _then(_self.copyWith(
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
  const _CardsState({this.status = CardsStatus.initial, final  List<Card> items = const <Card>[], this.errorMessage, this.draft = const CardDraft(title: '', description: ''), this.initialDraft, final  Set<CardDraftField> invalidDraftFields = const <CardDraftField>{}, this.hasSubmittedCreate = false, this.createStatus = CardsCreateStatus.idle, this.createError = false, this.createdCardId, this.editingCardId, this.hasSubmittedEdit = false, this.editStatus = CardsEditStatus.idle, this.editError = false, this.missingEditCardId, this.updatedCardId, this.deleteStatus = CardsDeleteStatus.idle, this.deletingCardId, this.deleteErrorCardId, this.deletedCardId}): _items = items,_invalidDraftFields = invalidDraftFields,super._();
  

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


}

// dart format on
