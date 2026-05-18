part of 'card_details.bloc.dart';

sealed class CardDetailsEvent extends Equatable {
  const CardDetailsEvent();

  @override
  List<Object> get props => [];
}

final class CardDetailsStarted extends CardDetailsEvent {
  const CardDetailsStarted(this.cardId);

  final String cardId;

  @override
  List<Object> get props => [cardId];
}
