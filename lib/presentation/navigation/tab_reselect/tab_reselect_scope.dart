import 'package:flutter/widgets.dart';
import 'package:project_tweety/presentation/navigation/tab_reselect/tab_reselect_controller.dart';

/// Provides the tab reselect controller to root pages inside the shell.
class TabReselectScope extends InheritedWidget {
  /// Creates a scope for active-tab callback registration.
  const TabReselectScope({
    required this.controller,
    required super.child,
    super.key,
  });

  /// The controller owned by the app navigation shell.
  final TabReselectController controller;

  /// Returns the nearest controller, or `null` outside the tab shell.
  static TabReselectController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TabReselectScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(TabReselectScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
