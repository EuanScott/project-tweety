import 'package:flutter/material.dart';
import 'package:project_tweety/presentation/extensions/modal_extension.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  // TODO: Set it so that the i10n can be dynamically updated from the app and not always by changing the phone language in settings

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: const Text('Open Modal'),
        onPressed: () {
          context.showAppModal(const Center(child: Text('Modal content')));
        },
      ),
    );
  }
}
