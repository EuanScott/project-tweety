import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_app_preferences_repository.dart';
import '../../../support/fake_logs_repository.dart';

void main() {
  group('Log entry details', () {
    useAppHarness();

    testWidgets(
      'shows a not-found message for a log entry missing from the loaded collection',
      (WidgetTester tester) async {
        replaceLogsRepository(FakeLogsRepository());

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-999',
        );

        expect(find.text('Entry not found'), findsOneWidget);
        expect(find.text('This entry is not available.'), findsOneWidget);
      },
    );

    testWidgets(
      'shows a load-failure message when the collection fails to load',
      (WidgetTester tester) async {
        replaceLogsRepository(
          FakeLogsRepository(readError: StateError('read failed')),
        );

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );

        expect(find.text('Unable to load entry'), findsOneWidget);
        expect(find.text('Unable to load logs right now.'), findsOneWidget);
      },
    );

    testWidgets('shows the load-failure description in Spanish', (
      WidgetTester tester,
    ) async {
      replaceAppPreferencesRepository(
        FakeAppPreferencesRepository(const AppPreferences(languageCode: 'es')),
      );
      replaceLogsRepository(
        FakeLogsRepository(readError: StateError('read failed')),
      );

      await pumpApp(
        tester,
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      expect(find.text('Unable to load logs right now.'), findsNothing);
      expect(
        find.text('No se pudieron cargar los registros ahora mismo.'),
        findsOneWidget,
      );
    });

    // UI Responsiveness Test (previously manual-only)
    testWidgets('displays log entry ID as selectable text', (
      WidgetTester tester,
    ) async {
      replaceLogsRepository(FakeLogsRepository());

      await pumpApp(
        tester,
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );
      await tester.pumpAndSettle();

      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('card-1'), findsOneWidget);
    });
  });
}
