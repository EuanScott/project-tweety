# AGENTS.md

## Scope
- This file applies to everything under `lib/data/`.
- It builds on the human-readable guidance in `data.md` and turns it into implementation rules for future work.

## Purpose
- The data layer is responsible for retrieving, shaping, and returning data for the rest of the app.
- This layer implements repository contracts defined in the domain layer.
- Data-layer code may depend on data sources, DTOs, services, and domain contracts, but domain logic should not live here.

## Directory Responsibilities
- `datasources/`
  - Use for raw data access such as mock providers, API clients, local storage adapters, or cache readers.
  - Data sources should describe where the data comes from, for example `MockCardsDataSource`.
- `dtos/`
  - Use for transferred or raw data objects.
  - Prefer the `Dto` suffix over `Model`.
  - DTOs may provide mapping helpers such as `toEntity()`.
- `repositories/`
  - Use for concrete repository implementations that fulfill domain repository contracts.
  - Repositories coordinate data sources and map DTOs into domain entities.
- `services/`
  - Use for shared infrastructure helpers that speak to external systems, such as HTTP services.
- `constants/`
  - Use for data-layer constants such as endpoint paths or request-related values.

## DTO Conventions
- Prefer `Dto` naming, for example `CardItemDto`.
- DTOs represent raw or transferred data, not app-level business objects.
- DTOs may include:
  - serialization and deserialization helpers
  - mapping helpers like `toEntity()`
- DTOs should not contain UI logic or presentation concerns.
- Prefer keeping DTOs immutable.

## Data Source Conventions
- Data sources should expose raw fetch/save operations and stay close to the underlying source shape.
- Mock data sources are acceptable and encouraged while API work is not yet in place.
- Prefer names that make the source obvious:
  - `MockCardsDataSource`
  - `CardsRemoteDataSource`
  - `CardsLocalDataSource`
- Data sources should not return widgets or presentation-specific types.

## Repository Implementation Conventions
- Repository implementations should live in `repositories/` and end with `_impl.dart` when that fits the existing naming style.
- Repositories should implement contracts from `lib/domain/repositories/`.
- Repositories should map DTOs into domain entities before returning values to the domain layer.
- Repositories should hide datasource and transport details from callers.
- Repositories may combine multiple data sources when required, but should stay focused on data orchestration rather than business policy.

## Dependency Injection
- Prefer `@LazySingleton(as: ContractType)` for repository implementations unless the feature needs a different lifecycle.
- Prefer `@lazySingleton` for data sources unless there is a reason to create new instances repeatedly.
- If injectable annotations change, regenerate outputs with:
  - `dart run build_runner build --delete-conflicting-outputs`

## Boundaries
- Do not import presentation-layer files into `lib/data/`.
- Do not return DTOs outside the data layer when the domain layer should consume entities instead.
- Do not place app-specific business rules here if they belong in the domain layer.

## Testing Guidance
- Test DTO mapping behavior where it adds value.
- Test repository implementations for:
  - DTO-to-entity mapping
  - data-source coordination
  - expected behavior for mock and future remote sources
- Prefer fakes or mocks for data sources when testing repositories.

## Reference Implementation
- Use the `cards` feature as the current reference:
  - `MockCardsDataSource`
  - `CardItemDto`
  - `CardsRepositoryImpl`
