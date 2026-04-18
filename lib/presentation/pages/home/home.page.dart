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
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.read<HomeBloc>().add(
                    const HomeActionPressed(HomeAction.cancel),
                  );
                },
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<HomeBloc>().add(
                    const HomeActionPressed(HomeAction.next),
                  );
                },
                child: const Text('Next'),
              ),
            ),
          ],
        ),
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
        const Text('Modals'),
        TextButton(
          child: const Text('Context Modal'),
          onPressed: () {
            context.showAppModal(const Center(child: Text('Modal content')));
          },
        ),
        TextButton(
          child: const Text('Page Modal'),
          onPressed: () {
            AppModal.page<bool>(
              context: context,
              child: const Center(child: Text('Modal content')),
            );
          },
        ),
        TextButton(
          child: const Text('Blocking Modal'),
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
        ),
        TextButton(
          child: const Text('Compact Modal'),
          onPressed: () async {
            await AppModal.compact<bool>(
              context: context,
              maxHeightFactor: 0.35,
              child: const Center(child: Text('Modal content')),
            );
          },
        ),
        TextButton(
          child: const Text('Blocking Modal'),
          onPressed: () async {
            final result = await WebviewModal.show(
              context,
              'https://euanscott.github.io/tester.html',
            );

            if (result != null) {
              log('User result: $result');
            }
          },
        ),
      ],
    );
  }
}
