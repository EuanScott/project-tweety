---
name: data-scaffold
description: Scaffold only the data layer for a Project Tweety feature using the repo's nested lib/data folders and existing domain contracts. Use when implementing repository implementations, datasources, or DTOs for an existing feature. If the matching domain layer is missing, route through $domain-scaffold first in the same flow unless the user explicitly restricts the task to data-only.
---

# Data Scaffold

Scaffold the data layer only.
Use this when the work should stay inside `lib/data/`, or when the user is implementing storage, transport, or repository orchestration for an existing feature.

Start by reading:
- Root `AGENTS.md`
- `lib/AGENTS.md`
- `lib/domain/AGENTS.md`
- `lib/data/AGENTS.md`

If the written guidance and the current source tree disagree, follow the current source tree.
For `lib/data/` and `lib/domain/`, the repo currently nests files by feature or entity name, and the scaffold should match that structure.

## Inputs

Collect or infer these inputs before scaffolding:
- feature name in snake_case
- folder key, usually the nearest existing singular business name
- whether the data layer needs only a repository implementation or also datasources and DTOs
- whether the work is bootstrap-only or already has a concrete data shape

Ask a short clarifying question only if the feature name, folder key, or required data pieces are ambiguous.

## Workflow

### 1. Inspect existing patterns

Read the closest existing domain and data areas before generating files.
Prefer current source examples over older written guidance.

Use the current repo as the reference for nested paths such as:
- `lib/domain/repositories/card/card.repository.dart`
- `lib/data/repositories/card/cards.repository_impl.dart`
- `lib/data/dtos/card/card.dto.dart`
- `lib/data/datasources/card/card.mock.dart`

### 2. Verify domain prerequisites first

Before creating data files, verify that the matching domain contract already exists.
At minimum, look for the repository contract under:
- `lib/domain/repositories/<folder-key>/`

If the planned data work depends on entities, verify those too under:
- `lib/domain/entities/<entity>/`

If the domain prerequisites are missing:
- explain the dependency in plain language
- tell the user what is missing
- invoke `$domain-scaffold` to create the minimal domain prerequisites first in the same flow unless the user explicitly restricted scope to data-only
- after the domain files exist, continue with the data scaffold

Use clear messages such as:
- `The data layer depends on a domain repository contract first. I’ll use $domain-scaffold to create that minimal domain layer, then continue with the data layer.`
- `The requested data scaffold needs a domain entity that does not exist yet. I’ll route through $domain-scaffold for that prerequisite, then return to data.`

If the user explicitly restricted the task to data-only, stop and report the missing prerequisite instead of silently expanding scope.

### 3. Create the repository implementation

Create the repository implementation in:
- `lib/data/repositories/<folder-key>/<feature>.repository_impl.dart`

Follow these rules:
- implement the matching domain repository contract
- keep bootstrap implementations minimal when there is no real payload yet
- annotate the repository implementation with `@LazySingleton(as: ContractType)` unless a different lifecycle is justified

### 4. Add datasources and DTOs only when justified

Create these only when the feature has a real source shape or transport model:
- `lib/data/datasources/<folder-key>/`
- `lib/data/dtos/<entity>/`

Follow these rules:
- do not create mock datasources or DTOs by default
- keep datasources close to source shape
- keep DTOs responsible for mapping and serialization concerns
- keep repository implementations responsible for orchestration

### 5. Keep the scaffold intentionally minimal

Do not over-generate.
Avoid adding:
- presentation-layer files
- domain-layer files beyond the minimal prerequisites needed to unblock data
- datasources or DTOs when the repository implementation can stay payload-free
- extra storage or network abstractions that have no current consumer

### 6. Finish cleanly

After creating source files:
- regenerate code only if Injectable annotations changed
- run targeted tests first when tests are part of the task
- summarize whether `$domain-scaffold` was used as part of the same flow

## File Contract

Use [data_contract.md](references/data_contract.md) for the expected nested paths, prerequisite checks, and same-flow routing behavior when domain files are missing.
