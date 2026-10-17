import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_logs_repository.dart';

void main() {
  group('Creating a log entry', () {
    useAppHarness();

    testWidgets(
      'turns the editor into the new log entry in place when the region '
      'shows one pane',
      (tester) async {
        replaceLogsRepository(FakeLogsRepository());
        await pumpApp(tester, initialLocation: AppRoutes.logsPath);

        await tester.tap(find.byTooltip('Create entry'));
        await tester.pumpAndSettle();
        final editorRoute = ModalRoute.of(
          tester.element(find.byType(AppTextField).first),
        );

        await _fillAndCreate(tester);

        expect(
          currentRoutePath(tester),
          '${AppRoutes.logsDetailFullPathPrefix}created-card',
        );
        expect(
          ModalRoute.of(tester.element(find.text('New description'))),
          same(editorRoute),
        );

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(currentRoutePath(tester), AppRoutes.logsPath);
      },
    );

    testWidgets('lists the new log entry first', (tester) async {
      replaceLogsRepository(FakeLogsRepository());
      await pumpApp(tester, initialLocation: AppRoutes.logsNewPath);

      await _fillAndCreate(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('New title')).dy,
        lessThan(tester.getTopLeft(find.text('Card Title 1')).dy),
      );
    });

    testWidgets(
      'opens another log entry afterwards without asking to discard',
      (tester) async {
        replaceLogsRepository(FakeLogsRepository());
        await pumpApp(tester, initialLocation: AppRoutes.logsNewPath);

        await _fillAndCreate(tester);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Card Title 1'));
        await tester.pumpAndSettle();

        expect(find.text('Discard changes?'), findsNothing);
        expect(
          currentRoutePath(tester),
          '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );
      },
    );

    testWidgets(
      'asks before discarding a new log entry started beside a selected '
      'Card',
      (tester) async {
        replaceLogsRepository(FakeLogsRepository());
        await pumpApp(
          tester,
          surfaceSize: const Size(1000, 900),
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-2',
        );

        await tester.tap(find.byTooltip('Create entry'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(AppTextField).first, 'Half a title');
        await tester.tap(find.text('Card Title 1'));
        await tester.pumpAndSettle();

        expect(find.text('Discard changes?'), findsOneWidget);
      },
    );
  });
}

Future<void> _fillAndCreate(WidgetTester tester) async {
  await tester.enterText(find.byType(AppTextField).first, 'New title');
  await tester.enterText(find.byType(AppTextField).last, 'New description');
  await tester.tap(find.widgetWithText(AppButton, 'Create entry'));
  await tester.pumpAndSettle();
}
