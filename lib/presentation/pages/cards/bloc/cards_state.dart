part of 'cards_bloc.dart';

enum CardsStatus { initial, loading, success, failure }

@freezed
class CardsState with _$CardsState {
  const CardsState._();

  const factory CardsState({
    @Default(CardsStatus.initial) CardsStatus status,
    @Default(<CardItem>[]) List<CardItem> items,
    String? errorMessage,
  }) = _CardsState;

  bool get isInitial => status == CardsStatus.initial;

  bool get isLoading => status == CardsStatus.loading;

  bool get isSuccess => status == CardsStatus.success;

  bool get isFailure => status == CardsStatus.failure;

  bool get hasItems => items.isNotEmpty;

  bool get hasError => (errorMessage?.isNotEmpty ?? false);

  @override
  // TODO: implement errorMessage
  String? get errorMessage => throw UnimplementedError();

  @override
  // TODO: implement items
  List<CardItem> get items => throw UnimplementedError();

  @override
  // TODO: implement status
  CardsStatus get status => throw UnimplementedError();
}
