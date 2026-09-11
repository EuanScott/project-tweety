part of '../cards.page.dart';

class const _CardsList({
  required final List<card_model.Card> items,
  required final String? selectedCardId,
  required final ValueChanged<String> onCardSelected,
  required final Future<void> Function() onRefresh,
  super.key,
}) extends StatefulWidget {
  static const EdgeInsets _listPadding = .symmetric(vertical: 8);

  @override
  State<_CardsList> createState() => _CardsListState();
}

class _CardsListState extends State<_CardsList> {
  static const Duration _scrollDuration = Duration(milliseconds: 250);
  static const double _selectedCardElevation = 6;

  /// A list row is a preview, not the content. Capping the lines keeps every
  /// row a predictable height so a long card cannot push the rest off screen.
  static const int _titleMaxLines = 1;
  static const int _descriptionMaxLines = 2;

  /// Where a selected card is placed when it has to be moved. A split region
  /// shows the details beside the list, so centring keeps the selection next
  /// to what it opened. A compact region shows the list on its own, where the
  /// top reads as the natural resting place.
  static const double _splitCardAlignment = 0.5;
  static const double _compactCardAlignment = 0;

  final ScrollController _materialScrollController = ScrollController();

  /// Set while a card that was never on screen is being brought into view, so
  /// the intermediate jump that makes it merely visible does not count as
  /// having placed it.
  bool _isPlacingOffscreenCard = false;
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
            margin: const .symmetric(vertical: 8),
            shape: isSelected ? _selectedCardShape(theme) : null,
            elevation: isSelected ? _selectedCardElevation : null,
            clipBehavior: .antiAlias,
            child: InkWell(
              onTap: () => widget.onCardSelected(item.id),
              child: Padding(
                padding: const .all(16),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: _titleMaxLines,
                      overflow: .ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: _descriptionMaxLines,
                      overflow: .ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Only selection is expressed here. Colour, elevation, and the shadow that
  /// lifts a card off the page come from the design system's card theme, so
  /// cards look the same wherever they are used.
  ShapeBorder _selectedCardShape(ThemeData theme) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: theme.colorScheme.primary, width: 2),
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
      if (!_isPlacingOffscreenCard && _isSettledInPlace(selectedContext)) {
        return;
      }

      _isPlacingOffscreenCard = false;
      Scrollable.ensureVisible(
        selectedContext,
        duration: _scrollDuration,
        curve: Curves.easeOutCubic,
        alignment: _selectedCardAlignment,
      );
      return;
    }

    _isPlacingOffscreenCard = true;

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

  double get _selectedCardAlignment {
    return PaneLayoutScope.of(context) == PaneLayoutMode.split
        ? _splitCardAlignment
        : _compactCardAlignment;
  }

  /// Whether the card is already somewhere the reader can live with: fully on
  /// screen and no higher than the halfway line. Moving it from there would
  /// scroll content the reader did not ask to lose.
  bool _isSettledInPlace(BuildContext cardContext) {
    final cardBox = cardContext.findRenderObject();
    final viewportBox = Scrollable.maybeOf(
      cardContext,
    )?.context.findRenderObject();

    if (cardBox is! RenderBox ||
        viewportBox is! RenderBox ||
        !cardBox.hasSize ||
        !viewportBox.hasSize) {
      return false;
    }

    final top = cardBox.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
    final bottom = top + cardBox.size.height;
    final viewportHeight = viewportBox.size.height;

    final isFullyVisible = top >= 0 && bottom <= viewportHeight;
    final isBelowHalfway = top >= viewportHeight / 2;

    return isFullyVisible && isBelowHalfway;
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
