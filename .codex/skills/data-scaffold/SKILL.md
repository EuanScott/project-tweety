---
name: data-scaffold
description: Scaffold only the data layer for a Project Tweety feature using the repo's nested lib/data folders. Use when implementing repository contracts, repository implementations, datasources, or DTOs for an existing feature. Add or depend on domain only when mobile-owned behavior justifies it.
---

# Data Scaffold

Scaffold the data layer only.
Use this when the work should stay inside `lib/data/`, or when the user is implementing storage, transport, or repository orchestration for an existing feature.

## Help mode

If the user invokes this skill with `--help`:
- do not scaffold or edit files
- return a short, human-readable help response
- explain what the skill does
- list the required and optional inputs
- mention that a `curl` request can be supplied to define the API call shape
- show one or two example invocations

Start by reading:
- Root `AGENTS.md`
- `lib/AGENTS.md`
- `lib/domain/AGENTS.md`
- `lib/data/AGENTS.md`

If the written guidance and the current source tree disagree, follow the current source tree.
For `lib/data/` and optional `lib/domain/`, the repo currently nests files by feature or entity name, and the scaffold should match that structure.

## Inputs

Collect or infer these inputs before scaffolding:
- feature name in snake_case
- folder key, usually the nearest existing feature or entity name
- whether the data layer needs a repository contract, repository implementation, datasources, and DTOs
- whether the work is bootstrap-only or already has a concrete data shape
- whether optional domain already exists or is justified by mobile-owned behavior
- optional `curl` request that defines the API call to implement
- optional sample response body when the user has one available

Ask a short clarifying question only if the feature name, folder key, or required data pieces are ambiguous.

## Workflow

### 1. Inspect existing patterns

Read `_template` and the closest existing data area before generating files.
Prefer current source examples over older written guidance.

Use the current repo as the reference for nested paths such as:
- `lib/data/repositories/<feature>/<feature>.repository.dart`
- `lib/data/repositories/<feature>/<feature>.repository_impl.dart`
- `lib/data/dtos/<entity>/<entity>.dto.dart`
- `lib/data/datasources/<feature>/<source>_<feature>.datasource.dart`

### 1a. Parse a supplied curl request when present

If the user provides a `curl` request:
- treat it as the source of truth for the transport shape
- extract the HTTP method, URL, headers, query params, and request body
- preserve the request semantics unless the user explicitly asks to adapt them
- use any supplied sample response body to shape DTOs and response mapping

If a `curl` request is present, the work is no longer bootstrap-only by default.
Treat it as concrete transport work.

### 2. Decide whether domain prerequisites apply

Do not require domain for normal data scaffolding.
By default, create or use a data-layer repository contract under:
- `lib/data/repositories/<folder-key>/<feature>.repository.dart`

If optional domain is justified or already exists, verify the matching domain contract under:
- `lib/domain/repositories/<folder-key>/`

If optional domain depends on entities, verify those too under:
- `lib/domain/entities/<entity>/`

If optional domain prerequisites are missing, route through `$domain-scaffold` only after stating why mobile-owned domain behavior is required.

### 3. Create the repository implementation

Create the repository contract and implementation in:
- `lib/data/repositories/<folder-key>/<feature>.repository.dart`
- `lib/data/repositories/<folder-key>/<feature>.repository_impl.dart`

Follow these rules:
- implement the data-layer repository contract by default
- implement a domain repository contract only when optional domain exists
- keep bootstrap implementations minimal when there is no real payload yet
- annotate the repository implementation with `@LazySingleton(as: ContractType)` unless a different lifecycle is justified

If a `curl` request is present:
- implement the repository around the concrete datasource call instead of a payload-free stub
- preserve the API intent in the repository contract while mapping raw transport details in the data layer

### 4. Add datasources and DTOs only when justified

Create these only when the feature has a real source shape or transport model:
- `lib/data/datasources/<folder-key>/`
- `lib/data/dtos/<entity>/`

Follow these rules:
- do not create mock datasources or DTOs by default
- keep datasources close to source shape
- keep DTOs responsible for mapping and serialization concerns
- keep repository implementations responsible for orchestration

If a `curl` request is present:
- create a datasource by default
- use the extracted URL, HTTP method, headers, and request body shape in that datasource
- create DTOs when the request body or sample response has a concrete structure worth modelling
- if a sample response body is available, use it to shape the DTO and repository mapping
- if no sample response is available, keep the response handling conservative and document any assumptions in the final summary

### 5. Keep the scaffold intentionally minimal

Do not over-generate.
Avoid adding:
- presentation-layer files
- domain-layer files unless mobile-owned behavior justifies them
- datasources or DTOs when the repository implementation can stay payload-free
- extra storage or network abstractions that have no current consumer

### 6. Finish cleanly

After creating source files:
- regenerate code only if Injectable annotations changed
- run targeted tests first when tests are part of the task
- summarize whether optional domain was intentionally skipped or added
- if a `curl` request was used, summarize which request details were implemented from it and whether a sample response body was available

## File Contract

Use [data_contract.md](references/data_contract.md) for the expected nested paths and optional-domain rules.
