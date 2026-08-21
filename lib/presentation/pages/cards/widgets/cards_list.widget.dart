part of '../cards.page.dart';

class const _CardsList({
  required final List<card_model.Card> items,
  required final String? selectedCardId,
  required final ValueChanged<String> onCardSelected,
  required final Future<void> Function() onRefresh,
  super.key,
}) extends StatefulWidget {
  static const EdgeInsets _listPadding = EdgeInsets.symmetric(vertical: 8);

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
