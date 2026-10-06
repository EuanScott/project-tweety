# ADR-0015: Every route builds a native platform page, and Cards stacks follow the URL

Status: accepted
Date: 2026-10-06
Decision maker: Euan Scott

## Context

The app builds `MaterialApp` from `package:material_ui`. go_router chooses the
page type for a `GoRoute.builder` route by looking for the `MaterialApp` or
`CupertinoApp` class from `package:flutter`. That lookup never finds the
`material_ui` class. go_router then uses `NoTransitionPage`, so Settings, App
Preferences, Home, Access denied and the error page opened with no transition
and could not be closed with the iOS edge swipe.

Only the routes that already used `pageBuilder` with a platform page were
correct. Nothing stopped a new route from using `builder`.

Cards details and the card editor were siblings of `/cards`, as
[ADR-0006](0006-surface-classification-scopes.md) recorded. A `go` to a card
therefore built a stack with one page. A deep link, a saved new card, and a
fold from split to compact all left a card with no list to swipe back to.

## Decision

We will build every route's page with `platformPage` from
`packages/navigation`, and `createNavigationRouter` will reject any `GoRoute`
that uses `builder`. We will nest `/cards/new` and `/cards/:cardId` under
`/cards` and navigate Cards with `go` only, so the page stack always follows
the URL.

## Alternatives

- Upgrade go_router so that it detects `material_ui`. go_router 17.5.0 does not,
  and an upgrade alone would leave the next route free to regress.
- Fix each route by hand and keep `builder` available. That is how the defect
  started.
- Keep Cards routes as siblings and patch each `go` call site. A cold deep link
  and a fold from split to compact still have no list underneath.

## Consequences

- iOS and macOS pages slide in and close with the edge swipe. Other platforms
  get the Material page transition.
- A route that uses `builder` fails when the router is created, so tests catch
  it.
- In a split region the list location builds an empty page under the single
  visible panes page. The router can pop there, so the Android system back
  clears the Cards selection instead of leaving the tab. The Cards list page
  sets `PageScaffold.impliesBackAction` to `false` so that no back button shows
  over that hidden page.
- The card editors allow a pop while the draft has no changes, so the edge
  swipe works there. A draft with changes still blocks the pop and asks first.
- `Cards` no longer flattens the stack when the region becomes split, and
  `CardDetailsPage` no longer supplies its own back action.

Re-evaluate if go_router starts to detect the `material_ui` app, or if a second
feature needs split panes.

## Confirmation

`packages/navigation/test/navigation_router_test.dart` covers the page type,
the edge swipe, the error page, and the rejection of `builder` routes.
`test/presentation/navigation/settings_navigation.flow_test.dart` and
`test/presentation/pages/cards/cards_back_stack.flow_test.dart` drive the whole
app on iOS. `test/presentation/pages/cards/cards_navigation.flow_test.dart`
covers the single visible page in a split region.
