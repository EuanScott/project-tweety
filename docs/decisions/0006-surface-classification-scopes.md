# ADR-0006: Window and region surface classification are separate decisions

Status: proposed
Date: 2026-09-04
Decision maker: Euan Scott

## Context

Two different questions in this app both reduced to "is this surface big
enough", both used 600 logical pixels as the threshold, and both were called
some variant of "expanded". They are not the same question.

- **Window**: may the device rotate freely, and should a modal present as a
  floating window? `DisplayMetrics.isExpandedSurface` answers this from
  `MediaQueryData.size.shortestSide`. Its callers are
  `lib/core/platform/orientation_policy.service.dart` and
  `lib/presentation/widgets/app_modal.dart`.
- **Content region**: does the area a page renders into show two panes or one?
  This is smaller than the window — the navigation rail and the safe area both
  take width out of it before a page sees anything.

Conflating them produced a live defect. `cards.page.dart` measured the region
with its own `LayoutBuilder` placed above `PageScaffold`, while `PageScaffold`
measured again inside its own `SafeArea`. On a surface with horizontal
safe-area insets the two measurements differ by exactly the inset width, so
there was a band of widths where routing chose the split layout and layout
chose the compact one. In that band the card details rendered nowhere: the
location was `/cards/<id>` and the user saw only the list.

A third measurement existed at the tap call site, where push-versus-replace was
keyed on `selectedCardId == null` as a stand-in for "am I on a phone". That
proxy is wrong on a tablet, where the first selection pushed a page that
nothing had asked for.

## Decision

**We will treat window classification and content-region classification as two
named concepts, and we will classify a content region exactly once per region
and publish the result through `PaneLayoutScope`.** `DisplayMetrics` keeps the
window question. Routing and layout both read `PaneLayoutScope.of(context)`
rather than measuring for themselves, and the scope measures the region as
callers experience it — incoming constraints less horizontal safe-area insets,
with a vertical fold or hinge overriding width.

## Alternatives

- **One shared surface classification for both questions** — rejected. It would
  make orientation policy depend on how wide a navigation rail happens to be,
  which is not what "may this device rotate" means.
- **A shared helper both call sites invoke with their own context** — rejected.
  The defect was two measuring positions, not two copies of a threshold. A
  helper leaves both positions in place.
- **`PageScaffold` publishing the mode itself** — rejected. The cards page needs
  the answer above `PageScaffold` in order to decide whether to render one at
  all.

## Consequences

`PageScaffold` no longer takes a `secondaryBreakpoint`, and its
`usesSplitPaneLayout` helper is gone; a page that wants split panes must sit
inside a `PaneLayoutScope`. `SplitPaneLayout` drops the four raw layout
primitives it used to require and is testable on its own.

The scope is published in the cards `ShellRoute` rather than in
`packages/navigation`, because only one feature needs it today and the
navigation package has no `design_system` dependency. A second feature wanting
split panes is the trigger to promote it into the shell.

Stack depth now follows the region mode, so `/cards/:id` and `/cards/new` are
siblings of `/cards` rather than children. A compact region pushes onto that
route; a split region replaces it. Two costs follow: a cold deep link in a
compact region has no page to pop, so `CardDetailsPage` supplies its own back
action when `canPop()` is false; and a page pushed while compact must be
flattened when the region becomes split, which `Cards` does from
`didChangeDependencies`.

Re-evaluate if a second feature needs split panes, or if a page needs a
breakpoint other than the region default.

## Confirmation

`packages/design_system/test/adaptive/pane_layout_test.dart` covers the region
rule including the safe-area subtraction.
`test/presentation/pages/cards/split_pane_drift_app_test.dart` drives the whole
app with horizontal insets across the band where the two old measurements
disagreed. `test/presentation/pages/cards/cards_navigation_test.dart` covers
stack depth in both regions, the cold deep link, and the compact-to-split
transition.
