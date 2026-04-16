import 'package:flutter/material.dart';

/// Brand-level design tokens used to build a shared application theme.
///
/// A [DesignBrand] contains the values that are expected to differ between
/// applications or product variants, such as B2C and B2B, while the overall
/// theme structure remains the same.
class DesignBrand {
  const DesignBrand({
    required this.name,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.disabledColor,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.surfaceLight,
    required this.surfaceVariantLight,
    required this.onSurfaceLight,
    required this.surfaceDark,
    required this.surfaceVariantDark,
    required this.onSurfaceDark,
    required this.outline,
  });

  final String name;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color disabledColor;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color surfaceLight;
  final Color surfaceVariantLight;
  final Color onSurfaceLight;
  final Color surfaceDark;
  final Color surfaceVariantDark;
  final Color onSurfaceDark;
  final Color outline;
}
