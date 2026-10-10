part of 'cards.bloc.dart';

@freezed
sealed class CardsEvent with _$CardsEvent {
  const factory started() = CardsStarted;

  const factory createStarted() = CardsCreateStarted;

  const factory draftChanged(CardDraft draft) = CardsDraftChanged;

  const factory createSubmitted() = CardsCreateSubmitted;

  const factory editStarted(String cardId) = CardsEditStarted;

  const factory editCancelled() = CardsEditCancelled;

  const factory draftDiscarded() = CardsDraftDiscarded;

  const factory editSubmitted() = CardsEditSubmitted;

  const factory deleteSubmitted(String cardId) = CardsDeleteSubmitted;

  /// Pushes every pending change to the Account.
  const factory syncRequested() = CardsSyncRequested;

  /// Replaces where sync stands and which Cards carry an unsynced change.
  const factory syncChanged(
    CardsSync sync, {
    @Default(<String, UnsyncedCardChange>{})
    Map<String, UnsyncedCardChange> unsyncedChanges,
  }) = CardsSyncChanged;
}
