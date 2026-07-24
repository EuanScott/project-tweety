# Cards SQLite Implementation Prompts

These prompts implement the tickets in `tickets.md` and the source plan in
`docs/plans/cards_sqlite_end_to_end_integration.md`.

## Execution order

With one shared workspace, run these serially to avoid overlapping edits to
`CardsBloc`, Cards pages, routes, localization, and generated DI. If isolated
worktrees are available, prompts 2 and 3 may run in parallel after prompt 1.

Prepend this to every prompt:

Work only on this ticket. Start by reading root and nearest `AGENTS.md` files
plus `docs/plans/cards_sqlite_end_to_end_integration.md`. Preserve unrelated
existing worktree changes, especially ADR-related changes. Use TDD for
behavior changes; add focused tests before implementation, then run the
relevant tests, generation where needed, and `flutter analyze`. Do not use
destructive Git commands or hand-edit generated files. Report changed files,
red/green evidence, verification, and remaining risks.

## 1. Route-driven selection and unified read state

 Implement the `Make card selection route-driven and consolidate read state`
 ticket from `tickets.md`.

 Make `/cards/:cardId` authoritative on compact and wide layouts. Selecting
 from `/cards` must push the first details route; selecting another card from
 a wide-layout detail route must replace the current detail location. Remove
 widget-local selected-card state.

 Expand `CardsBloc` so list, selected-detail, loading, missing, and failure
 state derive from its loaded collection. Preserve list refresh behavior and
 deep links. Remove `CardDetailsBloc`, its tests, and injectable generated
 wiring; regenerate derived code instead of editing it.

 Preserve existing responsive split-pane, list/detail scrolling, tab reselect,
 and route tests. Add regression coverage for compact and wide route
 selection/replacement, deep links, missing/loading/failure details, and no
 duplicate read BLoC.

 Finish with targeted tests, generated DI/build files as required, then
 `flutter analyze`.

## 2. Create validated, persisted cards

 Implement the `Create and persist validated cards` ticket from `tickets.md`,
 on top of the completed route-driven Cards state.

 First harden the write contract. Add immutable `CardDraft`,
 `CardDraftField { title, description }`, `InvalidCardDraftException` carrying
 invalid fields, and an injected deterministic-testable UUID-v4
 `CardIdGenerator`. Add the required UUID dependency. Change repository
 mutations to:

 ```dart
 Future<Card> createCard(CardDraft draft);
 Future<Card> updateCard({required String cardId, required CardDraft draft});
 ```

 Validate trimmed title and description in the repository; preserve raw input
 in UI state. Datasource create must return the persisted DTO; the repository
 returns its app-facing `Card`. Do not catch duplicate-ID SQLite primary-key
 failures. Preserve v3 schema, database name, seed, insertion order, and sync
 metadata transitions.

 Add `/cards/new` before `:cardId`, navigation helpers, toolbar add action,
 and empty-list CTA. Build the editor through an exported adaptive
 `AppTextField` in `design_system`; Cards code must not branch directly on
 Material versus Cupertino text fields. Render the editor as the compact body
 and wide secondary pane. Keep raw draft and validation errors through refresh;
 show errors after first submission and update them live afterward. Disable
 affected controls and ignore duplicate saves while pending. On success,
 replace `/cards/new` with `/cards/:newId`; on failure retain the draft and
 show persistent inline localized feedback.

 Add English, Spanish, and Hebrew ARB copy and regenerate localization. Cover
 ID generation, validation/trimming, returned persistence values, duplicate
 IDs, datasource sync behavior, BLoC mutation guards/draft preservation,
 compact/wide/Material/Cupertino/RTL widgets, localization, and DI.

## 3. Delete with confirmation and recovery

 Implement the `Delete cards with confirmation and recovery` ticket from
 `tickets.md`, preserving the completed create flow.

 Add `AppButton.destructive` and a minimal exported adaptive
 confirmation-dialog API to `design_system`; it must render Material and
 Cupertino confirmations while keeping labels/content owned by the app. Add
 focused package tests for both platforms.

 Expose Delete only in read-only Card details. Require destructive
 confirmation; dismissing does nothing. On confirmation, disable affected
 controls and ignore duplicate delete requests. Use the existing datasource
 semantics: created cards are physically removed; synced/updated cards become
 tombstones; deleting a missing ID succeeds idempotently.

 On success remove the card from visible `CardsBloc` state and navigate to
 `/cards`. On failure retain it, show persistent localized feedback, and offer
 retry. Add all required ARB translations and regenerate localization.

 Add datasource/repository/BLoC/widget coverage for confirmation dismissal,
 success, retryable failure, Material/Cupertino, compact/wide, RTL, tombstones,
 physical deletion, and idempotent missing deletion.

