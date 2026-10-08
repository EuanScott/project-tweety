import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation.extension.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.widget.dart';

class Settings extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.settingsTab,
      titleBehavior: PageTitleBehavior.largeStatic,
      bodyPadding: EdgeInsets.zero,
      body: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        AppListSection(
          children: [
            AppListTile(
              title: Text(l10n.settingsAppPreferencesTitle),
              subtitle: Text(l10n.settingsAppPreferencesSubtitle),
              onTap: () {
                unawaited(context.openAppPreferences());
              },
            ),
          ],
        ),
      ],
    );
  }
}
