# Complete Cards SQLite Integration

Status: completed. The verified implementation is described by the
[Cards SQLite architecture record](../architecture/cards_sqlite_foundation.md)
and its terms are defined in the [Cards context](../CONTEXT.md).

## Summary

This completed plan established local CRUD end-to-end: user-visible create,
inline edit, delete, validation, guarded navigation, and persistence across
relaunch. Remote synchronization remains deferred.

## Implemented interface changes

- `CardDraft(title, description)` is the write value.
- Repository mutations are:
  - `Future<Card> createCard(CardDraft draft)`
  - `Future<Card> updateCard({required String cardId, required CardDraft draft})`
  - `Future<void> deleteCard(String cardId)`
- UUID v4 IDs are generated behind an injected `CardIdGenerator`.
- Created/updated DTOs return from `CardsDataSource`; `null` represents an update target that is missing
  or deleted.
- Typed invalid-draft and card-not-found failures are available.
- `/cards/new` and a generic asynchronous navigation-package guard protect dirty branch resets.
- Narrow adaptive design-system primitives cover `AppTextField`, confirmation dialog, and
  destructive button.

## Tasks

1. [x] **Harden the persistence contract**
   - Introduce `CardDraft`, UUID generation, trimming, and repository validation.
   - Require both title and description; reject blank trimmed values.
   - Make create/update return the persisted card.
   - Preserve existing sync-status and tombstone transitions.
   - Cover repository, local datasource, mock datasource, and DI through TDD.

2. [x] **Consolidate Cards state**
   - Make `CardsBloc` own collection loading, editor state, validation, create/update/delete
     operations, and mutation failures.
   - Derive selected-card details from the loaded collection.
   - Remove `CardDetailsBloc` and its generated wiring.
   - Keep drafts and current data intact when writes fail or while retrying.

3. [x] **Add guarded navigation**
   - Add a generic `TabBranchResetGuard<TTab>` to `packages/navigation`.
   - Await its callback before an active nested tab resets to its root.
   - Prevent duplicate resets while confirmation is pending.
   - Use it alongside `PopScope` and explicit selection/cancel guards for dirty Cards drafts.

4. [x] **Implement card creation**
   - Add `/cards/new`, navigation helpers, toolbar add action, and empty-list CTA.
   - On compact layouts, show the editor as the Cards body; on wide layouts, show it in the
     secondary pane beside the list.
   - Validate both fields, disable actions while saving, and retain the form after failure.
   - After success, replace the create route with `/cards/{newId}`.

5. [x] **Implement inline editing**
   - Add Edit, Save, and Cancel actions to card details.
   - Update the list and details atomically from the repository result.
   - Keep the card selected after saving.
   - Confirm before discarding a dirty edit through cancel, back, card selection, or active-tab
     reset.

6. [x] **Implement deletion and recovery UX**
   - Require destructive confirmation before deletion.
   - On success, remove the card from visible state and return to `/cards`.
   - Keep the card visible and show retryable localized feedback on failure.
   - Verify seeded/synced cards become hidden tombstones and unsynced-created cards are physically
     removed.

7. [x] **Complete integration verification and documentation**
   - Drive create, edit, delete, close, reopen, and native process-relaunch flows through production
     DI.
   - Verify dirty status transitions directly through the datasource seam.
   - Add all copy to English, Spanish, and Hebrew ARB files and regenerate localization.
   - Update SQLite architecture/plan documents and add a concise `CONTEXT.md` defining Card,
     CardDraft, dirty card, and tombstone.
   - Land each task as a small green commit directly on `main`.

## Test Plan

- Repository tests: deterministic UUID, trimming, validation, returned values, and missing-update
  failure.
- BLoC tests: loading, draft changes, validation, CRUD success, concurrent-action guards, and
  recoverable failures.
- Widget tests: compact/wide create and edit, delete confirmation, dirty-discard prompts, empty
  state, navigation outcomes, Material/Cupertino behavior, and RTL layout.
- SQLite tests: created/updated/deleted transitions, tombstone visibility, physical deletion of
  unsynced cards, and persistence after reopen.
- Native smoke tests on Android and iOS, followed by full `flutter test` and `flutter analyze`.

## Assumptions

- Scope is local SQLite CRUD only; no API, sync coordinator, retries, or conflict resolution.
- Schema version 3, database name, sample seed, and sync metadata remain unchanged.
- New cards append to the existing ordering.
- Switching to another top-level tab preserves the branch and draft; only actions that actually
  discard it require confirmation.
- No arbitrary field-length limits are introduced.
