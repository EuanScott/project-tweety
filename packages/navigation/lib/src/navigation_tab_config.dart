import 'package:flutter/widgets.dart';

/// Presentation and route metadata for a top-level navigation tab.
///
/// The consuming app owns [TTab], route names, route paths, icons, and label
/// localization. This package only uses the metadata to build the shared shell
/// and decide how active-tab taps should behave.
class const NavigationTabConfig<TTab extends Object>({
  /// The app-owned tab identifier.
  required final TTab tab,

  /// The absolute root path for this tab branch.
  required final String rootPath,

  /// The named route for this tab branch root.
  required final String routeName,

  /// The icon rendered in the bottom navigation bar.
  required final IconData icon,

  /// Resolves the tab label using the consuming app's localization context.
  required final String Function(BuildContext context) labelBuilder,
});
