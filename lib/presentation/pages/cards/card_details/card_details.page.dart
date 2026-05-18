import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/domain/entities/card/card.entity.dart'
    as card_model;
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

import 'bloc/card_details.bloc.dart';

class CardDetailsPage extends StatelessWidget {
  const CardDetailsPage({required this.cardId, super.key});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.cardDetailsTitle,
      body: CardDetailsContent(cardId: cardId),
    );
  }
}

class CardDetailsContent extends StatelessWidget {
  const CardDetailsContent({required this.cardId, super.key});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(cardId),
      create: (_) =>
          GetIt.I<CardDetailsBloc>()..add(CardDetailsStarted(cardId)),
      child: const _CardDetailsView(),
    );
  }
}

class _CardDetailsView extends StatelessWidget {
  const _CardDetailsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CardDetailsBloc, CardDetailsState>(
      builder: (context, state) {
        if (state.isInitial || state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isFailure) {
          return _CardDetailsMessage(
            title: l10n.cardDetailsLoadFailedTitle,
            description:
                state.errorMessage ?? l10n.cardDetailsLoadFailedDescription,
          );
        }

        if (state.isMissing) {
          return _CardDetailsMessage(
            title: l10n.cardDetailsMissingTitle,
            description: l10n.cardDetailsMissingDescription,
          );
        }

        final card = state.card;
        if (card == null) {
          return _CardDetailsMessage(
            title: l10n.cardDetailsMissingTitle,
            description: l10n.cardDetailsMissingDescription,
          );
        }

        return _CardDetailsBody(card: card);
      },
    );
  }
}

class CardDetailsEmptyState extends StatelessWidget {
  const CardDetailsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _CardDetailsMessage(
      title: l10n.cardDetailsEmptyTitle,
      description: l10n.cardDetailsEmptyDescription,
    );
  }
}

class _CardDetailsBody extends StatelessWidget {
  const _CardDetailsBody({required this.card});

  final card_model.Card card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(card.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(card.description, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text(l10n.cardDetailsIdLabel, style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        SelectableText(card.id, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _CardDetailsMessage extends StatelessWidget {
  const _CardDetailsMessage({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
