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
}
