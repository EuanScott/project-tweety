part of 'settings.cubit.dart';

enum SettingsStatus { initial, loading, success, failure }

@freezed
abstract class SettingsState with _$SettingsState {
  const SettingsState._();

  const factory SettingsState({
    @Default(SettingsStatus.initial) SettingsStatus status,
    Settings? settings,
    String? errorMessage,
  }) = _SettingsState;

  bool get isInitial => status == SettingsStatus.initial;

  bool get isLoading => status == SettingsStatus.loading;

  bool get isSuccess => status == SettingsStatus.success;

  bool get isFailure => status == SettingsStatus.failure;

  bool get hasSettings => settings != null;

  bool get hasError => (errorMessage?.isNotEmpty ?? false);

  Settings get effectiveSettings => settings ?? const Settings();
}