## 4. Edit persisted cards

 Implement the `Edit persisted cards without losing failed drafts` ticket from
 `tickets.md`.

 Add read-only-details Edit, Save, and Cancel behavior using the existing Cards
 editor state and the repository draft contract. Entering edit seeds the raw
 draft from the selected persisted card. Save uses the same trim/validation
 semantics as create.

 Change datasource update to return the persisted `CardDto` or `null` for a
 missing/tombstoned target. Map `null` in the repository to
 `CardNotFoundException` carrying the requested ID. On success atomically
 replace the item in `CardsBloc`, retain its selected route, update read-only
 details, and exit edit mode.

 Disable edit controls and ignore duplicate updates while pending. Preserve raw
 edit draft and validation errors through refresh and recoverable failures.
 Cancel returns to read-only details. For a missing update target, retain
 draft, present a non-retryable not-found state, and provide Return to cards.
 Preserve existing created-versus-updated sync transitions.

 Add localized English/Spanish/Hebrew copy, regenerate localization, and cover
 repository/datasource/BLoC/widget behavior including missing targets and sync
 transitions.

## 5. Guard unsaved drafts

 Implement the `Protect unsaved drafts across navigation` ticket from
 `tickets.md`.

 Add and export a generic `TabBranchResetGuard<TTab>` in
 `packages/navigation`. It accepts `Future<bool> Function()` as its
 reset-decision callback. Integrate it into nested active-branch reset handling
 so it awaits the decision, permits reset only on `true`, and suppresses
 duplicate reset requests while awaiting. Preserve current root-tab reselect
 and scroll-to-top behavior; add package-level tests.

 In Cards, define dirty editor state as raw current title/description differing
 from the initial snapshot. Guard back, Cancel, Add, card selection, and
 active-tab branch reset with a localized adaptive discard confirmation.
 Dismissal retains route and raw draft. Confirmed discard routes back to
 read-only details for edit and `/cards` for create. Switching top-level tabs
 preserves the branch and draft without prompting.

 Add ARB copy in all three languages, regenerate localization, and cover
 Material/Cupertino, compact/wide, RTL, back, cancel, selection, add, reselect,
 dismissal, confirmation, and duplicate-reset flows.

## 6. End-to-end persistence verification

 Implement the `Prove end-to-end persistence and native relaunch` ticket from
 `tickets.md`.

 Extend integration coverage through production DI and SQLite to execute
 create, edit, delete, close, reopen, list, and detail flows. Assert created,
 updated, synced, deleted, and tombstone transitions through the datasource
 seam. Update Android and iOS native relaunch smoke instructions/tests so
 persistence survives an actual process relaunch.

 Verify localized output and generated DI are current. Run `flutter test`,
 `flutter analyze`, and the applicable Android/iOS integration smoke commands;
 report any environment-bound native checks separately rather than weakening
 coverage.

## 7. Publish the completed architecture

 Implement the `Publish the Cards model and completed architecture` ticket from
 `tickets.md` only after all behavioral verification is green.

 Add or update the project glossary/context so it precisely distinguishes
 `Card`, `CardDraft`, unsaved draft, dirty card, and tombstone without
 implementation details. Update the Cards SQLite architecture record with the
 verified repository, datasource, UI, navigation-guard, and lifecycle behavior.
 Mark the source plan and `tickets.md` accurately complete, ensuring
 terminology and links agree across all documents.

 Do not change runtime code. Run documentation/link validators and relevant
 documentation tests.

## Assumptions

- Local SQLite CRUD only; no API sync coordinator, retries, or conflict
  resolution.
- `uuid` is the production UUID-v4 implementation behind the injected
  generator.
- Existing unrelated worktree changes remain untouched.
