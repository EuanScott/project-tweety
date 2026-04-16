part of 'cards_bloc.dart';

sealed class CardsEvent extends Equatable {
  const CardsEvent();

  @override
  List<Object> get props => [];
}

final class CardsStarted extends CardsEvent {
  const CardsStarted();
}
