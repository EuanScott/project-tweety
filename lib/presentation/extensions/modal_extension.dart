import 'package:flutter/material.dart';

extension ModalExtension on BuildContext {
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
