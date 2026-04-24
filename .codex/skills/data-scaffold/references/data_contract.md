# Data Scaffold Contract

Use this reference when creating only the data layer for a Project Tweety feature.

## Source of Truth

- follow the current source tree when older docs disagree
- `lib/data/` and `lib/domain/` are nested by feature or entity key
- when a `curl` request is supplied, use it as the source of truth for transport details

## Prerequisites

Verify these before scaffolding data:
- repository contract under `lib/domain/repositories/<folder-key>/`
- entity under `lib/domain/entities/<entity>/` only when the data layer needs a real payload

## Default Paths

- repository implementation: `lib/data/repositories/<folder-key>/<feature>.repository_impl.dart`
- datasource when needed: `lib/data/datasources/<folder-key>/<source>.datasource.dart`
- DTO when needed: `lib/data/dtos/<entity>/<entity>.dto.dart`

## Same-Flow Routing

If domain prerequisites are missing and the user did not restrict scope to data-only:
- explain the missing prerequisite plainly
- route through `$domain-scaffold` to create the minimal domain contract first
- continue with the data scaffold in the same turn

Example human-readable messages:
- `The data layer depends on a domain repository contract first. I’ll use $domain-scaffold to add that, then continue with data.`
- `This data scaffold needs a domain entity first. I’ll route through $domain-scaffold for that prerequisite, then return to the data layer.`

If the user restricted scope to data-only:
- stop and report the missing prerequisite instead of expanding scope

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
