import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/settings.entity.dart';
import 'package:project_tweety/domain/usecases/get_settings.usecase.dart';
import 'package:project_tweety/domain/usecases/save_settings.usecase.dart';

part 'settings.state.dart';
part 'settings.cubit.freezed.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
    this._getSettingsUseCase,
    this._saveSettingsUseCase,
  ) : super(const SettingsState());

  final GetSettingsUseCase _getSettingsUseCase;
  final SaveSettingsUseCase _saveSettingsUseCase;

  Future<void> loadSettings() async {
    emit(
      state.copyWith(
        status: SettingsStatus.loading,
        settings: null,
        errorMessage: null,
      ),
    );

    try {
      final settings = await _getSettingsUseCase();

      emit(
        state.copyWith(
          status: SettingsStatus.success,
          settings: settings,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          settings: null,
          errorMessage: 'Unable to load settings right now.',
        ),
      );
    }
  }

  Future<void> updateThemeMode(SettingsThemeMode themeMode) async {
    final currentSettings = state.effectiveSettings;
    final updatedSettings = currentSettings.copyWith(themeMode: themeMode);

    await _persistSettings(updatedSettings);
  }

  Future<void> updateLanguageCode(String languageCode) async {
    final currentSettings = state.effectiveSettings;
    final updatedSettings = currentSettings.copyWith(
      languageCode: languageCode,
    );

    await _persistSettings(updatedSettings);
  }

  Future<void> _persistSettings(Settings settings) async {
    emit(
      state.copyWith(
        status: SettingsStatus.success,
        settings: settings,
        errorMessage: null,
      ),
    );

    try {
      await _saveSettingsUseCase(settings);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: SettingsStatus.success,
          errorMessage: 'Unable to save settings right now.',
        ),
      );
    }
  }
}
