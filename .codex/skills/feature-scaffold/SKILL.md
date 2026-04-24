---
name: feature-scaffold
description: Scaffold a new Project Tweety feature using the repo's layered-first Flutter structure across lib/domain, lib/data, and lib/presentation only. Use when adding a new page-backed feature that needs a minimal repository, use case, page, and BLoC scaffold that follows the repo's dotted filename conventions, nested per-feature data/domain folders, Freezed state pattern, Injectable wiring, and low-opinionated bootstrap flow. Do not use for work under lib/features or for design-system-only changes.
---

# Feature Scaffold

Create a new layered feature in one pass instead of treating domain, data, and presentation as separate generation steps.

## Help mode

If the user invokes this skill with `--help`:
- do not scaffold or edit files
- return a short, human-readable help response
- explain what the skill does
- list the required and optional inputs
- mention that a `curl` request can be supplied for the data/API side of the feature
- show one or two example invocations

Start by reading the repo guidance that defines the contract:
- Root `AGENTS.md`
- `lib/AGENTS.md`
- `lib/domain/AGENTS.md`
- `lib/data/AGENTS.md`
- `lib/presentation/pages/AGENTS.md`

If the written guidance and the current source tree disagree, follow the current source tree.
For `lib/domain/` and `lib/data/`, the repo currently nests files by feature or entity name, and the scaffold should match that structure.

Use this skill only for the layered app structure under `lib/domain/`, `lib/data/`, and `lib/presentation/pages/`.
Treat `lib/features/` as explicitly out of scope.

## Inputs

Collect or infer these inputs before scaffolding:
- feature name in snake_case, usually plural for list-style features, such as `cards`
- primary page intent, such as list, detail, preferences, or editor
- initial repository operations that are actually needed now
- optional `curl` request that defines a real API call for the feature
- optional sample response body when the user has one available

Ask a short clarifying question only if the feature name or required operations are ambiguous.

## Workflow

### 1. Inspect existing patterns

Read the closest existing feature before generating files.
Prefer current source examples over historical scripts.

For this repo, use the `cards` flow as the main reference for:
- page and BLoC structure
- Freezed state shape
- use case wiring

### 2. Scaffold the domain layer first

Create the minimum domain files needed for the requested feature:
- repository contract in `lib/domain/repositories/<feature-or-entity>/`
- one or more use cases in `lib/domain/usecases/<feature-or-entity>/`

Follow these rules:
- Use the nested folders already established in the repo, for example `lib/domain/repositories/card/card.repository.dart` and `lib/domain/usecases/card/get_card.usecase.dart`
- Use dotted filenames such as `card.repository.dart` and `get_card.usecase.dart`
- The folder key may be singular even when the file name is plural; mirror the nearest existing pattern for that domain area
- Keep repository contracts intent-based
- Add only the operations needed for the requested feature
- Prefer a payload-free bootstrap method such as `fetchOthers()` when the initial scaffold does not yet model real data
- Skip domain entities until the feature has a concrete payload to represent
- Annotate use cases with `@injectable` when they are consumed through DI

If a `curl` request is supplied:
- derive the repository operation from the API intent instead of using a payload-free bootstrap method
- create a concrete domain entity when the request/response shape justifies one
- let the use case reflect the real operation rather than a placeholder fetch

### 3. Scaffold the data layer second

Create only the matching data files that are justified by the current scope.
For the default first pass, create only the repository implementation in `lib/data/repositories/<feature-or-entity>/`.

Follow these rules:
- Do not create mock datasources or DTOs by default
- Add datasources or DTOs only when the feature has a real source shape or transport model to represent
- Use the nested folders already established in the repo, for example `lib/data/repositories/card/cards.repository_impl.dart`, `lib/data/dtos/card/card.dto.dart`, and `lib/data/datasources/card/card.mock.dart`
- The folder key may be singular even when the file name is plural; mirror the nearest existing pattern for that domain area
- Use `.repository_impl.dart` filenames
- Keep the initial repository implementation minimal, for example a `Future<void>` method that completes successfully
- Annotate datasource and repository implementation for Injectable using the repo's preferred lifecycles

If a `curl` request is supplied:
- route the data-layer scaffolding through the same rules as `$data-scaffold`
- create a datasource by default
- use the extracted method, URL, headers, query params, and request body in that datasource
- create DTOs when the request body or sample response has a real structure
- use the sample response body, when available, to shape DTO mapping and the repository implementation

### 4. Scaffold the presentation layer last

Create the page and BLoC files under `lib/presentation/pages/<feature>/`:
- `<feature>.page.dart`
- `bloc/<feature>.bloc.dart`
- `bloc/<feature>.event.dart`
- `bloc/<feature>.state.dart`

Follow these rules:
- Use one feature-scoped BLoC per page unless the task says otherwise
- Prefer a small event set; start with a bootstrap event such as `<Feature>Started`
- Name the page widget `<Feature>Page`, for example `CardsPage`
- Use a single Freezed state with a feature-scoped status enum and no payload fields by default
- Keep the initial state unopinionated: status plus optional error message is usually enough
- Let the initial BLoC flow emit `loading` and then `success` without attaching domain data
- Add derived getters only when they improve rendering clarity
- Resolve the BLoC with `GetIt.I<YourBloc>()`
- Trigger initial loading during provider creation when the page owns the BLoC lifecycle
- Keep the app bar minimal; do not add trailing actions, refresh icons, or custom app bar controls in the default scaffold
- Render the initial success UI as `Center(child: Text('<feature>'))` using the feature name
- Do not scaffold list rendering, item cards, or placeholder domain data until the user asks for real content

### 5. Keep the scaffold intentionally minimal

Do not over-generate.
Avoid adding:
- entities, DTOs, or datasources when there is no concrete data shape yet
- extra CRUD use cases that are not required yet
- navigation wiring in `main.dart` unless the user asked for end-to-end integration
- localization keys unless labels or tabs are part of the requested scope
- widget extraction that is not needed for clarity
- placeholder collections or card-style UI copied from `cards`
- tests if the task is explicitly scaffold-only and the user does not want them yet

### 6. Finish the scaffold cleanly

After creating source files:
- regenerate code only if Injectable annotations or Freezed types changed
- regenerate localization only if ARB inputs changed
- run targeted tests first when tests are part of the task
- summarize any intentionally unimplemented methods or follow-up integration steps
- if a `curl` request was used, summarize which data-layer pieces were derived from it and whether a sample response body was available

## File Contract

Use [layered_scaffold.md](references/layered_scaffold.md) for the expected file matrix, naming rules, and recommended defaults for a new layered feature.

## Replacement Guidance

Prefer this skill over the legacy shell generators in `tools/android_studio_templates/`.
Those scripts encode older filename patterns and split generation by layer.
This skill should synthesize the whole scaffold directly from the repo's current conventions and the specific user request.
