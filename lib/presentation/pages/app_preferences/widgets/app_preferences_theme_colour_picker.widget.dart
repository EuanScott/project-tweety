part of '../app_preferences.page.dart';

class const _AppPreferencesThemeColourPicker({
  required final app_preferences_entity.AppPreferencesThemeColour themeColour,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == .dark;
    final colorScheme = theme.colorScheme;
    final selected = _copy(l10n, themeColour);

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        AppSwatchPicker<app_preferences_entity.AppPreferencesThemeColour>(
          value: themeColour,
          options: [
            for (final option
                in app_preferences_entity.AppPreferencesThemeColour.values)
              AppSwatchOption(
                value: option,
                label: _copy(l10n, option).name,
                primary: isDark
                    ? option.brand.primaryDark
                    : option.brand.primaryLight,
              ),
          ],
          onChanged: context.read<AppPreferencesCubit>().updateThemeColour,
        ),
        const SizedBox(height: 10),
        Semantics(
          liveRegion: true,
          child: Text(
            selected.description,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  ({String name, String description}) _copy(
    AppLocalizations l10n,
    app_preferences_entity.AppPreferencesThemeColour themeColour,
  ) {
    return switch (themeColour) {
      .fjord => (
        name: l10n.themeColourFjord,
        description: l10n.themeColourFjordDescription,
      ),
      .fynbos => (
        name: l10n.themeColourFynbos,
        description: l10n.themeColourFynbosDescription,
      ),
      .kalahari => (
        name: l10n.themeColourKalahari,
        description: l10n.themeColourKalahariDescription,
      ),
      .lyng => (
        name: l10n.themeColourLyng,
        description: l10n.themeColourLyngDescription,
      ),
      .whin => (
        name: l10n.themeColourWhin,
        description: l10n.themeColourWhinDescription,
      ),
      .douro => (
        name: l10n.themeColourDouro,
        description: l10n.themeColourDouroDescription,
      ),
      .cuillin => (
        name: l10n.themeColourCuillin,
        description: l10n.themeColourCuillinDescription,
      ),
    };
  }
}
