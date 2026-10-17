import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';
import 'package:project_tweety/presentation/pages/logs/bloc/logs.bloc.dart';

void main() {
  const opening = LogEntryDraft(title: 'Title', description: 'Body');
  const changed = LogEntryDraft(title: 'Changed', description: 'Body');

  group('LogsEditor', () {
    test('only the closed editor is not open', () {
      expect(const LogsEditor.closed().isOpen, isFalse);
      expect(const LogsEditor.creating().isOpen, isTrue);
      expect(
        const LogsEditor.editing(
          logEntryId: 'card-1',
          initialDraft: opening,
          draft: opening,
        ).isOpen,
        isTrue,
      );
      expect(
        const LogsEditor.missing(
          logEntryId: 'card-1',
          initialDraft: opening,
          draft: opening,
        ).isOpen,
        isTrue,
      );
    });

    test('a new entry is dirty once its draft is not empty', () {
      expect(const LogsEditor.creating().isDirty, isFalse);
      expect(const LogsEditor.creating(draft: changed).isDirty, isTrue);
      expect(
        const LogsEditor.creating(
          draft: LogEntryDraft(title: ' ', description: ''),
        ).isDirty,
        isTrue,
      );
    });

    test('an edit is dirty once its draft differs from the opening one', () {
      expect(
        const LogsEditor.editing(
          logEntryId: 'card-1',
          initialDraft: opening,
          draft: opening,
        ).isDirty,
        isFalse,
      );
      expect(
        const LogsEditor.editing(
          logEntryId: 'card-1',
          initialDraft: opening,
          draft: changed,
        ).isDirty,
        isTrue,
      );
      expect(
        const LogsEditor.missing(
          logEntryId: 'card-1',
          initialDraft: opening,
          draft: changed,
        ).isDirty,
        isTrue,
      );
      expect(const LogsEditor.closed().isDirty, isFalse);
    });

    test('reports saving and a failed save from either open form', () {
      expect(
        const LogsEditor.creating(save: LogsSaveStatus.saving).isSaving,
        isTrue,
      );
      expect(
        const LogsEditor.editing(
          logEntryId: 'card-1',
          initialDraft: opening,
          draft: changed,
          save: LogsSaveStatus.failed,
        ).hasSaveFailed,
        isTrue,
      );
      expect(const LogsEditor.creating().isSaving, isFalse);
      expect(const LogsEditor.creating().hasSaveFailed, isFalse);
      expect(const LogsEditor.closed().isSaving, isFalse);
    });

    test('shows invalid fields only for a form that can still be saved', () {
      const invalid = {LogEntryDraftField.title};
      expect(
        const LogsEditor.creating(invalidFields: invalid).invalidFields,
        invalid,
      );
      expect(const LogsEditor.closed().invalidFields, isEmpty);
      expect(
        const LogsEditor.missing(
          logEntryId: 'card-1',
          initialDraft: opening,
          draft: changed,
        ).invalidFields,
        isEmpty,
      );
    });
  });

  group('LogsState', () {
    test('is loading until the first load ends', () {
      expect(const LogsState().isLoading, isTrue);
      expect(const LogsState(load: LogsLoad.loading()).isLoading, isTrue);
      expect(const LogsState(load: LogsLoad.loaded()).isLoading, isFalse);
      expect(
        const LogsState(load: LogsLoad.failed(LogsError.loadFailed)).isLoading,
        isFalse,
      );
    });

    test('the dirty flag follows the editor', () {
      expect(const LogsState().isDraftDirty, isFalse);
      expect(
        const LogsState(editor: LogsEditor.creating(draft: changed))
            .isDraftDirty,
        isTrue,
      );
    });

    test('an edit and a missing edit both show the editor for their entry', () {
      const editing = LogsState(
        editor: LogsEditor.editing(
          logEntryId: 'card-1',
          initialDraft: opening,
          draft: opening,
        ),
      );
      const missing = LogsState(
        editor: LogsEditor.missing(
          logEntryId: 'card-1',
          initialDraft: opening,
          draft: opening,
        ),
      );

      expect(editing.isEditingLogEntry('card-1'), isTrue);
      expect(editing.isEditingLogEntry('card-2'), isFalse);
      expect(editing.hasMissingEditFor('card-1'), isFalse);
      expect(missing.isEditingLogEntry('card-1'), isTrue);
      expect(missing.hasMissingEditFor('card-1'), isTrue);
      expect(missing.hasMissingEditFor('card-2'), isFalse);
      expect(
        const LogsState(editor: LogsEditor.creating())
            .isEditingLogEntry('card-1'),
        isFalse,
      );
    });

    test('names the entry a delete is about in each delete state', () {
      const deleting = LogsState(deletion: LogsDeletion.deleting('card-1'));
      const failed = LogsState(deletion: LogsDeletion.failed('card-1'));

      expect(deleting.isDeletingLogEntry('card-1'), isTrue);
      expect(deleting.isDeletingLogEntry('card-2'), isFalse);
      expect(deleting.hasDeleteErrorFor('card-1'), isFalse);
      expect(failed.hasDeleteErrorFor('card-1'), isTrue);
      expect(failed.hasDeleteErrorFor('card-2'), isFalse);
      expect(failed.isDeletingLogEntry('card-1'), isFalse);
    });
  });
}
