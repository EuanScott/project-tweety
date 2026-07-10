# AGENTS.md

## Purpose
- This file defines the default pattern for new feature work under `lib/`.
- This document is the source of truth for feature structure, naming, and layer boundaries under `lib/`.

## Skill Hints
- Users can scaffold and wire features manually. Skills are optional shortcuts for repeated patterns under `lib/`.
- For new BFF-backed layered architecture scaffolds with optional domain, mirror `_template` first:
  - data repository contract in `lib/data/repositories/_template/`
  - data repository implementation in `lib/data/repositories/_template/`
  - page and BLoC files in `lib/presentation/pages/_template/`
- Do not add entities, DTOs, datasources, navigation, localization, or rich UI until the feature has real behavior or data shape that justifies them.
- Do not add a domain layer by default. Assume the BFF handles mobile-specific shaping and common business logic.
- Add `lib/domain` only when the mobile app owns meaningful policy, orchestration, stateful app concepts, or custom behavior that should not live in presentation or data. Settings-style functionality is a valid case-by-case exception.
- If the task is a new feature that spans domain, data, and presentation, prefer `$feature-scaffold`.
- If the task is only domain work and the domain need is justified, prefer `$domain-scaffold`.
- If the task is only data work, prefer `$data-scaffold`.
- If the task is only page and BLoC/Cubit work, prefer `$page-scaffold`.
- If the task is a reusable widget under `lib/presentation/widgets/`, prefer the widget-specific guidance in that folder.
- If the user wants examples or expected inputs, use `<skill> --help` instead of guessing.

## Feature Structure
- New features should follow the layered structure already used in this repo:
  - `lib/presentation/pages/<feature>/`
  - `lib/presentation/pages/<feature>/bloc/`
  - `lib/data/datasources/`
  - `lib/data/dtos/`
  - `lib/data/repositories/`
- Add `lib/domain/entities/`, `lib/domain/repositories/`, and `lib/domain/usecases/` only when the feature has mobile-owned domain behavior.
- Prefer feature names that describe the business or UI intent, not placeholders like `other`, `misc`, or `stuff`.
- `_template` is the only intentional placeholder feature name. It exists as a copyable implementation reference for agents and should not be wired into app navigation.

## State Management Pattern
- Prefer BLoC when the feature has meaningful events, multiple user intents, retry/refresh flows, or enough orchestration that event names improve readability.
- Cubit is allowed for simple page state when there is no useful event vocabulary and state changes are direct commands, such as loading static preferences or toggling local UI state.
- Prefer one Freezed state class per page BLoC or Cubit instead of many small state subclasses.
- Use a status enum inside the state for lifecycle flow such as `initial`, `loading`, `success`, and `failure`.
- Use Freezed-generated `copyWith`; do not manually implement `copyWith`.
- If you need computed getters on a Freezed state, add `const MyState._();` and place only real derived getters there.
- Never leave manual getters that throw `UnimplementedError()` inside a Freezed state.
- For BLoCs, keep events small and explicit. For simple load flows, use a single `<Feature>Started` event.
- Keep BLoC/Cubit logic focused on orchestration: emit loading, call the injected dependency, emit success or failure.

## UI Integration
- Prefer `BlocProvider(create: ...)` when the widget owns the BLoC lifecycle.
- Prefer `BlocProvider.value(...)` only when reusing an existing BLoC instance.
- Prefer `BlocBuilder` for pure rendering.
- Use `BlocConsumer` only when the page needs both rendering and side effects such as snackbars, dialogs, navigation, or analytics hooks.
- For DI-backed page BLoCs, resolve them with `GetIt.I<YourBloc>()`, not the `getIt` helper.
- Trigger initial loading in the provider creation flow with the injected feature BLoC/Cubit and its initial load method or start event.

## Naming Conventions
- Standardize filenames on `feature_or_entity.role.dart`.
- Use `_` inside the business name and `.` before the technical role.
- Keep class names and filenames aligned across presentation, data, and optional domain layers.
- Use plural feature names for feature-scoped pages, repositories, and list-style use cases:
  - `<Feature>`
  - `<Feature>Bloc`
  - `<Feature>Cubit`
  - `<Feature>Event`
  - `<Feature>State`
  - `<Feature>Status`
  - `<Feature>Repository`
- Use singular or product-specific entity names for the actual business object:
  - `<Entity>`
  - `<Entity>Dto`
- Preferred filename examples:
  - `<feature>.page.dart`
  - `<feature>.bloc.dart`
  - `<feature>.cubit.dart`
  - `<feature>.event.dart`
  - `<feature>.state.dart`
  - `<entity>.entity.dart`
  - `<entity>.value.dart`
  - `<feature>.repository.dart`
  - `<action>_<feature>.usecase.dart`
  - `<entity>.dto.dart`
  - `<feature>_<source>.datasource.dart`
  - `<feature>.repository_impl.dart`

## Domain Layer
- The domain layer is optional, not the default feature layer.
- Domain entities should be framework-light and represent app-owned concepts.
- Entity filenames should use the entity name plus `.entity.dart`.
- Repository contracts live in the domain layer only when domain is justified; otherwise data-layer repository contracts are acceptable.
- Repository filenames should use the feature name plus `.repository.dart`.
- Use cases own justified mobile policy or orchestration and provide the entry point the BLoC depends on; a pure repository pass-through does not justify a domain layer.
- Use case filenames should describe the action plus `.usecase.dart`.
- BLoCs and Cubits should depend on the narrowest useful contract. In the default BFF-backed path, that can be a data-layer repository contract; when domain exists, prefer use cases.

## Data Layer
- Data layer objects that represent transferred or raw data should be named `Dto`, not `Model`.
- DTO filenames should use the entity name plus `.dto.dart`.
- Data sources should describe where the data comes from.
- Data source filenames should use the source description plus `.datasource.dart`.
- Repository implementations should map DTOs into app-facing repository values before returning data
  to callers when no domain layer exists.
- Repository values should use natural business class names such as `Card`; use
  `<entity>.value.dart` only when a feature needs separate files for several repository values.
- Use `toValue()` for DTO-to-repository-value mapping and reserve `toEntity()` for mapping into a
  domain entity.
- Repository implementation filenames should use the feature name plus `.repository_impl.dart`.
- Keep mock data sources in place until a real API implementation exists; they should still follow the same contract shape as a real data source.

## Injectable and DI
- Annotate BLoCs, Cubits, and optional use cases with `@injectable` when they should be created as factories.
- Annotate repository implementations with `@LazySingleton(as: ContractType)` when a single shared instance is appropriate.
- Annotate mock or remote data sources with `@lazySingleton` unless the feature has a reason to use a different lifecycle.
- After changing injectable annotations or Freezed types, regenerate outputs with:
  - `dart run build_runner build --delete-conflicting-outputs`

## Localization and Navigation
- When renaming a feature, tab, or page, also update:
  - navigation wiring in `main.dart`
  - localization keys in ARB files
  - generated localization output via `flutter gen-l10n`
- Keep tab labels aligned with the feature name.

## Testing Guidance
- Add focused tests around the feature layers:
  - BLoC/Cubit tests for event-or-command-to-state flow
  - repository tests for DTO-to-app-facing mapping
  - widget tests for page rendering of loading, success, and failure
- Mock the use case for BLoC tests when domain exists; otherwise mock or fake the data repository contract.
- Mock or fake the repository or data source for data tests.

## Drift Policy
- If an existing feature differs from this document, follow the documented convention unless the deviation is intentional and documented.
