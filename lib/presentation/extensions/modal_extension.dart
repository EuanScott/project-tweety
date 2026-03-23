import 'package:flutter/material.dart';

@Deprecated("Just a tester, don't use going forward")
/// Convenience modal helpers available directly from a [BuildContext].
extension ModalExtension on BuildContext {

  /// Shows the standard app bottom-sheet modal.
  ///
  /// This is a convenience wrapper for presenting modal content directly from a
  /// [BuildContext].
  ///
  /// [child] is the widget rendered inside the modal.
  ///
  /// The returned [Future<T?>] completes when the modal is dismissed and
  /// carries the optional value passed to `Navigator.pop`.
  Future<T?> showAppModal<T>(Widget child) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.20,
        widthFactor: 1,
        child: child,
      ),
    );
  }
}
