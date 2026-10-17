part of '../logs.page.dart';

/// The one scroll view of the Logs page: the sync row, then the log entries, or
/// [placeholder] filling the rest when there are none to show. Pull to
/// refresh and the clearance under the primary action apply to all of it.
class const _LogsList({
  required final List<LogEntry> items,
  required final Map<String, UnsyncedLogEntryChange> unsyncedChanges,
  required final String? selectedLogEntryId,
  required final ValueChanged<String> onLogEntrySelected,
  required final Future<void> Function() onRefresh,
  final Widget? placeholder,
  super.key,
}) extends StatefulWidget {
  static const EdgeInsets _listPadding = .symmetric(vertical: 8);

  /// Rows before the first log entry: the sync row.
  static const int _leadingRowCount = 1;

  /// Half the gap between neighbouring log entries, shared with the sync row so
  /// every gap in the list is the same.
  static const EdgeInsets _logEntryMargin = .symmetric(vertical: 4);

  @override
  State<_LogsList> createState() => _LogsListState();
}

class _LogsListState extends State<_LogsList> {
  static const Duration _scrollDuration = Duration(milliseconds: 250);

  /// A list row is a preview, not the content. Capping the lines keeps every
  /// row a predictable height so a long log entry cannot push the rest off screen.
  static const int _titleMaxLines = 1;
  static const int _descriptionMaxLines = 2;

  /// Where a selected log entry is placed when it has to be moved. A split region
  /// shows the details beside the list, so centring keeps the selection next
  /// to what it opened. A compact region shows the list on its own, where the
  /// top reads as the natural resting place.
  static const double _splitLogEntryAlignment = 0.5;
  static const double _compactLogEntryAlignment = 0;

  final ScrollController _materialScrollController = ScrollController();

  /// Set while a log entry that was never on screen is being brought into view, so
  /// the intermediate jump that makes it merely visible does not count as
  /// having placed it.
  bool _isPlacingOffscreenLogEntry = false;
  final Map<String, GlobalKey> _itemKeys = {};

  /// Set while a pull to refresh runs. Its own spinner already says the
  /// Log entries are loading, so the placeholder steps aside.
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _scheduleSelectedLogEntryScroll();
  }

  @override
  void didUpdateWidget(_LogsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedLogEntryId != widget.selectedLogEntryId ||
        oldWidget.items != widget.items) {
      _scheduleSelectedLogEntryScroll();
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
    final bottomClearance = AppPrimaryActionPane.bottomClearanceOf(context);
    final placeholder = _isRefreshing ? null : widget.placeholder;

    return AppRefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: _LogsList._listPadding.copyWith(
              bottom: placeholder == null
                  ? _LogsList._listPadding.bottom + bottomClearance
                  : 0,
            ),
            sliver: SliverList.builder(
              itemCount: _LogsList._leadingRowCount + widget.items.length,
              itemBuilder: (context, index) =>
                  index < _LogsList._leadingRowCount
                  ? const _LogsSyncRow()
                  : _buildLogEntry(
                      widget.items[index - _LogsList._leadingRowCount],
                      theme,
                    ),
            ),
          ),
          if (placeholder != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: .only(bottom: bottomClearance),
                child: placeholder,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Widget _buildLogEntry(LogEntry item, ThemeData theme) {
    final isSelected = item.id == widget.selectedLogEntryId;
    final unsyncedChange = widget.unsyncedChanges[item.id];

    return Card(
      key: _itemKeyFor(item.id),
      margin: _LogsList._logEntryMargin,
      shape: isSelected ? _selectedLogEntryShape(theme) : null,
      clipBehavior: .antiAlias,
      child: InkWell(
        onTap: () => widget.onLogEntrySelected(item.id),
        child: Padding(
          padding: const .all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                spacing: 8,
                children: [
                  Flexible(
                    child: Text(
                      item.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: _titleMaxLines,
                      overflow: .ellipsis,
                    ),
                  ),
                  if (unsyncedChange != null)
                    _UnsyncedMarker(change: unsyncedChange),
                ],
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
  }

  /// Only selection is expressed here, as an outline. Colour and shape come
  /// from the design system's card theme, so the rows look the same wherever
  /// they are used.
  ShapeBorder _selectedLogEntryShape(ThemeData theme) {
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

  GlobalKey _itemKeyFor(String logEntryId) {
    return _itemKeys.putIfAbsent(logEntryId, () => GlobalKey());
  }

  void _scheduleSelectedLogEntryScroll() {
    final selectedLogEntryId = widget.selectedLogEntryId;
    if (selectedLogEntryId == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.selectedLogEntryId != selectedLogEntryId) {
        return;
      }

      _scrollSelectedLogEntryIntoView(selectedLogEntryId);
    });
  }

  void _scrollSelectedLogEntryIntoView(String selectedLogEntryId) {
    final selectedContext = _itemKeys[selectedLogEntryId]?.currentContext;
    if (selectedContext != null) {
      if (!_isPlacingOffscreenLogEntry && _isSettledInPlace(selectedContext)) {
        return;
      }

      _isPlacingOffscreenLogEntry = false;
      Scrollable.ensureVisible(
        selectedContext,
        duration: _scrollDuration,
        curve: Curves.easeOutCubic,
        alignment: _selectedLogEntryAlignment,
      );
      return;
    }

    _isPlacingOffscreenLogEntry = true;

    final selectedIndex = widget.items.indexWhere(
      (item) => item.id == selectedLogEntryId,
    );
    final position = _primaryScrollPosition;
    if (selectedIndex == -1 || position == null) {
      return;
    }

    final rowIndex = _LogsList._leadingRowCount + selectedIndex;
    final lastRowIndex = _LogsList._leadingRowCount + widget.items.length - 1;
    final targetOffset = position.maxScrollExtent * rowIndex / lastRowIndex;

    position.jumpTo(
      targetOffset.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
    _scheduleSelectedLogEntryScroll();
  }

  double get _selectedLogEntryAlignment {
    return PaneLayoutScope.of(context) == PaneLayoutMode.split
        ? _splitLogEntryAlignment
        : _compactLogEntryAlignment;
  }

  /// Whether the log entry is already somewhere the reader can live with: fully on
  /// screen and no higher than the halfway line. Moving it from there would
  /// scroll content the reader did not ask to lose.
  bool _isSettledInPlace(BuildContext logEntryContext) {
    final logEntryBox = logEntryContext.findRenderObject();
    final viewportBox = Scrollable.maybeOf(logEntryContext)?.context
        .findRenderObject();

    if (logEntryBox is! RenderBox ||
        viewportBox is! RenderBox ||
        !logEntryBox.hasSize ||
        !viewportBox.hasSize) {
      return false;
    }

    final top = logEntryBox
        .localToGlobal(Offset.zero, ancestor: viewportBox)
        .dy;
    final bottom = top + logEntryBox.size.height;
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

/// Marks a log entry whose change has not reached the Account yet.
class const _UnsyncedMarker({required final UnsyncedLogEntryChange change})
    extends StatelessWidget {
  static const double _dotSize = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = theme.colorScheme.secondary;

    return Row(
      mainAxisSize: .min,
      spacing: 4,
      children: [
        Icon(Icons.circle, size: _dotSize, color: color),
        Text(switch (change) {
          UnsyncedLogEntryChange.created => l10n.logsUnsyncedCreated,
          UnsyncedLogEntryChange.updated => l10n.logsUnsyncedUpdated,
        }, style: theme.textTheme.labelMedium?.copyWith(color: color)),
      ],
    );
  }
}
