import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

import '../../extensions/modal_extension.dart';
import '../../widgets/app_modal.dart';
import '../../widgets/webview_modal.dart';
import 'bloc/home_bloc.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => GetIt.I<HomeBloc>()..add(const HomeStarted()),
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) =>
            previous.lastAction != current.lastAction && current.hasLastAction,
        listener: (context, state) {
          final action = state.lastAction;

          if (action != null) {
            log('Home action pressed: $action');
          }
        },
        child: PageScaffold(title: l10n.homeTab, body: const _HomeView()),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // TODO: Better usecase widgets for things like buttons so that the robots doesn't invent anything
        // TODO: Maybe make list of implemented widgets to view, rather than everything on this page (UI library vibes)
        const _PrimaryActions(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.read<HomeBloc>().add(
              const HomeActionPressed(HomeAction.primary),
            );
          },
          child: const Text('Button'),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            context.read<HomeBloc>().add(
              const HomeActionPressed(HomeAction.secondary),
            );
          },
          child: const Text('Button'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            context.read<HomeBloc>().add(
              const HomeActionPressed(HomeAction.back),
            );
          },
          child: const Text('Back'),
        ),
        const SizedBox(height: 32),
        Text('Modals', style: theme.textTheme.headlineSmall),
        TextButton(
          onPressed: () {
            context.showAppModal(const Center(child: Text('Modal content')));
          },
          child: const Text('Context Modal'),
        ),
        TextButton(
          onPressed: () {
            AppModal.page<bool>(
              context: context,
              child: const Center(child: Text('Modal content')),
            );
          },
          child: const Text('Page Modal'),
        ),
        TextButton(
          onPressed: () {
            AppModal.blocking<bool>(
              context: context,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Close Modal'),
                ),
              ),
            );
          },
          child: const Text('Blocking Modal'),
        ),
        TextButton(
          onPressed: () async {
            await AppModal.compact<bool>(
              context: context,
              maxHeightFactor: 0.35,
              child: const Center(child: Text('Modal content')),
            );
          },
          child: const Text('Compact Modal'),
        ),
        TextButton(
          onPressed: () async {
            final result = await WebviewModal.show(
              context,
              'https://euanscott.github.io/tester.html',
            );

            if (result != null) {
              log('User result: $result');
            }
          },
          child: const Text('Blocking Modal'),
        ),
      ],
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions();

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    final useVerticalLayout = textScaleFactor >= 1.4;

    final cancelButton = OutlinedButton(
      onPressed: () {
        context.read<HomeBloc>().add(
          const HomeActionPressed(HomeAction.cancel),
        );
      },
      child: const Text('Cancel', textAlign: TextAlign.center),
    );
    final nextButton = ElevatedButton(
      onPressed: () {
        context.read<HomeBloc>().add(const HomeActionPressed(HomeAction.next));
      },
      child: const Text('Next', textAlign: TextAlign.center),
    );

    if (useVerticalLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [cancelButton, const SizedBox(height: 12), nextButton],
      );
    }

    return Row(
      children: [
        Expanded(child: cancelButton),
        const SizedBox(width: 16),
        Expanded(child: nextButton),
      ],
    );
  }
}
