part of 'cards.bloc.dart';

@freezed
sealed class CardsEvent with _$CardsEvent {
  const factory CardsEvent.started() = CardsStarted;

  const factory CardsEvent.createStarted() = CardsCreateStarted;

  const factory CardsEvent.draftChanged(CardDraft draft) = CardsDraftChanged;

  const factory CardsEvent.createSubmitted() = CardsCreateSubmitted;

  const factory CardsEvent.editStarted(String cardId) = CardsEditStarted;

  const factory CardsEvent.editCancelled() = CardsEditCancelled;

  const factory CardsEvent.draftDiscarded() = CardsDraftDiscarded;

  const factory CardsEvent.editSubmitted() = CardsEditSubmitted;

  const factory CardsEvent.deleteSubmitted(String cardId) =
      CardsDeleteSubmitted;
}
