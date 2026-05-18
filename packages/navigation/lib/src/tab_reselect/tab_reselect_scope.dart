import 'package:flutter/widgets.dart';
import 'package:navigation/src/tab_reselect/tab_reselect_controller.dart';

/// Provides the tab reselect controller to root pages inside the shell.
class TabReselectScope<TTab extends Object> extends InheritedWidget {
  /// Creates a scope for active-tab callback registration.
  const TabReselectScope({
    required this.controller,
    required super.child,
    super.key,
  });

  /// The controller owned by the app navigation shell.
  final TabReselectController<TTab> controller;

  /// Returns the nearest controller, or `null` outside the tab shell.
  static TabReselectController<TTab>? maybeOf<TTab extends Object>(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<TabReselectScope<TTab>>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(TabReselectScope<TTab> oldWidget) {
    return controller != oldWidget.controller;
  }
}
