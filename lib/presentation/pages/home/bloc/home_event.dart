part of 'home_bloc.dart';

@freezed
sealed class HomeEvent with _$HomeEvent {
  const factory HomeEvent.started() = HomeStarted;

  const factory HomeEvent.actionPressed(HomeAction action) = HomeActionPressed;
}
