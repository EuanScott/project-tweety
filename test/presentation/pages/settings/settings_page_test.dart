import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/pages/settings/settings.page.dart';

void main() {
  group('Settings', () {
    testWidgets('uses large Cupertino chrome on iOS', (tester) async {
      await _pumpSettings(tester);

      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsNothing);
    });

    testWidgets('does not collapse its large title for short content', (
      tester,
    ) async {
      await _pumpSettings(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      final navigationBar = tester.widget<NestedScrollView>(
        find.byType(NestedScrollView),
      );

      expect(navigationBar.physics, isA<NeverScrollableScrollPhysics>());
    });
  });
}

Future<void> _pumpSettings(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: DesignSystemTheme.light().copyWith(platform: TargetPlatform.iOS),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Settings(),
    ),
  );
}
