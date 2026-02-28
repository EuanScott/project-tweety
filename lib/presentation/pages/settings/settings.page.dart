import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  // TODO: Set it so that the i10n can be dynamically updated from the app and not always by changing the phone language in settings

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings', style: TextStyle(fontSize: 30)),
    );
  }
}
