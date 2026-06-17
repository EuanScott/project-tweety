part of '_template.bloc.dart';

enum TemplateStatus { initial, loading, success, failure }

@freezed
abstract class TemplateState with _$TemplateState {
  const TemplateState._();

  const factory TemplateState({
    @Default(TemplateStatus.initial) TemplateStatus status,
    String? errorMessage,
  }) = _TemplateState;

  bool get isInitial => status == TemplateStatus.initial;

  bool get isLoading => status == TemplateStatus.loading;

  bool get isSuccess => status == TemplateStatus.success;

  bool get isFailure => status == TemplateStatus.failure;

  bool get hasError => (errorMessage?.isNotEmpty ?? false);
}
