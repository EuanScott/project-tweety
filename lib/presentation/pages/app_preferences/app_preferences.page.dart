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

part 'widgets/app_preferences_content.widget.dart';
part 'widgets/app_preferences_error.widget.dart';

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
