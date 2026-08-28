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
      theme: DesignSystemTheme.light(brand: DesignBrands.tweetyB2c),
      darkTheme: DesignSystemTheme.dark(brand: DesignBrands.tweetyB2c),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // The gallery's own chrome (nav, header, showcase controls) must
      // always render Material — only the two comparison panes inside a
      // showcase should ever show Cupertino, and each pane already sets
      // its own explicit platform override regardless of this ambient
      // value.
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(platform: TargetPlatform.android),
          child: child!,
        );
      },
      home: const GalleryShell(),
    );
  }
}
