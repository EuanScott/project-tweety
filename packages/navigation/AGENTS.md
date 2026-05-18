# AGENTS.md

## Scope
- This file applies to everything under `packages/navigation/`.

## Purpose
- `navigation` is a shared Flutter package for reusable app navigation mechanics.
- Keep route definitions, page builders, app-local localization, and app analytics wiring in the consuming app.
- The package should make tab-shell navigation repeatable without knowing anything about a specific app.

## Package Boundaries
- Do not import from `project_tweety` or any consuming app.
- Keep the public API small and export it from `lib/navigation.dart`.
- Keep implementation details under `lib/src/`.
- Prefer generic types and callbacks over app-specific enums, route constants, analytics facades, or localization classes.
- Do not add app route names, app paths, page imports, `AppLocalizations`, or `AnalyticsFacade` here.
- Do not depend on `design_system`; the package should rely on Material/Flutter primitives and the consuming app's active `ThemeData`.

## Public API Shape
- Export public types from `lib/navigation.dart`.
- Keep package APIs generic over the consuming app's tab identifier, usually `TTab extends Object`.
- Prefer accepting `BuildContext` builders, callbacks, route lists, and tab metadata rather than app-specific objects.
- Current public concepts:
  - `NavigationTabConfig<TTab>`
  - `NavigationBranch<TTab>`
  - `createNavigationRouter<TTab>()`
  - `NavigationShell<TTab>`
  - `NavigationRouteErrorPage`
  - `TabReselectController<TTab>`
  - `TabReselectScope<TTab>`
  - `TabReselectHandler<TTab>`

## Router Factory Rules
- `createNavigationRouter<TTab>()` owns generic `GoRouter` assembly only.
- The consuming app must provide root redirect paths, tab configs, branch route trees, error UI, observers, and analytics callbacks.
- Validate structural mistakes early:
  - empty tab list
  - tab/branch count mismatch
  - duplicate tabs or branches
  - missing branch for a tab
  - branch for an unknown tab
- Do not infer route names, labels, or page builders inside the package.

## Tab Shell Rules
- `NavigationShell<TTab>` owns bottom navigation behavior.
- Tapping a different tab switches branch.
- Tapping the active tab on a nested route returns that branch to its root.
- Tapping the active tab on its root route runs the registered tab reselect callback, if any.
- Keep tab reselect behavior UI-local; do not add data refresh semantics to the package.

## Error Page Rules
- `NavigationRouteErrorPage` owns only generic presentation.
- The consuming app must provide localized title, description, action label, and action callback.
- Do not read app localization or app route helpers inside this package.

## Dependency Conventions
- Keep dependencies lightweight and navigation-focused.
- `go_router` and Flutter are acceptable dependencies for this package.

## Consumption Pattern
- Consuming apps should depend on this package through a local path dependency first.
- Apps should pass route data, tab labels, page builders, and analytics callbacks into package APIs instead of reaching into package internals.
- Apps should import only `package:navigation/navigation.dart`.
- Do not expose or document imports from `lib/src/`.

## Testing Guidance
- Add package tests for generic behavior when package APIs change.
- Prefer focused tests around tab reselect registration, router factory validation, and shell behavior.
- App route behavior should remain covered in the consuming app's widget tests.
- Do not add Project Tweety pages or localization to package tests.

## Documentation
- Keep `README.md` updated when package APIs or ownership rules change.
- Keep `lib/presentation/navigation/README.md` updated when the app-side integration pattern changes.
