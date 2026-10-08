part of '../app_preferences.page.dart';

class const _AppPreferencesContent({
  required final app_preferences_entity.AppPreferences appPreferences,
}) extends StatelessWidget {
  static const double _maxContentWidth = 600;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AppPreferencesCubit>();

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              AppPageIntro(description: l10n.appPreferencesIntro),
              AppListSection(
                header: l10n.appPreferencesThemeLabel,
                children: [
                  AppListSectionContent(
                    child: SizedBox(
                      width: double.infinity,
                      child:
                          AppSegmentedControl<
                            app_preferences_entity.AppPreferencesThemeMode
                          >(
                            value: appPreferences.themeMode,
                            segments: [
                              for (final themeMode
                                  in app_preferences_entity
                                      .AppPreferencesThemeMode
                                      .values)
                                AppPickerOption(
                                  value: themeMode,
                                  label: _themeModeLabel(l10n, themeMode),
                                ),
                            ],
                            onChanged: cubit.updateThemeMode,
                          ),
                    ),
                  ),
                  AppListSectionContent(
                    title: l10n.appPreferencesThemeColourLabel,
                    child: _AppPreferencesThemeColourPicker(
                      themeColour: appPreferences.themeColour,
                    ),
                  ),
                ],
              ),
              AppListSection(
                header: l10n.appPreferencesLanguageLabel,
                footer: _languageFooter(context, l10n),
                children: [
                  AppSelectionRow<String?>(
                    title: l10n.appPreferencesLanguageLabel,
                    value: appPreferences.languageCode,
                    options: [
                      AppPickerOption<String?>(
                        value: null,
                        label: l10n.appPreferencesLanguageSystem,
                      ),
                      for (final language in AppLanguageOptions.supported)
                        AppPickerOption<String?>(
                          value: language.languageCode,
                          label: language.nativeLabel,
                        ),
                    ],
                    onChanged: cubit.updateLanguageCode,
                  ),
                ],
              ),
              AppListSection(
                header: l10n.appPreferencesTextDisplayHeader,
                footer: l10n.appPreferencesTextSizeFooter,
                children: [
                  AppListTile(
                    title: Text(l10n.appPreferencesTextSizeRow),
                    opensOtherApp: true,
                    onTap: () => _openSystemTextSettings(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  String _languageFooter(BuildContext context, AppLocalizations l10n) {
    if (appPreferences.languageCode != null) {
      return l10n.appPreferencesDirectionFooter;
    }

    final effectiveLanguageLabel = AppLanguageOptions.labelForLanguageCode(
      Localizations.localeOf(context).languageCode,
    );

    return '${l10n.appPreferencesLanguageFollowingSystem(effectiveLanguageLabel)} '
        '${l10n.appPreferencesDirectionFooter}';
  }
}
