import 'package:flutter/material.dart';

class CustomBottomSheetThemeData {
  static BottomSheetThemeData lightBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      dragHandleColor: colorScheme.primary,
      clipBehavior: Clip.antiAlias,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  static BottomSheetThemeData darkBottomSheetTheme(ColorScheme colorScheme) {
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
