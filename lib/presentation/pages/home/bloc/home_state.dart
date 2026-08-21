part of 'home_bloc.dart';

enum HomeStatus { initial, ready }

@freezed
abstract class HomeState with _$HomeState {
  const new _();

  const factory({
    @Default(HomeStatus.initial) HomeStatus status,
    HomeAction? lastAction,
  }) = _HomeState;

  bool get isInitial => status == HomeStatus.initial;

  bool get isReady => status == HomeStatus.ready;

  bool get hasLastAction => lastAction != null;
}
