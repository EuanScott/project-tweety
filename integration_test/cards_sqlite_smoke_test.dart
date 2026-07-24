import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/dart_init.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';
import 'package:project_tweety/data/services/card/card_id.generator.dart';
import 'package:project_tweety/main.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';

const _smokeCardId = 'cards-sqlite-relaunch-smoke-card';
const _expectExistingSmokeCard = bool.fromEnvironment(
  'EXPECT_EXISTING_SQLITE_SMOKE_CARD',
);
const _preserveSmokeTombstone = bool.fromEnvironment(
  'PRESERVE_SQLITE_SMOKE_TOMBSTONE',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
    await dartInit();
    GetIt.I
      ..unregister<CardIdGenerator>()
      ..registerLazySingleton<CardIdGenerator>(() => _SmokeCardIdGenerator());
  });

  tearDown(() => GetIt.I.reset());

  testWidgets(
    'persists Cards CRUD lifecycle through production DI and a native relaunch',
    (tester) async {
      if (_expectExistingSmokeCard) {
        await _verifyProcessRelaunch(tester);
      } else {
        await _exerciseCrudAndInternalReopen(tester);
      }
    },
  );
}

Future<void> _exerciseCrudAndInternalReopen(WidgetTester tester) async {
  final repository = GetIt.I<CardsRepository>();
  final dataSource = GetIt.I<CardsDataSource>();

  await _removePreviousSmokeCard(repository, dataSource);

  final createdCard = await repository.createCard(
    const CardDraft(
      title: 'Native persistence smoke',
      description: 'Persists Cards CRUD across native app launches.',
    ),
  );

  expect(createdCard.id, _smokeCardId, reason: 'Use the stable relaunch key.');
  expect(
    await _dirtyCard(dataSource),
    isA<CardDto>()
        .having((card) => card.id, 'id', _smokeCardId)
        .having(
          (card) => card.syncStatus,
          'sync status',
          CardSyncStatus.created,
        ),
  );

  final createdAndEditedCard = await repository.updateCard(
    cardId: _smokeCardId,
    draft: const CardDraft(
      title: 'Native persistence smoke edited',
      description: 'Created cards remain created until they are acknowledged.',
    ),
  );
  expect(createdAndEditedCard.title, 'Native persistence smoke edited');
  expect((await _dirtyCard(dataSource)).syncStatus, CardSyncStatus.created);

  await dataSource.markCardsSynced([_smokeCardId]);
  expect(
    (await dataSource.getCardById(_smokeCardId))?.syncStatus,
    CardSyncStatus.synced,
  );

  final updatedCard = await repository.updateCard(
    cardId: _smokeCardId,
    draft: const CardDraft(
      title: 'Native persistence smoke updated',
      description: 'Synced cards become updated when edited locally.',
    ),
  );
  expect(updatedCard.title, 'Native persistence smoke updated');
  expect((await _dirtyCard(dataSource)).syncStatus, CardSyncStatus.updated);

  await _verifyListAndDetailFlow(tester, updatedCard);

  await repository.deleteCard(_smokeCardId);
  expect(await repository.getCardById(_smokeCardId), isNull);
  expect(
    (await repository.getCards()).map((card) => card.id),
    isNot(contains(_smokeCardId)),
  );
  expect(
    await _dirtyCard(dataSource),
    isA<CardDto>()
        .having((card) => card.id, 'id', _smokeCardId)
        .having(
          (card) => card.syncStatus,
          'sync status',
          CardSyncStatus.deleted,
        )
        .having((card) => card.deletedAt, 'deleted at', isNotNull),
  );

  await _closeAndReopenComposition(tester);
  final reopenedRepository = GetIt.I<CardsRepository>();
  final reopenedDataSource = GetIt.I<CardsDataSource>();

  expect(await reopenedRepository.getCardById(_smokeCardId), isNull);
  expect(
    (await reopenedRepository.getCards()).map((card) => card.id),
    isNot(contains(_smokeCardId)),
  );
  expect(
    (await _dirtyCard(reopenedDataSource)).syncStatus,
    CardSyncStatus.deleted,
  );

  if (!_preserveSmokeTombstone) {
    await reopenedDataSource.markCardsSynced([_smokeCardId]);
    expect(
      (await reopenedDataSource.getDirtyCards()).map((card) => card.id),
      isNot(contains(_smokeCardId)),
    );
  }

  await _showResult(tester, 'SQLite close and reopen verified');
}

Future<void> _verifyProcessRelaunch(WidgetTester tester) async {
  final repository = GetIt.I<CardsRepository>();
  final dataSource = GetIt.I<CardsDataSource>();

  expect(await repository.getCardById(_smokeCardId), isNull);
  expect(
    (await repository.getCards()).map((card) => card.id),
    isNot(contains(_smokeCardId)),
  );
  expect(
    await _dirtyCard(dataSource),
    isA<CardDto>()
        .having((card) => card.id, 'id', _smokeCardId)
        .having(
          (card) => card.syncStatus,
          'sync status',
          CardSyncStatus.deleted,
        )
        .having((card) => card.deletedAt, 'deleted at', isNotNull),
  );

  await dataSource.markCardsSynced([_smokeCardId]);
  expect(
    (await dataSource.getDirtyCards()).map((card) => card.id),
    isNot(contains(_smokeCardId)),
  );

  await _showResult(tester, 'SQLite native relaunch verified');
}

Future<void> _verifyListAndDetailFlow(WidgetTester tester, Card card) async {
  await tester.pumpWidget(const MyApp(initialLocation: AppRoutes.cardsPath));
  await tester.pumpAndSettle();

  expect(find.text(card.title), findsOneWidget);

  await tester.tap(find.text(card.title));
  await tester.pumpAndSettle();

  expect(find.text(card.title), findsWidgets);
  expect(find.text(card.description), findsOneWidget);
  expect(find.text(card.id), findsOneWidget);
}

Future<void> _closeAndReopenComposition(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await GetIt.I<AppDatabase>().close();
  await GetIt.I.reset();
  await dartInit();
}

Future<void> _removePreviousSmokeCard(
  CardsRepository repository,
  CardsDataSource dataSource,
) async {
  if (await repository.getCardById(_smokeCardId) != null) {
    await repository.deleteCard(_smokeCardId);
  }
  await dataSource.markCardsSynced([_smokeCardId]);
}

Future<CardDto> _dirtyCard(CardsDataSource dataSource) async {
  final cards = await dataSource.getDirtyCards();
  return cards.singleWhere((card) => card.id == _smokeCardId);
}

Future<void> _showResult(WidgetTester tester, String message) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: Text(message)),
    ),
  );
  await tester.pumpAndSettle();
}

class _SmokeCardIdGenerator implements CardIdGenerator {
  @override
  String generate() => _smokeCardId;
}
