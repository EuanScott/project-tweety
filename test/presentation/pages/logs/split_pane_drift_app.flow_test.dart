import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/logs/log_entry_details/log_entry_details.page.dart';

import '../../../support/app_harness.dart';

void main() {
  group('Log entries on a surface with horizontal safe-area insets', () {
    useAppHarness();

    for (final width in [700.0, 800.0, 860.0]) {
      testWidgets('renders the selected log entry at $width wide', (
        tester,
      ) async {
        await pumpApp(
          tester,
          surfaceSize: Size(width, 800),
          padding: const EdgeInsets.only(left: 40, right: 40),
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );

        final pushed = find.byType(LogEntryDetailsPage).evaluate().isNotEmpty;
        final inline = find
            .byType(LogEntryDetailsContent)
            .evaluate()
            .isNotEmpty;

        expect(
          pushed || inline,
          isTrue,
          reason: 'route is /logs/card-1 but no log entry details are rendered',
        );
      });
    }
  });
}
