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

    testWidgets('lets its large title collapse into the toolbar on scroll', (
      tester,
    ) async {
      await _pumpSettings(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, -100));
      await tester.pump();

      final header = tester.state<NestedScrollViewState>(
        find.byType(NestedScrollView),
      );

      expect(header.outerController.offset, greaterThan(0));

      await gesture.up();
      await tester.pumpAndSettle();
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
