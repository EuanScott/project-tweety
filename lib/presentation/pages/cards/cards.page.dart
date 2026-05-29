import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/domain/entities/card/card.entity.dart'
    as card_model
    show Card;
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation_extensions.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

import 'bloc/cards.bloc.dart';
import 'card_details/card_details.page.dart';

// TODO: What about portrait tablet view mode?
class Cards extends StatefulWidget {
  const Cards({this.selectedCardId, super.key});

  final String? selectedCardId;

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  static const double _secondaryBreakpoint = 600;

  final GlobalKey<_CardsListState> _cardsListKey = GlobalKey<_CardsListState>();
  late String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    _selectedCardId = widget.selectedCardId;
  }

  @override
  void didUpdateWidget(Cards oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedCardId != widget.selectedCardId) {
      _selectedCardId = widget.selectedCardId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<CardsBloc>()..add(const CardsStarted()),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;

          return TabReselectHandler(
            tab: AppTab.cards,
            onReselect: _scrollToTop,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showSecondary = PageScaffold.usesSplitPaneLayout(
                  context,
                  constraints,
                  secondaryBreakpoint: _secondaryBreakpoint,
                );
                final selectedCardId = _selectedCardId;

                if (!showSecondary && widget.selectedCardId != null) {
                  return CardDetailsPage(cardId: widget.selectedCardId!);
                }

                return PageScaffold(
                  title: l10n.cardsTab,
                  titleBehavior: showSecondary
                      ? PageTitleBehavior.largeStatic
                      : PageTitleBehavior.large,
                  secondaryBreakpoint: _secondaryBreakpoint,
                  secondaryBody: selectedCardId == null
                      ? const CardDetailsEmptyState()
                      : CardDetailsContent(cardId: selectedCardId),
                  body: _CardsView(
                    listKey: _cardsListKey,
                    selectedCardId: selectedCardId,
                    onCardSelected: (cardId) => _selectCard(
                      context,
                      cardId,
                      showSecondary: showSecondary,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _selectCard(
    BuildContext context,
    String cardId, {
    required bool showSecondary,
  }) {
    if (showSecondary) {
      // TODO: Remove this setState in favour of bloc state
      setState(() {
        _selectedCardId = cardId;
      });
      return;
    }

    context.openCardDetails(cardId);
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
