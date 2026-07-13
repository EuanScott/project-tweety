# AGENTS.md

## Scope

This guidance applies to everything under `lib/domain/` and supplements the
root and `lib/` guidance.

## Source of truth and routing

- Domain is optional. Do not add it to a feature by default.
- Read `lib/domain/_template/README.md` for the canonical domain structure
  whenever domain work is justified.
- Prefer `$domain-scaffold` for domain-only work and `$feature-scaffold` for a
  full feature with a justified domain branch.

## Domain gate

Add domain only for meaningful mobile-owned policy, decisions, orchestration,
stateful app concepts, or custom behavior that would otherwise leak into data
or presentation. A repository pass-through does not justify domain.

## Responsibilities and boundaries

- Entities are immutable, framework-light mobile-owned concepts.
- Repository contracts express domain intent; data provides implementations.
- Use cases own the policy or orchestration that justified the layer and expose
  focused operations.
- Domain must not depend on DTOs, datasources, repository implementations,
  transport, persistence, widgets, or BLoCs.
- Add entities only when a real domain payload has a current consumer.
- Use `@injectable` only for domain objects constructed through DI; contracts do
  not need annotations.

## Verification

- Keep repository contracts cohesive and use cases intent-based.
- Test each policy rule through the use-case contract with a fake or mock
  repository.
- Regenerate Injectable output after annotation changes with:
  `dart run build_runner build --delete-conflicting-outputs`.
