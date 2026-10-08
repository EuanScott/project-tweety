part of 'cards.bloc.dart';

enum CardsStatus { initial, loading, success, failure }

enum CardsCreateStatus { idle, creating, success, failure }

enum CardsEditStatus { idle, updating, success, failure, notFound }

enum CardsDeleteStatus { idle, deleting, success, failure }

@freezed
sealed class CardsDetail with _$CardsDetail {
  const factory loading() = CardsDetailLoading;

  const factory success(Card card) = CardsDetailSuccess;

  const factory missing() = CardsDetailMissing;

  const factory failure(String errorMessage) = CardsDetailFailure;
}

/// What a sync would push for a Card that has not reached the Account yet.
enum UnsyncedCardChange { created, updated }

/// Where a sync, or a background download of Cards, stands.
///
/// Counts are changes, so a deleted Card waiting to sync is counted even
/// though it has no row in the list.
@freezed
sealed class CardsSync with _$CardsSync {
  const new _();

  const factory upToDate({DateTime? lastSyncedAt}) = CardsSyncUpToDate;

  const factory pending({required int changeCount}) = CardsSyncPending;

  const factory syncing({required int savedCount, required int changeCount}) =
      CardsSyncSyncing;

  const factory synced({required int changeCount}) = CardsSyncSynced;

  const factory partial({required int savedCount, required int changeCount}) =
      CardsSyncPartial;

  const factory offline({required int changeCount}) = CardsSyncOffline;

  const factory failed({required int changeCount}) = CardsSyncFailed;

  const factory alreadyUpToDate() = CardsSyncAlreadyUpToDate;

  const factory downloading({required int cardCount}) = CardsSyncDownloading;

  const factory downloaded({required int cardCount}) = CardsSyncDownloaded;

  /// Whether a sync or a download is running, so a new sync cannot start.
  bool get isBusy => switch (this) {
    CardsSyncSyncing() || CardsSyncDownloading() => true,
    _ => false,
  };
}

@freezed
abstract class CardsState with _$CardsState {
  const new _();

  const factory({
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
    @Default(CardsSync.upToDate()) CardsSync sync,
    @Default(<String, UnsyncedCardChange>{})
    Map<String, UnsyncedCardChange> unsyncedChanges,
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
      return const .loading();
    }

    if (isFailure) {
      return .failure(errorMessage ?? 'Unable to load cards right now.');
    }

    for (final card in items) {
      if (card.id == cardId) {
        return .success(card);
      }
    }

    return const .missing();
  }
}
