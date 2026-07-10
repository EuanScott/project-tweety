# SQLite Cards App Persistence Plan

Status: implemented on `main`.

## Summary

Replace mocked cards with SQLite-backed app persistence using raw `sqflite`, behind an app-owned
`AppDatabase` boundary. The implementation supports local CRUD and adds sync-ready metadata so a
later user-triggered bulk upload can sync only dirty local changes without a disruptive schema
migration.

This database is for Project Tweety feature-owned relational persistence. It is not a replacement
for secure storage, SharedPreferences, file storage, or other platform/device storage packages.

## Key changes

- Add `sqflite`, `path`, and `sqflite_common_ffi` for test support.
- Add `AppDatabase` under `lib/core/storage` and register `SqfliteAppDatabase` through DI.
- Keep schema creation and migrations inside the concrete database implementation.
- Add `CardsLocalDataSource`, which depends on `AppDatabase`, not raw path or open APIs.
- Keep SQL table logic in the datasource; do not add an ORM or generic repository over SQL.
- Bind SQLite-backed local persistence in production while retaining the mock implementation.
- Seed the ten sample cards only during migration 3 and only when the cards table is empty.

## Schema and migrations

- Manage schema versions in Dart rather than external SQL assets.
- Execute migrations sequentially from `oldVersion + 1` through `newVersion`.
- Version 1 creates the cards table.
- Version 2 adds sync metadata.
- Version 3 performs one-time sample seeding.
- Reject downgrades rather than silently resetting data.

## Data model and APIs

Cards contain `id`, `title`, and `description`, plus local persistence metadata:

- `sync_status`: `synced`, `created`, `updated`, or `deleted`
- `updated_at`: the latest local mutation time
- `last_synced_at`: the latest successful upload time
- `deleted_at`: the local tombstone time

`CardsRepository` exposes list, lookup, create, update, and delete. `CardsDataSource` additionally
exposes dirty reads and marking uploaded IDs as synced for the future sync service.

## Behavior

- First launch creates the database and seeds synced sample cards.
- Creating a card records it as `created`.
- Updating a synced card records it as `updated`.
- Updating an unsynced created card keeps it `created`.
- Deleting a synced or updated card creates a hidden `deleted` tombstone.
- Deleting an unsynced created card removes it physically.
- Marking uploaded IDs synced removes uploaded tombstones and records `last_synced_at` on retained
  rows.
- Duplicate IDs fail through the SQLite primary-key constraint.

## Deferred work

- Bulk upload API integration
- User-triggered sync UI
- Conflict resolution policy
- Event/outbox storage
- A domain layer, unless sync conflict behavior becomes mobile-owned policy
