---
type: ADR
id: "0001"
title: "Record architecture decisions"
status: proposed
date: 2026-07-17
decision_makers:
  - "Repository maintainer"
---

# ADR-0001: Record architecture decisions

## Context

Project Tweety has architectural documentation but no durable, chronological
record of the significant choices and trade-offs that shaped it. Future changes
need enough context to avoid blindly retaining or reversing those choices.

## Decision Drivers

- Preserve the rationale for durable technical choices near the code.
- Keep documentation small enough to read and maintain.
- Make proposed decisions reviewable before they guide implementation.

## Decision

**We will record architecturally significant decisions as Markdown ADRs in
`docs/decisions`.** Each record will use the repository template and lifecycle
documented in the ADR catalog.

## Options Considered

- **A versioned ADR log** (chosen): captures one decision and its consequences
  in a reviewable, durable record.
- **Living architecture documents only**: describe the current system but lose
  the rejected alternatives and historical rationale.
- **Undocumented decisions**: keeps short-term overhead low but makes future
  change riskier.

## Consequences

- Future maintainers can trace durable choices to their context and trade-offs.
- Significant decisions incur a small drafting and review cost.
- Re-evaluate this convention if the records become stale, overly bureaucratic,
  or insufficient for the project’s decision volume.

## Confirmation

Review this proposed ADR before accepting it. Validate every new ADR with
`dart run tool/decisions/adr.dart check`, and consult applicable accepted ADRs
during architecture and code review.
