# Navigation Package

`navigation` is a local Flutter package for reusable tab-shell navigation mechanics. It is intentionally app-agnostic: consuming apps provide route names, paths, page builders, localization, and analytics callbacks.

## What This Package Owns

- `createNavigationRouter<TTab>()` for assembling a tab-shell `GoRouter`
- `NavigationShell<TTab>` for `StatefulNavigationShell` + adaptive `NavigationBar`/`NavigationRail`/`NavigationDrawer`
- `NavigationTabConfig<TTab>` for tab metadata
- `NavigationBranch<TTab>` for app-provided branch route trees
- `NavigationNavigatorKeys<TTab>` for root and branch navigator keys
- `NavigationRouteErrorPage` for generic route-error UI
- `TabReselectController<TTab>`, `TabReselectScope<TTab>`, and `TabReselectHandler<TTab>`

## What Consuming Apps Own

Apps must keep these outside the package:

- route constants and route names
- actual `GoRoute` trees and page builders
- app tab enum values
- localized tab labels and error text
- app navigation extensions
- analytics facades, trackers, and observers

This keeps the package reusable and prevents dependencies on a specific app.

## Basic Usage

```dart
final router = createNavigationRouter<AppTab>(
  initialLocation: AppRoutes.rootPath,
  rootPath: AppRoutes.rootPath,
  rootRedirectPath: AppRoutes.homePath,
  tabs: appTabConfigs,
  branches: [
    NavigationBranch<AppTab>(
      tab: AppTab.home,
      routes: [
        GoRoute(
          path: AppRoutes.homePath,
          name: AppRoutes.homeName,
          builder: (context, state) => const Home(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, error) {
    return NavigationRouteErrorPage(
      error: error,
      title: 'Page not found',
      description: 'The page is not available.',
      actionLabel: 'Go home',
      onActionPressed: () => context.goNamed(AppRoutes.homeName),
    );
  },
);
```

The app can pass observers and analytics callbacks without the package knowing the analytics implementation:

```dart
createNavigationRouter<AppTab>(
  // ...
  observers: _navigationObservers(analyticsTracker),
  onTabRouteSelected: analyticsTracker?.trackScreenName,
);
```

## Adaptive Shell

`NavigationShell<TTab>` uses the width available to the shell:

- below `600dp`: bottom `NavigationBar`
- `600dp` to `1199dp`: compact `NavigationRail` with labels under icons
- `1200dp` and wider: permanent `NavigationDrawer`

The package only adapts the shared navigation chrome. Consuming apps keep route definitions and destination-specific layouts, including list-detail behavior, in their own presentation layer.

## Tab Configuration

Tab configuration is app-owned because labels, icons, route names, and tab ids are app decisions.

```dart
const appTabConfigs = [
  NavigationTabConfig<AppTab>(
    tab: AppTab.home,
    rootPath: AppRoutes.homePath,
    routeName: AppRoutes.homeName,
    icon: Icons.home,
    labelBuilder: _homeTabLabel,
  ),
];
```

`labelBuilder` receives `BuildContext` so the app can resolve localization without exposing localization types to the package.

## Branches

Each `NavigationBranch<TTab>` must match one tab config. The router factory validates empty tabs, mismatched counts, duplicates, missing branches, and unknown branches.

```dart
NavigationBranch<AppTab>(
  tab: AppTab.settings,
  restorationScopeId: 'settings_branch',
  observers: _navigationObservers(analyticsTracker),
  routes: [
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
    ),
  ],
)
```

## Active Tab Reselect

Root tab pages can register a callback for tapping the already-selected tab:

```dart
TabReselectHandler<AppTab>(
  tab: AppTab.cards,
  onReselect: _scrollToTop,
  child: CardsView(...),
)
```

Behavior:

- tapping a different tab switches branch
- tapping the active tab from a nested route returns that branch to its root
- tapping the active tab on its root route runs the registered callback

Use this for UI-local actions such as scrolling to top or focusing a search field.

## Package Rules

- Import this package through `package:navigation/navigation.dart`.
- Do not import from `lib/src/` in consuming apps.
- Keep package APIs generic over `TTab extends Object`.
- Do not add app-specific route constants, localization, analytics, pages, or business logic.
- Add focused package tests when public behavior changes.
