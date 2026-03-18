import 'dart:developer';

import 'package:flutter/material.dart';
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => log('something'),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => log('something'),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
          Container(height: 16),
          ElevatedButton(
            onPressed: () => log('something'),
            // TODO: To make this a secondary button
            // style: Theme.of(context).elevatedButtonTheme.style!.asSecondary(),
            child: const Text('Button'),
          ),
          Container(height: 16),
          OutlinedButton(
            onPressed: () => log('something'),
            child: const Text('Button'),
          ),
          Container(height: 16),
          TextButton(
            onPressed: () => log('something'),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
