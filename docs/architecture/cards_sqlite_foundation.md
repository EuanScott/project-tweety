# Cards SQLite persistence

The feature terms used here are defined in the [Cards context](../CONTEXT.md).

## Decision

Cards reads and local mutations use native SQLite on Android and iOS. The data path is:

`CardsRepository -> CardsDataSource -> CardsLocalDataSource -> AppDatabase -> Sqflite`

`CardsDataSource` is the test and source-selection seam. `AppDatabase` is a Sqflite-shaped lifecycle
and transaction boundary, not a database-provider abstraction.

The repository presents saved `Card` values to the app and accepts `CardDraft`
values for create and update. It applies the Cards validation and normalization
contract, generates identities for new Cards, returns the persisted result of a
successful mutation, and reports a missing update target explicitly. The
datasource is responsible for the local lifecycle of a Card: new Cards are
locally created, edits preserve the correct pending-change state, deletion is
idempotent, and deleted Cards remain hidden while their deletion awaits
reconciliation.

## Current scope

- schema version 1 creates card identity, title, and description
- schema version 2 adds sync status and mutation timestamps
- schema version 3 seeds the existing ten sample cards when the table is empty
- production dependency injection binds the local datasource
- the mock datasource follows the same CRUD contract but is not production-registered
- the cards repository exposes list, direct ID reads, create, update, and delete
- the datasource contract exposes dirty reads and successful-upload acknowledgement for future sync
- local changes are tracked as created, updated, or deleted for a later bulk upload
- tombstones are hidden from normal reads and removed after a successful upload

## Cards UI and navigation

`CardsBloc` owns the loaded collection and editor state. The selected Card is
route-driven: `/cards` shows the collection, `/cards/new` starts creation, and
`/cards/:cardId` identifies the Card to show or edit. On compact layouts the
editor occupies the Cards body; on wide layouts it occupies the secondary pane.
Successful creation replaces the create route with the new Card, successful
editing keeps the selected Card, and successful deletion returns to `/cards`.

The UI retains a draft when validation or a recoverable mutation failure occurs.
Before navigation would discard an unsaved draft, it asks for confirmation.
Switching top-level tabs preserves the nested Cards branch and its draft.

The reusable navigation package supplies `TabBranchResetGuard` for active
branch resets. It waits for the feature's decision before resetting and ignores
additional reset requests while that decision is pending. Cards uses that guard
alongside its back, cancel, add, and selection discard decisions.

The bulk upload API, sync UI, and conflict policy remain deferred.

## Lifecycle guarantees

- concurrent callers share a pending database open
- callers can retry after an open failure
- writes commit atomically or roll back
- close drains active callbacks, and later callers reopen cleanly
- downgrade attempts fail without modifying the database
- close and reopen preserve Cards and their pending lifecycle state
- the native relaunch smoke procedure verifies the same persistence boundary
  across an actual Android or iOS process restart

## Upgrade behavior

Version-1 foundation databases migrate in place. Existing rows are preserved, receive `synced`
status, and are not reseeded. Version-2 databases preserve existing metadata, while an empty version-2
database receives the sample cards once during the version-3 migration. Downgrades remain rejected.

## Supported targets

Android and iOS are supported for this iteration. Web and desktop database factories are deferred.

## Native smoke test

Run the checked-in smoke on a clean Android emulator or iOS Simulator:

```sh
flutter test integration_test/cards_sqlite_smoke_test.dart -d <device-id>
```

The first phase uses production DI to create, edit, acknowledge, edit again, and delete a stable
smoke card. It asserts `created`, `synced`, `updated`, and `deleted` states through the datasource,
checks the list and detail UI before deletion, then closes and rebuilds the composition. The deleted
record remains a hidden tombstone after that internal reopen, then is cleaned up by the standard
one-phase command.

For an actual process-relaunch check, run the first phase with the app left installed, force-stop it,
then replace only its executable with the second-phase verifier. Do not uninstall between those steps:
uninstalling removes the SQLite container that this check is intended to preserve. The second phase
requires the hidden tombstone to still exist, acknowledges it, and removes the test data.

### Android

```sh
adb uninstall com.example.project_tweety
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/cards_sqlite_smoke_test.dart \
  -d <device-id> \
  --dart-define=PRESERVE_SQLITE_SMOKE_TOMBSTONE=true \
  --keep-app-running
adb -s <device-id> shell am force-stop com.example.project_tweety
flutter build apk \
  --debug \
  --target=integration_test/cards_sqlite_smoke_test.dart \
  --dart-define=EXPECT_EXISTING_SQLITE_SMOKE_CARD=true
adb -s <device-id> install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s <device-id> shell monkey -p com.example.project_tweety 1
```

### iOS

```sh
xcrun simctl uninstall <device-id> com.example.projectTweety
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/cards_sqlite_smoke_test.dart \
  -d <device-id> \
  --dart-define=PRESERVE_SQLITE_SMOKE_TOMBSTONE=true \
  --keep-app-running
xcrun simctl terminate <device-id> com.example.projectTweety
flutter build ios \
  --simulator \
  --debug \
  --no-codesign \
  --target=integration_test/cards_sqlite_smoke_test.dart \
  --dart-define=EXPECT_EXISTING_SQLITE_SMOKE_CARD=true
xcrun simctl install <device-id> build/ios/iphonesimulator/Runner.app
xcrun simctl launch <device-id> com.example.projectTweety
```

The relaunched verifier fails unless the tombstone created by the first process is present and shows
`SQLite native relaunch verified` when it passes.
