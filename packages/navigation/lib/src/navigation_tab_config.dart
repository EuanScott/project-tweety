import 'package:flutter/widgets.dart';

/// Presentation and route metadata for a top-level navigation tab.
///
/// The consuming app owns [TTab], route names, route paths, icons, and label
/// localization. This package only uses the metadata to build the shared shell
/// and decide how active-tab taps should behave.
class NavigationTabConfig<TTab extends Object> {
  /// Creates metadata for one top-level tab.
  const NavigationTabConfig({
    required this.tab,
    required this.rootPath,
    required this.routeName,
    required this.icon,
    required this.labelBuilder,
  });

  /// The app-owned tab identifier.
  final TTab tab;

  /// The absolute root path for this tab branch.
  final String rootPath;

  /// The named route for this tab branch root.
  final String routeName;

  /// The icon rendered in the bottom navigation bar.
  final IconData icon;

  /// Resolves the tab label using the consuming app's localization context.
  final String Function(BuildContext context) labelBuilder;
}
