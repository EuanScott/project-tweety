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
  const logEntryDraft = LogEntryDraft(
    title: 'Card Title 1',
    description: 'Card body',
  );

  group('LogsBloc', () {
    blocTest<LogsBloc, LogsState>(
      'discarding an unsaved new entry clears the draft and the dirty flag',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      act: (bloc) => bloc
        ..add(const LogsCreateStarted())
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(title: 'Unsaved', description: ''),
          ),
        )
        ..add(const LogsDraftDiscarded()),
      verify: (bloc) {
        expect(bloc.state.editor, const LogsEditor.closed());
        expect(bloc.state.isDraftDirty, isFalse);
      },
    );

    blocTest<LogsBloc, LogsState>(
      'discarding an edit of an existing entry closes the editor',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () => const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
      act: (bloc) => bloc
        ..add(const LogsEditStarted('card-1'))
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(title: 'Changed', description: 'Card body'),
          ),
        )
        ..add(const LogsDraftDiscarded()),
      verify: (bloc) {
        expect(bloc.state.editor, const LogsEditor.closed());
        expect(bloc.state.isEditingLogEntry('card-1'), isFalse);
        expect(bloc.state.isDraftDirty, isFalse);
      },
    );

    blocTest<LogsBloc, LogsState>(
      'tracks dirty state from raw draft values against the editor snapshot',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () => const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
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
        const LogsState(load: LogsLoad.loading()),
        const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
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
        const LogsState(load: LogsLoad.loading()),
        const LogsState(load: LogsLoad.failed(LogsError.loadFailed)),
      ],
      verify: (bloc) {
        expect(
          const LogsState(load: LogsLoad.loading()).detailFor('card-1'),
          const LogsDetail.loading(),
        );
        expect(
          bloc.state.detailFor('card-1'),
          const LogsDetail.failure(LogsError.loadFailed),
        );
      },
      errors: () => [isA<StateError>()],
    );

    blocTest<LogsBloc, LogsState>(
      'shows validation after submit and updates it from raw draft changes',
      build: () => LogsBloc(FakeLogsRepository(logs: const [])),
      act: (bloc) => bloc
        ..add(const LogsCreateStarted())
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
        const LogsState(editor: LogsEditor.creating()),
        const LogsState(
          editor: LogsEditor.creating(
            draft: LogEntryDraft(title: '  ', description: '\t'),
          ),
        ),
        const LogsState(
          editor: LogsEditor.creating(
            draft: LogEntryDraft(title: '  ', description: '\t'),
            hasSubmitted: true,
            invalidFields: {
              LogEntryDraftField.title,
              LogEntryDraftField.description,
            },
          ),
        ),
        const LogsState(
          editor: LogsEditor.creating(
            draft: LogEntryDraft(title: 'Raw title', description: '\t'),
            hasSubmitted: true,
            invalidFields: {LogEntryDraftField.description},
          ),
        ),
        const LogsState(
          editor: LogsEditor.creating(
            draft: LogEntryDraft(
              title: 'Raw title',
              description: 'Raw description',
            ),
            hasSubmitted: true,
          ),
        ),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'ignores draft changes and saves while no editor is open',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      act: (bloc) => bloc
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(title: 'Stray', description: 'Stray'),
          ),
        )
        ..add(const LogsCreateSubmitted())
        ..add(const LogsEditSubmitted())
        ..add(const LogsEditCancelled())
        ..add(const LogsDraftDiscarded()),
      expect: () => const <LogsState>[],
    );

    blocTest<LogsBloc, LogsState>(
      'ignores duplicate create submissions while one is pending',
      build: () {
        controlledCreateRepository = FakeLogsRepository.gated();
        return LogsBloc(controlledCreateRepository);
      },
      act: (bloc) async {
        bloc
          ..add(const LogsCreateStarted())
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
      skip: 1,
      expect: () => [
        const LogsState(
          editor: LogsEditor.creating(
            draft: LogEntryDraft(
              title: 'New title',
              description: 'New description',
            ),
          ),
        ),
        const LogsState(
          editor: LogsEditor.creating(
            draft: LogEntryDraft(
              title: 'New title',
              description: 'New description',
            ),
            hasSubmitted: true,
            save: LogsSaveStatus.saving,
          ),
        ),
        const LogsState(
          items: [
            LogEntry(
              id: 'created-card',
              title: 'New title',
              description: 'New description',
            ),
          ],
          outcome: LogsOutcome.created('created-card'),
        ),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'a create that ends after its editor was discarded still lists and '
      'opens the new entry, and leaves the editor closed',
      build: () {
        controlledCreateRepository = FakeLogsRepository.gated();
        return LogsBloc(controlledCreateRepository);
      },
      act: (bloc) async {
        bloc
          ..add(const LogsCreateStarted())
          ..add(
            const LogsDraftChanged(
              LogEntryDraft(title: 'New title', description: 'New description'),
            ),
          )
          ..add(const LogsCreateSubmitted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const LogsDraftDiscarded());
        await Future<void>.delayed(Duration.zero);
        controlledCreateRepository.completeCreate();
      },
      verify: (bloc) {
        expect(bloc.state.editor, const LogsEditor.closed());
        expect(bloc.state.outcome, const LogsOutcome.created('created-card'));
        expect(bloc.state.items.map((item) => item.id), ['created-card']);
      },
    );

    blocTest<LogsBloc, LogsState>(
      'a created log entry is listed first and leaves no unsaved draft',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () => const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
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
              (state) => state.outcome,
              'outcome',
              const LogsOutcome.created('created-card'),
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
        ..add(const LogsCreateStarted())
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(
              title: '  Raw title  ',
              description: 'Raw description',
            ),
          ),
        )
        ..add(const LogsCreateSubmitted()),
      skip: 1,
      expect: () => [
        const LogsState(
          editor: LogsEditor.creating(
            draft: LogEntryDraft(
              title: '  Raw title  ',
              description: 'Raw description',
            ),
          ),
        ),
        const LogsState(
          editor: LogsEditor.creating(
            draft: LogEntryDraft(
              title: '  Raw title  ',
              description: 'Raw description',
            ),
            hasSubmitted: true,
            save: LogsSaveStatus.saving,
          ),
        ),
        const LogsState(
          editor: LogsEditor.creating(
            draft: LogEntryDraft(
              title: '  Raw title  ',
              description: 'Raw description',
            ),
            hasSubmitted: true,
            save: LogsSaveStatus.failed,
          ),
        ),
      ],
      errors: () => [isA<StateError>()],
    );

    blocTest<LogsBloc, LogsState>(
      'preserves the active raw draft and validation state when refreshing',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () => const LogsState(
        editor: LogsEditor.creating(
          draft: LogEntryDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          hasSubmitted: true,
          invalidFields: {LogEntryDraftField.title},
        ),
      ),
      act: (bloc) => bloc.add(const LogsStarted()),
      expect: () => [
        const LogsState(
          load: LogsLoad.loading(),
          editor: LogsEditor.creating(
            draft: LogEntryDraft(
              title: '  Raw title  ',
              description: 'Raw description',
            ),
            hasSubmitted: true,
            invalidFields: {LogEntryDraftField.title},
          ),
        ),
        const LogsState(
          load: LogsLoad.loaded(),
          items: [logEntry],
          editor: LogsEditor.creating(
            draft: LogEntryDraft(
              title: '  Raw title  ',
              description: 'Raw description',
            ),
            hasSubmitted: true,
            invalidFields: {LogEntryDraftField.title},
          ),
        ),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'updates an edited log entry atomically and returns to read-only details',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () => const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
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
          load: LogsLoad.loaded(),
          items: [logEntry],
          editor: LogsEditor.editing(
            logEntryId: 'card-1',
            initialDraft: logEntryDraft,
            draft: logEntryDraft,
          ),
        ),
        const LogsState(
          load: LogsLoad.loaded(),
          items: [logEntry],
          editor: LogsEditor.editing(
            logEntryId: 'card-1',
            initialDraft: logEntryDraft,
            draft: LogEntryDraft(
              title: '  Updated title  ',
              description: 'Updated body',
            ),
          ),
        ),
        const LogsState(
          load: LogsLoad.loaded(),
          items: [logEntry],
          editor: LogsEditor.editing(
            logEntryId: 'card-1',
            initialDraft: logEntryDraft,
            draft: LogEntryDraft(
              title: '  Updated title  ',
              description: 'Updated body',
            ),
            hasSubmitted: true,
            save: LogsSaveStatus.saving,
          ),
        ),
        const LogsState(
          load: LogsLoad.loaded(),
          items: [
            LogEntry(
              id: 'card-1',
              title: 'Updated title',
              description: 'Updated body',
            ),
          ],
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
      seed: () => const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
      act: (bloc) => bloc
        ..add(const LogsEditStarted('card-1'))
        ..add(
          const LogsDraftChanged(
            LogEntryDraft(title: 'Raw title', description: 'Raw description'),
          ),
        )
        ..add(const LogsEditSubmitted())
        ..add(const LogsEditSubmitted()),
      skip: 2,
      expect: () => [
        const LogsState(
          load: LogsLoad.loaded(),
          items: [logEntry],
          editor: LogsEditor.editing(
            logEntryId: 'card-1',
            initialDraft: logEntryDraft,
            draft: LogEntryDraft(
              title: 'Raw title',
              description: 'Raw description',
            ),
            hasSubmitted: true,
            save: LogsSaveStatus.saving,
          ),
        ),
        const LogsState(
          load: LogsLoad.loaded(),
          items: [logEntry],
          editor: LogsEditor.missing(
            logEntryId: 'card-1',
            initialDraft: logEntryDraft,
            draft: LogEntryDraft(
              title: 'Raw title',
              description: 'Raw description',
            ),
          ),
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.hasMissingEditFor('card-1'), isTrue);
        expect(bloc.state.isEditingLogEntry('card-1'), isTrue);
        expect(bloc.state.isDraftDirty, isTrue);
      },
      errors: () => [isA<LogEntryNotFoundException>()],
    );

    blocTest<LogsBloc, LogsState>(
      'ignores duplicate edit submissions while an update is pending',
      build: () {
        controlledCreateRepository = FakeLogsRepository.gated();
        return LogsBloc(controlledCreateRepository);
      },
      seed: () => const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
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
          load: LogsLoad.loaded(),
          items: [logEntry],
          editor: LogsEditor.editing(
            logEntryId: 'card-1',
            initialDraft: logEntryDraft,
            draft: LogEntryDraft(
              title: 'Updated title',
              description: 'Card body',
            ),
            hasSubmitted: true,
            save: LogsSaveStatus.saving,
          ),
        ),
        const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
      ],
    );

    blocTest<LogsBloc, LogsState>(
      'preserves an active edit draft and validation state when refreshing',
      build: () => LogsBloc(FakeLogsRepository(logs: const [logEntry])),
      seed: () => const LogsState(
        load: LogsLoad.loaded(),
        items: [logEntry],
        editor: LogsEditor.editing(
          logEntryId: 'card-1',
          initialDraft: logEntryDraft,
          draft: LogEntryDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          hasSubmitted: true,
          invalidFields: {LogEntryDraftField.title},
        ),
      ),
      act: (bloc) => bloc.add(const LogsStarted()),
      expect: () => [
        const LogsState(
          load: LogsLoad.loading(),
          editor: LogsEditor.editing(
            logEntryId: 'card-1',
            initialDraft: logEntryDraft,
            draft: LogEntryDraft(
              title: '  Raw title  ',
              description: 'Raw description',
            ),
            hasSubmitted: true,
            invalidFields: {LogEntryDraftField.title},
          ),
        ),
        const LogsState(
          load: LogsLoad.loaded(),
          items: [logEntry],
          editor: LogsEditor.editing(
            logEntryId: 'card-1',
            initialDraft: logEntryDraft,
            draft: LogEntryDraft(
              title: '  Raw title  ',
              description: 'Raw description',
            ),
            hasSubmitted: true,
            invalidFields: {LogEntryDraftField.title},
          ),
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
        load: LogsLoad.loaded(),
        items: [logEntry],
        editor: LogsEditor.editing(
          logEntryId: 'card-1',
          initialDraft: logEntryDraft,
          draft: LogEntryDraft(
            title: 'Raw title',
            description: 'Raw description',
          ),
        ),
      ),
      act: (bloc) => bloc.add(const LogsEditSubmitted()),
      expect: () => [
        const LogsState(
          load: LogsLoad.loaded(),
          items: [logEntry],
          editor: LogsEditor.editing(
            logEntryId: 'card-1',
            initialDraft: logEntryDraft,
            draft: LogEntryDraft(
              title: 'Raw title',
              description: 'Raw description',
            ),
            hasSubmitted: true,
            save: LogsSaveStatus.saving,
          ),
        ),
        const LogsState(
          load: LogsLoad.loaded(),
          items: [logEntry],
          editor: LogsEditor.editing(
            logEntryId: 'card-1',
            initialDraft: logEntryDraft,
            draft: LogEntryDraft(
              title: 'Raw title',
              description: 'Raw description',
            ),
            hasSubmitted: true,
            save: LogsSaveStatus.failed,
          ),
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
      seed: () => const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
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
          load: LogsLoad.loaded(),
          items: [logEntry],
          deletion: LogsDeletion.deleting('card-1'),
        ),
        const LogsState(
          load: LogsLoad.loaded(),
          outcome: LogsOutcome.deleted('card-1'),
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
      seed: () => const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
      act: (bloc) => bloc.add(const LogsDeleteSubmitted('card-1')),
      expect: () => [
        const LogsState(
          load: LogsLoad.loaded(),
          items: [logEntry],
          deletion: LogsDeletion.deleting('card-1'),
        ),
        const LogsState(
          load: LogsLoad.loaded(),
          items: [logEntry],
          deletion: LogsDeletion.failed('card-1'),
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
      seed: () => const LogsState(
        load: LogsLoad.loaded(),
        items: [logEntry],
        editor: LogsEditor.editing(
          logEntryId: 'card-1',
          initialDraft: logEntryDraft,
          draft: logEntryDraft,
        ),
      ),
      act: (bloc) => bloc.add(const LogsEditSubmitted()),
      expect: () => [
        const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
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
      seed: () => const LogsState(load: LogsLoad.loaded(), items: [logEntry]),
      act: (bloc) => bloc.add(
        const LogsSyncChanged(
          LogsSync.pending(changeCount: 2),
          unsyncedChanges: {'card-1': UnsyncedLogEntryChange.updated},
        ),
      ),
      expect: () => [
        const LogsState(
          load: LogsLoad.loaded(),
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

        expect(syncs, const [LogsSync.waiting(), LogsSync.alreadyUpToDate()]);
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
          LogsSync.waiting(),
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

      test('a sync queued behind a download is visibly busy at once, and '
          'stays busy when the download ends', () async {
        repository
          ..syncSummary = twoPending
          ..queuedSync = Completer<void>();
        bloc.add(const LogsSyncRequested());
        await settle();

        expect(bloc.state.sync.isBusy, isTrue);

        repository.reportDownload(
          const LogsDownloadProgress.finished(addedCount: 0),
        );
        await settle();

        expect(bloc.state.sync.isBusy, isTrue);
        expect(repository.syncRequestCount, 1);

        repository.queuedSync!.complete();
        await settle();

        expect(bloc.state.sync.isBusy, isFalse);
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

    group('download', () {
      const downloadedEntry = LogEntry(
        id: 'card-remote',
        title: 'From another device',
        description: 'Downloaded',
      );
      late FakeLogsRepository repository;
      late LogsBloc bloc;
      late List<LogsSync> syncs;

      setUp(() async {
        repository = FakeLogsRepository(logs: const [logEntry]);
        bloc = LogsBloc(repository)..add(const LogsStarted());
        await pumpEventQueue();
        syncs = [];
        bloc.stream.map((state) => state.sync).distinct().listen(syncs.add);
      });

      tearDown(() => bloc.close());

      test('shows the entries being added, then how many were added, in one '
          'list update', () async {
        repository.download(const [downloadedEntry]);
        await pumpEventQueue();

        expect(syncs, const [
          LogsSync.downloading(logEntryCount: 1),
          LogsSync.downloaded(logEntryCount: 1),
        ]);
        expect(bloc.state.items, contains(downloadedEntry));
        expect(bloc.state.items, contains(logEntry));
      });

      test('a download that added entries shows the markers of what is '
          'still pending', () async {
        repository.syncSummary = const LogsSyncSummary(
          pendingChanges: {'card-1': PendingLogEntryChange.updated},
        );

        repository.download(const [downloadedEntry]);
        await pumpEventQueue();

        expect(bloc.state.unsyncedChanges, {
          'card-1': UnsyncedLogEntryChange.updated,
        });
      });

      test('a download that ends having added nothing goes back to what is '
          'pending, and leaves the list alone', () async {
        repository.syncSummary = const LogsSyncSummary(
          pendingChanges: {'card-1': PendingLogEntryChange.updated},
        );
        final readsBefore = repository.collectionReadCount;

        repository
          ..reportDownload(const LogsDownloadProgress.adding(logEntryCount: 2))
          ..reportDownload(const LogsDownloadProgress.finished(addedCount: 0));
        await pumpEventQueue();

        expect(syncs, const [
          LogsSync.downloading(logEntryCount: 2),
          LogsSync.pending(changeCount: 1),
        ]);
        expect(repository.collectionReadCount, readsBefore);
      });

      test('a sync cannot start while a download adds entries', () async {
        repository.reportDownload(
          const LogsDownloadProgress.adding(logEntryCount: 2),
        );
        await pumpEventQueue();

        bloc.add(const LogsSyncRequested());
        await pumpEventQueue();

        expect(repository.syncRequestCount, 0);
        expect(bloc.state.sync, const LogsSync.downloading(logEntryCount: 2));
      });

      test('stops listening when closed', () async {
        await bloc.close();

        repository.download(const [downloadedEntry]);
        await pumpEventQueue();

        expect(syncs, isEmpty);
      });
    });
  });
}
