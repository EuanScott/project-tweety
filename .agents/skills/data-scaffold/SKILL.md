---
name: data-scaffold
description: "Scaffold Project Tweety data artifacts for an existing feature: repository contracts and implementations, datasources, DTOs, or transport wiring. Use only for data-layer work."
---

# Data Scaffold

## Required inputs

Collect:

- `feature_name` and `folder_key` in snake_case;
- `repository_operations` needed now;
- `required_artifacts`: repository, implementation, datasource, and/or DTO;
- `source` and concrete data shape when a datasource or DTO is requested;
- the existing domain contract when the implementation belongs to a justified domain path;
- optional `curl` text and request/response samples.

Ask only for required information that repository inspection cannot resolve.

## Workflow

### 1. Establish authority and preflight targets

Apply sources in this order: user request, applicable `AGENTS.md`, `tool/templates/feature/data/repositories/`, then the nearest data implementation only for uncovered details. Read root, `lib`, and data guidance; read domain guidance only when consuming an existing domain contract.

Before the first red test, inspect only that guidance, the exact existing or
canonical pair, the requested source seam, and one nearest focused test. Do not
inventory the repository. Expand only to resolve a concrete symbol, contract,
or generated-input question.

List every proposed target. Stop if any target already exists unless the user explicitly requests an update. Keep all new artifacts under `lib/data/`.

**Gate:** Confirm complete inputs, a resolved contract owner, an in-scope target list, and zero unapproved overwrites.

### 2. Select the exact manifest

For a feature without domain, require the complete baseline pair:

- `lib/data/repositories/<folder_key>/<feature_name>.repository.dart`
- `lib/data/repositories/<folder_key>/<feature_name>.repository_impl.dart`

Create both when repository scaffolding is requested and neither exists. When both already exist, verify them as prerequisites and add only the requested datasource, DTO, or transport change. Stop on a half-created pair instead of inventing the missing contract or implementation outside the stated scope.

For a justified domain feature, verify these upstream artifacts already exist:

- `lib/domain/repositories/<folder_key>/<feature_name>.repository.dart`
- at least one policy-bearing `lib/domain/usecases/<folder_key>/<action>_<feature_name>.usecase.dart`
- a domain entity only when a real domain payload exists

Then create only `lib/data/repositories/<folder_key>/<feature_name>.repository_impl.dart`; never duplicate the contract under `lib/data`. Stop and direct missing domain work to `$domain-scaffold` instead of silently expanding this skill's scope.

Add `lib/data/datasources/<folder_key>/<feature_name>_<source>.datasource.dart` only for a real source. Add `lib/data/dtos/<entity>/<entity>.dto.dart` only for a concrete transport or persistence shape.

**Gate:** Confirm the baseline pair or domain implementation path, and justify each conditional datasource and DTO against a real boundary.

### 3. Resolve optional transport work

When `curl` text is supplied, read [the curl transport branch](../references/curl_transport.md). Parse it as text; never execute it. Require response evidence before assuming response DTO fields or mapping. Route concrete request, mapping, error, or retry behavior through `/implement` and its TDD flow.

**Gate:** Trace method, path, query, headers, body, and response mapping to evidence; reuse existing networking/auth seams; retain no credential value.

### 4. Specify and create the data artifacts

For repository orchestration, mapping, or transport behaviour, add the nearest
focused failing test and confirm the expected red state before production
changes. Pure interface/file skeletons need no behavioural assertion.

Keep contracts app-facing and intent-based. Keep datasources close to raw source shape. Keep DTOs responsible for serialization and mapping. Keep repository implementations responsible for orchestration and for hiding transport details.

Map DTOs with `toValue()` when no domain exists and with `toEntity()` only for a justified domain entity. Annotate the repository implementation with `@LazySingleton(as: ContractType)` and the datasource with the nearest justified lifecycle unless current scoped guidance requires otherwise.

Do not invent placeholder operations, DTO fields, network clients, domain policy, or presentation behavior.

**Gate:** Confirm the implementation satisfies exactly one contract, raw DTOs do not escape data, transport details remain hidden, and imports do not point to presentation.

### 5. Verify completion

Format all changed inputs before one required code-generation pass. Run the targeted test and scoped analysis. Broaden tests only when a shared seam's behaviour changed; a feature-local addition does not require the full widget suite.

**Gate:** Apply [the shared scaffold completion gate](../references/scaffold_completion.md) to the selected data manifest.
