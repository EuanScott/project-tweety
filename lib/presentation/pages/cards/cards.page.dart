import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart'
    as card_model
    show Card;
import 'package:project_tweety/data/repositories/card/cards.repository.dart'
    show CardDraft, CardDraftField;
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation_extensions.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';
import 'package:project_tweety/presentation/widgets/tool_bar.dart';

import 'bloc/cards.bloc.dart';
import 'card_details/card_details.page.dart';
import 'draft_discard_guard.dart';

part 'widgets/cards_editor.widget.dart';
part 'widgets/cards_empty.widget.dart';
part 'widgets/cards_error.widget.dart';
part 'widgets/cards_list.widget.dart';

// TODO: What about portrait tablet view mode?
// TODO: Editing on dual screen isn't giving weird stack behaviour
class Cards extends StatefulWidget {
  const Cards({this.selectedCardId, this.isCreating = false, super.key});

  final String? selectedCardId;
  final bool isCreating;

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  static const double _secondaryBreakpoint = 600;

  final GlobalKey<_CardsListState> _cardsListKey = GlobalKey<_CardsListState>();

  @override
  void initState() {
    super.initState();
    if (widget.isCreating) {
      context.read<CardsBloc>().add(const CardsCreateStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CardsDraftDiscardGuard(
      child: BlocListener<CardsBloc, CardsState>(
        listenWhen: (previous, current) =>
            (previous.createdCardId != current.createdCardId &&
                current.createdCardId != null) ||
            (previous.deletedCardId != current.deletedCardId &&
                current.deletedCardId != null),
        listener: (context, state) {
          final createdCardId = state.createdCardId;
          if (createdCardId != null) {
            context.goCardDetails(createdCardId);
            return;
          }
          context.goCards();
        },
        child: TabReselectHandler(
          tab: AppTab.cards,
          onReselect: _scrollToTop,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showSecondary = PageScaffold.usesSplitPaneLayout(
                context,
                constraints,
                secondaryBreakpoint: _secondaryBreakpoint,
              );
              final selectedCardId = widget.selectedCardId;

              if (!showSecondary && widget.isCreating) {
                return PageScaffold(
                  title: l10n.cardCreateTitle,
                  body: const _CardEditor(),
                );
              }

              if (!showSecondary && selectedCardId != null) {
                return CardDetailsPage(cardId: selectedCardId);
              }

              return PageScaffold(
                title: l10n.cardsTab,
                titleBehavior: showSecondary
                    ? PageTitleBehavior.largeStatic
                    : PageTitleBehavior.large,
                secondaryBreakpoint: _secondaryBreakpoint,
                trailingAction: widget.isCreating
                    ? null
                    : ToolBarAction(
                        icon: Icons.add,
                        tooltip: l10n.cardCreateAction,
                        onPressed: () => CardsDraftDiscardGuard.discardThen(
                          context,
                          () => context.openNewCard(),
                        ),
                      ),
                secondaryBody: widget.isCreating
                    ? const _CardEditor()
                    : selectedCardId == null
                    ? const CardDetailsEmptyState()
                    : CardDetailsContent(cardId: selectedCardId),
                body: _CardsView(
                  listKey: _cardsListKey,
                  selectedCardId: selectedCardId,
                  onCardSelected: (cardId) => _selectCard(context, cardId),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _selectCard(BuildContext context, String cardId) {
    unawaited(
      CardsDraftDiscardGuard.discardThen(
        context,
        () => _navigateToCard(context, cardId),
      ),
    );
  }

  void _navigateToCard(BuildContext context, String cardId) {
    if (widget.selectedCardId == null) {
      unawaited(context.openCardDetails(cardId));
      return;
    }

    context.goCardDetails(cardId);
  }

  void _scrollToTop() {
    _cardsListKey.currentState?.scrollToTop();
  }
}

class _CardsView extends StatelessWidget {
  const _CardsView({
    required this.listKey,
    required this.selectedCardId,
    required this.onCardSelected,
  });

  final GlobalKey<_CardsListState> listKey;
  final String? selectedCardId;
  final ValueChanged<String> onCardSelected;

  @override
  Widget build(BuildContext context) {
    // TODO: buildWhen and listenWhen for small dedicated UI tasks (snackbar or only conditional rebuilds required)
    return BlocBuilder<CardsBloc, CardsState>(
      builder: (context, state) {
        if (state.isInitial || state.isLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state.isFailure) {
          return _CardsError(
            message: state.errorMessage ?? 'Something went wrong.',
          );
        }

        if (!state.hasItems) {
          return const _CardsEmpty();
        }

        return _CardsList(
          key: listKey,
          items: state.items,
          selectedCardId: selectedCardId,
          onCardSelected: onCardSelected,
          onRefresh: () => _refreshCards(context),
        );
      },
    );
  }

  Future<void> _refreshCards(BuildContext context) async {
    final bloc = context.read<CardsBloc>()..add(const CardsStarted());

    await bloc.stream.firstWhere((state) => !state.isLoading);
  }
}
