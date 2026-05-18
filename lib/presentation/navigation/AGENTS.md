# AGENTS.md

## Purpose
- This folder owns app-level navigation for Project Tweety.
- Keep route definitions, tab metadata, navigation helpers, analytics wiring, and route-specific documentation here.
- Feature pages should call navigation helpers instead of hard-coding route names or paths.
- Reusable navigation mechanics live in the local `packages/navigation` package.

## Package Boundary
- This folder is the consuming app side of navigation.
- Keep app-owned concepts here:
  - route names and paths
  - page builders and nested route trees
  - `AppTab`
  - localized tab label builders
  - app navigation extensions
  - analytics facade/tracker/observer wiring
- Do not move app pages, app localization, `AnalyticsFacade`, or route constants into `packages/navigation`.
- If a navigation behavior can be expressed generically with route data, tab configs, callbacks, or builders, prefer putting that behavior in `packages/navigation`.

## Folder Structure
- `router.dart` should only compose the `GoRouter` tree and wire dependencies together.
- `routes.dart` owns route names and paths.
- `tabs/` owns the app tab enum and the app-specific tab config list.
- `analytics/` owns navigation observers and route screen tracking.
- `navigation_extensions.dart` owns app navigation helpers used by feature pages.
- `packages/navigation` owns the shell, navigator-key helper, route error page widget, router factory, and tab reselect lifecycle.

## Router File Boundary
- Do not put large widgets, tab reselect lifecycle code, or analytics observer implementations directly in `router.dart`.
- If `router.dart` grows beyond route composition, keep reusable mechanics in `packages/navigation` and app-specific helpers in this folder.
- Keep `router.dart` readable enough that the full route tree can be understood at a glance.
- `router.dart` should pass app route data into `createNavigationRouter<AppTab>()`.
- Branch order must match `appTabConfigs`; the package validates count and tab identity, but humans should still keep the order easy to scan.

## Adding Navigation
- Add route constants to `routes.dart` first.
- Add feature/page builders in `router.dart` through app-owned `GoRoute` definitions.
- Add feature-facing helper methods to `navigation_extensions.dart` instead of using route names in pages.
- For a new top-level tab:
  - add a value to `AppTab`
  - add a matching `NavigationTabConfig<AppTab>` to `tabs/app_tab_config.dart`
  - add a matching `NavigationBranch<AppTab>` to `router.dart`
  - keep the enum order, tab config order, and branch order aligned
- For a nested page under an existing tab, add it as a child route of that tab root and keep the bottom shell intact.

## Analytics Boundary
- Keep analytics app-owned for now.
- `router.dart` may create `NavigationAnalyticsTracker` and app-owned observers.
- Pass screen-name callbacks into package APIs, such as `onTabRouteSelected`.
- Do not make `packages/navigation` depend on `AnalyticsFacade`; split analytics into its own package later if the API stabilizes.

## Current Router Choice
- Use plain `go_router` for now.
- Do not add `go_router_builder` yet.
- The app currently has a small route graph:
  - `/home`
  - `/cards`
  - `/settings`
  - `/settings/app-preferences`
- Plain `go_router` is enough while routes are simple, mostly static, and do not require path or query parameters.

## When To Reconsider go_router_builder
- Bring up `go_router_builder` before adding more navigation infrastructure once the app reaches roughly 8-12 routes.
- Also reconsider it earlier if routes need:
  - path parameters, such as `/cards/:cardId`
  - query parameters or filters
  - repeated navigation to the same parameterized pages from multiple features
  - frequent route refactors where string route names become fragile
- If these conditions are met, discuss typed routes before continuing with more plain string route wiring.

## Plain go_router Pattern
- Prefer navigation helpers for feature code:

```dart
context.openAppPreferences();
```

- Keep raw route names inside the navigation layer:

```dart
context.pushNamed(AppRoutes.settingsAppPreferencesName);
```

## go_router_builder Example
- With `go_router_builder`, routes are modeled as typed route classes and generated code provides typed navigation APIs.

```dart
@TypedGoRoute<SettingsRoute>(
  path: '/settings',
  routes: [
    TypedGoRoute<AppPreferencesRoute>(
      path: 'app-preferences',
    ),
  ],
)
class SettingsRoute extends GoRouteData {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Settings();
  }
}

class AppPreferencesRoute extends GoRouteData {
  const AppPreferencesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AppPreferencesPage();
  }
}
```

- Generated-style navigation then becomes:

```dart
const AppPreferencesRoute().push(context);
```

- Parameterized routes become constructor fields:

```dart
class CardDetailsRoute extends GoRouteData {
  const CardDetailsRoute({required this.cardId});

  final String cardId;
}
```

## Tab Reselect Behavior
- Root tab pages may register custom active-tab behavior with `TabReselectHandler` from `package:navigation/navigation.dart`.
- Custom active-tab behavior should only run on the tab root route.
- Nested routes should return to the tab root when the active tab is tapped.
- Register tab reselect handlers only from root tab pages, not nested pages.
- Use tab reselect for UI-local actions such as scrolling a list to the top or focusing a search field.
- Do not use tab reselect to reload domain data unless the user explicitly asks for that behavior.

## Documentation
- Keep `README.md` in this folder updated when the app/package boundary changes.
- Keep `packages/navigation/README.md` updated when package APIs or ownership rules change.
