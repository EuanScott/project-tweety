import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../support/app_harness.dart';

const _iPadPortrait = Size(834, 1194);
const _iPadLandscape = Size(1194, 834);
const _toggle = 'Toggle side navigation';

/// The expanded sidebar names each tab; the collapsed one shows only icons.
final _expandedSidebar = find.text('Home');

/// Logs shows its empty right pane only while it splits.
final _twoPanes = find.text('Select an entry');

void main() {
  group('iPad sidebar', () {
    useAppHarness();

    testWidgets('starts collapsed in portrait so Logs shows two panes', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: _iPadPortrait,
        initialLocation: AppRoutes.logsPath,
        platform: TargetPlatform.iOS,
      );

      expect(_expandedSidebar, findsNothing);
      expect(_twoPanes, findsOneWidget);
    });

    testWidgets('gives Logs one pane while expanded in portrait, and two '
        'again when collapsed', (WidgetTester tester) async {
      await pumpApp(
        tester,
        surfaceSize: _iPadPortrait,
        initialLocation: AppRoutes.logsPath,
        platform: TargetPlatform.iOS,
      );

      await tester.tap(find.byTooltip(_toggle));
      await tester.pumpAndSettle();

      expect(_expandedSidebar, findsOneWidget);
      expect(_twoPanes, findsNothing);

      await tester.tap(find.byTooltip(_toggle));
      await tester.pumpAndSettle();

      expect(_expandedSidebar, findsNothing);
      expect(_twoPanes, findsOneWidget);
    });

    testWidgets('starts expanded in landscape with two Logs panes', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: _iPadLandscape,
        initialLocation: AppRoutes.logsPath,
        platform: TargetPlatform.iOS,
      );

      expect(_expandedSidebar, findsOneWidget);
      expect(_twoPanes, findsOneWidget);
    });

    testWidgets('resets to the new orientation default when the device turns', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: _iPadPortrait,
        initialLocation: AppRoutes.logsPath,
        platform: TargetPlatform.iOS,
      );
      await tester.tap(find.byTooltip(_toggle));
      await tester.pumpAndSettle();
      expect(_expandedSidebar, findsOneWidget);

      await tester.binding.setSurfaceSize(_iPadLandscape);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(_toggle));
      await tester.pumpAndSettle();
      expect(_expandedSidebar, findsNothing);

      await tester.binding.setSurfaceSize(_iPadPortrait);
      await tester.pumpAndSettle();

      expect(_expandedSidebar, findsNothing);
      expect(_twoPanes, findsOneWidget);
    });

    testWidgets('keeps the Android drawer expanded in portrait', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1200, 1600),
        initialLocation: AppRoutes.logsPath,
        platform: TargetPlatform.android,
      );

      expect(find.byType(NavigationDrawer), findsOneWidget);
      expect(_expandedSidebar, findsOneWidget);
    });
  });
}
