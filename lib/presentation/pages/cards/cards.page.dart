import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
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

// TODO: What about portrait tablet view mode?
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
    CardsDraftDiscardGuard.discardThen(
      context,
      () => _navigateToCard(context, cardId),
    );
  }

  void _navigateToCard(BuildContext context, String cardId) {
    if (widget.selectedCardId == null) {
      context.openCardDetails(cardId);
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

class _CardsEmpty extends StatelessWidget {
  const _CardsEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.cardCreateEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.cardCreateEmptyDescription, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton.primary(
              onPressed: () => CardsDraftDiscardGuard.discardThen(
                context,
                () => context.openNewCard(),
              ),
              child: Text(l10n.cardCreateAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardEditor extends StatefulWidget {
  const _CardEditor();

  @override
  State<_CardEditor> createState() => _CardEditorState();
}

class _CardEditorState extends State<_CardEditor> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          CardsDraftDiscardGuard.discardThen(context, context.goCards);
        }
      },
      child: BlocBuilder<CardsBloc, CardsState>(
        builder: (context, state) {
          final invalidDraftFields = state.invalidDraftFields;
          final isCreating = state.isCreating;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Text(
                l10n.cardCreateTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _titleController,
                label: l10n.cardCreateTitleLabel,
                enabled: !isCreating,
                errorText: invalidDraftFields.contains(CardDraftField.title)
                    ? l10n.cardCreateTitleRequired
                    : null,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _onDraftChanged(context),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: l10n.cardCreateDescriptionLabel,
                enabled: !isCreating,
                minLines: 4,
                maxLines: 6,
                errorText:
                    invalidDraftFields.contains(CardDraftField.description)
                    ? l10n.cardCreateDescriptionRequired
                    : null,
                textInputAction: TextInputAction.done,
                onChanged: (_) => _onDraftChanged(context),
              ),
              if (state.createError) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.cardCreateFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              AppButton.primary(
                onPressed: isCreating
                    ? null
                    : () => context.read<CardsBloc>().add(
                        const CardsCreateSubmitted(),
                      ),
                child: Text(l10n.cardCreateAction),
              ),
              const SizedBox(height: 12),
              AppButton.secondary(
                onPressed: isCreating
                    ? null
                    : () => CardsDraftDiscardGuard.discardThen(
                        context,
                        context.goCards,
                      ),
                child: Text(l10n.cardEditCancelAction),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onDraftChanged(BuildContext context) {
    context.read<CardsBloc>().add(
      CardsDraftChanged(
        CardDraft(
          title: _titleController.text,
          description: _descriptionController.text,
        ),
      ),
    );
  }
}

class _CardsList extends StatefulWidget {
  static const EdgeInsets _listPadding = EdgeInsets.symmetric(vertical: 8);

  const _CardsList({
    required this.items,
    required this.selectedCardId,
    required this.onCardSelected,
    required this.onRefresh,
    super.key,
  });

  final List<card_model.Card> items;
  final String? selectedCardId;
  final ValueChanged<String> onCardSelected;
  final Future<void> Function() onRefresh;

  @override
  State<_CardsList> createState() => _CardsListState();
}

class _CardsListState extends State<_CardsList> {
  static const Duration _scrollDuration = Duration(milliseconds: 250);

  final ScrollController _materialScrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    _scheduleSelectedCardScroll();
  }

  @override
  void didUpdateWidget(_CardsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedCardId != widget.selectedCardId ||
        oldWidget.items != widget.items) {
      _scheduleSelectedCardScroll();
    }
  }

  @override
  void dispose() {
    _materialScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scrollController = _scrollControllerFor(context);

    return AppRefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: _CardsList._listPadding,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = item.id == widget.selectedCardId;

          return Card(
            key: _itemKeyFor(item.id),
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: theme.cardTheme.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            elevation: 3,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => widget.onCardSelected(item.id),
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
            ),
          );
        },
      ),
    );
  }

  void scrollToTop() {
    final position = _primaryScrollPosition;
    if (position == null) {
      return;
    }

    position.animateTo(
      position.minScrollExtent,
      duration: _scrollDuration,
      curve: Curves.easeOutCubic,
    );
  }

  GlobalKey _itemKeyFor(String cardId) {
    return _itemKeys.putIfAbsent(cardId, () => GlobalKey());
  }

  void _scheduleSelectedCardScroll() {
    final selectedCardId = widget.selectedCardId;
    if (selectedCardId == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.selectedCardId != selectedCardId) {
        return;
      }

      _scrollSelectedCardIntoView(selectedCardId);
    });
  }

  void _scrollSelectedCardIntoView(String selectedCardId) {
    final selectedContext = _itemKeys[selectedCardId]?.currentContext;
    if (selectedContext != null) {
      Scrollable.ensureVisible(
        selectedContext,
        duration: _scrollDuration,
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
      return;
    }

    final selectedIndex = widget.items.indexWhere(
      (item) => item.id == selectedCardId,
    );
    final position = _primaryScrollPosition;
    if (selectedIndex == -1 || position == null) {
      return;
    }

    final targetOffset = widget.items.length <= 1
        ? position.minScrollExtent
        : position.maxScrollExtent * selectedIndex / (widget.items.length - 1);

    position.jumpTo(
      targetOffset.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
    _scheduleSelectedCardScroll();
  }

  ScrollPosition? get _primaryScrollPosition {
    final controller = _scrollControllerFor(context);
    if (controller == null || !controller.hasClients) {
      return null;
    }

    return controller.position;
  }

  ScrollController? _scrollControllerFor(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return PrimaryScrollController.maybeOf(context) ??
          _materialScrollController;
    }

    return _materialScrollController;
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
            AppButton.primary(
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
