import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'bloc/home_bloc.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: const _HomeView(),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
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
        ],
      ),
    );
  }
}
