import 'package:flutter/widgets.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.dart';

/// Registry for callbacks that run when the active bottom tab is tapped.
///
/// The navigation shell owns one controller and root tab pages register through
/// [TabReselectHandler]. Nested routes do not receive custom reselect actions.
class TabReselectController {
  final Map<AppTab, VoidCallback> _callbacks = <AppTab, VoidCallback>{};

  /// Registers [callback] as the current active-tab action for [tab].
  void register(AppTab tab, VoidCallback callback) {
    _callbacks[tab] = callback;
  }

  /// Removes [callback] if it is still the active callback for [tab].
  void unregister(AppTab tab, VoidCallback callback) {
    if (_callbacks[tab] == callback) {
      _callbacks.remove(tab);
    }
  }

  /// Runs the registered callback for [tab], if one exists.
  bool handle(AppTab tab) {
    final callback = _callbacks[tab];

    if (callback == null) {
      return false;
    }

    callback();
    return true;
  }
}
