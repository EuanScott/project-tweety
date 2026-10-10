import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart'
    as card_model
    show Card;
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation.extension.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.model.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.widget.dart';

import 'bloc/cards.bloc.dart';
import 'card_details/card_details.page.dart';
import 'draft_discard_guard.widget.dart';

part 'widgets/cards_empty.widget.dart';
part 'widgets/cards_error.widget.dart';
part 'widgets/cards_list.widget.dart';
part 'widgets/cards_sync_row.widget.dart';

// TODO: What about portrait tablet view mode?
// TODO: Editing on dual screen isn't giving weird stack behaviour
class const Cards({
  final String? selectedCardId,
  final bool isCreating = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  final GlobalKey<_CardsListState> _cardsListKey = GlobalKey<_CardsListState>();

  @override
  void initState() {
    super.initState();
    if (widget.isCreating) {
      context.read<CardsBloc>().add(const CardsCreateStarted());
    }
  }

  /// Cards locations can share one page, so moving to the editor may reuse
  /// this state rather than build a new one.
  @override
  void didUpdateWidget(Cards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCreating && !oldWidget.isCreating) {
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
          child: Builder(
            builder: (context) {
              final isSplit =
                  PaneLayoutScope.of(context) == PaneLayoutMode.split;
              final selectedCardId = widget.selectedCardId;

              if (!isSplit && widget.isCreating) {
                return PageScaffold(
                  title: l10n.cardCreateTitle,
                  body: const CardEditor(),
                );
              }

              if (!isSplit && selectedCardId != null) {
                return CardDetailsPage(cardId: selectedCardId);
              }

              return PageScaffold(
                title: l10n.cardsTab,
                impliesBackAction: false,
                titleBehavior: isSplit
                    ? PageTitleBehavior.largeStatic
                    : PageTitleBehavior.large,
                primaryAction: ToolBarIconAction(
                  icon: Icons.add,
                  tooltip: l10n.cardCreateAction,
                  onPressed: () => _createCard(context),
                ),
                showsPrimaryAction: !widget.isCreating,
                secondaryBody: widget.isCreating
                    ? const CardEditor()
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

  void _createCard(BuildContext context) {
    unawaited(CardsDraftDiscardGuard.discardThen(context, context.goNewCard));
  }

  void _selectCard(BuildContext context, String cardId) {
    unawaited(
      CardsDraftDiscardGuard.discardThen(
        context,
        () => context.goCardDetails(cardId),
      ),
    );
  }

  void _scrollToTop() {
    _cardsListKey.currentState?.scrollToTop();
  }
}

class const _CardsView({
  required final GlobalKey<_CardsListState> listKey,
  required final String? selectedCardId,
  required final ValueChanged<String> onCardSelected,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: buildWhen and listenWhen for small dedicated UI tasks (snackbar or only conditional rebuilds required)
    return BlocBuilder<CardsBloc, CardsState>(
      builder: (context, state) {
        if (state.isFailure) {
          return _CardsError(
            message: state.errorMessage ?? 'Something went wrong.',
          );
        }

        return _CardsList(
          key: listKey,
          items: state.items,
          unsyncedChanges: state.unsyncedChanges,
          selectedCardId: selectedCardId,
          onCardSelected: onCardSelected,
          onRefresh: () => _refreshCards(context),
          placeholder: _placeholderFor(state),
        );
      },
    );
  }

  /// What fills the page under the sync row when no Cards are showing.
  Widget? _placeholderFor(CardsState state) {
    if (state.hasItems) {
      return null;
    }

    if (state.isInitial || state.isLoading) {
      return const Center(child: AppLoadingIndicator());
    }

    return const _CardsEmpty();
  }

  Future<void> _refreshCards(BuildContext context) async {
    final bloc = context.read<CardsBloc>()..add(const CardsStarted());

    await bloc.stream.firstWhere((state) => !state.isLoading);
  }
}
