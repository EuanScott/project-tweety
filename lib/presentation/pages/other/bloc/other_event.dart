part of 'other_bloc.dart';

sealed class OtherEvent extends Equatable {
  const OtherEvent();

  @override
  List<Object> get props => [];
}

final class OtherStarted extends OtherEvent {
  const OtherStarted();
}
