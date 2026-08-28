import 'package:design_system/design_system.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:material_ui/material_ui.dart' hide GlobalMaterialLocalizations;

import 'shell/gallery_shell.dart';

/// Root widget for the design_system component gallery.
class const GalleryApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'design_system Component Gallery',
      debugShowCheckedModeBanner: false,
      theme: DesignSystemTheme.light(),
      darkTheme: DesignSystemTheme.dark(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const GalleryShell(),
    );
  }
}
