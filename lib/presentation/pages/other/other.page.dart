import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/domain/entities/other_card_item.dart';

import 'bloc/other_bloc.dart';

class Other extends StatelessWidget {
  const Other({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<OtherBloc>()..add(const OtherStarted()),
      child: const _OtherView(),
    );
  }
}

class _OtherView extends StatelessWidget {
  const _OtherView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtherBloc, OtherState>(
      builder: (context, state) {
        if (state.isInitial || state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isFailure) {
          return _OtherError(
            message: state.errorMessage ?? 'Something went wrong.',
          );
        }

        return _OtherList(items: state.items);
      },
    );
  }
}

class _OtherList extends StatelessWidget {
  const _OtherList({required this.items});

  final List<OtherCardItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OtherError extends StatelessWidget {
  const _OtherError({required this.message});

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
                context.read<OtherBloc>().add(const OtherStarted());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
