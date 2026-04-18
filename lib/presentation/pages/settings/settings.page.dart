import 'package:flutter/material.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  // TODO: Set it so that the i10n can be dynamically updated from the app and not always by changing the phone language in settings

  // Global UI Bloc (Theme and Language)
  // SharedPrederences to save what the user has set (not secure_storage)
  // Set theme and language in a settings page
  // Separate global bloc for business logic (auth and stuff)
  // Updated agents for coding standards based off of cards page

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.settingsTab,
      body: const Center(child: Text('Settings')),
    );
  }
}
