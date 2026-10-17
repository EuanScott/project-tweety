import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';
import 'package:project_tweety/presentation/pages/logs/bloc/logs.bloc.dart';

import '../../../../support/fake_logs_repository.dart';

void main() {
  const logEntry = LogEntry(
    id: 'card-1',
    title: 'Card Title 1',
    description: 'Card body',
  );

  group('LogsBloc', () {
    blocTest<LogsBloc, LogsState>(
      'tracks dirty state from raw draft values against the editor snapshot',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () =>
          const LogsState(status: LogsStatus.success, items: [logEntry]),
      act: (bloc) => bloc
        ..add(const LogsEditStarted('card-1'))
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(title: ' Card Title 1 ', description: 'Card body'),
          ),
        ),
      expect: () => [
        isA<LogsState>().having(
          (state) => state.isDraftDirty,
          'is dirty',
          isFalse,
        ),
        isA<LogsState>().having(
          (state) => state.isDraftDirty,
          'is dirty',
          isTrue,
        ),
      ],
    );
    late FakeLogsRepository controlledCreateRepository;
    blocTest<LogsBloc, LogsState>(
      'loads the collection and derives selected and missing details from it',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      act: (bloc) => bloc.add(const LogsStarted()),
      expect: () => [
        const LogsState(status: LogsStatus.loading),
        const LogsState(status: LogsStatus.success, items: [logEntry]),
      ],
      verify: (bloc) {
        expect(
          bloc.state.detailFor('card-1'),
          const LogsDetail.success(logEntry),
        );
        expect(
          bloc.state.detailFor('missing-card'),
          const LogsDetail.missing(),
        );
      },
    );

    blocTest<LogsBloc, LogsState>(
      'derives loading and failure details from collection loading',
      build: () => LogsBloc(
        FakeLogsRepository(logs: const [], readError: StateError('failed')),
      ),
      act: (bloc) => bloc.add(const LogsStarted()),
      expect: () => [
        const LogsState(status: LogsStatus.loading),
        const LogsState(
          status: LogsStatus.failure,
          errorMessage: 'Unable to load logs right now.',
        ),
      ],
      verify: (bloc) {
        expect(
          const LogsState(status: LogsStatus.loading).detailFor('card-1'),
          const LogsDetail.loading(),
        );
        expect(
          bloc.state.detailFor('card-1'),
          const LogsDetail.failure('Unable to load logs right now.'),
        );
      },
      errors: () => [isA<StateError>()],
    );

    blocTest<LogsBloc, LogsState>(
      'shows validation after submit and updates it from raw draft changes',
      build: () => LogsBloc(FakeLogsRepository(logs: const [])),
      act: (bloc) => bloc
        ..add(
          const LogsDraftChanged(LogEntryDraft(title: '  ', description: '\t')),
        )
        ..add(const LogsCreateSubmitted())
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(title: 'Raw title', description: '\t'),
          ),
        )
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(title: 'Raw title', description: 'Raw description'),
          ),
        ),
      expect: () => [
        const LogsState(
          draft: LogEntryDraft(title: '  ', description: '\t'),
        ),
        const LogsState(
          draft: LogEntryDraft(title: '  ', description: '\t'),
          hasSubmittedCreate: true,
          invalidDraftFields: {
            LogEntryDraftField.title,
            LogEntryDraftField.description,
          },
        ),
        const LogsState(
          draft: LogEntryDraft(title: 'Raw title', description: '\t'),
          hasSubmittedCreate: true,
          invalidDraftFields: {LogEntryDraftField.description},
        ),
        const LogsState(
          draft: LogEntryDraft(
            title: 'Raw title',
            description: 'Raw description',
          ),
          hasSubmittedCreate: true,
        ),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'ignores duplicate create submissions while one is pending',
      build: () {
        controlledCreateRepository = FakeLogsRepository.gated();
        return LogsBloc(controlledCreateRepository);
      },
      act: (bloc) async {
        bloc
          ..add(
            const LogsDraftChanged(
              LogEntryDraft(title: 'New title', description: 'New description'),
            ),
          )
          ..add(const LogsCreateSubmitted())
          ..add(const LogsCreateSubmitted());
        await Future<void>.delayed(Duration.zero);
        expect(controlledCreateRepository.createRequestCount, 1);
        controlledCreateRepository.completeCreate();
      },
      expect: () => [
        const LogsState(
          draft: LogEntryDraft(
            title: 'New title',
            description: 'New description',
          ),
        ),
        const LogsState(
          draft: LogEntryDraft(
            title: 'New title',
            description: 'New description',
          ),
          hasSubmittedCreate: true,
          createStatus: LogsCreateStatus.creating,
        ),
        const LogsState(
          items: [
            LogEntry(
              id: 'created-card',
              title: 'New title',
              description: 'New description',
            ),
          ],
          createStatus: LogsCreateStatus.success,
          createdLogEntryId: 'created-card',
        ),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'a created log entry is listed first and leaves no unsaved draft',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () =>
          const LogsState(status: LogsStatus.success, items: [logEntry]),
      act: (bloc) => bloc
        ..add(const LogsCreateStarted())
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(title: 'New title', description: 'New description'),
          ),
        )
        ..add(const LogsCreateSubmitted()),
      skip: 3,
      expect: () => [
        isA<LogsState>()
            .having((state) => state.items.map((item) => item.id), 'item ids', [
              'created-card',
              'card-1',
            ])
            .having(
              (state) => state.createdLogEntryId,
              'created id',
              'created-card',
            )
            .having((state) => state.isDraftDirty, 'is dirty', isFalse),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'retains the raw draft after a create failure',
      build: () => LogsBloc(
        FakeLogsRepository(
          logs: const [],
          createError: StateError('create failed'),
        ),
      ),
      act: (bloc) => bloc
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(
              title: '  Raw title  ',
              description: 'Raw description',
            ),
          ),
        )
        ..add(const LogsCreateSubmitted()),
      expect: () => [
        const LogsState(
          draft: LogEntryDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
        ),
        const LogsState(
          draft: LogEntryDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          hasSubmittedCreate: true,
          createStatus: LogsCreateStatus.creating,
        ),
        const LogsState(
          draft: LogEntryDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          hasSubmittedCreate: true,
          createStatus: LogsCreateStatus.failure,
          createError: true,
        ),
      ],
      errors: () => [isA<StateError>()],
    );

    blocTest<LogsBloc, LogsState>(
      'preserves the active raw draft and validation state when refreshing',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () => const LogsState(
        draft: LogEntryDraft(
          title: '  Raw title  ',
          description: 'Raw description',
        ),
        hasSubmittedCreate: true,
        invalidDraftFields: {LogEntryDraftField.title},
      ),
      act: (bloc) => bloc.add(const LogsStarted()),
      expect: () => [
        const LogsState(
          status: LogsStatus.loading,
          draft: LogEntryDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          hasSubmittedCreate: true,
          invalidDraftFields: {LogEntryDraftField.title},
        ),
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          hasSubmittedCreate: true,
          invalidDraftFields: {LogEntryDraftField.title},
        ),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'updates an edited log entry atomically and returns to read-only details',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () =>
          const LogsState(status: LogsStatus.success, items: [logEntry]),
      act: (bloc) => bloc
        ..add(const LogsEditStarted('card-1'))
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(
              title: '  Updated title  ',
              description: 'Updated body',
            ),
          ),
        )
        ..add(const LogsEditSubmitted()),
      expect: () => [
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(title: 'Card Title 1', description: 'Card body'),
          initialDraft: LogEntryDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingLogEntryId: 'card-1',
        ),
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(
            title: '  Updated title  ',
            description: 'Updated body',
          ),
          initialDraft: LogEntryDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingLogEntryId: 'card-1',
        ),
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(
            title: '  Updated title  ',
            description: 'Updated body',
          ),
          initialDraft: LogEntryDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingLogEntryId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: LogsEditStatus.updating,
        ),
        const LogsState(
          status: LogsStatus.success,
          items: [
            LogEntry(
              id: 'card-1',
              title: 'Updated title',
              description: 'Updated body',
            ),
          ],
          editStatus: LogsEditStatus.success,
          updatedLogEntryId: 'card-1',
        ),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'retains an edit draft but exposes a non-retryable missing target',
      build: () => LogsBloc(
        FakeLogsRepository(
          logs: const [],
          updateError: const LogEntryNotFoundException('card-1'),
        ),
      ),
      seed: () =>
          const LogsState(status: LogsStatus.success, items: [logEntry]),
      act: (bloc) => bloc
        ..add(const LogsEditStarted('card-1'))
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(title: 'Raw title', description: 'Raw description'),
          ),
        )
        ..add(const LogsEditSubmitted()),
      expect: () => [
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(title: 'Card Title 1', description: 'Card body'),
          initialDraft: LogEntryDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingLogEntryId: 'card-1',
        ),
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(
            title: 'Raw title',
            description: 'Raw description',
          ),
          initialDraft: LogEntryDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingLogEntryId: 'card-1',
        ),
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(
            title: 'Raw title',
            description: 'Raw description',
          ),
          initialDraft: LogEntryDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingLogEntryId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: LogsEditStatus.updating,
        ),
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(
            title: 'Raw title',
            description: 'Raw description',
          ),
          initialDraft: LogEntryDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingLogEntryId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: LogsEditStatus.notFound,
          missingEditLogEntryId: 'card-1',
        ),
      ],
      errors: () => [isA<LogEntryNotFoundException>()],
    );

    blocTest<LogsBloc, LogsState>(
      'ignores duplicate edit submissions while an update is pending',
      build: () {
        controlledCreateRepository = FakeLogsRepository.gated();
        return LogsBloc(controlledCreateRepository);
      },
      seed: () =>
          const LogsState(status: LogsStatus.success, items: [logEntry]),
      act: (bloc) async {
        bloc
          ..add(const LogsEditStarted('card-1'))
          ..add(
            const LogsDraftChanged(
              LogEntryDraft(title: 'Updated title', description: 'Card body'),
            ),
          )
          ..add(const LogsEditSubmitted())
          ..add(const LogsEditSubmitted());
        await Future<void>.delayed(Duration.zero);
        expect(controlledCreateRepository.updateRequestCount, 1);
        controlledCreateRepository.completeUpdate(logEntry);
      },
      skip: 2,
      expect: () => [
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(
            title: 'Updated title',
            description: 'Card body',
          ),
          initialDraft: LogEntryDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingLogEntryId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: LogsEditStatus.updating,
        ),
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          editStatus: LogsEditStatus.success,
          updatedLogEntryId: 'card-1',
        ),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'preserves an active edit draft and validation state when refreshing',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () => const LogsState(
        status: LogsStatus.success,
        items: [logEntry],
        draft: LogEntryDraft(
          title: '  Raw title  ',
          description: 'Raw description',
        ),
        invalidDraftFields: {LogEntryDraftField.title},
        editingLogEntryId: 'card-1',
        hasSubmittedEdit: true,
      ),
      act: (bloc) => bloc.add(const LogsStarted()),
      expect: () => [
        const LogsState(
          status: LogsStatus.loading,
          draft: LogEntryDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          invalidDraftFields: {LogEntryDraftField.title},
          editingLogEntryId: 'card-1',
          hasSubmittedEdit: true,
        ),
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          invalidDraftFields: {LogEntryDraftField.title},
          editingLogEntryId: 'card-1',
          hasSubmittedEdit: true,
        ),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'retains the raw edit draft after a recoverable update failure',
      build: () => LogsBloc(
        FakeLogsRepository(
          logs: const [],
          updateError: StateError('update failed'),
        ),
      ),
      seed: () => const LogsState(
        status: LogsStatus.success,
        items: [logEntry],
        draft: LogEntryDraft(
          title: 'Raw title',
          description: 'Raw description',
        ),
        editingLogEntryId: 'card-1',
      ),
      act: (bloc) => bloc.add(const LogsEditSubmitted()),
      expect: () => [
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(
            title: 'Raw title',
            description: 'Raw description',
          ),
          editingLogEntryId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: LogsEditStatus.updating,
        ),
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          draft: LogEntryDraft(
            title: 'Raw title',
            description: 'Raw description',
          ),
          editingLogEntryId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: LogsEditStatus.failure,
          editError: true,
        ),
      ],
      errors: () => [isA<StateError>()],
    );

    blocTest<LogsBloc, LogsState>(
      'removes a log entry after deletion and ignores duplicate requests while pending',
      build: () {
        controlledCreateRepository = FakeLogsRepository.gated();
        return LogsBloc(controlledCreateRepository);
      },
      seed: () =>
          const LogsState(status: LogsStatus.success, items: [logEntry]),
      act: (bloc) async {
        bloc
          ..add(const LogsDeleteSubmitted('card-1'))
          ..add(const LogsDeleteSubmitted('card-1'));
        await Future<void>.delayed(Duration.zero);
        expect(controlledCreateRepository.deleteRequestCount, 1);
        controlledCreateRepository.completeDelete();
      },
      expect: () => [
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          deleteStatus: LogsDeleteStatus.deleting,
          deletingLogEntryId: 'card-1',
        ),
        const LogsState(
          status: LogsStatus.success,
          deletedLogEntryId: 'card-1',
          deleteStatus: LogsDeleteStatus.success,
        ),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'retains the log entry and exposes retryable deletion failure',
      build: () => LogsBloc(
        FakeLogsRepository(
          logs: const [],
          deleteError: StateError('delete failed'),
        ),
      ),
      seed: () =>
          const LogsState(status: LogsStatus.success, items: [logEntry]),
      act: (bloc) => bloc.add(const LogsDeleteSubmitted('card-1')),
      expect: () => [
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          deleteStatus: LogsDeleteStatus.deleting,
          deletingLogEntryId: 'card-1',
        ),
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          deleteStatus: LogsDeleteStatus.failure,
          deleteErrorLogEntryId: 'card-1',
        ),
      ],
      errors: () => [isA<StateError>()],
    );

    late FakeLogsRepository unchangedEditRepository;
    blocTest<LogsBloc, LogsState>(
      'submitting unchanged edit draft exits edit mode without update',
      build: () {
        unchangedEditRepository = FakeLogsRepository(logs: const [logEntry]);
        return LogsBloc(unchangedEditRepository);
      },
      seed: () => LogsState(
        status: LogsStatus.success,
        items: const [logEntry],
        editingLogEntryId: 'card-1',
        draft: LogEntryDraft(
          title: logEntry.title,
          description: logEntry.description,
        ),
        initialDraft: LogEntryDraft(
          title: logEntry.title,
          description: logEntry.description,
        ),
      ),
      act: (bloc) => bloc.add(const LogsEditSubmitted()),
      expect: () => [
        LogsState(
          status: LogsStatus.success,
          items: const [logEntry],
          draft: LogEntryDraft(
            title: logEntry.title,
            description: logEntry.description,
          ),
          editStatus: LogsEditStatus.idle,
        ),
      ],
      verify: (_) {
        expect(unchangedEditRepository.updateRequestCount, 0);
      },
    );

    test('starts with every log entry synced and none marked', () {
      final bloc = LogsBloc(FakeLogsRepository());
      addTearDown(bloc.close);

      expect(bloc.state.sync, const LogsSync.upToDate());
      expect(bloc.state.unsyncedChanges, isEmpty);
    });

    blocTest<LogsBloc, LogsState>(
      'replaces the sync status and the unsynced log entry changes together',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () =>
          const LogsState(status: LogsStatus.success, items: [logEntry]),
      act: (bloc) => bloc.add(
        const LogsSyncChanged(
          LogsSync.pending(changeCount: 2),
          unsyncedChanges: {'card-1': UnsyncedLogEntryChange.updated},
        ),
      ),
      expect: () => [
        const LogsState(
          status: LogsStatus.success,
          items: [logEntry],
          sync: LogsSync.pending(changeCount: 2),
          unsyncedChanges: {'card-1': UnsyncedLogEntryChange.updated},
        ),
      ],
    );

    group('sync', () {
      const twoPending = LogsSyncSummary(
        pendingChanges: {
          'card-1': PendingLogEntryChange.updated,
          'card-2': PendingLogEntryChange.deleted,
        },
      );
      late FakeLogsRepository repository;
      late LogsBloc bloc;
      late List<LogsSync> syncs;

      setUp(() {
        repository = FakeLogsRepository(logs: const [logEntry]);
        bloc = LogsBloc(repository);
        syncs = [];
        bloc.stream.map((state) => state.sync).distinct().listen(syncs.add);
      });

      tearDown(() => bloc.close());

      Future<void> settle() => pumpEventQueue();

      test('loading the log entries shows what is pending and marks each '
          'Card', () async {
        repository.syncSummary = twoPending;

        bloc.add(const LogsStarted());
        await settle();

        expect(bloc.state.sync, const LogsSync.pending(changeCount: 2));
        expect(bloc.state.unsyncedChanges, {
          'card-1': UnsyncedLogEntryChange.updated,
        });
      });

      test('with nothing pending, loading shows the last sync '
          'time', () async {
        final lastSyncedAt = DateTime.utc(2026, 10, 9);
        repository.syncSummary = LogsSyncSummary(lastSyncedAt: lastSyncedAt);

        bloc.add(const LogsStarted());
        await settle();

        expect(bloc.state.sync, LogsSync.upToDate(lastSyncedAt: lastSyncedAt));
      });

      test('a saved change refreshes the pending count', () async {
        bloc.add(const LogsStarted());
        await settle();
        repository.syncSummary = const LogsSyncSummary(
          pendingChanges: {'created-card': PendingLogEntryChange.created},
        );

        bloc
          ..add(const LogsCreateStarted())
          ..add(
            const LogsDraftChanged(
              LogEntryDraft(title: 'New', description: 'New'),
            ),
          )
          ..add(const LogsCreateSubmitted());
        await settle();

        expect(bloc.state.sync, const LogsSync.pending(changeCount: 1));
        expect(bloc.state.unsyncedChanges, {
          'created-card': UnsyncedLogEntryChange.created,
        });
      });

      test('with nothing pending, a sync says it is already up to '
          'date', () async {
        bloc.add(const LogsSyncRequested());
        await settle();

        expect(syncs, const [LogsSync.alreadyUpToDate()]);
      });

      test('a full sync shows progress, then synced, and clears the '
          'markers', () async {
        repository
          ..syncSummary = twoPending
          ..summaryAfterSync = const LogsSyncSummary()
          ..syncProgress = [1, 2]
          ..syncResult = const LogsSyncResult(changeCount: 2, savedCount: 2);

        bloc.add(const LogsSyncRequested());
        await settle();

        expect(syncs, const [
          LogsSync.syncing(savedCount: 0, changeCount: 2),
          LogsSync.syncing(savedCount: 1, changeCount: 2),
          LogsSync.syncing(savedCount: 2, changeCount: 2),
          LogsSync.synced(changeCount: 2),
        ]);
        expect(bloc.state.unsyncedChanges, isEmpty);
      });

      test('a partial sync names what will try again, and keeps its '
          'marker', () async {
        repository
          ..syncSummary = twoPending
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

      test('nothing saved because of the network says offline', () async {
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

      test('nothing saved for any other reason says it could not '
          'sync', () async {
        repository
          ..syncSummary = twoPending
          ..syncResult = const LogsSyncResult(changeCount: 2, savedCount: 0);

        bloc.add(const LogsSyncRequested());
        await settle();

        expect(bloc.state.sync, const LogsSync.failed(changeCount: 2));
      });

      test('a sync that throws says it could not sync', () async {
        repository
          ..syncSummary = twoPending
          ..syncResult = const LogsSyncResult(changeCount: 2, savedCount: 0)
          ..syncError = Exception('database closed');

        bloc.add(const LogsSyncRequested());
        await settle();

        expect(bloc.state.sync, const LogsSync.failed(changeCount: 2));
      });

      test('a second press while a sync runs is dropped', () async {
        repository
          ..syncSummary = twoPending
          ..pendingSync = Completer<void>();

        bloc
          ..add(const LogsSyncRequested())
          ..add(const LogsSyncRequested());
        await settle();
        repository.pendingSync!.complete();
        await settle();

        expect(repository.syncRequestCount, 1);
      });

      test('a full sync with changes saved during it shows them as '
          'pending', () async {
        repository
          ..syncSummary = twoPending
          ..summaryAfterSync = const LogsSyncSummary(
            pendingChanges: {'card-3': PendingLogEntryChange.updated},
          )
          ..syncResult = const LogsSyncResult(changeCount: 2, savedCount: 2);

        bloc.add(const LogsSyncRequested());
        await settle();

        expect(bloc.state.sync, const LogsSync.pending(changeCount: 1));
      });

      test('a change saved during a sync updates the markers and keeps '
          'the progress', () async {
        bloc.add(const LogsStarted());
        await settle();
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
        bloc
          ..add(const LogsCreateStarted())
          ..add(
            const LogsDraftChanged(
              LogEntryDraft(title: 'New', description: 'New'),
            ),
          )
          ..add(const LogsCreateSubmitted());
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
    });
  });
}
