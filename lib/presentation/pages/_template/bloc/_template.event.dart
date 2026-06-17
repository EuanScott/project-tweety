part of '_template.bloc.dart';

sealed class TemplateEvent extends Equatable {
  const TemplateEvent();

  @override
  List<Object> get props => [];
}

final class TemplateStarted extends TemplateEvent {
  const TemplateStarted();
}
