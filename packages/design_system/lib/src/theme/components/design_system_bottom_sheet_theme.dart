import 'package:material_ui/material_ui.dart';

class DesignSystemBottomSheetTheme {
  new _();

  static BottomSheetThemeData light(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      dragHandleColor: colorScheme.primary,
      clipBehavior: .antiAlias,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: Radius.circular(16)),
      ),
    );
  }

  static BottomSheetThemeData dark(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      dragHandleColor: colorScheme.primary,
      clipBehavior: .antiAlias,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: Radius.circular(16)),
      ),
    );
  }
}
