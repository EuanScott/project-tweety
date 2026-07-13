---
name: domain-scaffold
description: "Scaffold Project Tweety domain contracts, policy-bearing use cases, and entities for an existing feature with stated mobile-owned behaviour. Use only for domain-layer work."
---

# Domain Scaffold

## Required inputs

Collect:

- `feature_name` and `folder_key` in snake_case;
- `domain_reason`: the concrete policy, decision, or orchestration owned by the mobile app;
- `repository_operations` required by that policy;
- the rule each use case enforces;
- an entity name and shape only when a real domain payload exists.

Reject an empty or infrastructure-only `domain_reason`. Ask only for required information that repository inspection cannot resolve.

## Workflow

### 1. Establish authority and preflight targets

Apply sources in this order: user request, applicable `AGENTS.md`, `lib/domain/_template/README.md`, then the nearest domain implementation only for uncovered details. Use the template to select only the artifacts justified by the stated domain policy. Read root, `lib`, and domain guidance.

List every proposed target. Stop if any target already exists unless the user explicitly requests an update. Keep all new artifacts under `lib/domain/`.

**Gate:** Confirm complete inputs, resolved authority, an in-scope target list, and zero unapproved overwrites.

### 2. Prove the domain seam

Require the use case to own observable mobile policy such as validation, a decision, ordering, coordination across operations, or app-owned state transition. Reject a use case that only forwards arguments and returns one repository call unchanged. Route pure transport or BFF-shaped orchestration to `$data-scaffold` instead.

State the policy independently of UI, HTTP, persistence, DTOs, and repository implementation details.

**Gate:** Express `domain_reason` as a testable rule and identify why neither presentation nor data is the correct owner.

### 3. Select the exact manifest

Create:

- `lib/domain/repositories/<folder_key>/<feature_name>.repository.dart`;
- one or more `lib/domain/usecases/<folder_key>/<action>_<feature_name>.usecase.dart` files that enforce the stated policy;
- `lib/domain/entities/<folder_key>/<entity>.entity.dart` only when the policy operates on a real domain payload.

Add only operations required by the policy. Do not create data implementations, DTOs, datasources, pages, BLoCs, navigation, or localization.

**Gate:** Confirm one cohesive repository contract, at least one policy-bearing use case, and no entity without a concrete payload and consumer.

### 4. Specify and create domain behavior

Write a failing unit test for each policy rule before implementing it. Keep contracts intent-based and independent from data types. Keep entities immutable and framework-light. Let use cases depend only on domain contracts, expose `call()` when nearby code does, and use `@injectable` only when DI constructs them.

Do not embed presentation formatting, transport fields, persistence details, or pass-through-only behavior.

**Gate:** Confirm tests observe the stated policy, domain imports remain independent, and every public operation has a current consumer or requested purpose.

### 5. Verify completion

Run the targeted unit tests red then green. Format changed Dart files. Regenerate only when Injectable or other generated inputs changed. Run analysis and proportionate broader tests.

**Gate:** Apply [the shared scaffold completion gate](../references/scaffold_completion.md) to the selected domain manifest.
