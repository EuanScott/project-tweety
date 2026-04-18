import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_tweety/domain/entities/settings.entity.dart'
    as settings_entity;
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

import 'bloc/settings.cubit.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.settingsTab,
      body: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if ((state.isInitial || state.isLoading) && !state.hasSettings) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isFailure && !state.hasSettings) {
          return _SettingsError(
            message: state.errorMessage ?? 'Something went wrong.',
          );
        }

        return _SettingsContent(settings: state.effectiveSettings);
      },
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({required this.settings});

  final settings_entity.Settings settings;

  @override
  Widget build(BuildContext context) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final effectiveThemeMode = _effectiveThemeMode(platformBrightness);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<settings_entity.SettingsThemeMode>(
          initialValue: settings.themeMode,
          decoration: InputDecoration(
            labelText: 'Theme',
            helperText: _themeModeHelperText(effectiveThemeMode),
          ),
          selectedItemBuilder: (context) {
            return settings_entity.SettingsThemeMode.values
                .map(
                  (themeMode) => Text(
                    _selectedThemeModeLabel(themeMode, effectiveThemeMode),
                  ),
                )
                .toList(growable: false);
          },
          items: settings_entity.SettingsThemeMode.values
              .map(
                (themeMode) => DropdownMenuItem(
                  value: themeMode,
                  child: Text(_themeModeLabel(themeMode)),
                ),
              )
              .toList(growable: false),
          onChanged: (themeMode) {
            if (themeMode == null) {
              return;
            }

            context.read<SettingsCubit>().updateThemeMode(themeMode);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: settings.languageCode,
          decoration: const InputDecoration(labelText: 'Language'),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'es', child: Text('Español')),
          ],
          onChanged: (languageCode) {
            if (languageCode == null) {
              return;
            }

            context.read<SettingsCubit>().updateLanguageCode(languageCode);
          },
        ),
      ],
    );
  }

  settings_entity.SettingsThemeMode _effectiveThemeMode(
    Brightness platformBrightness,
  ) {
    if (settings.themeMode != settings_entity.SettingsThemeMode.system) {
      return settings.themeMode;
    }

    return platformBrightness == Brightness.dark
        ? settings_entity.SettingsThemeMode.dark
        : settings_entity.SettingsThemeMode.light;
  }

  String _themeModeLabel(settings_entity.SettingsThemeMode themeMode) {
    switch (themeMode) {
      case settings_entity.SettingsThemeMode.system:
        return 'System';
      case settings_entity.SettingsThemeMode.light:
        return 'Light';
      case settings_entity.SettingsThemeMode.dark:
        return 'Dark';
    }
  }

  String _selectedThemeModeLabel(
    settings_entity.SettingsThemeMode themeMode,
    settings_entity.SettingsThemeMode effectiveThemeMode,
  ) {
    if (themeMode != settings_entity.SettingsThemeMode.system) {
      return _themeModeLabel(themeMode);
    }

    return 'System (${_themeModeLabel(effectiveThemeMode)})';
  }

  String _themeModeHelperText(
    settings_entity.SettingsThemeMode effectiveThemeMode,
  ) {
    if (settings.themeMode != settings_entity.SettingsThemeMode.system) {
      return 'Currently applied: ${_themeModeLabel(effectiveThemeMode)}';
    }

    return 'Following device setting: ${_themeModeLabel(effectiveThemeMode)}';
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                context.read<SettingsCubit>().loadSettings();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
