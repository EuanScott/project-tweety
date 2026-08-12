import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/domain/repositories/app_preferences/app_preferences.repository.dart';

part 'app_preferences.state.dart';
part 'app_preferences.cubit.freezed.dart';

@injectable
class AppPreferencesCubit extends Cubit<AppPreferencesState> {
  AppPreferencesCubit(this._repository) : super(const AppPreferencesState());

  final AppPreferencesRepository _repository;

  Future<void> loadAppPreferences() async {
    emit(
      state.copyWith(
        status: AppPreferencesStatus.loading,
        appPreferences: null,
        errorMessage: null,
      ),
    );

    try {
      final appPreferences = await _repository.getAppPreferences();

      emit(
        state.copyWith(
          status: AppPreferencesStatus.success,
          appPreferences: appPreferences,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: AppPreferencesStatus.failure,
          appPreferences: null,
          errorMessage: 'Unable to load app preferences right now.',
        ),
      );
    }
  }

  Future<void> updateThemeMode(AppPreferencesThemeMode themeMode) async {
    final currentAppPreferences = state.effectiveAppPreferences;
    if (currentAppPreferences.themeMode == themeMode) {
      return;
    }

    final updatedAppPreferences = currentAppPreferences.copyWith(
      themeMode: themeMode,
    );

    await _persistAppPreferences(updatedAppPreferences);
  }

  Future<void> updateLanguageCode(String? languageCode) async {
    final currentAppPreferences = state.effectiveAppPreferences;
    if (currentAppPreferences.languageCode == languageCode) {
      return;
    }

    final updatedAppPreferences = currentAppPreferences.copyWith(
      languageCode: languageCode,
    );

    await _persistAppPreferences(updatedAppPreferences);
  }

  Future<void> _persistAppPreferences(AppPreferences appPreferences) async {
    emit(
      state.copyWith(
        status: AppPreferencesStatus.success,
        appPreferences: appPreferences,
        errorMessage: null,
      ),
    );

    try {
      await _repository.saveAppPreferences(appPreferences);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: AppPreferencesStatus.success,
          errorMessage: 'Unable to save app preferences right now.',
        ),
      );
    }
  }
}
