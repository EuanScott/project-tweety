# AGENTS.md

## Scope
- This file applies to everything under `packages/design_system/`.

## Purpose
- `design_system` is a shared Flutter package for reusable theming and UI-level design primitives.
- Keep this package presentation-focused; it should not contain app-specific business logic, BLoCs, repositories, or data/domain code.

## Package Boundaries
- Do not import from `project_tweety` or any consuming app.
- Keep the public API small and export it from `lib/design_system.dart`.
- Keep implementation details under `lib/src/`.

## Theming Conventions
- Prefer brand/token-driven configuration instead of duplicating theme structures.
- Put shared `ThemeData`, `ColorScheme`, typography, and component theme builders here.
- Add new brands through token objects like `DesignBrand` and shared presets like `DesignBrands`.
- Keep B2C and B2B variants using the same structural theme logic wherever possible.

## Adaptive Primitive Conventions
- `packages/design_system` owns app-level visible UI primitives that choose the native presentation per platform, such as buttons, list rows, loading indicators, and pickers.
- Design-system primitives may use raw Material and Cupertino widgets internally, but consuming pages and shared widgets should depend on the primitive API instead of branching on platform themselves.
- Keep primitive APIs semantic and app-facing, for example `AppButton.primary`, `AppLoadingIndicator`, or `AppPickerField`, rather than mirroring every underlying Flutter platform widget option.
- When a page or shared widget needs visible UI that is not covered by an existing primitive, add the narrow primitive here first and cover both Material and Cupertino behavior with focused tests.

## Dependency Conventions
- Keep dependencies lightweight and UI-focused.
- Only add package dependencies that are truly required by the shared design system.

## Consumption Pattern
- Consuming apps should depend on this package through a local path dependency first.
- Apps should use package APIs like `DesignSystemTheme.light(...)` and `DesignSystemTheme.dark(...)` rather than copying theme code locally.
