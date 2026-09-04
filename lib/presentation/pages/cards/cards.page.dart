import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

import 'bloc/cards.bloc.dart';
import 'card_details/card_details.page.dart';
import 'draft_discard_guard.dart';

part 'widgets/cards_editor.widget.dart';
part 'widgets/cards_empty.widget.dart';
part 'widgets/cards_error.widget.dart';
part 'widgets/cards_list.widget.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _flattenStackWhenSplit();
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
                  body: const _CardEditor(),
                );
              }

              if (!isSplit && selectedCardId != null) {
                return CardDetailsPage(cardId: selectedCardId);
              }

              return PageScaffold(
                title: l10n.cardsTab,
                titleBehavior: isSplit
                    ? PageTitleBehavior.largeStatic
                    : PageTitleBehavior.large,
                trailingAction: widget.isCreating
                    ? null
                    : ToolBarAction(
                        icon: Icons.add,
                        tooltip: l10n.cardCreateAction,
                        onPressed: () => _createCard(context, isSplit: isSplit),
                      ),
                secondaryBody: widget.isCreating
                    ? const _CardEditor()
                    : selectedCardId == null
                    ? const CardDetailsEmptyState()
                    : CardDetailsContent(cardId: selectedCardId),
                body: _CardsView(
                  listKey: _cardsListKey,
                  selectedCardId: selectedCardId,
                  onCardSelected: (cardId) =>
                      _selectCard(context, cardId, isSplit: isSplit),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _createCard(BuildContext context, {required bool isSplit}) {
    unawaited(
      CardsDraftDiscardGuard.discardThen(
        context,
        () => _navigateToNewCard(context, isSplit: isSplit),
      ),
    );
  }

  void _selectCard(
    BuildContext context,
    String cardId, {
    required bool isSplit,
  }) {
    unawaited(
      CardsDraftDiscardGuard.discardThen(
        context,
        () => _navigateToCard(context, cardId, isSplit: isSplit),
      ),
    );
  }

  /// A split region already shows the secondary pane the editor renders into,
  /// so opening the editor replaces the location. Pushing would play a page
  /// transition over a layout that never changed. In a compact region the
  /// editor is a page of its own and is pushed.
  void _navigateToNewCard(BuildContext context, {required bool isSplit}) {
    if (isSplit) {
      context.goNewCard();
      return;
    }

    unawaited(context.openNewCard());
  }

  /// Selecting a card in a split region changes which card the visible details
  /// pane shows, so it replaces the location instead of stacking a page. In a
  /// compact region the details are a page of their own and are pushed.
  void _navigateToCard(
    BuildContext context,
    String cardId, {
    required bool isSplit,
  }) {
    if (isSplit) {
      context.goCardDetails(cardId);
      return;
    }

    unawaited(context.openCardDetails(cardId));
  }

  /// A page pushed while the region was compact is still on the stack when the
  /// device unfolds or rotates into a split region, where the details already
  /// sit beside the list. Replacing the location drops that stale page so the
  /// back affordance does not outlive the layout that justified it.
  void _flattenStackWhenSplit() {
    final isTopmostPage = ModalRoute.of(context)?.isCurrent ?? false;

    if (!isTopmostPage ||
        PaneLayoutScope.of(context) != PaneLayoutMode.split ||
        !GoRouter.of(context).canPop()) {
      return;
    }

    final selectedCardId = widget.selectedCardId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (widget.isCreating) {
        context.goNewCard();
        return;
      }

      if (selectedCardId == null) {
        context.goCards();
        return;
      }

      context.goCardDetails(selectedCardId);
    });
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
