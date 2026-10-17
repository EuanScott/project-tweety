import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/dart_init.dart';
import 'package:project_tweety/data/repositories/auth/auth.repository.dart';
import 'package:project_tweety/data/datasources/log_entry/logs.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';
import 'package:project_tweety/data/services/log_entry/log_entry_id.generator.dart';
import 'package:project_tweety/main.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

const _smokeLogEntryId = 'cards-sqlite-relaunch-smoke-card';
const _expectExistingSmokeLogEntry = bool.fromEnvironment(
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
      ..unregister<LogEntryIdGenerator>()
      ..registerLazySingleton<LogEntryIdGenerator>(
        () => _SmokeLogEntryIdGenerator(),
      );
  });

  tearDown(() => GetIt.I.reset());

  testWidgets(
    'persists the log entry CRUD lifecycle through production DI and a native relaunch',
    (tester) async {
      if (_expectExistingSmokeLogEntry) {
        await _verifyProcessRelaunch(tester);
      } else {
        await _exerciseCrudAndInternalReopen(tester);
      }
    },
  );
}

Future<void> _exerciseCrudAndInternalReopen(WidgetTester tester) async {
  final repository = GetIt.I<LogsRepository>();
  final dataSource = GetIt.I<LogsDataSource>();

  await _removePreviousSmokeLogEntry(repository, dataSource);

  final createdLogEntry = await repository.createLogEntry(
    const LogEntryDraft(
      title: 'Native persistence smoke',
      description: 'Persists Cards CRUD across native app launches.',
    ),
  );

  expect(
    createdLogEntry.id,
    _smokeLogEntryId,
    reason: 'Use the stable relaunch key.',
  );
  expect(
    await _unsyncedLogEntry(dataSource),
    isA<LogEntryDto>()
        .having((logEntry) => logEntry.id, 'id', _smokeLogEntryId)
        .having(
          (logEntry) => logEntry.syncStatus,
          'sync status',
          LogEntrySyncStatus.created,
        ),
  );

  final createdAndEditedLogEntry = await repository.updateLogEntry(
    logEntryId: _smokeLogEntryId,
    draft: const LogEntryDraft(
      title: 'Native persistence smoke edited',
      description: 'Created cards remain created until they are acknowledged.',
    ),
  );
  expect(createdAndEditedLogEntry.title, 'Native persistence smoke edited');
  expect(
    (await _unsyncedLogEntry(dataSource)).syncStatus,
    LogEntrySyncStatus.created,
  );

  await _acknowledgeSmokeLogEntry(dataSource);
  expect(
    (await dataSource.getLogEntryById(_smokeLogEntryId))?.syncStatus,
    LogEntrySyncStatus.synced,
  );

  final updatedLogEntry = await repository.updateLogEntry(
    logEntryId: _smokeLogEntryId,
    draft: const LogEntryDraft(
      title: 'Native persistence smoke updated',
      description: 'Synced cards become updated when edited locally.',
    ),
  );
  expect(updatedLogEntry.title, 'Native persistence smoke updated');
  expect(
    (await _unsyncedLogEntry(dataSource)).syncStatus,
    LogEntrySyncStatus.updated,
  );

  await _verifyListAndDetailFlow(tester, updatedLogEntry);

  await repository.deleteLogEntry(_smokeLogEntryId);
  expect(await repository.getLogEntryById(_smokeLogEntryId), isNull);
  expect(
    (await repository.getLogs()).map((logEntry) => logEntry.id),
    isNot(contains(_smokeLogEntryId)),
  );
  expect(
    await _unsyncedLogEntry(dataSource),
    isA<LogEntryDto>()
        .having((logEntry) => logEntry.id, 'id', _smokeLogEntryId)
        .having(
          (logEntry) => logEntry.syncStatus,
          'sync status',
          LogEntrySyncStatus.deleted,
        )
        .having((logEntry) => logEntry.deletedAt, 'deleted at', isNotNull),
  );

  await _closeAndReopenComposition(tester);
  final reopenedRepository = GetIt.I<LogsRepository>();
  final reopenedDataSource = GetIt.I<LogsDataSource>();

  expect(await reopenedRepository.getLogEntryById(_smokeLogEntryId), isNull);
  expect(
    (await reopenedRepository.getLogs()).map((logEntry) => logEntry.id),
    isNot(contains(_smokeLogEntryId)),
  );
  expect(
    (await _unsyncedLogEntry(reopenedDataSource)).syncStatus,
    LogEntrySyncStatus.deleted,
  );

  if (!_preserveSmokeTombstone) {
    await _acknowledgeSmokeLogEntry(reopenedDataSource);
    expect(
      (await reopenedDataSource.getUnsyncedLogs()).map(
        (logEntry) => logEntry.id,
      ),
      isNot(contains(_smokeLogEntryId)),
    );
  }

  await _showResult(tester, 'SQLite close and reopen verified');
}

