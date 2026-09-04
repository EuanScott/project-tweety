import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';
import 'package:project_tweety/presentation/pages/cards/card_details/card_details.page.dart';

import '../../../support/app_harness.dart';

void main() {
  group('Cards on a surface with horizontal safe-area insets', () {
    useAppHarness();

    for (final width in [700.0, 800.0, 860.0]) {
      testWidgets('renders the selected card at $width wide', (tester) async {
        await pumpApp(
          tester,
          surfaceSize: Size(width, 800),
          padding: const EdgeInsets.only(left: 40, right: 40),
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        final pushed = find.byType(CardDetailsPage).evaluate().isNotEmpty;
        final inline = find.byType(CardDetailsContent).evaluate().isNotEmpty;

        expect(
          pushed || inline,
          isTrue,
          reason: 'route is /cards/card-1 but no card details are rendered',
        );
      });
    }
  });
}
