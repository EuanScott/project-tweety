import 'package:design_system/design_system.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
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

    testWidgets('groups the personalisation row in a list section', (
      tester,
    ) async {
      await _pumpSettings(tester);

      expect(
        find.descendant(
          of: find.byType(AppListSection),
          matching: find.text('Personalisation'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('places the personalisation card under the large title', (
      tester,
    ) async {
      const iPhoneStatusBarHeight = 62.0;
      tester.view.padding = FakeViewPadding(
        top: iPhoneStatusBarHeight * tester.view.devicePixelRatio,
      );
      addTearDown(tester.view.resetPadding);
      await _pumpSettings(tester);

      final body = tester.getRect(
        find
            .ancestor(
              of: find.byType(AppListSection),
              matching: find.byType(SafeArea),
            )
            .first,
      );
      final card = tester.getRect(find.byType(CupertinoListTile));

      expect(card.top - body.top, 36);
      expect(card.left, 16);
    });

    testWidgets('shows no chevron on the personalisation row on Android', (
      tester,
    ) async {
      await _pumpSettings(tester, platform: TargetPlatform.android);

      expect(find.text('Personalisation'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('shows the Cupertino chevron on the personalisation row', (
      tester,
    ) async {
      await _pumpSettings(tester);

      expect(find.byType(CupertinoListTileChevron), findsOneWidget);
    });
  });
}

Future<void> _pumpSettings(
  WidgetTester tester, {
  TargetPlatform platform = TargetPlatform.iOS,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: DesignSystemTheme.light().copyWith(platform: platform),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Settings(),
    ),
  );
}
