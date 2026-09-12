# Split-Pane / Scaffold Architecture Review

Status: findings only, no implementation started. Pick items up individually.

## Summary

Follow-up to a review of where shared widgets belong (`design_system` vs.
`lib/presentation/widgets/`) — that placement question is settled: keep
`SplitPaneLayout` and `AppModal` in `lib/presentation/widgets/`. This
document instead captures three depth/locality issues found in the same
area while investigating that question. None are urgent; each is
independent and can be scheduled separately.

## 1. Split-pane decision computed twice

**Files**: `lib/presentation/widgets/split_pane_layout.dart`,
`lib/presentation/widgets/page_scaffold.dart:171-235`,
`lib/presentation/pages/cards/cards.page.dart:71-97`

**Problem**: `cards.page.dart` runs its own `LayoutBuilder` and calls
`PageScaffold.usesSplitPaneLayout(...)` to decide whether to push
`CardDetailsPage` or render it inline as `secondaryBody`. `PageScaffold`
then re-runs the identical `SplitPaneLayout.shouldUse` breakpoint check a
second time internally to decide whether to actually lay out the split
pane. Two independent computations of the same decision, in two files,
with nothing keeping them in sync — they can disagree.

`SplitPaneLayout`'s constructor also takes four raw layout primitives
(`displayFeature`, `constraints`, `resolvedPadding`, `globalOffset`) that
callers must assemble themselves via `MediaQuery`, `LayoutBuilder`, and a
post-frame `RenderBox` lookup. Only `PageScaffold` currently assembles
this correctly. There is no test coverage for `SplitPaneLayout` today.

**Suggested next step**: introduce a single owned query (e.g. a static
`PageScaffold.splitPaneDecisionOf(BuildContext)`) that gathers the
`MediaQuery`/constraints data once and returns a small value type both
`cards.page.dart` (routing) and `PageScaffold` (layout) read from.
Narrow `SplitPaneLayout`'s constructor to the sizing decision only, and
add coverage for its Row/pane-sizing branches once the interface is
narrower.

**Priority**: highest of the three — the only one with a live correctness
risk (the two checks disagreeing) rather than duplication alone, and the
one with zero current test coverage.

## 2. Duplicated ToolBarAction → icon mapping

**Files**: `lib/presentation/widgets/tool_bar.dart:77-85`,
`lib/presentation/widgets/page_scaffold.dart:137-155`,
`packages/design_system/lib/src/adaptive/app_button.dart`

**Problem**: `PageScaffold` only composes `ToolBar` on the Material
branch. On Cupertino it bypasses `ToolBar` entirely and hand-builds
`CupertinoNavigationBar`/`CupertinoSliverNavigationBar` with its own
trailing-action mapping (`_cupertinoTrailingAction`), duplicating the
`ToolBarAction` → icon logic `ToolBar` already implements for Material —
without reusing `AppButton`, which already solves this exact
Material/Cupertino variance elsewhere in the app.

**Suggested next step**: move the `ToolBarAction` → widget mapping into
`ToolBar` itself, built on `AppButton`, branching Material/Cupertino
internally the way `AppButton`/`AppPickerField` already do. Have
`PageScaffold` call `ToolBar` unconditionally on both platforms and drop
`_cupertinoTrailingAction`.

**Priority**: second — mechanically simpler once #1 gives `PageScaffold` a
cleaner surface to build against; a natural follow-up in the same session
as #1, but not blocked by it.

## 3. AppModal doesn't adapt to Cupertino

**Files**: `lib/presentation/widgets/app_modal.dart:124-157`,
`test/presentation/widgets/app_modal.widget_test.dart`

**Problem**: `AppModal`'s three named constructors (`page`, `blocking`,
`compact`) funnel into one private `_show`, which is Material-only
(`showModalBottomSheet`/`BottomSheet`). Every other widget at this layer
(`PageScaffold`, `AppButton`, `AppPickerField`) adapts per platform;
`AppModal` renders a Material-styled sheet even on Cupertino.

**Suggested next step**: branch inside `_show` on `AppDesignPlatform`,
presenting `CupertinoModalPopup`/`showCupertinoDialog` as appropriate,
keeping the existing three-constructor public interface unchanged. The
existing widget test already exercises real modal behaviour (pop values,
back-dismissal, navigator observer) and should extend to the new branch
rather than needing a new harness.

**Priority**: independent — a feature gap rather than a shallow-module
symptom, lower architectural leverage than #1/#2. Pick up any time.

