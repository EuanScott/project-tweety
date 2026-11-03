import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';
import 'package:project_tweety/presentation/pages/logs/bloc/logs_sync.bloc.dart';

import '../../../../support/fake_logs_repository.dart';

void main() {
  const logEntry = LogEntry(
    id: 'card-1',
    title: 'Card Title 1',
    description: 'Card body',
  );
  const draft = LogEntryDraft(title: 'New', description: 'New');
  const twoPending = LogsSyncSummary(
    pendingChanges: {
      'card-1': PendingLogEntryChange.updated,
      'card-2': PendingLogEntryChange.deleted,
    },
  );

  late FakeLogsRepository repository;
  late LogsSyncBloc bloc;
  late List<LogsSync> syncs;

  Future<void> settle() => pumpEventQueue();

  setUp(() {
    repository = FakeLogsRepository(logs: const [logEntry]);
    bloc = LogsSyncBloc(repository);
    syncs = [];
    bloc.stream.map((state) => state.sync).distinct().listen(syncs.add);
  });

  tearDown(() => bloc.close());

  test('starts with every log entry synced and none marked', () {
    expect(bloc.state.sync, const LogsSync.upToDate());
    expect(bloc.state.unsyncedChanges, isEmpty);
  });

  group('refreshing', () {
    test('shows what is pending and marks each log entry', () async {
      repository.syncSummary = twoPending;

      bloc.add(const LogsSyncRefreshed());
      await settle();

      expect(bloc.state.sync, const LogsSync.pending(changeCount: 2));
      expect(bloc.state.unsyncedChanges, {
        'card-1': UnsyncedLogEntryChange.updated,
      });
    });

    test('with nothing pending shows the last sync time', () async {
      final lastSyncedAt = DateTime.utc(2026, 10, 9);
      repository.syncSummary = LogsSyncSummary(lastSyncedAt: lastSyncedAt);

      bloc.add(const LogsSyncRefreshed());
      await settle();

      expect(bloc.state.sync, LogsSync.upToDate(lastSyncedAt: lastSyncedAt));
    });
  });

  group('a saved change', () {
    const onePending = LogsSyncSummary(
      pendingChanges: {'created-card': PendingLogEntryChange.created},
    );

    test('after a create refreshes the count and the markers', () async {
      repository.syncSummary = onePending;

      await repository.createLogEntry(draft);
      await settle();

      expect(bloc.state.sync, const LogsSync.pending(changeCount: 1));
      expect(bloc.state.unsyncedChanges, {
        'created-card': UnsyncedLogEntryChange.created,
      });
    });

    test('after an update refreshes the count', () async {
      repository.syncSummary = const LogsSyncSummary(
        pendingChanges: {'card-1': PendingLogEntryChange.updated},
      );

      await repository.updateLogEntry(logEntryId: 'card-1', draft: draft);
      await settle();

      expect(bloc.state.sync, const LogsSync.pending(changeCount: 1));
    });

    test('after a delete counts it, with no marker to show', () async {
      repository.syncSummary = const LogsSyncSummary(
        pendingChanges: {'card-1': PendingLogEntryChange.deleted},
      );

      await repository.deleteLogEntry('card-1');
      await settle();

      expect(bloc.state.sync, const LogsSync.pending(changeCount: 1));
      expect(bloc.state.unsyncedChanges, isEmpty);
    });

    test('from a gated write shows only once the write finishes', () async {
      final gated = FakeLogsRepository.gated()..syncSummary = onePending;
      final gatedBloc = LogsSyncBloc(gated);
      addTearDown(gatedBloc.close);

      unawaited(gated.createLogEntry(draft));
      await settle();
      expect(gatedBloc.state.sync, const LogsSync.upToDate());

      gated.completeCreate();
      await settle();
      expect(gatedBloc.state.sync, const LogsSync.pending(changeCount: 1));
    });

    test('from a write that fails changes nothing', () async {
      final failing = FakeLogsRepository(createError: StateError('write'))
        ..syncSummary = onePending;
      final failingBloc = LogsSyncBloc(failing);
      addTearDown(failingBloc.close);

      await expectLater(failing.createLogEntry(draft), throwsStateError);
      await settle();

      expect(failingBloc.state.sync, const LogsSync.upToDate());
    });

    test('during a sync updates the markers and keeps the progress', () async {
      repository
        ..syncSummary = twoPending
        ..syncResult = const LogsSyncResult(changeCount: 2, savedCount: 2)
        ..pendingSync = Completer<void>();
      bloc.add(const LogsSyncRequested());
      await settle();

      repository.syncSummary = const LogsSyncSummary(
        pendingChanges: {
          'card-1': PendingLogEntryChange.updated,
          'card-2': PendingLogEntryChange.deleted,
          'created-card': PendingLogEntryChange.created,
        },
      );
      await repository.createLogEntry(draft);
      await settle();

      expect(
        bloc.state.sync,
        const LogsSync.syncing(savedCount: 0, changeCount: 2),
      );
      expect(
        bloc.state.unsyncedChanges,
        containsPair('created-card', UnsyncedLogEntryChange.created),
      );
      repository.pendingSync!.complete();
    });

    test('during a download updates the markers and keeps the '
        'download', () async {
      repository.reportDownload(
        const LogsDownloadProgress.adding(logEntryCount: 2),
      );
      await settle();

      repository.syncSummary = const LogsSyncSummary(
        pendingChanges: {'card-1': PendingLogEntryChange.updated},
      );
      await repository.updateLogEntry(logEntryId: 'card-1', draft: draft);
      await settle();

      expect(bloc.state.sync, const LogsSync.downloading(logEntryCount: 2));
      expect(bloc.state.unsyncedChanges, {
        'card-1': UnsyncedLogEntryChange.updated,
      });
    });
  });

  group('overlapping summary reads', () {
    const onePending = LogsSyncSummary(
      pendingChanges: {'card-1': PendingLogEntryChange.updated},
    );

    void answerRead(int index, LogsSyncSummary summary) =>
        repository.heldSummaryReads[index].complete(summary);

    setUp(() => repository.holdSummaryReads = true);

    test('two saved changes end on the newest count', () async {
      bloc
        ..add(const LogsSyncRefreshed())
        ..add(const LogsSyncRefreshed());
      await settle();

      answerRead(0, onePending);
      await settle();
      answerRead(1, twoPending);
      await settle();

      expect(bloc.state.sync, const LogsSync.pending(changeCount: 2));
    });

    test('a read that answers after a newer one is dropped', () async {
      bloc
        ..add(const LogsSyncRefreshed())
        ..add(const LogsSyncRefreshed());
      await settle();

      answerRead(1, onePending);
      await settle();
      answerRead(0, twoPending);
      await settle();

      expect(bloc.state.sync, const LogsSync.pending(changeCount: 1));
      expect(bloc.state.unsyncedChanges, {
        'card-1': UnsyncedLogEntryChange.updated,
      });
    });

    test('a read older than a sync result changes neither the row nor the '
        'markers', () async {
      repository.syncResult = const LogsSyncResult(
        changeCount: 1,
        savedCount: 1,
      );
      bloc.add(const LogsSyncRefreshed());
      await settle();
      bloc.add(const LogsSyncRequested());
      await settle();

      answerRead(1, const LogsSyncSummary());
      await settle();
      expect(bloc.state.sync, const LogsSync.synced(changeCount: 1));

      answerRead(0, twoPending);
      await settle();

      expect(bloc.state.sync, const LogsSync.synced(changeCount: 1));
      expect(bloc.state.unsyncedChanges, isEmpty);
    });

    test('a change saved after the final read of a sync shows as '
        'pending', () async {
      repository.syncResult = const LogsSyncResult(
        changeCount: 1,
        savedCount: 1,
      );
      bloc.add(const LogsSyncRequested());
      await settle();
      bloc.add(const LogsSyncRefreshed());
      await settle();

      answerRead(0, const LogsSyncSummary());
      await settle();
      expect(bloc.state.sync, const LogsSync.synced(changeCount: 1));

      answerRead(1, onePending);
      await settle();

      expect(bloc.state.sync, const LogsSync.pending(changeCount: 1));
      expect(bloc.state.unsyncedChanges, {
        'card-1': UnsyncedLogEntryChange.updated,
      });
    });

    test('a read that started before a download ended keeps '
        'downloaded', () async {
      bloc.add(const LogsSyncRefreshed());
      await settle();
      repository.reportDownload(
        const LogsDownloadProgress.finished(addedCount: 1),
      );
      await settle();

      answerRead(0, const LogsSyncSummary());
      await settle();
      answerRead(1, onePending);
      await settle();

      expect(bloc.state.sync, const LogsSync.downloaded(logEntryCount: 1));
      expect(bloc.state.unsyncedChanges, {
        'card-1': UnsyncedLogEntryChange.updated,
      });
    });
  });

  group('a sync', () {
    test('with nothing pending says it is already up to date', () async {
      bloc.add(const LogsSyncRequested());
      await settle();

      expect(syncs, const [LogsSync.waiting(), LogsSync.alreadyUpToDate()]);
    });

    test('shows progress, then synced, and clears the markers', () async {
      repository
        ..syncSummary = twoPending
        ..summaryAfterSync = const LogsSyncSummary()
        ..syncProgress = const [1, 2]
        ..syncResult = const LogsSyncResult(changeCount: 2, savedCount: 2);
      bloc.add(const LogsSyncRefreshed());
      await settle();
      syncs.clear();

      bloc.add(const LogsSyncRequested());
      await settle();

      expect(syncs, const [
        LogsSync.waiting(),
        LogsSync.syncing(savedCount: 0, changeCount: 2),
        LogsSync.syncing(savedCount: 1, changeCount: 2),
        LogsSync.syncing(savedCount: 2, changeCount: 2),
        LogsSync.synced(changeCount: 2),
      ]);
      expect(bloc.state.unsyncedChanges, isEmpty);
    });

    test('that is partial names what will try again, and keeps its '
        'marker', () async {
      repository
        ..summaryAfterSync = const LogsSyncSummary(
          pendingChanges: {'card-1': PendingLogEntryChange.updated},
        )
        ..syncResult = const LogsSyncResult(changeCount: 2, savedCount: 1);

      bloc.add(const LogsSyncRequested());
      await settle();

      expect(
        bloc.state.sync,
        const LogsSync.partial(savedCount: 1, changeCount: 2),
      );
      expect(bloc.state.unsyncedChanges, {
        'card-1': UnsyncedLogEntryChange.updated,
      });
    });

    test('that saved nothing because of the network says offline', () async {
      repository
        ..syncSummary = twoPending
        ..syncResult = const LogsSyncResult(
          changeCount: 2,
          savedCount: 0,
          onlyNetworkFailures: true,
        );

      bloc.add(const LogsSyncRequested());
      await settle();

      expect(bloc.state.sync, const LogsSync.offline(changeCount: 2));
    });

    test('that saved nothing for another reason says it could not '
        'sync', () async {
      repository
        ..syncSummary = twoPending
        ..syncResult = const LogsSyncResult(changeCount: 2, savedCount: 0);

      bloc.add(const LogsSyncRequested());
      await settle();

      expect(bloc.state.sync, const LogsSync.failed(changeCount: 2));
    });

    test('that throws says it could not sync', () async {
      repository
        ..syncResult = const LogsSyncResult(changeCount: 2, savedCount: 0)
        ..syncError = StateError('push');

      bloc.add(const LogsSyncRequested());
      await settle();

      expect(bloc.state.sync, const LogsSync.failed(changeCount: 2));
    });

    test('drops a second press while it runs', () async {
      repository
        ..syncResult = const LogsSyncResult(changeCount: 2, savedCount: 2)
        ..pendingSync = Completer<void>();

      bloc
        ..add(const LogsSyncRequested())
        ..add(const LogsSyncRequested());
      await settle();
      repository.pendingSync!.complete();
      await settle();

      expect(repository.syncRequestCount, 1);
    });

    test('with changes saved during it shows them as pending', () async {
      repository
        ..summaryAfterSync = const LogsSyncSummary(
          pendingChanges: {'card-3': PendingLogEntryChange.updated},
        )
        ..syncResult = const LogsSyncResult(changeCount: 2, savedCount: 2);

      bloc.add(const LogsSyncRequested());
      await settle();

      expect(bloc.state.sync, const LogsSync.pending(changeCount: 1));
    });
  });

  group('a sync queued behind a download', () {
    setUp(() async {
      repository
        ..syncResult = const LogsSyncResult(changeCount: 1, savedCount: 1)
        ..queuedSync = Completer<void>();
      bloc.add(const LogsSyncRequested());
      await settle();
    });

    test('stays waiting when the download reports adding', () async {
      repository.reportDownload(
        const LogsDownloadProgress.adding(logEntryCount: 1),
      );
      await settle();

      expect(bloc.state.sync, const LogsSync.waiting());
      repository.queuedSync!.complete();
    });

    test('stays waiting when the download added entries', () async {
      repository.reportDownload(
        const LogsDownloadProgress.finished(addedCount: 1),
      );
      await settle();

      expect(bloc.state.sync, const LogsSync.waiting());
      repository.queuedSync!.complete();
    });

    test('stays waiting when the download added nothing', () async {
      repository.reportDownload(
        const LogsDownloadProgress.finished(addedCount: 0),
      );
      await settle();

      expect(bloc.state.sync, const LogsSync.waiting());
      repository.queuedSync!.complete();
    });

    test('still updates the markers when the download ends', () async {
      repository.syncSummary = const LogsSyncSummary(
        pendingChanges: {'card-1': PendingLogEntryChange.updated},
      );
      repository.reportDownload(
        const LogsDownloadProgress.finished(addedCount: 1),
      );
      await settle();

      expect(bloc.state.unsyncedChanges, {
        'card-1': UnsyncedLogEntryChange.updated,
      });
      repository.queuedSync!.complete();
    });

    test('shows its own progress and result after the download', () async {
      repository.reportDownload(
        const LogsDownloadProgress.finished(addedCount: 1),
      );
      await settle();
      syncs.clear();

      repository.queuedSync!.complete();
      await settle();

      expect(syncs, const [
        LogsSync.syncing(savedCount: 0, changeCount: 1),
        LogsSync.synced(changeCount: 1),
      ]);
    });
  });

  group('a download with no sync', () {
    test('shows the entries being added, then how many were added', () async {
      repository.download(const [
        LogEntry(id: 'card-remote', title: 'Remote', description: 'Remote'),
      ]);
      await settle();

      expect(syncs, const [
        LogsSync.downloading(logEntryCount: 1),
        LogsSync.downloaded(logEntryCount: 1),
      ]);
    });

    test('that added entries shows the markers of what is still '
        'pending', () async {
      repository.syncSummary = const LogsSyncSummary(
        pendingChanges: {'card-1': PendingLogEntryChange.updated},
      );

      repository.reportDownload(
        const LogsDownloadProgress.finished(addedCount: 1),
      );
      await settle();

      expect(bloc.state.sync, const LogsSync.downloaded(logEntryCount: 1));
      expect(bloc.state.unsyncedChanges, {
        'card-1': UnsyncedLogEntryChange.updated,
      });
    });

    test('that added nothing goes back to what is pending', () async {
      repository.syncSummary = const LogsSyncSummary(
        pendingChanges: {'card-1': PendingLogEntryChange.updated},
      );

      repository
        ..reportDownload(const LogsDownloadProgress.adding(logEntryCount: 2))
        ..reportDownload(const LogsDownloadProgress.finished(addedCount: 0));
      await settle();

      expect(syncs, const [
        LogsSync.downloading(logEntryCount: 2),
        LogsSync.pending(changeCount: 1),
      ]);
    });

    test('shows after an earlier sync result', () async {
      bloc.add(const LogsSyncRequested());
      await settle();
      expect(bloc.state.sync, const LogsSync.alreadyUpToDate());

      repository.download(const [
        LogEntry(id: 'card-remote', title: 'Remote', description: 'Remote'),
      ]);
      await settle();

      expect(bloc.state.sync, const LogsSync.downloaded(logEntryCount: 1));
    });

    test('blocks a sync while it adds entries', () async {
      repository.reportDownload(
        const LogsDownloadProgress.adding(logEntryCount: 2),
      );
      await settle();

      bloc.add(const LogsSyncRequested());
      await settle();

      expect(repository.syncRequestCount, 0);
      expect(bloc.state.sync, const LogsSync.downloading(logEntryCount: 2));
    });
  });

  test('stops listening when closed', () async {
    await bloc.close();

    repository.download(const [
      LogEntry(id: 'card-remote', title: 'Remote', description: 'Remote'),
    ]);
    await repository.createLogEntry(draft);
    await settle();

    expect(syncs, isEmpty);
  });
}
