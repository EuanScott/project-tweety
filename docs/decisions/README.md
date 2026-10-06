# Architecture Decision Records

This folder contains Architecture Decision Records (ADRs) for Project Tweety.
ADRs capture the rationale and consequences of durable technical decisions;
they complement current-state architecture documentation rather than replacing
it.

## When to create an ADR

Create one for a decision that is cross-cutting, costly to reverse, or affects
structure, non-functional requirements, dependencies, interfaces, construction
techniques, or durable team conventions. Skip local implementation details,
short-lived experiments, and work already decided by an ADR.

## Format and lifecycle

Use [the template](adr-template.md). One ADR describes one decision and uses a
unique, never-reused `NNNN-short-title.md` filename. The date is the original
proposal date. Each ADR starts with its H1 followed by the required Markdown
metadata lines:

```md
# ADR-NNNN: Short decision title

Status: proposed
Date: YYYY-MM-DD
```

`Decision maker`, `Supersedes`, and `Superseded by` are optional labelled
lines. Supersession values use links such as
`[ADR-0001](0001-short-title.md)`.

An ADR stands on its own. Do not link to GitHub issues, pull requests, or the
project board. Those links tie a durable record to a planning tool that changes.
When a decision comes from earlier planning, describe that source in one short
sentence instead. Links to other ADRs and to files in this repository are fine.

`proposed` records are editable and ready for review. A human reviewer changes
a proposal to `accepted` or `rejected`; accepted and rejected decision bodies
are then immutable. A later accepted ADR may supersede an older one by adding
`Supersedes` to the replacement and `Superseded by` plus `superseded` status to
the predecessor. `deprecated` means a decision should no longer guide new work
without a specific replacement.

## Index

The index is generated from each ADR's H1 and `Status` line. Run:

```sh
dart run tool/decisions/adr.dart generate-index
```

<!-- adr-index:start -->
| ID | Title | Status |
|----|-------|--------|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | accepted |
| [0002](0002-test-layer-conventions.md) | Test layer conventions | accepted |
| [0003](0003-pre-commit-validator-enforcement.md) | Pre-commit validator enforcement | superseded → [0010](0010-pre-commit-analysis-and-ci-enforcement.md) |
| [0004](0004-value-type-conventions.md) | Value type conventions | accepted |
| [0005](0005-design-system-example-app-location.md) | design_system example app lives inside the package | accepted |
| [0006](0006-surface-classification-scopes.md) | Window and region surface classification are separate decisions | accepted |
| [0007](0007-cards-local-source-of-truth.md) | Local SQLite remains the source of truth for Cards | accepted |
| [0008](0008-cards-are-owned-by-the-signed-in-account.md) | Cards are owned by the signed-in Account | accepted |
| [0009](0009-conventional-commit-driven-versioning.md) | Conventional-commit-driven versioning | accepted |
| [0010](0010-pre-commit-analysis-and-ci-enforcement.md) | Pre-commit analysis and CI enforcement | accepted |
| [0011](0011-dart-file-role-vocabulary.md) | Dart file role vocabulary | superseded → [0012](0012-dart-file-roles-with-di-modules.md) |
| [0012](0012-dart-file-roles-with-di-modules.md) | Dart file roles, with dependency-injection modules | accepted |
| [0013](0013-firebase-config-committed-with-restricted-keys.md) | Firebase config is committed, and its API keys are restricted to the app's identity | accepted |
| [0014](0014-neutral-navigation-surfaces.md) | Navigation uses neutral surfaces; only the selected item carries the brand colour | accepted |
| [0015](0015-native-pages-for-every-route.md) | Every route builds a native platform page, and Cards stacks follow the URL | accepted |
| [0016](0016-theme-colours-are-complete-brand-presets.md) | Theme colours are complete brand presets named after places and plants | accepted |
| [0017](0017-neutral-app-icon-and-splash.md) | App icon and splash screen are neutral across theme colours | proposed |
<!-- adr-index:end -->
