---
name: feature-scaffold
description: "Scaffold a new Project Tweety page-backed feature across data and presentation, adding domain only for stated mobile-owned policy. Use for whole-feature creation outside lib/features and packages/design_system."
---

# Feature Scaffold

## Required inputs

Collect:

- `feature_name`: a meaningful snake_case name;
- `page_intent`: the page's purpose;
- `initial_load_operation`: one lower_snake read-only bootstrap, starting with
  `load`, `fetch`, `get`, `list`, `read`,
  `watch`, or `refresh`;
- `controller`: default `bloc`; use `cubit` only when explicitly requested;
- `folder_key` when it cannot be safely derived;
- `domain_reason` for domain: a concrete mobile-owned policy or orchestration;
- optional `curl` text and request/response samples for API-backed work.

Ask only for inputs inspection cannot resolve. Reject empty `domain_reason` and
domain without mobile-owned policy before inspection or edits. Offer data plus
presentation only on request.

## Workflow

### 1. Establish authority and preflight targets

Apply user request, applicable `AGENTS.md`, the selected layer's `_template`,
then one nearest implementation for gaps. Read selected-layer guidance. Use the tool for
supported no-domain baselines; inspect templates only for unsupported work.

Reject targets under `lib/features/` or `packages/design_system`. List targets;
stop on existing paths unless an update was explicitly requested.

**Gate:** Proceed only with complete inputs, authoritative sources, scoped targets, and no unapproved overwrite.

### 2. Select one artifact manifest

Use the no-domain manifest by default:

- `lib/data/repositories/<folder_key>/<feature_name>.repository.dart`
- `lib/data/repositories/<folder_key>/<feature_name>.repository_impl.dart`
- `lib/presentation/pages/<feature_name>/<feature_name>.page.dart`
- `lib/presentation/pages/<feature_name>/widgets/<feature_name>_view.widget.dart`
- `lib/presentation/pages/<feature_name>/bloc/<feature_name>.bloc.dart`
- `lib/presentation/pages/<feature_name>/bloc/<feature_name>.event.dart`
- `lib/presentation/pages/<feature_name>/bloc/<feature_name>.state.dart`

Use the domain manifest only when `domain_reason` identifies real mobile-owned policy:

- `lib/domain/repositories/<folder_key>/<feature_name>.repository.dart`
- one or more policy-bearing `lib/domain/usecases/<folder_key>/<action>_<feature_name>.usecase.dart`
- `lib/domain/entities/<folder_key>/<entity>.entity.dart` only for a real domain payload
- `lib/data/repositories/<folder_key>/<feature_name>.repository_impl.dart`
- the same presentation manifest, depending on the use case instead of the repository

On the domain path, read `lib/domain/_template/README.md`, keep the contract in
domain, and reject pass-through use cases. Add a datasource or DTO only for a
concrete boundary.

**Gate:** Record exactly one baseline manifest and justify every conditional entity, DTO, datasource, or extra use case.

For a no-domain baseline with one initial load, render the manifest first:

```sh
dart run tool/skills/scaffold.dart --feature <feature_name> \
  --layers data,presentation \
  --initial-load-operation <read_only_operation> \
  --controller <bloc|cubit> --dry-run
```

Add `--folder-key` only when needed. Review the JSON and targets; hold `--write`
until step 4. The tool refuses overwrites, atomically replaces each reserved
target from a staged file, and rolls back its reserved targets on caught
failures; it is not crash-atomic across the multi-directory manifest. Domain
uses `$domain-scaffold` and `/implement` with TDD. Add other behaviour red-first
after this baseline. Pass lower_snake_case (`fetch_catalog`); generated Dart
keeps lowerCamelCase (`fetchCatalog`).

### 3. Resolve optional transport work

For `curl`, read [the transport branch](../references/curl_transport.md), parse
without executing, require response evidence, and route behaviour through
`/implement` with TDD.

**Gate:** Trace transport choices to supplied evidence, reuse the repository's networking/auth seams, and retain no credential value in source, tests, logs, or summaries.

### 4. Create lower layers

Before production writes, add and run a focused failing controller/repository
test for the initial-load behaviour. Then rerun the reviewed command with
`--write`, verify the untouched baseline with `--check`, and implement only
enough to pass. Treat later intentional semantic changes as test-owned rather
than scaffold drift.

Name datasources `<feature_name>_<source>.datasource.dart`. Derive repository operation names from the requested behavior; do not invent placeholder operations. Annotate implementations with the nearest justified Injectable lifecycle.

On the no-domain path, make the data contract app-facing and inject it into presentation. On the domain path, keep transport types out of domain, implement the domain contract in data, put actual policy in the use case, and map a DTO to an entity only when both shapes exist.

**Gate:** Confirm imports point inward correctly, the implementation satisfies the single selected contract, and no generated file was hand-edited.

### 5. Create presentation last

Mirror the BLoC `_template` by default: use one Freezed state, a feature-scoped status enum, a small event set, `GetIt.I`, page-owned provider lifecycle, and design-system/app primitives for visible UI. Keep the initial state payload-free unless real behavior requires data. Keep page-local helper widgets under `widgets/` as UI-only `part` files of the page library.

When the user explicitly requests Cubit, read [the Cubit variant](../page-scaffold/references/cubit_variant.md) and replace the BLoC/event portion of the manifest; do not claim `_template` is a Cubit template.

**Gate:** Confirm the page consumes the selected existing lower-layer dependency and the controller/state files match the chosen BLoC or explicit Cubit variant exactly.

### 6. Verify completion

Format Dart and regenerate outputs when inputs changed. Run analysis, targeted
tests, then proportionate broader tests. Use `/implement` with TDD beyond
scaffolding.

**Gate:** Apply [the shared scaffold completion gate](../references/scaffold_completion.md) to the selected feature manifest.
