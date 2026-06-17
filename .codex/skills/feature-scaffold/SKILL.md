---
name: feature-scaffold
description: Scaffold a new Project Tweety feature using the repo's default BFF-backed layered architecture with optional domain across lib/data and lib/presentation, adding lib/domain only when mobile-owned behavior justifies it. Use when adding a new page-backed feature that needs a minimal repository, page, and BLoC or Cubit scaffold that follows the repo's dotted filename conventions, nested per-feature folders, Freezed state pattern, Injectable wiring, and low-opinionated bootstrap flow. Do not use for work under lib/features or for design-system-only changes.
---

# Feature Scaffold

Create a new feature in one pass instead of treating data and presentation as separate generation steps.
The default architecture is BFF-backed layered architecture with optional domain.
Assume the BFF handles mobile-specific shaping and common business logic.
Do not add `lib/domain` unless the feature has mobile-owned policy, orchestration, stateful app concepts, or custom behavior that would otherwise leak into presentation or data.

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
For `lib/data/` and optional `lib/domain/`, the repo currently nests files by feature or entity name, and the scaffold should match that structure.

Use this skill only for the app structure under `lib/data/`, `lib/presentation/pages/`, and justified optional `lib/domain/`.
Treat `lib/features/` as explicitly out of scope.

## Inputs

Collect or infer these inputs before scaffolding:
- feature name in snake_case, usually plural for list-style features
- primary page intent, such as list, detail, preferences, or editor
- initial repository operations that are actually needed now
- whether the feature needs a domain layer, and the specific mobile-owned behavior that justifies it
- optional `curl` request that defines a real API call for the feature
- optional sample response body when the user has one available

Ask a short clarifying question only if the feature name or required operations are ambiguous.

## Workflow

### 1. Inspect existing patterns

Read `_template` before generating files.
Prefer current source examples over historical scripts.

For this repo, use `_template` as the source of truth for:
- page and BLoC structure
- Freezed state shape
- data repository contract and implementation wiring

### 2. Decide whether domain is required

Skip domain by default.
Create domain files only when the feature has mobile-owned behavior that should not live in the BFF, data layer, or BLoC.
Valid examples include settings-style local app policy, non-trivial client-side orchestration, durable app-owned entities, or feature rules that must be tested independently from transport and UI.

When domain is justified, create only the minimum domain files needed:
- repository contract in `lib/domain/repositories/<feature-or-entity>/`
- one or more use cases in `lib/domain/usecases/<feature-or-entity>/`

Follow these rules:
- Use the nested folders already established in the repo, for example `lib/domain/repositories/<feature>/<feature>.repository.dart` and `lib/domain/usecases/<feature>/<action>_<feature>.usecase.dart`
- Use dotted filenames such as `<feature>.repository.dart` and `<action>_<feature>.usecase.dart`
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

### 3. Scaffold the data layer

Create only the matching data files that are justified by the current scope.
For the default first pass, create the repository contract and repository implementation in `lib/data/repositories/<feature-or-entity>/`.

Follow these rules:
- Do not create mock datasources or DTOs by default
- Add datasources or DTOs only when the feature has a real source shape or transport model to represent
- Use the nested folders already established in the repo, for example `lib/data/repositories/<feature>/<feature>.repository.dart`, `lib/data/repositories/<feature>/<feature>.repository_impl.dart`, `lib/data/dtos/<entity>/<entity>.dto.dart`, and `lib/data/datasources/<feature>/<source>_<feature>.datasource.dart`
- The folder key may be singular even when the file name is plural; mirror the nearest existing pattern for that domain area
- Use `.repository_impl.dart` filenames
- Keep the initial repository implementation minimal, for example a `Future<void>` method that completes successfully
- Annotate datasource and repository implementation for Injectable using the repo's preferred lifecycles
- If optional domain exists, the data implementation may implement the domain repository contract instead of a data-layer contract.

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
- Cubit is allowed instead of BLoC when state changes are simple commands and events add no useful vocabulary
- Prefer a small event set; start with a bootstrap event such as `<Feature>Started`
- Name the page widget `<Feature>Page`
- Use a single Freezed state with a feature-scoped status enum and no payload fields by default
- Keep the initial state unopinionated: status plus optional error message is usually enough
- Let the initial BLoC flow emit `loading` and then `success` without attaching placeholder data
- In the default path, inject the data-layer repository contract directly into the BLoC. If optional domain exists, inject the use case instead.
- Add derived getters only when they improve rendering clarity
- Resolve the BLoC with `GetIt.I<YourBloc>()`
- Trigger initial loading during provider creation when the page owns the BLoC lifecycle
- Keep the app bar minimal; do not add trailing actions, refresh icons, or custom app bar controls in the default scaffold
- Render the initial success UI as `Center(child: Text('<feature>'))` using the feature name
- Do not scaffold list rendering, item rows, or placeholder data until the user asks for real content

### 5. Keep the scaffold intentionally minimal

Do not over-generate.
Avoid adding:
- entities, DTOs, or datasources when there is no concrete data shape yet
- domain files when there is no mobile-owned behavior to justify them
- extra CRUD use cases that are not required yet
- navigation wiring in `main.dart` unless the user asked for end-to-end integration
- localization keys unless labels or tabs are part of the requested scope
- widget extraction that is not needed for clarity
- placeholder collections or copied rich UI from another feature
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
