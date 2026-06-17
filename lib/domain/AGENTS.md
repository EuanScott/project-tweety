# AGENTS.md

## Scope
- This file applies to everything under `lib/domain/`.
- It builds on the human-readable guidance in `readme.md` and turns it into implementation rules for future work.

## Purpose
- The domain layer is optional. Do not add it to a feature by default.
- Assume the BFF handles mobile-specific shaping and common business logic for ordinary app flows.
- Add domain only when the mobile app owns meaningful policy, orchestration, stateful app concepts, or custom behavior that would otherwise leak into presentation or data.
- Domain code should remain independent from presentation and data implementation details.
- When justified, this layer should contain the mobile-owned concepts the rest of that feature is built around:
  - entities
  - repository contracts
  - use cases

## Skill Hints
- Users can add domain files directly. `$domain-scaffold` is an optional helper only when the feature has a justified domain need.
- Do not mirror `_template` into `lib/domain`; `_template` intentionally has no domain layer.
- Skip domain entirely until the feature has mobile-owned behavior that needs it.
- Prefer `$domain-scaffold` for new or updated entities, repository contracts, and use cases.
- If the task spans more than domain, prefer `$feature-scaffold` for a full feature only when domain is justified; otherwise use data and page scaffolding without domain.
- If the user wants usage examples or expected inputs, run `$domain-scaffold --help`.

## Directory Responsibilities
- `entities/`
  - Use for concrete mobile-owned business objects when a feature has a domain payload.
  - Entities should model app concepts, not transport formats.
  - Prefer filenames such as `<entity>.entity.dart`.
- `repositories/`
  - Use for abstract contracts that the data layer implements.
  - Repository contracts define what the domain needs, not how it is fetched.
  - Prefer filenames such as `<feature>.repository.dart`.
- `usecases/`
  - Use for focused operations that the presentation layer can invoke.
  - Use cases should depend on repository contracts, not repository implementations.
  - Prefer filenames such as `<action>_<feature>.usecase.dart`.

## Entity Conventions
- Keep entities lightweight and framework-light.
- Prefer immutable entities with clear constructor requirements.
- Entities should not know about DTOs, services, widgets, or data sources.
- Entity filenames should use `.entity.dart`.
- Avoid adding presentation-specific formatting or rendering helpers to domain entities.

## Repository Contract Conventions
- Repository contracts should expose intent-based operations.
- Prefer names that describe the mobile-owned domain need.
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
  - `<entity>.entity.dart`
  - `<feature>.repository.dart`
  - `<action>_<feature>.usecase.dart`

## Boundaries
- Do not import data-layer DTOs, data sources, or repository implementations into `lib/domain/`.
- Do not place widget logic, BLoC logic, or UI concerns in the domain layer.
- Keep platform, transport, and persistence details out of domain code.
- Do not add domain as a pass-through wrapper around BFF-shaped data.

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
- No raw domain scaffold exists by default. Introduce domain only for a specific feature decision and document why the mobile app owns that behavior.
- Use the naming convention above for new domain files even where older files still use legacy names.
- If an existing domain feature differs from this document, follow the documented convention unless the deviation is intentional and documented.
