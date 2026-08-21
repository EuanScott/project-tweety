part of 'home_bloc.dart';

@freezed
sealed class HomeEvent with _$HomeEvent {
  const factory started() = HomeStarted;

  const factory actionPressed(HomeAction action) = HomeActionPressed;
}
