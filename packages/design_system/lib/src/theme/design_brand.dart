import 'package:material_ui/material_ui.dart';

/// Brand-level design tokens used to build a shared application theme.
///
/// A [DesignBrand] contains the values that are expected to differ between
/// applications or product variants, such as B2C and B2B, while the overall
/// theme structure remains the same.
class const DesignBrand({
  required final String name,
  required final Color primaryLight,
  required final Color onPrimaryLight,
  required final Color secondaryLight,
  required final Color onSecondaryLight,
  required final Color primaryDark,
  required final Color onPrimaryDark,
  required final Color secondaryDark,
  required final Color onSecondaryDark,
  required final Color disabledColor,
  required final Color error,
  required final Color onError,
  required final Color errorContainerLight,
  required final Color onErrorContainerLight,
  required final Color errorContainerDark,
  required final Color onErrorContainerDark,
  required final Color success,
  required final Color warning,
  required final Color info,
  required final Color surfaceLight,
  required final Color surfaceVariantLight,
  required final Color onSurfaceLight,
  required final Color surfaceDark,
  required final Color surfaceVariantDark,
  required final Color onSurfaceDark,
  required final Color navigationSurfaceLight,
  required final Color onNavigationSurfaceLight,
  required final Color navigationSelectedLight,
  required final Color onNavigationSelectedLight,
  required final Color navigationSurfaceDark,
  required final Color onNavigationSurfaceDark,
  required final Color navigationSelectedDark,
  required final Color onNavigationSelectedDark,
  required final Color outline,
});
