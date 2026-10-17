# Logs SQLite persistence

The feature terms used here are defined in the [glossary](../../GLOSSARY.md).

## Decision

Log entry reads and local mutations use native SQLite on Android and iOS. The data path is:

`LogsRepository -> LogsDataSource -> LogsLocalDataSource -> AppDatabase -> Sqflite`

Log entries are stored in the `cards` table and synced to `users/{uid}/cards`. The stored names
predate the Logs rename and are kept ([ADR-0019](../decisions/0019-log-entries-keep-the-cards-storage-names.md)).

`LogsDataSource` is the test and source-selection seam. `AppDatabase` is a Sqflite-shaped lifecycle
and transaction boundary, not a database-provider abstraction.

The repository presents saved `LogEntry` values to the app and accepts `LogEntryDraft`
values for create and update. It applies the log entry validation and normalization
contract, generates identities for new log entries, returns the persisted result of a
successful mutation, and reports a missing update target explicitly. The
datasource is responsible for the local lifecycle of a log entry: new log entries are
locally created, edits preserve the correct pending-change state, deletion is
idempotent, and deleted log entries remain hidden while their deletion awaits
reconciliation.

## Current scope

- schema version 1 creates the `cards` table with identity, title, and description
- schema version 2 adds sync status and mutation timestamps
- schema version 3 once seeded ten sample cards; it is now a no-op, so a new database has no log entries
- schema version 4 adds the owning Account (`user_id`, indexed); every query is scoped to the
  signed-in Account, and its first operation adopts any unowned log entries as never synced
- production dependency injection binds the local datasource
- the mock datasource follows the same CRUD contract but is not production-registered
- the Logs repository exposes list, direct ID reads, create, update, and delete
- the datasource contract exposes dirty reads and acknowledgement of confirmed pushes
- local changes are tracked as created, updated, or deleted until a sync pushes them
- tombstones are hidden from normal reads and removed after a successful upload
- a row is a tombstone when `sync_status` is `deleted` or `deleted_at` is set. Every query and the
  row mapping use this one rule, so a damaged status cannot hide a delete. A stored status the app
  does not know, on a row with no `deleted_at`, reads as `updated` and is pushed again
- a download adds the Account's log entries that the device does not hold, and changes nothing else

## Logs UI and navigation

`LogsBloc` owns the loaded collection and editor state. The selected log entry is
route-driven: `/logs` shows the collection, `/logs/new` starts creation, and
`/logs/:entryId` identifies the log entry to show or edit. On compact layouts the
editor occupies the Logs body; on wide layouts it occupies the secondary pane.
Successful creation replaces the create route with the new log entry, successful
editing keeps the selected log entry, and successful deletion returns to `/logs`.

`LogsState` follows [ADR-0004](../decisions/0004-value-type-conventions.md): each concern
is a small sealed union that carries only the data valid for its state, so states such as
"deleting with no log entry" or "an edit failure with no editor" cannot be built.

- `load`: `initial`, `loading`, `loaded` or `failed(LogsError)`. The error is a kind that
  the widget layer translates.
- `editor`: `closed`, `creating`, `editing(logEntryId, initialDraft, …)` or
  `missing(logEntryId, …)`. An open form also holds its draft, whether a save was tried,
  the invalid fields and a save status (`idle`, `saving`, `failed`). A new log entry opens
  empty, so the empty draft is its opening snapshot. "An editor is open" (`isOpen`) is the
  test for discarding a draft, and `isDraftDirty` compares the draft with the snapshot.
- `deletion`: `idle`, `deleting(id)` or `failed(id)`.
- `outcome`: `none`, `created(id)` or `deleted(id)`. It is the latest create or delete that finished.
  The page navigates when it changes, so a later outcome replaces an earlier one. A new create clears it.
- `sync`: the `LogsSync` union described under Download.

`items` and `unsyncedChanges` stay plain fields because no value of
theirs conflicts with another field. Draft changes and saves are ignored while no editor is
open. A save that ends after its editor was discarded still updates the list, but changes
the editor only if the same editor is still open.

The UI retains a draft when validation or a recoverable mutation failure occurs.
Before navigation would discard an unsaved draft, it asks for confirmation.
Switching top-level tabs preserves the nested Logs branch and its draft.

The reusable navigation package supplies `TabBranchResetGuard` for active
branch resets. It waits for the feature's decision before resetting and ignores
additional reset requests while that decision is pending. The Logs page uses that guard
alongside its back, cancel, add, and selection discard decisions.

Sync pushes every pending change to Firestore at `users/{uid}/cards/{cardId}` when the person presses
Sync ([ADR-0007](../decisions/0007-cards-local-source-of-truth.md)). Each log entry is one write, in
parallel, with a 10-second timeout. Only writes the server confirmed are acknowledged, and a log entry
edited after its push snapshot stays pending. Firestore offline persistence is off, so SQLite holds
the only pending queue. The owner-only rules live in `firestore.rules` and are deployed by hand. A
conflict policy remains deferred.

### Download

A download adds to the device every log entry the Account's copy holds and the device does not
([ADR-0008](../decisions/0008-cards-are-owned-by-the-signed-in-account.md), amendments of 2026-10-09
and 2026-10-17). The data path is:

`LogsDownloadTrigger -> LogsRepository.downloadLogs -> LogsRemoteDataSource.fetchLogs -> LogsDataSource.addDownloadedLogs`

