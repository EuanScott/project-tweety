# Cards SQLite read foundation

## Decision

Cards list and detail reads use native SQLite on Android and iOS. The data path is:

`CardsRepository -> CardsDataSource -> CardsLocalDataSource -> AppDatabase -> Sqflite`

`CardsDataSource` is the test and source-selection seam. `AppDatabase` is a Sqflite-shaped lifecycle
and transaction boundary, not a database-provider abstraction.

## Initial scope

- schema version 1 contains only card identity, title, and description
- the v1 migration inserts the existing ten sample cards once
- production dependency injection binds the local datasource
- the mock datasource follows the same read contract but is not production-registered
- the cards repository exposes list and direct ID reads only
- database writes are available transactionally as infrastructure, but card CRUD is deferred

CRUD behavior, conflict handling, tombstones, dirty tracking, and synchronization policy require a
separate design and schema migration after this foundation is verified.

## Lifecycle guarantees

- concurrent callers share a pending database open
- callers can retry after an open failure
- writes commit atomically or roll back
- close drains active callbacks, and later callers reopen cleanly
- downgrade attempts fail without modifying the database

## Development reset

The discarded CRUD/sync experiment used an unshipped version 3 database. Clear app data or reinstall
before running this v1 foundation on any simulator or device that opened the experimental database.

## Supported targets

Android and iOS are supported for this iteration. Web and desktop database factories are deferred.

## Native smoke test

Run the checked-in smoke on a clean Android emulator or iOS Simulator:

```sh
flutter test integration_test/cards_sqlite_smoke_test.dart -d <device-id>
```

The test reads the ten seed cards through production DI, commits a sentinel row, renders list and
detail views, tears down the app composition and database, then reboots it and verifies the same file
contains eleven cards before exercising list and detail again.

For a process-level iOS relaunch check, keep the first verifier installed, then replace only its app
bundle with the second-phase verifier so the simulator data container is preserved:

```sh
xcrun simctl uninstall <device-id> com.example.projectTweety
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/cards_sqlite_smoke_test.dart \
  -d <device-id> \
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

The relaunched verifier fails unless the sentinel already exists and shows `SQLite relaunch verified`
after list and detail reads pass again.
