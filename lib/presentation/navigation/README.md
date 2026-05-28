# Project Tweety Navigation

This folder owns the app-specific side of navigation. Reusable mechanics live in the local `navigation` package at `packages/navigation`.

## Ownership Split

App-owned in `lib/presentation/navigation`:

- route names and paths in `routes.dart`
- the `AppTab` enum
- localized tab labels and icons in `tabs/app_tab_config.dart`
- page builders and nested route trees in `router.dart`
- feature-facing helpers in `navigation_extensions.dart`
- analytics tracker and navigator observers in `analytics/`

Package-owned in `packages/navigation`:

- tab shell rendering
- adaptive bottom navigation and navigation rail behavior
- branch navigator key creation
- route error page widget
- generic tab reselect lifecycle
- `createNavigationRouter<TTab>()`

The package must not import app pages, app localization, app route constants, or `AnalyticsFacade`.

## How Routing Works

`router.dart` is the composition point:

1. The app creates analytics wiring.
2. The app defines `NavigationBranch<AppTab>` values with `GoRoute` trees and page builders.
3. The app passes `appTabConfigs`, branches, root redirect data, observers, and the localized error builder into `createNavigationRouter<AppTab>()`.
4. The package builds the `GoRouter`, `StatefulShellRoute.indexedStack`, branch navigators, and adaptive navigation shell.

This keeps the route graph easy to scan while moving repeated shell logic out of the app.

## Deep Links

`go_router` treats the incoming location as the source of truth, so routes such
as `/settings/app-preferences` and `/cards/:cardId` can be opened directly.

Widget tests exercise this with `MyApp(initialLocation: ...)`. Platform-level
Android and iOS link registration is not configured yet.

## Route Guards

Route guards live in `router.dart` on the `GoRoute` definitions. Pages should
not decide whether they are allowed to render. The router decides whether a
location can be displayed before the guarded page is built.

The temporary manual guard for Settings is controlled by:

```sh
flutter run --dart-define=CAN_ACCESS_SETTINGS=false
```

When `CAN_ACCESS_SETTINGS` is `false`, these routes redirect to
`/access-denied`:

- `/settings`
- `/settings/app-preferences`

`/access-denied` is a fallback explanation route for authorization failures.
It is not the right destination for every guard failure. When a user can resolve
the blocked condition, redirect them to the journey that resolves it instead:

- signed out user: redirect to login and preserve the intended route
- incomplete profile: redirect to profile completion and preserve the intended route
- missing role or entitlement: show access denied, request access, or upgrade flow
- unknown auth state: show a loading/splash gate, then re-evaluate

Testing notes live in [`docs/testing/navigation.md`](../../../docs/testing/navigation.md).

## Adaptive Shell

The shared shell switches navigation chrome from the available width:

- compact width below `600dp`: bottom `NavigationBar`
- medium width from `600dp`: compact `NavigationRail` with labels under icons
- tablet width from `1200dp`: permanent `NavigationDrawer`

Feature pages should still decide their own content layout. For example, the Cards branch uses `/cards/:cardId` as a nested route: compact widths show details as a page, while wider widths can keep the list and selected details visible together.

## Adding a Nested Route

1. Add the route name/path to `AppRoutes`.
2. Add the `GoRoute` as a child route under the correct branch in `router.dart`.
3. Add a helper to `navigation_extensions.dart` if feature code needs to open it.
4. Use the helper from the page instead of hard-coding route names.

Example shape:

```dart
GoRoute(
  path: AppRoutes.settingsPath,
  name: AppRoutes.settingsName,
  builder: (context, state) => const Settings(),
  routes: [
    GoRoute(
      path: AppRoutes.settingsAppPreferencesPath,
      name: AppRoutes.settingsAppPreferencesName,
      builder: (context, state) => const AppPreferencesPage(),
    ),
  ],
)
```

## Adding a Top-Level Tab

1. Add a value to `AppTab`.
2. Add a `NavigationTabConfig<AppTab>` to `tabs/app_tab_config.dart`.
3. Add a matching `NavigationBranch<AppTab>` to `router.dart`.
4. Keep `AppTab`, `appTabConfigs`, and branch order aligned.
5. Add or update navigation widget coverage for tab rendering and branch switching.

The package validates that every tab has a branch, but readable ordering is still the app's responsibility.

## Tab Reselect

Root tab pages can register active-tab behavior with:

```dart
TabReselectHandler<AppTab>(
  tab: AppTab.cards,
  onReselect: _scrollToTop,
  child: PageScaffold(...),
)
```

Use this for UI-local actions such as scrolling to the top or focusing a search field. Nested routes do not run custom reselect behavior; tapping the active tab from a nested route returns that branch to its root.

## Analytics

Analytics is intentionally still app-owned. `router.dart` creates the current tracker/observers and passes callbacks into package APIs:

```dart
onTabRouteSelected: analyticsTracker?.trackScreenName,
```

When analytics stabilizes, it can be split into a separate package without making `packages/navigation` depend on Project Tweety.
