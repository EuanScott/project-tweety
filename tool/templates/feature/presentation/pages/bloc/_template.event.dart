part of '_template.bloc.dart';

@freezed
sealed class TemplateEvent with _$TemplateEvent {
  const factory TemplateEvent.started() = TemplateStarted;
}
