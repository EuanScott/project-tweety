import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart'
    as card_model;
import 'package:project_tweety/data/repositories/card/cards.repository.dart'
    show CardDraft, CardDraftField;
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation_extensions.dart';
import 'package:project_tweety/presentation/pages/cards/bloc/cards.bloc.dart';
import 'package:project_tweety/presentation/pages/cards/draft_discard_guard.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

part 'widgets/card_details_body.widget.dart';
part 'widgets/card_details_editor.widget.dart';
part 'widgets/card_details_empty_state.widget.dart';
part 'widgets/card_details_message.widget.dart';

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
    return _CardDetailsView(cardId: cardId);
  }
}

class _CardDetailsView extends StatelessWidget {
  const _CardDetailsView({required this.cardId});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CardsBloc, CardsState>(
      builder: (context, state) {
        return switch (state.detailFor(cardId)) {
          CardsDetailLoading() => const Center(child: AppLoadingIndicator()),
          CardsDetailFailure(:final errorMessage) => _CardDetailsMessage(
            title: l10n.cardDetailsLoadFailedTitle,
            description: errorMessage,
          ),
          CardsDetailMissing() => _CardDetailsMessage(
            title: l10n.cardDetailsMissingTitle,
            description: l10n.cardDetailsMissingDescription,
          ),
          CardsDetailSuccess(:final card) => state.isEditingCard(cardId)
              ? _CardDetailsEditor(cardId: cardId)
              : _CardDetailsBody(card: card),
        };
      },
    );
  }
}
