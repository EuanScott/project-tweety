---
name: page-scaffold
description: "Scaffold a Project Tweety page and state management against an existing contract or use case. Use only for presentation-layer work, not shared widgets."
---

# Page Scaffold

## Required inputs

Collect:

- `feature_name` in snake_case;
- `page_intent` and initial user-visible behavior;
- `dependency`: the exact existing data contract, domain use case, or other lower-layer API;
- `controller`: default `bloc`; accept `cubit` only when the user explicitly requests it;
- the initial operation and whether a real payload already exists.

Ask only for required information that repository inspection cannot resolve.

## Workflow

### 1. Establish authority and preflight targets

Apply sources in this order: user request, applicable `AGENTS.md`, `lib/presentation/pages/_template/`, then the nearest page implementation only for uncovered details. Read root, `lib`, and page guidance. Use `_template` only for the default BLoC path.

List every proposed target. Stop if any target already exists unless the user explicitly requests an update. Keep all new artifacts under `lib/presentation/pages/<feature_name>/`.

**Gate:** Confirm complete inputs, the selected controller, an in-scope target list, and zero unapproved overwrites.

### 2. Verify the dependency

Resolve the named dependency to an existing source file and inspect its callable API. Prefer a data repository contract on the default BFF-backed path; prefer a use case when justified domain already exists. Do not depend on repository implementations or DTOs.

If the dependency is missing, stop without editing and direct the work to `$feature-scaffold`, `$data-scaffold`, or `$domain-scaffold` according to the missing layer.

**Gate:** Confirm the exact dependency symbol, source path, operation, return type, and DI availability.

### 3. Select the exact manifest

Use BLoC unless the user explicitly selected Cubit. Create the BLoC manifest:

- `lib/presentation/pages/<feature_name>/<feature_name>.page.dart`
- `lib/presentation/pages/<feature_name>/bloc/<feature_name>.bloc.dart`
- `lib/presentation/pages/<feature_name>/bloc/<feature_name>.event.dart`
- `lib/presentation/pages/<feature_name>/bloc/<feature_name>.state.dart`

For an explicit Cubit request, read [the Cubit variant](references/cubit_variant.md) and create only its stated manifest. Do not describe `_template` as a Cubit template.

**Gate:** Confirm the planned files match exactly one controller variant and include no lower-layer artifact.

### 4. Specify and create the page flow

Before production changes, add a focused BLoC/Cubit or widget test for the
initial operation, observable states, and first user-visible result. Run it and
confirm the expected missing-flow failure.

Mirror the BLoC `_template` for provider ownership, `GetIt.I`, Freezed state, feature-scoped status, loading/success/failure handling, and small explicit events. Keep the initial state payload-free unless the existing dependency returns data required by `page_intent`.

Use app/design-system primitives for visible controls and feedback when available. Keep business policy in the existing dependency or controller orchestration, not the widget tree. Add navigation or localization only when explicitly included in the request and target manifest.

**Gate:** Confirm the page calls the verified dependency, handles its observable states, renders app-facing values rather than DTOs, and owns no lower-layer behavior.

### 5. Verify completion

Format changed Dart files. Regenerate only when Freezed, Injectable, or localization inputs changed. Rerun the targeted tests, then analysis and proportionate broader tests.

**Gate:** Apply [the shared scaffold completion gate](../references/scaffold_completion.md) to the selected presentation manifest.
