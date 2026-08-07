# What would a Product Owner / BA / EM / Staff Engineer flag about this repo?

Researched to answer: this repo already has a workflow (`/to-spec` → `/to-tickets` →
`/implement`, GitHub Issues + the "Pecking" project board, ADRs in `docs/decisions/`).
Four roles exist in most engineering orgs to catch different failure modes — backlog
drift, requirements gaps, delivery/health blind spots, and architectural incoherence.
None of those roles exist here; it's a solo learner. This asks each role's actual
documented practice (not vibes) what it would check, then filters hard for what still
pays off with an audience of one.

## Product Owner — backlog, Definition of Done, prioritization signal

Primary source: the [Scrum Guide](https://scrumguides.org/scrum-guide.html).

- The guide defines the Product Backlog as "an emergent, ordered list of what is needed
  to improve the product. It is the single source of work undertaken by the Scrum Team,"
  and readiness for planning comes from refinement — "breaking down and further defining
  Product Backlog items into smaller more precise items" — not from a separately named
  gate. Notably, **the guide itself has no "Definition of Ready" concept**; that's an
  informally popular practice layered on top by teams, not Scrum canon. This repo's
  `Backlog` → `Ready` Status transition (`docs/agents/issue-tracker.md`) already
  functions as a de facto Definition of Ready, even without naming it that.
- The guide does define Definition of Done formally: "If a Product Backlog item does not
  meet the Definition of Done, it cannot be released or even presented at the Sprint
  Review." This repo has no equivalent artifact anywhere — no `Done` checklist exists in
  `docs/agents/issue-tracker.md`, the issue templates, or the ADR template. The closest
  thing is per-ticket acceptance criteria from `/to-tickets`, which are per-item, not a
  standing bar every ticket must clear (tests passing, lints clean, ADR consulted).
- The guide frames prioritization as ordering toward one **Product Goal** at a time —
  "fulfill (or abandon) one objective before taking on the next" — not as a scoring
  formula. This repo's Pecking board already has `Priority` (confirmed via
  `gh project field-list 2 --owner EuanScott`: `PVTSSF_lAHOA2dCz84BfWEjzhZpn1I`) and
  `Size` fields, but nothing in `docs/agents/issue-tracker.md` documents what sets
  Priority or what the current Product Goal even is — the fields exist as board
  plumbing, not as a recorded "why this over that" signal.

## Business Analyst — traceability, acceptance criteria, non-functional requirements

