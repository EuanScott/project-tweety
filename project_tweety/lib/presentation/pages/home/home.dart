import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:project_tweety/core/utils/button_style_extension.dart';
import 'package:project_tweety/l10n/app_localizations.dart';

class Home extends StatelessWidget {
  const Home({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => log('something'),
            child: Text(
              '${l10n.homeTab} Elevated',
              textAlign: TextAlign.center,
            ),
          ),
          Container(height: 16),
          const ElevatedButton(
            onPressed: null,
            child: Text('Primary Disabled', textAlign: TextAlign.center),
          ),
          Container(height: 16),
          ElevatedButton(
            onPressed: () => log('something'),
            style: Theme.of(context).elevatedButtonTheme.style!.asSecondary(),
            child: const Text(
              'Secondary Elevated',
              textAlign: TextAlign.center,
            ),
          ),
          Container(height: 16),
          ElevatedButton(
            onPressed: null,
            style: Theme.of(context).elevatedButtonTheme.style!.asSecondary(),
            child: const Text(
              'Secondary Disabled',
              textAlign: TextAlign.center,
            ),
          ),
          Container(height: 16),
          TextButton(
            onPressed: () => log('something'),
            child: const Text('Back', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
