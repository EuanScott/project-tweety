import 'package:flutter/material.dart';

import 'design_system_text_theme.dart';

class DesignSystemButtonTheme {
  DesignSystemButtonTheme._();

  static ElevatedButtonThemeData elevated(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        disabledBackgroundColor: colorScheme.onSurface.withAlpha(120),
        disabledForegroundColor: colorScheme.onSurface.withAlpha(120),
        elevation: 2,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: DesignSystemTextTheme.buttonTextStyle(
          colorScheme,
        ).copyWith(color: null),
      ),
    );
  }

  static OutlinedButtonThemeData outlined(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        disabledForegroundColor: colorScheme.onSurface.withAlpha(120),
        foregroundColor: colorScheme.primary,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: colorScheme.primary, width: 1),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: DesignSystemTextTheme.buttonTextStyle(
          colorScheme,
        ).copyWith(color: null),
      ),
    );
  }

  static TextButtonThemeData text(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        disabledForegroundColor: colorScheme.onSurface.withAlpha(120),
        foregroundColor: colorScheme.primary,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: DesignSystemTextTheme.buttonTextStyle(
          colorScheme,
        ).copyWith(color: null),
      ),
    );
  }
}
