import 'package:flutter/material.dart';

class DesignSystemBottomSheetTheme {
  DesignSystemBottomSheetTheme._();

  static BottomSheetThemeData light(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      dragHandleColor: colorScheme.primary,
      clipBehavior: Clip.antiAlias,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  static BottomSheetThemeData dark(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      dragHandleColor: colorScheme.primary,
      clipBehavior: Clip.antiAlias,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
}
