import 'package:flutter/widgets.dart';
import 'package:navigation/src/tab_reselect/tab_reselect_controller.dart';
import 'package:navigation/src/tab_reselect/tab_reselect_scope.dart';

/// Registers a page-owned callback for active-tab taps.
///
/// Use this on a tab's root page when tapping the already-selected bottom
/// navigation item should perform page-specific work, such as scrolling a list
/// to the top. The navigation shell only runs these callbacks while the tab is
/// already on its root route.
/// Creates a handler that registers [onReselect] for [tab].
class const TabReselectHandler<TTab extends Object>({
  /// The root tab this handler belongs to.
  required final TTab tab,

  /// Callback invoked when the user taps the active tab on its root route.
  required final VoidCallback onReselect,

  /// The page subtree that owns the callback lifecycle.
  required final Widget child,
  super.key,
}) extends StatefulWidget {
  @override
  State<TabReselectHandler<TTab>> createState() =>
      _TabReselectHandlerState<TTab>();
}

class _TabReselectHandlerState<TTab extends Object>
    extends State<TabReselectHandler<TTab>> {
  TabReselectController<TTab>? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final controller = TabReselectScope.maybeOf<TTab>(context);

    if (controller == _controller) {
      return;
    }

    _controller?.unregister(widget.tab, widget.onReselect);
    _controller = controller;
    _controller?.register(widget.tab, widget.onReselect);
  }

  @override
  void didUpdateWidget(TabReselectHandler<TTab> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tab == widget.tab &&
        oldWidget.onReselect == widget.onReselect) {
      return;
    }

    _controller?.unregister(oldWidget.tab, oldWidget.onReselect);
    _controller?.register(widget.tab, widget.onReselect);
  }

  @override
  void dispose() {
    _controller?.unregister(widget.tab, widget.onReselect);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
