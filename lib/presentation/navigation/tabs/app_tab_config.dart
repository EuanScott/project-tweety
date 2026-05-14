import 'package:flutter/material.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.dart';

/// Presentation metadata for a top-level app tab.
///
/// This keeps shell route ordering, root paths, labels, and icons in one place
/// so adding or reordering tabs does not require scattered index updates.
class AppTabConfig {
  /// Creates metadata for a bottom navigation destination.
  const AppTabConfig({
    required this.tab,
    required this.rootPath,
    required this.routeName,
    required this.icon,
    required this.label,
  });

  /// The tab represented by this configuration.
  final AppTab tab;

  /// The absolute root path for the tab branch.
  final String rootPath;

  /// The named route for the tab branch root.
  final String routeName;

  /// The icon shown in the bottom navigation bar.
  final IconData icon;

  /// Resolves the localized tab label.
  final String Function(AppLocalizations l10n) label;
}

/// Ordered top-level tab configurations used by the navigation shell.
const appTabConfigs = [
  AppTabConfig(
    tab: AppTab.home,
    rootPath: AppRoutes.homePath,
    routeName: AppRoutes.homeName,
    icon: Icons.home,
    label: _homeTabLabel,
  ),
  AppTabConfig(
    tab: AppTab.cards,
    rootPath: AppRoutes.cardsPath,
    routeName: AppRoutes.cardsName,
    icon: Icons.grid_view_rounded,
    label: _cardsTabLabel,
  ),
  AppTabConfig(
    tab: AppTab.settings,
    rootPath: AppRoutes.settingsPath,
    routeName: AppRoutes.settingsName,
    icon: Icons.settings,
    label: _settingsTabLabel,
  ),
];

String _homeTabLabel(AppLocalizations l10n) => l10n.homeTab;

String _cardsTabLabel(AppLocalizations l10n) => l10n.cardsTab;

String _settingsTabLabel(AppLocalizations l10n) => l10n.settingsTab;
