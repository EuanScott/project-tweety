/// Decides whether an active tab branch may reset to its root route.
///
/// A guard belongs to one [tab]. While a decision is pending, subsequent reset
/// requests are rejected so a confirmation UI cannot be opened repeatedly.
/// Creates a branch-reset guard for [tab].
class TabBranchResetGuard<TTab extends Object>({
  /// The tab whose nested branch this guard protects.
  required final TTab tab,

  /// Resolves to whether the branch may reset.
  required final Future<bool> Function() onResetRequested,
}) {
  bool _isResetPending = false;

  /// Requests permission to reset the branch.
  ///
  /// Returns `false` immediately when another request is awaiting a decision.
  Future<bool> requestReset() async {
    if (_isResetPending) {
      return false;
    }

    _isResetPending = true;
    try {
      return await onResetRequested();
    } finally {
      _isResetPending = false;
    }
  }
}
