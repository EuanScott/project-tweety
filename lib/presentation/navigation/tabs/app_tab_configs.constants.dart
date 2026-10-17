import 'package:material_ui/material_ui.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.model.dart';

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
    tab: AppTab.logs,
    rootPath: AppRoutes.logsPath,
    routeName: AppRoutes.logsName,
    icon: Icons.cabin,
    labelBuilder: _logsTabLabel,
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

String _logsTabLabel(BuildContext context) {
  return AppLocalizations.of(context)!.logsTab;
}

String _settingsTabLabel(BuildContext context) {
  return AppLocalizations.of(context)!.settingsTab;
}
