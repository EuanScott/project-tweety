# AGENTS.md

## Purpose
- This folder owns app-level navigation for Project Tweety.
- Keep route definitions, tab shell behavior, navigation helpers, and route-specific documentation here.
- Feature pages should call navigation helpers instead of hard-coding route names or paths.

## Folder Structure
- `router.dart` should only compose the `GoRouter` tree and wire dependencies together.
- `routes.dart` owns route names and paths.
- `navigator_keys.dart` owns root and branch navigator keys.
- `tabs/` owns tab enums and tab metadata used by the shell.
- `tab_reselect/` owns active-tab callback registration and the `TabReselectHandler` widget.
- `widgets/` owns navigation-specific widgets such as the app shell and route error page.
- `analytics/` owns navigation observers and route screen tracking.
- `navigation_extensions.dart` owns app navigation helpers used by feature pages.

## Router File Boundary
- Do not put large widgets, tab reselect lifecycle code, or analytics observer implementations directly in `router.dart`.
- If `router.dart` grows beyond route composition, extract the behavior into the matching folder above.
- Keep `router.dart` readable enough that the full route tree can be understood at a glance.

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
- Root tab pages may register custom active-tab behavior with `TabReselectHandler`.
- Custom active-tab behavior should only run on the tab root route.
- Nested routes should return to the tab root when the active tab is tapped.
