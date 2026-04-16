# AGENTS.md

## Purpose
- This file defines the default pattern for new feature work under `lib/`.
- Use the `cards` feature as the reference implementation for BLoC-driven presentation, DI, and clean architecture layering.

## Feature Structure
- New features should follow the layered structure already used in this repo:
  - `lib/presentation/pages/<feature>/`
  - `lib/presentation/pages/<feature>/bloc/`
  - `lib/domain/entities/`
  - `lib/domain/repositories/`
  - `lib/domain/usecases/`
  - `lib/data/datasources/`
  - `lib/data/dtos/`
  - `lib/data/repositories/`
- Prefer feature names that describe the business or UI intent, not placeholders like `other`, `misc`, or `stuff`.

## BLoC Pattern
- Prefer one Freezed state class per page/feature BLoC instead of many small state subclasses.
- Use a status enum inside the state for lifecycle flow such as `initial`, `loading`, `success`, and `failure`.
- Use Freezed-generated `copyWith`; do not manually implement `copyWith`.
- If you need computed getters on a Freezed state, add `const MyState._();` and place only real derived getters there.
- Never leave manual getters that throw `UnimplementedError()` inside a Freezed state.
- Keep events small and explicit. For simple load flows, a single event such as `CardsStarted` is preferred.
- Keep BLoC logic focused on orchestration: emit loading, call the use case, emit success or failure.

## UI Integration
- Prefer `BlocProvider(create: ...)` when the widget owns the BLoC lifecycle.
- Prefer `BlocProvider.value(...)` only when reusing an existing BLoC instance.
- Prefer `BlocBuilder` for pure rendering.
- Use `BlocConsumer` only when the page needs both rendering and side effects such as snackbars, dialogs, navigation, or analytics hooks.
- For DI-backed page BLoCs, resolve them with `GetIt.I<YourBloc>()`, not the `getIt` helper.
- Trigger initial loading in the provider creation flow, for example: `GetIt.I<CardsBloc>()..add(const CardsStarted())`.

## Naming Conventions
- Use feature-aligned names end-to-end:
  - `Cards`
  - `CardsBloc`
  - `CardsEvent`
  - `CardsState`
  - `CardsStatus`
  - `CardsRepository`
  - `GetCardsUseCase`
  - `MockCardsDataSource`
  - `CardItem`
  - `CardItemDto`
- Keep names consistent across presentation, domain, and data layers.

## Domain Layer
- Domain entities should be framework-light and represent app concepts, for example `CardItem`.
- Repository contracts live in the domain layer and expose intent-based methods, for example `getCards()`.
- Use cases wrap repository operations and provide the entry point the BLoC depends on.
- BLoCs should depend on use cases, not directly on repository implementations or data sources.

## Data Layer
- Data layer objects that represent transferred or raw data should be named `Dto`, not `Model`.
- Data sources should describe where the data comes from, for example `MockCardsDataSource`.
- Repository implementations should map DTOs into domain entities before returning data to the domain layer.
- Keep mock data sources in place until a real API implementation exists; they should still follow the same contract shape as a real data source.

## Injectable and DI
- Annotate BLoCs and use cases with `@injectable` when they should be created as factories.
- Annotate repository implementations with `@LazySingleton(as: ContractType)` when a single shared instance is appropriate.
- Annotate mock or remote data sources with `@lazySingleton` unless the feature has a reason to use a different lifecycle.
- After changing injectable annotations or Freezed types, regenerate outputs with:
  - `dart run build_runner build --delete-conflicting-outputs`

## Localization and Navigation
- When renaming a feature/tab/page, also update:
  - navigation wiring in `main.dart`
  - localization keys in ARB files
  - generated localization output via `flutter gen-l10n`
- Keep tab labels aligned with the feature name.

## Testing Guidance
- Add focused tests around the feature layers:
  - BLoC tests for event-to-state flow
  - repository tests for DTO-to-entity mapping
  - widget tests for page rendering of loading, success, and failure
- Mock the use case for BLoC tests.
- Mock or fake the repository/data source for domain/data tests.

## Cards Reference
- Use the `cards` feature as the working example for this pattern.
- Future BLoC-based pages should mirror its structure unless the task explicitly requires a different architecture.
