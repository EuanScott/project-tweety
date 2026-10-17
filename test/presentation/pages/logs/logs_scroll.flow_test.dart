import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../../support/app_harness.dart';

void main() {
  group('Log entries list selection placement', () {
    useAppHarness();

    testWidgets('leaves a log entry that already sits below the halfway line', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.logsPath,
      );

      final before = _logEntryBounds(tester, 'Card Title 5');
      expect(
        before.top,
        greaterThan(_viewport(tester, 'Card Title 5').center.dy),
      );

      await tester.tap(find.text('Card Title 5').first);
      await tester.pumpAndSettle();

      expect(_logEntryBounds(tester, 'Card Title 5'), before);
    });

    testWidgets('centres a log entry selected above the halfway line', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.logsPath,
      );

      await tester.drag(find.text('Card Title 1'), const Offset(0, -600));
      await tester.pumpAndSettle();

      final viewport = _viewport(tester, 'Card Title 5');
      expect(
        _logEntryBounds(tester, 'Card Title 5').top,
        lessThan(viewport.center.dy),
      );

      await tester.tap(find.text('Card Title 5').first);
      await tester.pumpAndSettle();

      expect(
        _logEntryBounds(tester, 'Card Title 5').center.dy,
        closeTo(_viewport(tester, 'Card Title 5').center.dy, 1),
      );
    });

    testWidgets('centres a log entry opened by deep link', (tester) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 600),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-7',
      );

      expect(
        _logEntryBounds(tester, 'Card Title 7').center.dy,
        closeTo(_viewport(tester, 'Card Title 7').center.dy, 1),
      );
    });
    testWidgets('keeps the list in place when the editor opens', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.logsPath,
      );

      await tester.drag(find.text('Card Title 1'), const Offset(0, -600));
      await tester.pumpAndSettle();

      final before = _logEntryBounds(tester, 'Card Title 5');

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(_logEntryBounds(tester, 'Card Title 5'), before);
    });

    testWidgets(
      'brings the last log entry as close to centre as the list allows',
      (tester) async {
        await pumpApp(
          tester,
          surfaceSize: const Size(1000, 900),
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-10',
        );

        final viewport = _viewport(tester, 'Card Title 10');
        final logEntry = _logEntryBounds(tester, 'Card Title 10');

        expect(logEntry.bottom, lessThanOrEqualTo(viewport.bottom));
        expect(logEntry.center.dy, greaterThan(viewport.center.dy));
      },
    );
  });
}

Finder _logEntryFinder(String title) {
  return find.ancestor(of: find.text(title), matching: find.byType(Card));
}

Rect _logEntryBounds(WidgetTester tester, String title) {
  return tester.getRect(_logEntryFinder(title).first);
}

Rect _viewport(WidgetTester tester, String anchorTitle) {
  return tester.getRect(
    find
        .ancestor(
          of: _logEntryFinder(anchorTitle),
          matching: find.byType(Scrollable),
        )
        .first,
  );
}
