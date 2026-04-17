part of 'cards.bloc.dart';

enum CardsStatus { initial, loading, success, failure }

@freezed
abstract class CardsState with _$CardsState {
  const CardsState._();

  const factory CardsState({
    @Default(CardsStatus.initial) CardsStatus status,
    @Default(<Card>[]) List<Card> items,
    String? errorMessage,
  }) = _CardsState;

  bool get isInitial => status == CardsStatus.initial;

  bool get isLoading => status == CardsStatus.loading;

  bool get isSuccess => status == CardsStatus.success;

  bool get isFailure => status == CardsStatus.failure;

  bool get hasItems => items.isNotEmpty;

  bool get hasError => (errorMessage?.isNotEmpty ?? false);
}
