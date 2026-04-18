part of 'app_preferences.cubit.dart';

enum AppPreferencesStatus { initial, loading, success, failure }

@freezed
abstract class AppPreferencesState with _$AppPreferencesState {
  const AppPreferencesState._();

  const factory AppPreferencesState({
    @Default(AppPreferencesStatus.initial) AppPreferencesStatus status,
    AppPreferences? appPreferences,
    String? errorMessage,
  }) = _AppPreferencesState;

  bool get isInitial => status == AppPreferencesStatus.initial;

  bool get isLoading => status == AppPreferencesStatus.loading;

  bool get isSuccess => status == AppPreferencesStatus.success;

  bool get isFailure => status == AppPreferencesStatus.failure;

  bool get hasAppPreferences => appPreferences != null;

  bool get hasError => (errorMessage?.isNotEmpty ?? false);

  AppPreferences get effectiveAppPreferences =>
      appPreferences ?? const AppPreferences();
}
