import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_tweety/core/platform/system_text_settings.service.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart'
    as app_preferences_entity;
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

import 'app_language_options.dart';
import 'cubit/app_preferences.cubit.dart';

class AppPreferencesPage extends StatelessWidget {
  const AppPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.appPreferencesTitle,
      body: const _AppPreferencesView(),
    );
  }
}

class _AppPreferencesView extends StatelessWidget {
  const _AppPreferencesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
      buildWhen: _shouldRebuild,
      builder: (context, state) {
        if ((state.isInitial || state.isLoading) && !state.hasAppPreferences) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state.isFailure && !state.hasAppPreferences) {
          return _AppPreferencesError(
            message: state.errorMessage ?? 'Something went wrong.',
          );
        }

        return _AppPreferencesContent(
          appPreferences: state.effectiveAppPreferences,
        );
      },
    );
  }

  bool _shouldRebuild(
    AppPreferencesState previous,
    AppPreferencesState current,
  ) {
    final previousBlockingState = _hasBlockingState(previous);
    final currentBlockingState = _hasBlockingState(current);

    if (previousBlockingState || currentBlockingState) {
      return previous.status != current.status ||
          previous.hasAppPreferences != current.hasAppPreferences ||
          previous.errorMessage != current.errorMessage;
    }

    return previous.effectiveAppPreferences != current.effectiveAppPreferences;
  }

  bool _hasBlockingState(AppPreferencesState state) {
    final isInitialLoad =
        (state.isInitial || state.isLoading) && !state.hasAppPreferences;
    final isBlockingFailure = state.isFailure && !state.hasAppPreferences;

    return isInitialLoad || isBlockingFailure;
  }
}

class _AppPreferencesContent extends StatelessWidget {
  const _AppPreferencesContent({required this.appPreferences});

  final app_preferences_entity.AppPreferences appPreferences;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final deviceThemeMode = _deviceThemeMode(platformBrightness);
    final effectiveLanguageLabel = _effectiveLanguageLabel(context);
    final direction = Directionality.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppPickerField<app_preferences_entity.AppPreferencesThemeMode>(
          label: l10n.appPreferencesThemeLabel,
          helperText: _themeModeHelperText(l10n, deviceThemeMode),
          value: appPreferences.themeMode,
          options: app_preferences_entity.AppPreferencesThemeMode.values
              .map(
                (themeMode) => AppPickerOption(
                  value: themeMode,
                  label: _selectedThemeModeLabel(
                    l10n,
                    themeMode,
                    deviceThemeMode,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: context.read<AppPreferencesCubit>().updateThemeMode,
        ),
        const SizedBox(height: 16),
        AppPickerField<String?>(
          label: l10n.appPreferencesLanguageLabel,
          helperText: _languageHelperText(l10n, effectiveLanguageLabel),
          value: appPreferences.languageCode,
          options: [
            AppPickerOption<String?>(
              value: null,
              label: l10n.appPreferencesLanguageSystem,
            ),
            ...AppLanguageOptions.supported.map(
              (language) => AppPickerOption<String?>(
                value: language.languageCode,
                label: language.nativeLabel,
              ),
            ),
          ],
          onChanged: context.read<AppPreferencesCubit>().updateLanguageCode,
        ),
        const SizedBox(height: 16),
        AppListTile(
          title: Text(l10n.appPreferencesDirectionLabel),
          subtitle: Text(
            l10n.appPreferencesDirectionDescription(
              _directionLabel(l10n, direction),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppListTile(
          title: Text(l10n.appPreferencesSystemTextTitle),
          subtitle: Text(l10n.appPreferencesSystemTextDescription),
        ),
        const SizedBox(height: 8),
        AppButton.primary(
          onPressed: () => _openSystemTextSettings(context),
          child: Text(l10n.appPreferencesSystemTextButton),
        ),
      ],
    );
  }

  Future<void> _openSystemTextSettings(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final opened = await SystemTextSettingsService.open();

    if (!context.mounted || opened) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.appPreferencesSystemTextOpenFailed)),
    );
  }

  app_preferences_entity.AppPreferencesThemeMode _deviceThemeMode(
    Brightness platformBrightness,
  ) {
    return platformBrightness == Brightness.dark
        ? app_preferences_entity.AppPreferencesThemeMode.dark
        : app_preferences_entity.AppPreferencesThemeMode.light;
  }

  String _themeModeLabel(
    AppLocalizations l10n,
    app_preferences_entity.AppPreferencesThemeMode themeMode,
  ) {
    switch (themeMode) {
      case app_preferences_entity.AppPreferencesThemeMode.system:
        return l10n.appPreferencesThemeSystem;
      case app_preferences_entity.AppPreferencesThemeMode.light:
        return l10n.appPreferencesThemeLight;
      case app_preferences_entity.AppPreferencesThemeMode.dark:
        return l10n.appPreferencesThemeDark;
    }
  }

  String _selectedThemeModeLabel(
    AppLocalizations l10n,
    app_preferences_entity.AppPreferencesThemeMode themeMode,
    app_preferences_entity.AppPreferencesThemeMode deviceThemeMode,
  ) {
    if (themeMode != app_preferences_entity.AppPreferencesThemeMode.system) {
      return _themeModeLabel(l10n, themeMode);
    }

    return l10n.appPreferencesThemeSystemSelected(
      _themeModeLabel(l10n, deviceThemeMode),
    );
  }

  String _themeModeHelperText(
    AppLocalizations l10n,
    app_preferences_entity.AppPreferencesThemeMode deviceThemeMode,
  ) {
    if (appPreferences.themeMode !=
        app_preferences_entity.AppPreferencesThemeMode.system) {
      return l10n.appPreferencesThemeDeviceSetting(
        _themeModeLabel(l10n, deviceThemeMode),
      );
    }

    return l10n.appPreferencesThemeFollowingSystem(
      _themeModeLabel(l10n, deviceThemeMode),
    );
  }

  String _languageHelperText(
    AppLocalizations l10n,
    String effectiveLanguageLabel,
  ) {
    if (appPreferences.languageCode != null) {
      return l10n.appPreferencesLanguageApplied(effectiveLanguageLabel);
    }

    return l10n.appPreferencesLanguageFollowingSystem(effectiveLanguageLabel);
  }

  String _effectiveLanguageLabel(BuildContext context) {
    final effectiveLocale = Localizations.localeOf(context);

    return AppLanguageOptions.labelForLanguageCode(
      effectiveLocale.languageCode,
    );
  }

  String _directionLabel(AppLocalizations l10n, TextDirection direction) {
    switch (direction) {
      case TextDirection.ltr:
        return l10n.appPreferencesDirectionLtr;
      case TextDirection.rtl:
        return l10n.appPreferencesDirectionRtl;
    }
  }
}

class _AppPreferencesError extends StatelessWidget {
  const _AppPreferencesError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            AppButton.primary(
              onPressed: () {
                context.read<AppPreferencesCubit>().loadAppPreferences();
              },
              child: Text(l10n.appPreferencesRetry),
            ),
          ],
        ),
      ),
    );
  }
}
