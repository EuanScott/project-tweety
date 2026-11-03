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

    test('a save that fails after its editor was discarded does not mark the '
        'reopened editor as submitted', () async {
      final repository = FakeLogsRepository.gated();
      final bloc = LogsBloc(repository);
      addTearDown(bloc.close);

      bloc
        ..add(const LogsCreateStarted())
        ..add(const LogsDraftChanged(logEntryDraft))
        ..add(const LogsCreateSubmitted());
      await pumpEventQueue();
      bloc
        ..add(const LogsDraftDiscarded())
        ..add(const LogsCreateStarted());
      await pumpEventQueue();

      repository.failCreate(StateError('write'));
      await pumpEventQueue();

      expect(
        bloc.state.editor,
        const LogsEditor.creating(save: LogsSaveStatus.failed),
      );
    });

    group('download', () {
      const downloadedEntry = LogEntry(
        id: 'card-remote',
        title: 'From another device',
        description: 'Downloaded',
      );
      late FakeLogsRepository repository;
      late LogsBloc bloc;

      setUp(() async {
        repository = FakeLogsRepository(logs: const [logEntry]);
        bloc = LogsBloc(repository)..add(const LogsStarted());
        await pumpEventQueue();
      });

      tearDown(() => bloc.close());

      test('adds the entries to the list when it ends', () async {
        repository.download(const [downloadedEntry]);
        await pumpEventQueue();

        expect(bloc.state.items, contains(downloadedEntry));
        expect(bloc.state.items, contains(logEntry));
      });

      test('that added nothing leaves the list alone', () async {
        final readsBefore = repository.collectionReadCount;

        repository
          ..reportDownload(const LogsDownloadProgress.adding(logEntryCount: 2))
          ..reportDownload(const LogsDownloadProgress.finished(addedCount: 0));
        await pumpEventQueue();

        expect(repository.collectionReadCount, readsBefore);
      });

      test('stops listening when closed', () async {
        await bloc.close();
        final readsBefore = repository.collectionReadCount;

        repository.download(const [downloadedEntry]);
        await pumpEventQueue();

        expect(repository.collectionReadCount, readsBefore);
      });
    });
  });
}
