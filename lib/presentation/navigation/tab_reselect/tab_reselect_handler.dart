import 'package:flutter/widgets.dart';
import 'package:project_tweety/presentation/navigation/tab_reselect/tab_reselect_controller.dart';
import 'package:project_tweety/presentation/navigation/tab_reselect/tab_reselect_scope.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.dart';

/// Registers a page-owned callback for active-tab taps.
///
/// Use this on a tab's root page when tapping the already-selected bottom
/// navigation item should perform page-specific work, such as scrolling a list
/// to the top. The app shell only runs these callbacks while the tab is already
/// on its root route.
class TabReselectHandler extends StatefulWidget {
  /// Creates a handler that registers [onReselect] for [tab].
  const TabReselectHandler({
    required this.tab,
    required this.onReselect,
    required this.child,
    super.key,
  });

  /// The root tab this handler belongs to.
  final AppTab tab;

  /// Callback invoked when the user taps the active tab on its root route.
  final VoidCallback onReselect;

  /// The page subtree that owns the callback lifecycle.
  final Widget child;

  @override
  State<TabReselectHandler> createState() => _TabReselectHandlerState();
}

class _TabReselectHandlerState extends State<TabReselectHandler> {
  TabReselectController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final controller = TabReselectScope.maybeOf(context);

    if (controller == _controller) {
      return;
    }

    _controller?.unregister(widget.tab, widget.onReselect);
    _controller = controller;
    _controller?.register(widget.tab, widget.onReselect);
  }

  @override
  void didUpdateWidget(TabReselectHandler oldWidget) {
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
