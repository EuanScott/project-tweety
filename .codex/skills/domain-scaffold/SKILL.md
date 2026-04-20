---
name: domain-scaffold
description: Scaffold only the domain layer for a Project Tweety feature using the repo's nested lib/domain folders. Use when adding or updating repository contracts, use cases, or domain entities without touching data or presentation, or when another layer depends on domain files that do not exist yet.
---

# Domain Scaffold

Scaffold the domain layer only.
Use this when the work should stay inside `lib/domain/` and the data or presentation layers either already exist or are intentionally out of scope.

Start by reading:
- Root `AGENTS.md`
- `lib/AGENTS.md`
- `lib/domain/AGENTS.md`

If the written guidance and the current source tree disagree, follow the current source tree.
For `lib/domain/`, the repo currently nests files by feature or entity name, and the scaffold should match that structure.

## Inputs

Collect or infer these inputs before scaffolding:
- feature name in snake_case
- domain folder key, usually the nearest existing singular business name
- required repository operations
- whether a concrete entity is needed now

Ask a short clarifying question only if the feature name, folder key, or required operations are ambiguous.

## Workflow

### 1. Inspect existing patterns

Read the closest existing domain area before generating files.
Prefer current source examples over older written guidance.

Use the current repo as the reference for nested paths such as:
- `lib/domain/repositories/card/card.repository.dart`
- `lib/domain/usecases/card/get_card.usecase.dart`
- `lib/domain/entities/card/card.entity.dart`

### 2. Create the repository contract

Create the repository contract in:
- `lib/domain/repositories/<folder-key>/<feature>.repository.dart`

Follow these rules:
- use dotted filenames
- keep the interface intent-based and cohesive
- add only the methods the requested scope needs now
- keep the contract independent from data-layer types

### 3. Create the use cases

Create one or more use cases in:
- `lib/domain/usecases/<folder-key>/`

Follow these rules:
- prefer one use case per focused operation
- annotate use cases with `@injectable` when they will be resolved through DI
- keep them thin wrappers around the repository contract
- use `call()` when that matches nearby patterns

### 4. Create entities only when justified

Create entities in:
- `lib/domain/entities/<entity>/<entity>.entity.dart`

Do not create an entity by default if the feature is still in a payload-free bootstrap stage.
Add the entity only when there is a real domain shape to model.

### 5. Keep the scaffold intentionally minimal

Do not over-generate.
Avoid adding:
- data-layer files
- presentation-layer files
- CRUD use cases that are not required yet
- extra entities that have no current consumer

### 6. Finish cleanly

After creating source files:
- regenerate code only if Injectable annotations changed
- run targeted tests first when tests are part of the task
- summarize any intentionally deferred entity or use case work

## File Contract

Use [domain_contract.md](references/domain_contract.md) for the expected nested paths, naming rules, and default scope for a domain-only scaffold.
