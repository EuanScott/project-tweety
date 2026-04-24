---
name: page-scaffold
description: Scaffold only the presentation layer for a Project Tweety feature using lib/presentation/pages and an existing domain-facing dependency such as a use case. Use when adding a new page and BLoC flow that should consume existing data or domain work without generating the lower layers again.
---

# Page Scaffold

Scaffold the presentation layer only.
Use this when the work should stay inside `lib/presentation/pages/` and the page should consume existing use cases or other already-available dependencies.

## Help mode

If the user invokes this skill with `--help`:
- do not scaffold or edit files
- return a short, human-readable help response
- explain what the skill does
- list the required and optional inputs
- show one or two example invocations

Start by reading:
- Root `AGENTS.md`
- `lib/AGENTS.md`
- `lib/presentation/pages/AGENTS.md`

If the written guidance and the current source tree disagree, follow the current source tree.

## Inputs

Collect or infer these inputs before scaffolding:
- feature name in snake_case
- page intent, such as list, detail, settings, or preferences
- the existing use case or dependency the BLoC should consume
- whether the initial page should remain payload-free

Ask a short clarifying question only if the feature name, page intent, or dependency target is ambiguous.

## Workflow

### 1. Inspect existing patterns

Read the closest existing page area before generating files.
Prefer current source examples over older written guidance.

Use the repo's current page structure as the default:
- `lib/presentation/pages/<feature>/<feature>.page.dart`
- `lib/presentation/pages/<feature>/bloc/<feature>.bloc.dart`
- `lib/presentation/pages/<feature>/bloc/<feature>.event.dart`
- `lib/presentation/pages/<feature>/bloc/<feature>.state.dart`

### 2. Verify the dependency target

Before creating the page and BLoC, verify the dependency the BLoC should consume already exists.
Prefer an existing use case from `lib/domain/usecases/`.

If the dependency is missing:
- explain the missing prerequisite plainly
- do not invent lower-layer behavior silently
- either ask the user whether to create the lower layer first, or tell them to use the appropriate layer skill if the scope is clearly presentation-only

### 3. Create the page

Create the page in:
- `lib/presentation/pages/<feature>/<feature>.page.dart`

Follow these rules:
- name the page widget `<Feature>Page`
- keep the app bar minimal with just the title
- use `BlocProvider(create: ...)` when the page owns the BLoC
- resolve DI-backed BLoCs with `GetIt.I<YourBloc>()`

### 4. Create the BLoC files

Create the BLoC files in:
- `lib/presentation/pages/<feature>/bloc/`

Follow these rules:
- prefer a small event set starting with `<Feature>Started`
- use a single Freezed state with a feature-scoped status enum
- keep the default scaffold payload-free unless the page is explicitly consuming real data
- let the initial flow emit `loading` and then `success` without attaching placeholder domain data
- add derived getters only when they improve rendering clarity

### 5. Keep the scaffold intentionally minimal

Do not over-generate.
Avoid adding:
- domain-layer files
- data-layer files
- navigation wiring unless explicitly requested
- localization keys unless explicitly requested
- list cards or placeholder item UIs copied from other features

### 6. Finish cleanly

After creating source files:
- regenerate code only if Freezed or Injectable inputs changed
- run targeted tests first when tests are part of the task
- summarize any missing upstream dependency that prevented a fuller scaffold

## File Contract

Use [page_contract.md](references/page_contract.md) for the expected page/BLoC files, default widget shape, and dependency prerequisites.