Primary source: IIBA's BABOK Guide, specifically the [Requirements Analysis and Design
Definition](https://www.iiba.org/knowledgehub/business-analysis-body-of-knowledge-babok-guide/7-requirements-analysis-and-design-definition/)
and [Requirements Life Cycle Management](https://www.iiba.org/knowledgehub/business-analysis-body-of-knowledge-babok-guide/5-requirements-life-cycle-management/)
knowledge areas.

- BABOK's Requirements Analysis and Design Definition area exists to "structure and
  organize requirements discovered during elicitation activities, specify and model
  requirements and designs, validate and verify information" — and explicitly separates
  **Verify Requirements** ("developed in enough detail... internally consistent, and of
  high quality") from **Validate Requirements** ("delivers business value"). The
  `/to-spec` template (`~/.claude/plugins/.../to-spec/SKILL.md`) has User Stories,
  Implementation Decisions, and Testing Decisions sections but nothing that separately
  forces a verify-vs-validate check — a spec can read as internally consistent while
  never being checked against "does this still solve the stated Problem Statement."
- BABOK's Requirements Life Cycle Management area names **Trace Requirements**
  as its own task: "establishing connections between requirements and their origins,
  implementations, and related elements... accountability throughout a requirement's
  journey from conception through deployment." This repo already has strong forward
  traceability — spec → sub-issue tickets via the native GitHub sub-issues API
  (`docs/agents/issue-tracker.md`) — but no traceability back the other direction: an
  ADR doesn't reference the spec/issue that prompted it, and a spec doesn't reference
  which ADRs constrained its Implementation Decisions.
- The `/to-spec` template has **no dedicated non-functional requirements section**.
  Problem Statement, Solution, User Stories, Implementation Decisions, Testing
  Decisions, Out of Scope, and Further Notes are all functional-shaped. BABOK's
  technique catalog names "Non-Functional Requirements Analysis" as its own
  technique, distinct from functional requirements — performance, accessibility,
  offline behavior in a Flutter app are exactly the kind of requirement that currently
  has nowhere obvious to live in the template except getting folded loosely into
  "Implementation Decisions" or "Further Notes," where it's easy to drop silently.

## Engineering Manager — delivery health, risk, technical debt

Primary source: [DORA's four/five key metrics](https://dora.dev/guides/dora-metrics-four-keys/).

- DORA defines **Deployment Frequency** ("the number of deployments over a given period
  or the time between deployments"), **Change Lead Time** ("the amount of time it takes
  for a change to go from committed to version control to deployed in production"),
  **Change Failure Rate** ("the ratio of deployments that require immediate
  intervention"), and what DORA now calls **Failed Deployment Recovery Time** ("the time
  it takes to recover from a deployment that fails and requires immediate
  intervention" — the metric formerly known as MTTR). All four presuppose there's a
  deployment pipeline to measure. This repo has **no CI/CD at all** — `.github/`
  contains only `ISSUE_TEMPLATE/`, no `workflows/` directory — so none of the four
  metrics have any data source yet. That's the actual finding, not a recommendation to
  start tracking them.
- The `to-tickets` skill file already names the right EM instinct in its own language —
  "Look for opportunities to prefactor the code to make the implementation easier. 'Make
  the change easy, then make the easy change.'" — but that's a per-ticket prompt, not a
  standing practice. There is no ticket type or label for technical debt as a
  first-class backlog item: `docs/agents/triage-labels.md` lists only `bug`,
  `enhancement`, `investigation`, `documentation` — debt currently has no label and no
  natural home, so it either gets folded into `enhancement` or stays undocumented in
  someone's head.
- Risk management in DORA's model is implicit in Change Failure Rate — how often does a
  change need a rollback or hotfix. With no CI and no deploy pipeline, that risk
  currently surfaces only if/when it's noticed manually; there's no forcing function.

## Staff+ Engineer — technical strategy, cross-cutting concerns, leverage

Primary source: Will Larson's [staff archetypes](https://staffeng.com/guides/staff-archetypes/).

- The four archetypes are defined precisely: **Tech Lead** ("guides the approach and
  execution of a particular team... partner closely with a single manager"),
  **Architect** ("responsible for the direction, quality, and approach within a
  critical area... combine in-depth knowledge of technical constraints, user needs, and
  organization level leadership"), **Solver** ("digs deep into arbitrarily complex
  problems and finds an appropriate path forward"), and **Right Hand** ("extends an
  executive's attention, borrowing their scope and authority to operate particularly
  complex organizations"). Right Hand is meaningless solo (there's no executive whose
  attention needs extending); Tech Lead presupposes a team to guide. Architect and
  Solver are the two archetypes that map onto a solo learner's actual position —
  they're the ones who set direction and dig into hard problems without needing anyone
  else in the loop.
- The Architect archetype's core input — "direction, quality, and approach within a
  critical area" — is exactly what's missing from this repo's documentation. ADRs
  (`docs/decisions/`) are explicitly point decisions: each records "what was decided,"
  one choice at a time, per ADR-0001's own framing ("a durable, chronological record of
  the significant choices"). There is no single document that reads as an accumulated
  *architecture* — where `lib/domain` is meant to grow next, which layers are
  considered stable vs. experimental, what "good" looks like across the `core` /
  `data` / `domain` / `features` / `presentation` split beyond what AGENTS.md states as
  static policy. An ADR log is a sequence of decisions; a strategy doc would be the
  currently-missing synthesis across them.
- "Make the change easy, then make the easy change" (prefactoring) is explicitly named
  in the `to-tickets` skill's step 2 ("Look for opportunities to prefactor the code...
  Any prefactoring should be done first") — so the seam-finding instinct staffeng.com's
  Architect/Solver archetypes describe is already wired into the ticket-generation flow.
  What isn't wired in is any standing record of *where the seams currently are* — no
  architecture-health note, no "known rough edges" list — so each spec/ticket cycle
  rediscovers seams from scratch rather than building on a maintained map of them.

## If you only do 3 things

Filtered hard for solo: cut velocity tracking, stakeholder alignment, sign-off gates,
and anything from the four roles above that only pays off once there's more than one
person reading it. What's left, in priority order:

1. **Add a short, explicit Definition of Done to `docs/agents/issue-tracker.md`.**
   This is the single highest-leverage gap: Scrum's own guide treats DoD as the one
   non-negotiable quality gate ("cannot be released or even presented... if it does not
   meet the Definition of Done"), and this repo currently has none — not even an
   informal one. Doesn't need process theater, just a checklist (tests pass, lints
   clean, relevant ADR consulted, board Status moved) that both a human and an agent
   check before flipping a ticket to `In review`/`Done`.

2. **Give technical debt a label and a home.** The EM-lens finding and the Staff-lens
   finding point at the same gap from two directions: there's a prefactoring instinct in
   `to-tickets` but no durable record of debt or architectural rough edges between
   cycles. A `tech-debt` label alongside the existing `bug`/`enhancement`/
   `investigation`/`documentation` set (`docs/agents/triage-labels.md`) costs nothing and
   makes debt visible on the board instead of living only in memory.

3. **Add a non-functional requirements prompt to the `/to-spec` template usage for this
   repo, and a one-line "informed by ADR-NNNN" backlink convention from spec to ADR.**
   Both are cheap, both close a real gap BABOK's traceability and requirements-design
   knowledge areas name explicitly, and both stay useful solo — future-you rereading a
   6-month-old spec benefits from "why did I build this" exactly as much as a
   teammate would.

Explicitly cut: DORA metrics and CI/CD (no deploy pipeline exists yet to measure — build
the pipeline first, if ever, before instrumenting it), a standalone technical-strategy
document (an accumulated architecture doc is real Staff-Architect value, but for a
one-person repo the ADR log plus AGENTS.md's layering rules already cover "direction" at
the current project size — revisit once `lib/domain` or `lib/features` actually grows),
and Priority/Size field documentation on the Pecking board (prioritization only needs a
recorded rationale once there's contention between competing priorities from more than
one voice).
