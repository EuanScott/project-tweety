# AGENTS.md

## Project Overview
- `project-tweety` is a Flutter playground app for exploring ideas, patterns, and experiments outside of production work.
- Prefer small, focused changes that fit the exploratory nature of the repo.
- Preserve the existing layered structure instead of introducing new architectural styles unless the task explicitly requires it.

## Tech Stack
- Flutter with Dart `>=3.8.1 <4.0.0`
- State management and DI packages include `bloc`, `flutter_bloc`, `get_it`, and `injectable`
- Code generation is used for DI and Flutter-generated assets/localization

## Repository Layout
- `packages/design_system`: shared Flutter design system package for reusable theming and UI-level primitives
- `lib/core`: cross-cutting concerns such as analytics, DI, error reporting, and feature flags
- `lib/data`: constants, DTOs, datasources, repositories, and services
- `lib/domain`: domain entities, repository contracts, and use cases
- `lib/features`: feature-scoped experiments; currently includes `dynamic_form`
- `lib/presentation`: pages, widgets, extensions, and UI helpers
- `lib/l10n`: ARB files and generated localization output
- `test`: widget and shared/unit tests

## Working Conventions
- Follow the existing lint rules in `analysis_options.yaml`, especially `avoid_print: true` and `prefer_single_quotes: true`.
- Match the current import style: package imports for app entrypoints and shared modules, relative imports where already generated or established.
- Use the `cards` feature as the naming reference for new layered work.
- Standardize filenames on `feature_or_entity.role.dart`.
- Use `_` inside the business name and `.` before the technical role.
- Preferred role suffixes are:
  - `.page.dart`
  - `.bloc.dart`
  - `.event.dart`
  - `.state.dart`
  - `.entity.dart`
  - `.dto.dart`
  - `.repository.dart`
  - `.repository_impl.dart`
  - `.datasource.dart`
  - `.usecase.dart`
- Do not add inline comments unless they clarify non-obvious behavior that cannot be expressed cleanly in code.

## Generated Files
- Treat generated files as derived artifacts unless the task explicitly targets generation output.
- Do not hand-edit these files unless absolutely necessary:
  - `lib/core/di/di.config.dart`
  - `lib/l10n/app_localizations.dart`
  - `lib/l10n/app_localizations_en.dart`
  - `lib/l10n/app_localizations_es.dart`
- If source annotations, ARB files, or generation inputs change, regenerate instead of patching generated output directly.

## Common Commands
- Install dependencies: `flutter pub get`
- Run the app: `flutter run`
- Run tests: `flutter test`
- Regenerate DI/build_runner output: `dart run build_runner build --delete-conflicting-outputs`
- Refresh localization output after ARB changes: `flutter gen-l10n`

## Testing Guidance
- Prefer targeted tests first, then broader validation if needed.
- Add or update tests near the affected area when the repo already has an appropriate test pattern.
- Avoid fixing unrelated failing tests as part of a focused task.
- Existing tests may include older scaffolded examples; align new tests with the current app behavior rather than preserving obsolete smoke tests.

## Change Scope
- Keep changes surgical and relevant to the requested task.
- Avoid committing build artifacts or platform-specific output unless the user explicitly asks for them.
- Prefer editing source files under `lib/`, `test/`, and project config files over touching generated directories like `build/`, `.dart_tool/`, `android/build/`, or `ios/Pods/`.
- Prefer placing reusable app-wide theming in `packages/design_system` instead of recreating it under `lib/`.
