import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/dart_init.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';
import 'package:project_tweety/main.dart';

const _smokeCardId = 'native-smoke-card';
const _expectExistingSmokeCard = bool.fromEnvironment(
  'EXPECT_EXISTING_SQLITE_SMOKE_CARD',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
    await dartInit();
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('reads cards through the native SQLite composition', (
    tester,
  ) async {
    final repository = GetIt.I<CardsRepository>();
    final database = GetIt.I<AppDatabase>();
    final initialCards = await repository.getCards();
    final existingSmokeCard = await repository.getCardById(_smokeCardId);

    if (_expectExistingSmokeCard) {
      expect(initialCards, hasLength(11));
      expect(existingSmokeCard?.title, 'Native persistence smoke');
    } else {
      expect(initialCards, hasLength(10));
      expect(existingSmokeCard, isNull);
      await database.write((db) {
        return db.insert('cards', const <String, Object?>{
          'id': _smokeCardId,
          'title': 'Native persistence smoke',
          'description': 'Persists across native app launches.',
        });
      });
    }

    await _verifyCardsUi(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await GetIt.I.reset();
    await dartInit();

    final reopenedRepository = GetIt.I<CardsRepository>();
    final cardsAfterReopen = await reopenedRepository.getCards();
    final cardAfterReopen = await reopenedRepository.getCardById(_smokeCardId);

    expect(cardsAfterReopen, hasLength(11));
    expect(cardAfterReopen?.title, 'Native persistence smoke');

    await _verifyCardsUi(tester);
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Text(
            _expectExistingSmokeCard
                ? 'SQLite relaunch verified'
                : 'SQLite first launch verified',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}

Future<void> _verifyCardsUi(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Cards'));
  await tester.pumpAndSettle();

  expect(find.text('Card Title 1'), findsWidgets);

  await tester.tap(find.text('Card Title 1').first);
  await tester.pumpAndSettle();

  expect(find.text('card-1'), findsOneWidget);
}
