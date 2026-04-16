part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeActionPressed extends HomeEvent {
  const HomeActionPressed(this.action);

  final HomeAction action;

  @override
  List<Object> get props => [action];
}
