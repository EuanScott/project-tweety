import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/domain/usecases/app_preferences/get_app_preferences.usecase.dart';
import 'package:project_tweety/domain/usecases/app_preferences/save_app_preferences.usecase.dart';

part 'app_preferences.state.dart';
part 'app_preferences.cubit.freezed.dart';

@injectable
class AppPreferencesCubit extends Cubit<AppPreferencesState> {
  AppPreferencesCubit(
    this._getAppPreferencesUseCase,
    this._saveAppPreferencesUseCase,
  ) : super(const AppPreferencesState());

  final GetAppPreferencesUseCase _getAppPreferencesUseCase;
  final SaveAppPreferencesUseCase _saveAppPreferencesUseCase;

  Future<void> loadAppPreferences() async {
    emit(
      state.copyWith(
        status: AppPreferencesStatus.loading,
        appPreferences: null,
        errorMessage: null,
      ),
    );

    try {
      final appPreferences = await _getAppPreferencesUseCase();

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
    final updatedAppPreferences = currentAppPreferences.copyWith(
      themeMode: themeMode,
    );

    await _persistAppPreferences(updatedAppPreferences);
  }

  Future<void> updateLanguageCode(String? languageCode) async {
    final currentAppPreferences = state.effectiveAppPreferences;
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
      await _saveAppPreferencesUseCase(appPreferences);
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
