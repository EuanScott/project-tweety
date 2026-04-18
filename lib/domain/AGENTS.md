# AGENTS.md

## Scope
- This file applies to everything under `lib/domain/`.
- It builds on the human-readable guidance in `readme.md` and turns it into implementation rules for future work.

## Purpose
- The domain layer defines the app’s business-facing contracts and concepts.
- Domain code should remain independent from presentation and data implementation details.
- This layer should contain the concepts the rest of the app is built around:
  - entities
  - repository contracts
  - use cases

## Directory Responsibilities
- `entities/`
  - Use for business objects such as `Card`.
  - Entities should model app concepts, not transport formats.
  - Prefer filenames such as `card.entity.dart`.
- `repositories/`
  - Use for abstract contracts that the data layer implements.
  - Repository contracts define what the app needs, not how it is fetched.
  - Prefer filenames such as `cards.repository.dart`.
- `usecases/`
  - Use for focused operations that the presentation layer can invoke.
  - Use cases should depend on repository contracts, not repository implementations.
  - Prefer filenames such as `get_cards.usecase.dart`, `create_card.usecase.dart`, `update_card.usecase.dart`, and `delete_card.usecase.dart`.

## Entity Conventions
- Keep entities lightweight and framework-light.
- Prefer immutable entities with clear constructor requirements.
- Entities should not know about DTOs, services, widgets, or data sources.
- Entity filenames should use `.entity.dart`.
- Avoid adding presentation-specific formatting or rendering helpers to domain entities.

## Repository Contract Conventions
- Repository contracts should expose intent-based operations.
- Prefer names that describe the app need, for example `getOrders()` or `saveProfile()`.
- Keep repository interfaces small and cohesive.
- Repository contracts belong in the domain layer even though implementations live in the data layer.
- Repository filenames should use `.repository.dart`.

## Use Case Conventions
- Prefer one use case per focused operation.
- Use cases should wrap repository calls and represent a clear action the app can perform.
- Presentation-layer BLoCs should depend on use cases rather than repository implementations.
- Annotate use cases with `@injectable` when they should be resolved through DI.
- Use cases may expose `call()` for simple ergonomics when appropriate.
- Use case filenames should use `.usecase.dart`.

## Naming Guidance
- Use plural feature names for feature-level files such as repositories and list-oriented use cases.
- Use singular or domain-specific entity names for business objects and DTO partners.
- Prefer names such as:
  - `card.entity.dart`
  - `cards.repository.dart`
  - `get_cards.usecase.dart`
  - `create_card.usecase.dart`
  - `update_card.usecase.dart`
  - `delete_card.usecase.dart`

## Boundaries
- Do not import data-layer DTOs, data sources, or repository implementations into `lib/domain/`.
- Do not place widget logic, BLoC logic, or UI concerns in the domain layer.
- Keep platform, transport, and persistence details out of domain code.

## Dependency Injection
- Domain contracts themselves do not need injectable annotations.
- Use cases may be injectable because they are constructed and consumed by higher layers.
- If injectable annotations change, regenerate outputs with:
  - `dart run build_runner build --delete-conflicting-outputs`

## Testing Guidance
- Prefer focused unit tests for use cases.
- Mock repository contracts when testing use cases.
- Test domain logic in isolation from UI and data transport concerns.

## Example
- Example names for these conventions:
  - `Card`
  - `CardsRepository`
  - `GetCardsUseCase`
- Use the naming convention above for new domain files even where older files still use legacy names.
- If an existing domain feature differs from this document, follow the documented convention unless the deviation is intentional and documented.
