import 'package:material_ui/material_ui.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.dart';

/// Ordered top-level tab configurations used by the navigation shell.
const appTabConfigs = [
  NavigationTabConfig<AppTab>(
    tab: AppTab.home,
    rootPath: AppRoutes.homePath,
    routeName: AppRoutes.homeName,
    icon: Icons.home,
    labelBuilder: _homeTabLabel,
  ),
  NavigationTabConfig<AppTab>(
    tab: AppTab.cards,
    rootPath: AppRoutes.cardsPath,
    routeName: AppRoutes.cardsName,
    icon: Icons.grid_view_rounded,
    labelBuilder: _cardsTabLabel,
  ),
  NavigationTabConfig<AppTab>(
    tab: AppTab.settings,
    rootPath: AppRoutes.settingsPath,
    routeName: AppRoutes.settingsName,
    icon: Icons.settings,
    labelBuilder: _settingsTabLabel,
  ),
];

String _homeTabLabel(BuildContext context) {
  return AppLocalizations.of(context)!.homeTab;
}

String _cardsTabLabel(BuildContext context) {
  return AppLocalizations.of(context)!.cardsTab;
}

String _settingsTabLabel(BuildContext context) {
  return AppLocalizations.of(context)!.settingsTab;
}