## Future consideration: extracting shared widgets to design_system

Deferred, not rejected — kept here so it isn't lost.

**Original proposal**: move `SplitPaneLayout` and `AppModal` (and
potentially other widgets in `lib/presentation/widgets/`) into
`packages/design_system/`. Both currently have no `project_tweety`-specific
dependencies — they only import `material_ui` — so nothing in their own
code rules this out.

**Why it isn't happening now**: `packages/design_system/AGENTS.md`
currently requires the package stay "independent of `project_tweety`", and
root `AGENTS.md` already names `lib/presentation/widgets/` as a valid home
for cross-page shared widgets. Moving now would go against the repo's
current stated conventions, not just add work.

**Triggers worth revisiting this for**:
- A second app consuming `design_system` — the scenario the original
  proposal itself identified as the deciding factor.
- The widget catalogue in `lib/presentation/widgets/` growing enough that
  the "no app dependencies" subset becomes large/valuable enough to justify
  the migration cost.

**Known migration cost**, so it doesn't need rediscovering: `AppModal` has
three call sites (`modal_extension.dart`, `cards.page.dart`,
`home.page.dart`) plus an existing widget test importing it via
`package:project_tweety/...`, all needing import updates. `SplitPaneLayout`
currently has no test coverage at all.

## 4. AppModal Cupertino support — item 3 is resolved

An in-progress, uncommitted diff on `app_modal.dart` implements exactly the
branch item 3 above asked for: `_show` now dispatches on
`AppDesignPlatform.of(context).isCupertino` to `_showMaterial` or
`_showCupertino`. Mark item 3 done once that diff lands.

The same diff also adds a close-icon affordance to `page`/`compact` (not
`blocking`) and lowers `standardMaxHeightFactor` from `0.95` to `0.8`; see
`docs/research/modal_close_button_hci_guidelines.md` for the sourcing behind
both changes and `docs/CONTEXT.md`'s "Modal presentation" section for the
vocabulary it introduced (modal variant, dismissal contract, close
affordance, resolving action).

## 5. AppModal's internal `_show`/`_showMaterial`/`_showCupertino` seam is duplicated

**Files**: `lib/presentation/widgets/app_modal.dart:143-272`

**Problem**: `AppModal` is still a deep module at its public seam — three
narrow entry points (`page`, `compact`, `blocking`) hide all bottom-sheet,
Cupertino-popup, constraint, and close-button logic. But the *internal* seam
between `_show` and its two backends is shallow: all three private methods
carry near-identical 9-12 parameter lists (`context`, `child`,
`borderRadius`, `canPop`, `maxHeightFactor`, `useSafeArea`,
`useRootNavigator`, `showCloseButton`, plus platform-specific extras like
`enableDrag`/`isScrollControlled`/`showDragHandle` on the Material side).
Every future flag has to be hand-threaded through all three signatures — the
exact operation the current diff just performed to add `showCloseButton` —
which is exactly the kind of duplication that lets a flag get wired into two
of three paths and silently dropped from the third.

**Suggested next step**: bundle the shared knobs into one private value type
(e.g. a `_ModalPresentation` record/class) that `_show` builds once and
`_showMaterial`/`_showCupertino` each accept as a single parameter. This
narrows the internal seam without touching the public `page`/`compact`/
`blocking` signatures.

**Priority**: low — no live bug today, just rising threading cost each time
a new cross-platform modal option is added.

## 6. AppModal test-interface gaps

**Files**: `test/presentation/widgets/app_modal.widget_test.dart`

**Problem**: per the interface-is-the-test-surface principle, several things
`AppModal` does are unproven by its test suite:
- no Cupertino behavior group exists for `.compact` (only `.page` and
  `.blocking` get full Cupertino coverage beyond the shared close-button/
  default-height groups);
- `useSafeArea` is never asserted true or false, on either platform;
- tap-outside actually *dismissing* is only exercised as the negative case
  for `blocking` (which must not dismiss) — `page`/`compact` dismissing on
  tap-outside is assumed from defaults, never asserted, on either platform;
- the `Stack`-over-`Column` natural-sizing rationale documented in
  `_withCloseButton`'s comment has no regression test guarding it.

**Suggested next step**: pick these up as a normal TDD task next time this
file is touched, per `AGENTS.md`'s testing guidance, rather than as a
one-off patch.

**Priority**: low — coverage gaps, not known defects.
