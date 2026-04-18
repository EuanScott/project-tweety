import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_tweety/domain/entities/app_preferences.entity.dart'
    as app_preferences_entity;
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

import 'bloc/app_preferences.cubit.dart';

// TODO: Update the docs to also include the cubit
// TODO: Update docs so that nested pages exist within a parents page? (unsure about this one)

class AppPreferencesPage extends StatelessWidget {
  const AppPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'App preferences',
      body: _AppPreferencesView(),
    );
  }
}

class _AppPreferencesView extends StatelessWidget {
  const _AppPreferencesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
      builder: (context, state) {
        if ((state.isInitial || state.isLoading) && !state.hasAppPreferences) {
          return const Center(child: CircularProgressIndicator());
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
}

class _AppPreferencesContent extends StatelessWidget {
  const _AppPreferencesContent({required this.appPreferences});

  final app_preferences_entity.AppPreferences appPreferences;

  @override
  Widget build(BuildContext context) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final effectiveThemeMode = _effectiveThemeMode(platformBrightness);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<app_preferences_entity.AppPreferencesThemeMode>(
          initialValue: appPreferences.themeMode,
          decoration: InputDecoration(
            labelText: 'Theme',
            helperText: _themeModeHelperText(effectiveThemeMode),
          ),
          selectedItemBuilder: (context) {
            return app_preferences_entity.AppPreferencesThemeMode.values
                .map(
                  (themeMode) => Text(
                    _selectedThemeModeLabel(themeMode, effectiveThemeMode),
                  ),
                )
                .toList(growable: false);
          },
          items: app_preferences_entity.AppPreferencesThemeMode.values
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

            context.read<AppPreferencesCubit>().updateThemeMode(themeMode);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: appPreferences.languageCode,
          decoration: const InputDecoration(labelText: 'Language'),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'es', child: Text('Español')),
          ],
          onChanged: (languageCode) {
            if (languageCode == null) {
              return;
            }

            context.read<AppPreferencesCubit>().updateLanguageCode(languageCode);
          },
        ),
      ],
    );
  }

  app_preferences_entity.AppPreferencesThemeMode _effectiveThemeMode(
    Brightness platformBrightness,
  ) {
    if (appPreferences.themeMode !=
        app_preferences_entity.AppPreferencesThemeMode.system) {
      return appPreferences.themeMode;
    }

    return platformBrightness == Brightness.dark
        ? app_preferences_entity.AppPreferencesThemeMode.dark
        : app_preferences_entity.AppPreferencesThemeMode.light;
  }

  String _themeModeLabel(
    app_preferences_entity.AppPreferencesThemeMode themeMode,
  ) {
    switch (themeMode) {
      case app_preferences_entity.AppPreferencesThemeMode.system:
        return 'System';
      case app_preferences_entity.AppPreferencesThemeMode.light:
        return 'Light';
      case app_preferences_entity.AppPreferencesThemeMode.dark:
        return 'Dark';
    }
  }

  String _selectedThemeModeLabel(
    app_preferences_entity.AppPreferencesThemeMode themeMode,
    app_preferences_entity.AppPreferencesThemeMode effectiveThemeMode,
  ) {
    if (themeMode != app_preferences_entity.AppPreferencesThemeMode.system) {
      return _themeModeLabel(themeMode);
    }

    return 'System (${_themeModeLabel(effectiveThemeMode)})';
  }

  String _themeModeHelperText(
    app_preferences_entity.AppPreferencesThemeMode effectiveThemeMode,
  ) {
    if (appPreferences.themeMode !=
        app_preferences_entity.AppPreferencesThemeMode.system) {
      return 'Currently applied: ${_themeModeLabel(effectiveThemeMode)}';
    }

    return 'Following device setting: ${_themeModeLabel(effectiveThemeMode)}';
  }
}

class _AppPreferencesError extends StatelessWidget {
  const _AppPreferencesError({required this.message});

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
                context.read<AppPreferencesCubit>().loadAppPreferences();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
