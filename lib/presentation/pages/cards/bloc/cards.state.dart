part of 'cards.bloc.dart';

enum CardsStatus { initial, loading, success, failure }

enum CardsCreateStatus { idle, creating, success, failure }

enum CardsEditStatus { idle, updating, success, failure, notFound }

enum CardsDeleteStatus { idle, deleting, success, failure }

enum CardsDetailStatus { loading, success, missing, failure }

class CardsDetail extends Equatable {
  const CardsDetail._({required this.status, this.card, this.errorMessage});

  const CardsDetail.loading() : this._(status: CardsDetailStatus.loading);

  const CardsDetail.success(Card card)
    : this._(status: CardsDetailStatus.success, card: card);

  const CardsDetail.missing() : this._(status: CardsDetailStatus.missing);

  const CardsDetail.failure(String errorMessage)
    : this._(status: CardsDetailStatus.failure, errorMessage: errorMessage);

  final CardsDetailStatus status;
  final Card? card;
  final String? errorMessage;

  bool get isLoading => status == CardsDetailStatus.loading;

  bool get isSuccess => status == CardsDetailStatus.success;

  bool get isMissing => status == CardsDetailStatus.missing;

  bool get isFailure => status == CardsDetailStatus.failure;

  @override
  List<Object?> get props => [status, card, errorMessage];
}

@freezed
abstract class CardsState with _$CardsState {
  const CardsState._();

  const factory CardsState({
    @Default(CardsStatus.initial) CardsStatus status,
    @Default(<Card>[]) List<Card> items,
    String? errorMessage,
    @Default(CardDraft(title: '', description: '')) CardDraft draft,
    CardDraft? initialDraft,
    @Default(<CardDraftField>{}) Set<CardDraftField> invalidDraftFields,
    @Default(false) bool hasSubmittedCreate,
    @Default(CardsCreateStatus.idle) CardsCreateStatus createStatus,
    @Default(false) bool createError,
    String? createdCardId,
    String? editingCardId,
    @Default(false) bool hasSubmittedEdit,
    @Default(CardsEditStatus.idle) CardsEditStatus editStatus,
    @Default(false) bool editError,
    String? missingEditCardId,
    String? updatedCardId,
    @Default(CardsDeleteStatus.idle) CardsDeleteStatus deleteStatus,
    String? deletingCardId,
    String? deleteErrorCardId,
    String? deletedCardId,
  }) = _CardsState;

  bool get isInitial => status == CardsStatus.initial;

  bool get isLoading => status == CardsStatus.loading;

  bool get isSuccess => status == CardsStatus.success;

  bool get isFailure => status == CardsStatus.failure;

  bool get hasItems => items.isNotEmpty;

  bool get hasError => (errorMessage?.isNotEmpty ?? false);

  bool get isCreating => createStatus == CardsCreateStatus.creating;

  /// Whether the untrimmed editor values differ from their opening snapshot.
  bool get isDraftDirty => initialDraft != null && draft != initialDraft;

  bool get isDeleting => deleteStatus == CardsDeleteStatus.deleting;

  bool get isEditing => editingCardId != null;

  bool get isUpdating => editStatus == CardsEditStatus.updating;

  bool isEditingCard(String cardId) => editingCardId == cardId;

  bool hasMissingEditFor(String cardId) =>
      editStatus == CardsEditStatus.notFound && missingEditCardId == cardId;

  bool isDeletingCard(String cardId) => isDeleting && deletingCardId == cardId;

  bool hasDeleteErrorFor(String cardId) =>
      deleteStatus == CardsDeleteStatus.failure && deleteErrorCardId == cardId;

  CardsDetail detailFor(String cardId) {
    if (isInitial || isLoading) {
      return const CardsDetail.loading();
    }

    if (isFailure) {
      return CardsDetail.failure(
        errorMessage ?? 'Unable to load cards right now.',
      );
    }

    for (final card in items) {
      if (card.id == cardId) {
        return CardsDetail.success(card);
      }
    }

    return const CardsDetail.missing();
  }
}
