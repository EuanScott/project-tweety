part of 'cards.bloc.dart';

sealed class CardsEvent extends Equatable {
  const CardsEvent();

  @override
  List<Object> get props => [];
}

final class CardsStarted extends CardsEvent {
  const CardsStarted();
}

final class CardsCreateStarted extends CardsEvent {
  const CardsCreateStarted();
}

final class CardsDraftChanged extends CardsEvent {
  const CardsDraftChanged(this.draft);

  final CardDraft draft;

  @override
  List<Object> get props => [draft];
}

final class CardsCreateSubmitted extends CardsEvent {
  const CardsCreateSubmitted();
}

final class CardsEditStarted extends CardsEvent {
  const CardsEditStarted(this.cardId);

  final String cardId;

  @override
  List<Object> get props => [cardId];
}

final class CardsEditCancelled extends CardsEvent {
  const CardsEditCancelled();
}

final class CardsDraftDiscarded extends CardsEvent {
  const CardsDraftDiscarded();
}

final class CardsEditSubmitted extends CardsEvent {
  const CardsEditSubmitted();
}

final class CardsDeleteSubmitted extends CardsEvent {
  const CardsDeleteSubmitted(this.cardId);

  final String cardId;

  @override
  List<Object> get props => [cardId];
}
