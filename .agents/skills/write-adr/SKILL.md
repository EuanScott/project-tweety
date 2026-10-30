---
name: write-adr
description: Draft Project Tweety ADRs. Use for architecture-decision requests.
---

# Write ADR

## 1. Confirm the decision belongs in the log

Use an ADR for a durable choice affecting structure, non-functional
requirements, dependencies, interfaces, construction techniques, or a
team-wide convention. Keep local implementation details, short-lived
experiments, and already-decided work out of the log.

**Gate:** Identify one significant decision or explain why no ADR is needed.

## 2. Establish context and authority

Read `docs/decisions/README.md`, `docs/decisions/adr-template.md`,
`docs/source_map.md`, applicable `AGENTS.md`, and the narrowest relevant code
and documentation. Inspect Git history only when it can establish why a choice
was made.

**Gate:** Separate repository evidence from facts that require user input.

## 3. Collect the decision record

Confirm the decision owner, chosen option, drivers, alternatives actually
considered, consequences, re-evaluation trigger, and confirmation approach.
Ask only for material information that inspection cannot establish. Record
consultation only when the user provides its source.

Never invent approval, people, alternatives, outcomes, or verification results.
Leave an unresolved fact as an explicit open question; stop when no chosen
option or owner is available.

**Gate:** Have user-confirmed ownership and outcome, with every uncertainty
visible.

## 4. Draft one proposed ADR

Find the highest existing numeric ADR ID and allocate the next ID. Copy the
template into the decisions directory using the numeric ID and short title; replace every placeholder;
set `Status: proposed`; and use today’s ISO date in `Date`. Use neutral facts in Context,
state the Decision as “We will…”, include only real options and trade-offs, and
describe positive, negative, and neutral consequences.

Run `dart run tool/decisions/adr.dart generate-index`. Do not change another
record’s lifecycle; accepting, rejecting, deprecating, and superseding are
explicit human review actions.

**Gate:** Create exactly one placeholder-free proposed ADR and a generated
catalog.

## 5. Verify and report

Run `dart run tool/decisions/adr.dart check` and `dart run tool/skills/validate.dart`.
Report the evidence used, files changed, validation results, and open questions.

**Gate:** Finish with a valid decision log or the precise validation failure.
