part of '../app_preferences.page.dart';

class const _AppPreferencesThemeColourPicker({
  required final app_preferences_entity.AppPreferencesThemeColour themeColour,
}) extends StatelessWidget {
  static const double _dotSize = 10;

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
                secondary: isDark
                    ? option.brand.secondaryDark
                    : option.brand.secondaryLight,
              ),
          ],
          onChanged: context.read<AppPreferencesCubit>().updateThemeColour,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _ColourDot(colour: colorScheme.primary),
            const SizedBox(width: 8),
            _ColourDot(colour: colorScheme.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${selected.name} · ${selected.colours}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: .w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
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

  ({String name, String colours, String description}) _copy(
    AppLocalizations l10n,
    app_preferences_entity.AppPreferencesThemeColour themeColour,
  ) {
    return switch (themeColour) {
      .fjord => (
        name: l10n.themeColourFjord,
        colours: l10n.themeColourFjordColours,
        description: l10n.themeColourFjordDescription,
      ),
      .fynbos => (
        name: l10n.themeColourFynbos,
        colours: l10n.themeColourFynbosColours,
        description: l10n.themeColourFynbosDescription,
      ),
      .kalahari => (
        name: l10n.themeColourKalahari,
        colours: l10n.themeColourKalahariColours,
        description: l10n.themeColourKalahariDescription,
      ),
      .lyng => (
        name: l10n.themeColourLyng,
        colours: l10n.themeColourLyngColours,
        description: l10n.themeColourLyngDescription,
      ),
      .whin => (
        name: l10n.themeColourWhin,
        colours: l10n.themeColourWhinColours,
        description: l10n.themeColourWhinDescription,
      ),
      .douro => (
        name: l10n.themeColourDouro,
        colours: l10n.themeColourDouroColours,
        description: l10n.themeColourDouroDescription,
      ),
      .cuillin => (
        name: l10n.themeColourCuillin,
        colours: l10n.themeColourCuillinColours,
        description: l10n.themeColourCuillinDescription,
      ),
    };
  }
}

class const _ColourDot({required final Color colour}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _AppPreferencesThemeColourPicker._dotSize,
      height: _AppPreferencesThemeColourPicker._dotSize,
      decoration: BoxDecoration(shape: .circle, color: colour),
    );
  }
}
