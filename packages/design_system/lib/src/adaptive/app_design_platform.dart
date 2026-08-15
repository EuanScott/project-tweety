import 'package:material_ui/material_ui.dart';

/// Resolves the design language the app should render for the current target.
///
/// This is intentionally narrower than Flutter's full platform list. Callers
/// should branch on design language, not on individual operating systems,
/// unless a widget has a concrete platform-specific behavior to support.
enum AppDesignPlatform {
  /// Material-first presentation for Android, web, desktop, and fallback cases.
  material,

  /// Cupertino-first presentation for iOS and macOS.
  cupertino;

  /// Resolves the active app design language from the inherited [ThemeData].
  static AppDesignPlatform of(BuildContext context) {
    final platform = Theme.of(context).platform;

    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return AppDesignPlatform.cupertino;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return AppDesignPlatform.material;
    }
  }

  /// Whether this design language should render Cupertino widgets.
  bool get isCupertino => this == AppDesignPlatform.cupertino;
}
