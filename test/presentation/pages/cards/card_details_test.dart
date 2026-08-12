import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_cards_repository.dart';

void main() {
  group('Card details', () {
    useAppHarness();

    testWidgets(
      'shows a not-found message for a card missing from the loaded collection',
      (WidgetTester tester) async {
        replaceCardsRepository(FakeCardsRepository());

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-999',
        );

        expect(find.text('Card not found'), findsOneWidget);
        expect(find.text('This card is not available.'), findsOneWidget);
      },
    );

    testWidgets(
      'shows a load-failure message when the collection fails to load',
      (WidgetTester tester) async {
        replaceCardsRepository(
          FakeCardsRepository(readError: StateError('read failed')),
        );

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        expect(find.text('Unable to load card'), findsOneWidget);
        expect(find.text('Unable to load cards right now.'), findsOneWidget);
      },
    );
  });
}
