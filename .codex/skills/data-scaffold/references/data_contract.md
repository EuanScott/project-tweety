# Data Scaffold Contract

Use this reference when creating only the data layer for a Project Tweety feature.

## Source of Truth

- follow the current source tree when older docs disagree
- `lib/data/` and optional `lib/domain/` are nested by feature or entity key
- when a `curl` request is supplied, use it as the source of truth for transport details

## Prerequisites

Do not require domain before scaffolding data.
Verify optional domain only when mobile-owned behavior justifies it:
- repository contract under `lib/domain/repositories/<folder-key>/`
- entity under `lib/domain/entities/<entity>/` only when optional domain needs a real payload

## Default Paths

- repository contract: `lib/data/repositories/<folder-key>/<feature>.repository.dart`
- repository implementation: `lib/data/repositories/<folder-key>/<feature>.repository_impl.dart`
- datasource when needed: `lib/data/datasources/<folder-key>/<source>.datasource.dart`
- DTO when needed: `lib/data/dtos/<entity>/<entity>.dto.dart`

## Optional Domain Routing

If mobile-owned behavior justifies domain and prerequisites are missing:
- explain the domain need plainly
- route through `$domain-scaffold` to create the minimal domain contract
- continue with the data scaffold in the same turn

If there is no mobile-owned domain behavior, keep the contract in `lib/data/repositories/<folder-key>/`.

## Defaults

- do not create mock datasources or DTOs by default
- keep bootstrap repository implementations payload-free when possible
- use `@LazySingleton(as: ContractType)` for repository implementations unless a different lifecycle is justified

If a `curl` request is supplied:
- create a datasource by default
- preserve the method, URL, headers, query params, and request body semantics from the `curl`
- use a supplied sample response body to shape DTOs and mapping when available
- treat the work as concrete transport scaffolding rather than bootstrap-only stubbing

## Out of Scope

- `lib/presentation/*`
- navigation and localization updates unless explicitly requested
