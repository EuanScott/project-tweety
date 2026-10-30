# App-owned Storage

This folder contains the persistence mechanisms owned by the app. Storage is split by data shape
and lifecycle rather than hidden behind a provider-neutral API.

## SQLite database

`AppDatabase` owns the native SQLite connection used for relational app data. It is intentionally
Sqflite-shaped: the boundary centralizes connection lifecycle and transaction behavior, but does
not promise that another database engine can be substituted without changes.

The initial database supports Android and iOS. It opens `project_tweety.db` in the platform database
directory on first use.

### Access contract

- `read` exposes query-only operations.
- `write` runs the callback in one transaction and rolls it back if the callback fails.
- concurrent first operations share one pending open.
- an open failure is propagated and a later operation retries with a new open.
- `close` drains operations that already started; later operations wait for close and then reopen.
- Injectable calls `close` when the registered database is disposed.

Database callbacks must use the executor passed to them. They must not recursively call `read`,
`write`, or `close` on `AppDatabase`.

### Log entries schema

Log entries are stored in the `cards` table. The stored names predate the Logs
rename and are kept ([ADR-0019](../../../docs/decisions/0019-log-entries-keep-the-cards-storage-names.md)).

Version 1 creates `cards` with the following columns:

- `id TEXT PRIMARY KEY`
- `title TEXT NOT NULL`
- `description TEXT NOT NULL`

Version 2 adds sync metadata:

- `sync_status TEXT NOT NULL DEFAULT 'synced'`
- `updated_at TEXT NOT NULL DEFAULT ''`
- `last_synced_at TEXT`
- `deleted_at TEXT`

Version 3 once inserted ten sample cards into an empty table. It is now a no-op
([ADR-0008](../../../docs/decisions/0008-cards-are-owned-by-the-signed-in-account.md)), so a new
database starts with no log entries.

Version 4 adds the owning Account:

- `user_id TEXT`, nullable for good, with the index `cards_user_id`

Rows that exist before version 4 keep a null `user_id` until the first signed-in Account adopts
them. Adoption belongs to the Logs datasource, not to the migration.

Version 5 adds the creation time:

- `created_at TEXT NOT NULL DEFAULT ''`, copied from `updated_at` for existing rows

Older files migrate in place without replacing existing rows. Downgrades remain
explicitly rejected; the app never destroys an existing database to recover from a version mismatch.

### Add a log entry column

Migrations are append-only. Do not edit a migration that already exists.

1. Increase `AppDatabaseMigrations.latestVersion` by one.
2. Add a `case` for the new version that calls a new `_add...V<n>` method.
3. Map the column in `toDatabaseRow` and `fromDatabaseRow` of the log entry DTO.
   Add the field to `toValue()`, `LogEntry` and `LogEntryDraft`. Also add it to `createLogEntry`
   and `updateLogEntry` in `LogsRepositoryImpl`. If you do not, the app cannot read or save it.
4. If the field syncs, add it to the Firestore datasource and to `isValidCard` in
   [`firestore.rules`](../../../firestore.rules). The rules allow only the listed keys, so a push
   with an unlisted key fails. The rules deploy by hand, separately from the app.
5. Extend the migration tests in `test/core/storage/`.

## Preferences storage

`AppPreferencesStorage` persists small, non-sensitive settings through one shared-preferences entry.
It currently stores:

- theme mode, defaulting to `ThemeMode.system`
- language code, defaulting to `en`

Startup initialization ensures defaults exist. Invalid or missing JSON is replaced with the default
preferences object.

Use constructor injection with the concrete preferences service:

```dart
class ExampleService {
  ExampleService(this._appPreferencesStorage);

  final AppPreferencesStorage _appPreferencesStorage;
}
```

## Non-goals

Neither storage mechanism is intended for auth tokens or other secrets. Preferences storage is also
not suitable for relational, offline-first, syncable, or large data.
