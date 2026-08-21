part of '../app_preferences.page.dart';

class const _AppPreferencesContent({
  required final app_preferences_entity.AppPreferences appPreferences,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final deviceThemeMode = _deviceThemeMode(platformBrightness);
    final effectiveLanguageLabel = _effectiveLanguageLabel(context);
    final direction = Directionality.of(context);

    return ListView(
      padding: const .all(16),
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
      case .system:
        return l10n.appPreferencesThemeSystem;
      case .light:
        return l10n.appPreferencesThemeLight;
      case .dark:
        return l10n.appPreferencesThemeDark;
    }
  }

  String _selectedThemeModeLabel(
    AppLocalizations l10n,
    app_preferences_entity.AppPreferencesThemeMode themeMode,
    app_preferences_entity.AppPreferencesThemeMode deviceThemeMode,
  ) {
    if (themeMode != .system) {
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
    if (appPreferences.themeMode != .system) {
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
      case .ltr:
        return l10n.appPreferencesDirectionLtr;
      case .rtl:
        return l10n.appPreferencesDirectionRtl;
    }
  }
}
