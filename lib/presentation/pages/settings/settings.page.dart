import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:project_tweety/presentation/extensions/modal_extension.dart';
import 'package:project_tweety/presentation/widgets/app_modal.dart';
import 'package:project_tweety/presentation/widgets/webview_modal.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  // TODO: Set it so that the i10n can be dynamically updated from the app and not always by changing the phone language in settings

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TextButton(
            child: const Text('Context Modal'),
            onPressed: () {
              context.showAppModal(const Center(child: Text('Modal content')));
            },
          ),
          TextButton(
            child: const Text('Page Modal'),
            onPressed: () {
              AppModal.page<bool>(
                context: context,
                child: const Center(child: Text('Modal content')),
              );
            },
          ),
          TextButton(
            child: const Text('Blocking Modal'),
            onPressed: () {
              AppModal.blocking<bool>(
                context: context,
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Close Modal'),
                  ),
                ),
              );
            },
          ),
          TextButton(
            child: const Text('Compact Modal'),
            onPressed: () async {
              await AppModal.compact<bool>(
                context: context,
                maxHeightFactor: 0.35,
                child: const Center(child: Text('Modal content')),
              );
            },
          ),
          TextButton(
            child: const Text('Blocking Modal'),
            onPressed: () async {
              final result = await WebviewModal.show(
                context,
                'https://euanscott.github.io/tester.html',
              );

              if (result != null) {
                log('User result: $result');
              }
            },
          ),
        ],
      ),
    );
  }
}