1. **Trigger.** `MyApp` starts `LogsDownloadTrigger` after its first frame. The trigger starts a
   download at once when an Account is already signed in, and again each time the Session changes from
   signed out to signed in. A Session that changes but stays signed in starts nothing.
2. **Read.** One read of `users/{uid}/cards` from the server, with a 30-second timeout. Each document
   becomes a `synced` log entry of that uid. A document with no `createdAt` is dated from its
   `updatedAt`. A document with a missing or wrong-typed `title`, `description` or `updatedAt` is skipped
   and reported, and the rest still download.
3. **Merge.** One write transaction adds each document whose id no row holds, oldest `updatedAt` first,
   as `synced` with `last_synced_at` set to now. The check happens at write time.

| Row on the device with the same id | Result |
|---|---|
| none | inserted as `synced` |
| `synced`, older or newer than the document | kept; no `updatedAt` comparison |
| `created`, `updated` or a `deleted` tombstone | kept, still pending |
| another Account's row | kept; ids are the table's primary key |
| a `synced` row with no document | kept; a download never deletes |

4. **Exclusion.** The repository runs syncs and downloads one at a time: each waits for the other. A
   download asked for while one runs joins it, and one more runs after it, so a sign-in during a
   download is not lost. Rows read for one Account are never written for another: the write throws
   and adds nothing when the Session signed out or changed Account during the read. The repository
   reports this as `LogsSessionChangedException`.
5. **What the person sees.** Nothing while the read runs, unless the person presses Sync. A press
   shows "Syncing…" at once (`waiting`) and disables the button, while the sync waits for the
   download. The sync then shows its own progress. When the write has confirmed the Account
   and found log entries to add, the sync row shows `downloading`, and the Sync button is disabled.
   When the write ends, the list updates once and the row shows `downloaded`. A download that adds nothing shows nothing.
6. **Failure.** Nothing visible. An unreachable server (`unavailable`, or the timeout) is not reported,
   as with a push. A Session that signed out or changed Account during the download is not reported
   either. Any other failure, for example `permission-denied`, goes to the error reporter. The
   next start or sign-in tries again.

## Lifecycle guarantees

- concurrent callers share a pending database open
- callers can retry after an open failure
- writes commit atomically or roll back
- close drains active callbacks, and later callers reopen cleanly
- downgrade attempts fail without modifying the database
- close and reopen preserve log entries and their pending lifecycle state
- the native relaunch smoke procedure verifies the same persistence boundary
  across an actual Android or iOS process restart

## Upgrade behavior

Version-1 foundation databases migrate in place. Existing rows are preserved, receive `synced`
status, and are not reseeded. Version-2 databases preserve existing metadata. Version-3 databases gain a null `user_id`, and their
rows stay unowned until the first signed-in Account adopts them
([ADR-0008](../decisions/0008-cards-are-owned-by-the-signed-in-account.md)). No version seeds log entries.
Downgrades remain rejected.

## Supported targets

Android and iOS are supported for this iteration. Web and desktop database factories are deferred.

## Native smoke test

Run the checked-in smoke on a clean Android emulator or iOS Simulator:

```sh
flutter test integration_test/logs_sqlite_smoke.flow_test.dart -d <device-id>
```

The first phase uses production DI to create, edit, acknowledge, edit again, and delete a stable
smoke log entry. It asserts `created`, `synced`, `updated`, and `deleted` states through the datasource,
checks the list and detail UI before deletion, then closes and rebuilds the composition. The deleted
record remains a hidden tombstone after that internal reopen, then is cleaned up by the standard
one-phase command.

For an actual process-relaunch check, run the first phase with the app left installed, force-stop it,
then replace only its executable with the second-phase verifier. Do not uninstall between those steps:
uninstalling removes the SQLite container that this check is intended to preserve. The second phase
requires the hidden tombstone to still exist, acknowledges it, and removes the test data.

### Android

```sh
adb uninstall dev.euanscott.projecttweety
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/logs_sqlite_smoke.flow_test.dart \
  -d <device-id> \
  --dart-define=PRESERVE_SQLITE_SMOKE_TOMBSTONE=true \
  --keep-app-running
adb -s <device-id> shell am force-stop dev.euanscott.projecttweety
flutter build apk \
  --debug \
  --target=integration_test/logs_sqlite_smoke.flow_test.dart \
  --dart-define=EXPECT_EXISTING_SQLITE_SMOKE_CARD=true
adb -s <device-id> install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s <device-id> shell monkey -p dev.euanscott.projecttweety 1
```

### iOS

```sh
xcrun simctl uninstall <device-id> dev.euanscott.projecttweety
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/logs_sqlite_smoke.flow_test.dart \
  -d <device-id> \
  --dart-define=PRESERVE_SQLITE_SMOKE_TOMBSTONE=true \
  --keep-app-running
xcrun simctl terminate <device-id> dev.euanscott.projecttweety
flutter build ios \
  --simulator \
  --debug \
  --no-codesign \
  --target=integration_test/logs_sqlite_smoke.flow_test.dart \
  --dart-define=EXPECT_EXISTING_SQLITE_SMOKE_CARD=true
xcrun simctl install <device-id> build/ios/iphonesimulator/Runner.app
xcrun simctl launch <device-id> dev.euanscott.projecttweety
```

The relaunched verifier fails unless the tombstone created by the first process is present and shows
`SQLite native relaunch verified` when it passes.
