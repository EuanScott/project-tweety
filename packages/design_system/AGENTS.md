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

## Dependency Conventions
- Keep dependencies lightweight and UI-focused.
- Only add package dependencies that are truly required by the shared design system.

## Consumption Pattern
- Consuming apps should depend on this package through a local path dependency first.
- Apps should use package APIs like `DesignSystemTheme.light(...)` and `DesignSystemTheme.dark(...)` rather than copying theme code locally.
