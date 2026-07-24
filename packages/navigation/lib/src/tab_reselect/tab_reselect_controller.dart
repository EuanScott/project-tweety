import 'package:flutter/widgets.dart';
import 'package:navigation/src/tab_reselect/tab_branch_reset_guard.dart';

/// Registry for callbacks that run when the active bottom tab is tapped.
class TabReselectController<TTab extends Object> {
  final Map<TTab, VoidCallback> _callbacks = <TTab, VoidCallback>{};
  final Map<TTab, TabBranchResetGuard<TTab>> _branchResetGuards =
      <TTab, TabBranchResetGuard<TTab>>{};

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

  /// Registers the current nested-branch reset [guard] for its tab.
  void registerBranchResetGuard(TabBranchResetGuard<TTab> guard) {
    _branchResetGuards[guard.tab] = guard;
  }

  /// Removes [guard] when it is still current for its tab.
  void unregisterBranchResetGuard(TabBranchResetGuard<TTab> guard) {
    if (_branchResetGuards[guard.tab] == guard) {
      _branchResetGuards.remove(guard.tab);
    }
  }

  /// Requests permission to reset [tab]'s nested branch.
  Future<bool> requestBranchReset(TTab tab) async {
    final guard = _branchResetGuards[tab];
    return guard == null || await guard.requestReset();
  }
}
