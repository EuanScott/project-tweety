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

`proposed` records are editable and ready for review. A human reviewer changes
a proposal to `accepted` or `rejected`; accepted and rejected decision bodies
are then immutable. A later accepted ADR may supersede an older one by adding
`supersedes` to the replacement and `superseded_by` plus `superseded` status to
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
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | proposed |
<!-- adr-index:end -->