Future<void> _verifyProcessRelaunch(WidgetTester tester) async {
  final repository = GetIt.I<LogsRepository>();
  final dataSource = GetIt.I<LogsDataSource>();

  expect(await repository.getLogEntryById(_smokeLogEntryId), isNull);
  expect(
    (await repository.getLogs()).map((logEntry) => logEntry.id),
    isNot(contains(_smokeLogEntryId)),
  );
  expect(
    await _unsyncedLogEntry(dataSource),
    isA<LogEntryDto>()
        .having((logEntry) => logEntry.id, 'id', _smokeLogEntryId)
        .having(
          (logEntry) => logEntry.syncStatus,
          'sync status',
          LogEntrySyncStatus.deleted,
        )
        .having((logEntry) => logEntry.deletedAt, 'deleted at', isNotNull),
  );

  await _acknowledgeSmokeLogEntry(dataSource);
  expect(
    (await dataSource.getUnsyncedLogs()).map((logEntry) => logEntry.id),
    isNot(contains(_smokeLogEntryId)),
  );

  await _showResult(tester, 'SQLite native relaunch verified');
}

Future<void> _verifyListAndDetailFlow(
  WidgetTester tester,
  LogEntry logEntry,
) async {
  // The launch gate keeps a signed-out person on sign-in; this smoke test is
  // about log entries, so it signs in through the app's own identity source first.
  await GetIt.I<AuthRepository>().signInWithGoogle();
  await tester.pumpWidget(const MyApp(initialLocation: AppRoutes.logsPath));
  await tester.pumpAndSettle();

  expect(find.text(logEntry.title), findsOneWidget);

  await tester.tap(find.text(logEntry.title));
  await tester.pumpAndSettle();

  expect(find.text(logEntry.title), findsWidgets);
  expect(find.text(logEntry.description), findsOneWidget);
  expect(find.text(logEntry.id), findsOneWidget);
}

Future<void> _closeAndReopenComposition(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await GetIt.I<AppDatabase>().close();
  await GetIt.I.reset();
  await dartInit();
}

Future<void> _removePreviousSmokeLogEntry(
  LogsRepository repository,
  LogsDataSource dataSource,
) async {
  if (await repository.getLogEntryById(_smokeLogEntryId) != null) {
    await repository.deleteLogEntry(_smokeLogEntryId);
  }
  await _acknowledgeSmokeLogEntry(dataSource);
}

Future<LogEntryDto> _unsyncedLogEntry(LogsDataSource dataSource) async {
  final logs = await dataSource.getUnsyncedLogs();
  return logs.singleWhere((logEntry) => logEntry.id == _smokeLogEntryId);
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

class _SmokeLogEntryIdGenerator implements LogEntryIdGenerator {
  @override
  String generate() => _smokeLogEntryId;
}

/// Marks the smoke log entry synced as a confirmed push would, from its pending
/// snapshot.
Future<void> _acknowledgeSmokeLogEntry(LogsDataSource dataSource) async {
  final pending = await dataSource.getUnsyncedLogs();
  await dataSource.markLogsSynced([
    for (final logEntry in pending)
      if (logEntry.id == _smokeLogEntryId) logEntry,
  ]);
}
