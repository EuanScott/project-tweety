import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/domain/entities/card.entity.dart'
    as card_model
    show Card;
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/widgets/app_bar.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

import 'bloc/cards.bloc.dart';

class Cards extends StatelessWidget {
  const Cards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<CardsBloc>()..add(const CardsStarted()),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;

          return PageScaffold(
            title: l10n.cardsTab,
            trailingAction: CustomAppBarAction(
              icon: Icons.refresh,
              tooltip: 'Refresh cards',
              onPressed: () {
                context.read<CardsBloc>().add(const CardsStarted());
              },
            ),
            body: const _CardsView(),
          );
        },
      ),
    );
  }
}

class _CardsView extends StatelessWidget {
  const _CardsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardsBloc, CardsState>(
      builder: (context, state) {
        if (state.isInitial || state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isFailure) {
          return _CardsError(
            message: state.errorMessage ?? 'Something went wrong.',
          );
        }

        return _CardsList(items: state.items);
      },
    );
  }
}

class _CardsList extends StatelessWidget {
  const _CardsList({required this.items});

  final List<card_model.Card> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: EdgeInsets.zero,
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
                Text(item.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(item.description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardsError extends StatelessWidget {
  const _CardsError({required this.message});

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
                context.read<CardsBloc>().add(const CardsStarted());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
