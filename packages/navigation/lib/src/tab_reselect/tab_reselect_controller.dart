import 'package:flutter/widgets.dart';

/// Registry for callbacks that run when the active bottom tab is tapped.
class TabReselectController<TTab extends Object> {
  final Map<TTab, VoidCallback> _callbacks = <TTab, VoidCallback>{};

  /// Registers [callback] as the current active-tab action for [tab].
  void register(TTab tab, VoidCallback callback) {
    _callbacks[tab] = callback;
  }

  /// Removes [callback] if it is still the active callback for [tab].
  void unregister(TTab tab, VoidCallback callback) {
    if (_callbacks[tab] == callback) {
      _callbacks.remove(tab);
    }
  }

  /// Runs the registered callback for [tab], if one exists.
  bool handle(TTab tab) {
    final callback = _callbacks[tab];

    if (callback == null) {
      return false;
    }

    callback();
    return true;
  }
}
