# Tickets: Cards SQLite end-to-end integration

These tickets complete local Cards create, edit, delete, guarded navigation, and native SQLite persistence from [the source plan](docs/plans/cards_sqlite_end_to_end_integration.md).

Work the **frontier**: any ticket whose blockers are all done. After the enabling prefactor, creation and deletion can proceed independently; final verification rejoins deletion with the create/edit/navigation path.

## Make card selection route-driven and consolidate read state

**What to build:** Preserve the existing Cards list/detail experience while making `/cards/:cardId` authoritative across compact and wide layouts and consolidating read state into `CardsBloc`.
**Blocked by:** None — can start immediately.

- [x] Selecting from `/cards` pushes the first detail route.
- [x] Subsequent wide-layout selections replace the current detail location.
- [x] List, detail, missing, loading, and failure states come from `CardsBloc`.
- [x] `CardDetailsBloc` and its generated wiring are removed.
- [x] Existing responsive layout, deep-link, scrolling, and tab-reselect tests remain green.

## Create and persist validated cards

**What to build:** Let users create validated cards from compact or wide layouts and persist them through the production SQLite composition.

**Blocked by:** Make card selection route-driven and consolidate read state.

- [x] `/cards/new` is declared before the dynamic `:cardId` route and is reachable from the toolbar and empty-list CTA.
- [x] Both fields are required after trimming, with errors shown on first submit and updated live afterward.
- [x] The design system exposes an adaptive `AppTextField`; Cards pages do not branch directly between Material and Cupertino text controls.
- [x] The repository contract accepts a `CardDraft`, defines `CardDraftField { title, description }`, and reports invalid fields through `InvalidCardDraftException`.
- [x] Card IDs are generated through an injected, deterministic-testable UUID v4 generator.
- [x] Datasource creation returns the persisted `CardDto`, and the repository maps it to the returned app-facing `Card` while preserving existing sync metadata behavior.
- [x] Duplicate generated IDs continue to fail through the SQLite primary-key constraint and are covered by tests.
- [x] New cards append in insertion order, and no field-length limits are introduced.
- [x] Schema version 3, the database name, the sample seed, and existing sync columns remain unchanged.
- [x] While creation is pending, affected controls are disabled and duplicate mutation requests are ignored.
- [x] Refreshing the collection preserves the active raw draft and its validation state.
- [x] Successful creation replaces the editor route with `/cards/:newId`.
- [x] Failed creation preserves the draft and shows persistent localized inline feedback.
- [x] New copy is added to English, Spanish, and Hebrew ARB sources and generated localization is refreshed.
- [x] Material, Cupertino, compact, wide, RTL, repository, datasource, BLoC, localization, and generated-DI tests cover the slice.

## Edit persisted cards without losing failed drafts

**What to build:** Let users edit an existing card inline while preserving their draft through validation, transient failures, and missing-target failures.

**Blocked by:** Create and persist validated cards.

- [x] Edit seeds a draft from the selected persisted card.
- [x] Save applies the same trimming and validation contract as creation.
- [x] The datasource returns the persisted `CardDto` or `null` for a missing or tombstoned target, which the repository maps to `CardNotFoundException` carrying the missing ID.
- [x] Successful update exits edit mode, retains the same selected card, and refreshes list and read-only details atomically from the returned persisted card.
- [x] While update is pending, affected controls are disabled and duplicate mutation requests are ignored.
- [x] Refreshing the collection preserves the active raw edit draft and its validation state.
- [x] Cancel returns to read-only details for the same card.
- [x] Recoverable failures preserve the draft and show persistent inline feedback.
- [x] A missing update target preserves the draft, displays a non-retryable not-found state, and offers Return to cards.
- [x] Created-versus-updated sync transitions remain correct and covered through the datasource seam.
- [x] New copy is present in all three ARB sources and generated localization is refreshed.

## Delete cards with confirmation and recovery

**What to build:** Let users delete cards from read-only details with adaptive confirmation and recover safely from failed deletion.

**Blocked by:** Make card selection route-driven and consolidate read state.

- [x] Delete is available only from read-only details.
- [x] The design system exposes `AppButton.destructive` and an adaptive confirmation-dialog API used by the Cards UI.
- [x] An adaptive destructive confirmation is required before deletion, and dismissing it keeps the card unchanged.
- [x] Confirmed deletion tombstones synced or updated cards and physically removes unsynced-created cards.
- [x] Deleting an already-missing card is an idempotent success.
- [x] While deletion is pending, affected controls are disabled and duplicate mutation requests are ignored.
- [x] Success removes the visible card and navigates to `/cards`.
- [x] Failure leaves the card visible and shows persistent localized feedback with retry.
- [x] New copy is present in all three ARB sources and generated localization is refreshed.
- [x] Material, Cupertino, compact, wide, RTL, repository, datasource, BLoC, and widget behavior is tested.

## Protect unsaved drafts across navigation

**What to build:** Prevent unsaved create/edit input from being silently discarded by navigation while preserving ordinary tab-branch behavior.

**Blocked by:** Create and persist validated cards; Edit persisted cards without losing failed drafts.

- [x] Unsaved state compares raw editor input with its initial snapshot.
- [x] Back, Cancel, Add, card selection, and active-tab branch reset prompt before discarding unsaved input.
- [x] Back from edit returns to read-only details; Back from create returns to `/cards`.
- [x] Confirmation dismissal keeps the editor and draft intact.
- [x] Switching to another top-level tab preserves the branch and draft without prompting.
- [x] The navigation package exposes public `TabBranchResetGuard<TTab>` with a `Future<bool> Function()` reset-decision callback.
- [x] Nested active-branch reset awaits the guard and suppresses duplicate requests while pending.
- [x] Existing root-tab reselect and scroll-to-top behavior remains unchanged.
- [x] Discard-confirmation copy is present in all three ARB sources and generated localization is refreshed.
- [x] Material, Cupertino, compact, wide, and RTL navigation flows are covered by widget tests.

## Prove end-to-end persistence and native relaunch

**What to build:** Verify the complete workflow through production composition, database reopen, and native process relaunch.

**Blocked by:** Protect unsaved drafts across navigation; Delete cards with confirmation and recovery.

- [x] Integration coverage exercises create, edit, delete, close, reopen, list, and detail flows.
- [x] Tests inspect created, updated, deleted, synced, and tombstone transitions through the datasource seam.
- [x] Android and iOS native relaunch smoke flows verify persistence across process relaunch.
- [x] English, Spanish, and Hebrew localization output and generated DI configuration are current.
- [x] Full `flutter test` and `flutter analyze` pass.

## Publish the Cards model and completed architecture

**What to build:** Record the terminology and architectural state established by the verified implementation so future work can distinguish editor state from synchronization state.

**Blocked by:** Prove end-to-end persistence and native relaunch.

- [x] The glossary distinguishes Card, CardDraft, unsaved draft, dirty card, and tombstone without including implementation details.
- [x] The SQLite architecture records the completed repository, datasource, UI, navigation-guard, and lifecycle behavior.
- [x] The source plan status and completed tasks reflect the verified implementation.
- [x] Documentation links and terminology agree across the source plan, architecture record, and glossary.
