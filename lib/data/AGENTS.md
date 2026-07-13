# AGENTS.md

## Scope

This guidance applies to everything under `lib/data/` and supplements the root
and `lib/` guidance.

## Source of truth and routing

- Use `lib/data/repositories/_template/` for the baseline repository shape.
- Prefer `$data-scaffold` for repository, datasource, DTO, and transport work.
- Use the nearest existing implementation only for details not represented by
  the template or this guidance.
- Do not add a datasource or DTO without a concrete source, payload, or mapping
  boundary.

## Responsibilities and boundaries

- Data retrieves, coordinates, and shapes external or persisted data.
- Datasources expose raw source operations and stay close to source shape.
- DTOs represent transport or persistence shapes and remain inside data.
- Repositories hide transport details and return app-facing repository values
  unless implementing a justified domain contract.
- Repository implementations may orchestrate data sources but must not own
  mobile business policy.
- Data must not import presentation or return DTOs to presentation.
- Add domain only when mobile-owned policy or orchestration requires it; do not
  create a pass-through domain layer.

## Mapping

- Use `toValue()` for no-domain repository values and `toEntity()` only for
  justified domain entities.
- Keep repository contracts narrow and place them under
  `lib/data/repositories/<feature>/` unless the domain owns the contract.

## DI and verification

- Prefer `@LazySingleton(as: ContractType)` for repository implementations and
  `@lazySingleton` for data sources unless lifecycle needs differ.
- Test mapping, data-source coordination, and repository behavior at the
  repository contract boundary.
- Regenerate Injectable output after annotation changes with:
  `dart run build_runner build --delete-conflicting-outputs`.
