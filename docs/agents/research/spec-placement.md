# Where should a spec/PRD live? (solo project vs. larger team)

Researched to answer: this repo's `/to-spec` skill publishes specs as a single GitHub
issue on the same repo as the code. Is that where industry best practice says a spec
should live — and if this project ever grew into a multi-person team, what would need
to change?

## 1. Placement options, and the problem each solves

**In-repo RFC, PR-reviewed** — [Rust's `rfcs` repo](https://github.com/rust-lang/rfcs):
an RFC is a pull request against a dedicated spec repo (not the implementation repo).
It goes through open discussion, a 10-day "final comment period," then merges as
"active" text. Crucially, "every accepted RFC has an associated issue tracking its
implementation in the Rust repository" — the spec and its implementation tickets are
two separate artifacts, in two separate places, explicitly linked. This is the
strongest version of "spec gets PR-style diff review" — something a GitHub issue body
cannot do (issue bodies have edit history, not reviewable diffs).

**ADRs in-repo** — [Michael Nygard's original ADR post](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
and [adr.github.io](https://adr.github.io/): ADRs live as versioned markdown in the
repo (`doc/arch/adr-NNN.md`), numbered monotonically and never deleted — "if a decision
is reversed, we will keep the old one around, but mark it as superseded." The stated
purpose is permanence: "the motivation behind previous decisions is visible for
everyone, present and future." adr.github.io calls the accumulated set a project's
*decision log*. **An ADR is not a PRD** — it records one specific technical decision
and its rationale, after the fact; a spec/PRD describes what to build and why, before
the fact, at feature scope.

**Docs as code** — [Write the Docs guide](https://www.writethedocs.org/guide/docs-as-code/):
"you should be writing documentation with the same tools as code" — version control,
plain-text markup, code review. This is the general pattern that both the RFC-repo and
ADR patterns above are specific instances of. It's positioned as a way to get writers
and developers into the same workflow, and can even "block merging of new features if
they don't include documentation."

**Dedicated docs tools (Confluence, Notion, Google Docs)** — [Atlassian's own docs on
using Jira and Confluence together](https://support.atlassian.com/confluence-cloud/docs/use-jira-and-confluence-together/):
requirements get written in Confluence, then linked to Jira issues/epics for tracking —
"the tight integration between Confluence and Jira means you can easily access work
items from Confluence and see their status at a glance." [Atlassian's Confluence PRD
template](https://www.atlassian.com/software/confluence/templates/product-requirements)
is explicitly written "with your development team **and product designers**," and
Confluence is pitched as "a single source of truth" gathering research, specs, mockups,
and diagrams for people who aren't necessarily working inside the issue tracker at all.
This is the tell: these tools solve for a **cross-functional, partly non-engineering
audience** — PMs, designers, leadership — who need to read and comment without living
in the code repo's tracker.

**Issue-tracker-native docs (Linear)** — [Linear's own docs on Documents](https://linear.app/docs/documents):
Linear explicitly separates *Documents* (specs, PRDs, runbooks, meeting notes — "long-
form text attached to the work") from *Issues* (short, actionable, trackable). Its own
guidance: "issues with complex implementation needs may prefer to use a document rather
than a short description." Documents cross-reference into issues via `@`-mentions
rather than being issues themselves. Linear, a tool built specifically for engineering
teams, still concluded a spec needs a different container than a ticket.

**GitHub Issues/Discussions** — GitHub's own docs take no side here. Per
[GitHub's Discussions docs](https://docs.github.com/en/discussions/quickstart), Issues
are for "work that needs to be tracked on a project and is code-related," Discussions
are for "conversations that need to be transparent and accessible but do not need to be
tracked on a project." GitHub does not position either as a spec/PRD tool — both this
repo's spec-as-issue approach and any lighter alternative (e.g. Discussions) are
adaptations of GitHub's primitives, not something GitHub itself recommends.

## 2. Lifecycle: reference document vs. disposable work item

Every source above draws the same line. ADRs are explicitly permanent — "the old one
around, but marked superseded," never deleted
([Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)).
Confluence pages are a "single source of truth" that persists past any one Jira
ticket's lifecycle ([Atlassian](https://www.atlassian.com/software/confluence/templates/product-requirements)).
Linear Documents are deliberately not Issues because the content is meant to outlive
and contextualize many issues, not be closed and forgotten
([Linear](https://linear.app/docs/documents)). Rust RFCs are merged, permanent text;
the *implementation issue* is the disposable, closeable counterpart
([rust-lang/rfcs](https://github.com/rust-lang/rfcs)). The pattern is consistent: the
spec is reference material that survives; the ticket is a work-tracking artifact that's
meant to be closed and mostly forgotten once done.

## 3. How specs link back to tracked tickets

- **Jira/Confluence**: bidirectional linking via Application Links — `/jira` macro in
  Confluence to attach epics/issues, and a "linked pages" panel in Jira issues showing
  back-references
  ([Atlassian](https://support.atlassian.com/confluence-cloud/docs/use-jira-and-confluence-together/)).
- **Linear**: `@`-mention a Document from inside an Issue description or comment
  ([Linear](https://linear.app/docs/documents)).
- **Rust RFCs**: the merged RFC text links out to "an associated issue tracking its
  implementation," a plain issue reference, no special tooling
  ([rust-lang/rfcs](https://github.com/rust-lang/rfcs)).
- **This repo**: GitHub native sub-issues — each ticket `/to-tickets` creates is
  attached to the spec issue via the sub-issues API (see
  `docs/agents/issue-tracker.md`), giving a progress bar on the parent issue. This is
  functionally closest to the Linear/Rust pattern (structured link from ticket back to
  spec) even though the spec itself lives as an issue rather than a separate doc.

## 4. Tradeoffs: solo project vs. larger team

Factors that push a spec out of the code repo and into a dedicated doc/tracker tool,
based on what the sources above actually optimize for:

- **Non-engineering stakeholders without repo access** — Confluence/Notion/Google Docs
  solve for PMs, designers, and leadership who need to read and comment but don't have
  (or want) a GitHub account. A solo learner has no such audience.
- **Rich commenting / inline suggestion review** — Google Docs- and Confluence-style
  inline comments and suggested edits are a different review primitive than a GitHub
  issue's linear comment thread. Matters once more than one person is actively
  negotiating the spec text; irrelevant solo.
- **PR-style diff review of the spec text itself** — Rust's RFC-as-PR pattern gets
  reviewable diffs and a formal "final comment period" gate
  ([rust-lang/rfcs](https://github.com/rust-lang/rfcs)) — something a GitHub *issue*
  body cannot offer (issue bodies just have silent edit history, no diff view, no
  required-reviewers gate). A repo-markdown RFC file reviewed via PR would get this;
  the current issue-as-spec approach does not.
- **Discoverability outside the repo** — a Confluence space or Notion workspace is
  browsable by non-technical stakeholders across many repos/teams; a GitHub issue is
  discoverable only to people who already look at that repo's issue tracker.
- **Versioning/audit trail needs** — ADRs and Rust RFCs solve this by being permanent,
  numbered, superseded-not-deleted repo files
  ([Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)).
  A GitHub issue has an edit history but no formal "superseded by" convention the way
  ADRs do.
- **Org-standardized tooling** — if a company already runs Jira/Confluence or Linear
  company-wide, fighting that to keep specs in the code repo creates a second source of
  truth nobody outside engineering checks. This is an organizational-gravity argument,
  not a technical one, but it's the practical reason most companies' PRDs end up in
  Confluence/Notion/Linear rather than in-repo.
- **Weight the spec needs to carry** — a solo learner's spec doesn't need sign-off from
  anyone; a company's PRD often gates budget, headcount, or cross-team commitments, and
  needs a paper trail proving stakeholders reviewed and approved it. Dedicated doc
  tools have approval/status metadata (Confluence page status, Linear document state)
  built for that; a GitHub issue does not.

## 5. This repo's current approach, characterized honestly

This repo's `/to-spec` → GitHub issue pattern (see `docs/agents/issue-tracker.md`) is
closest in spirit to the **docs-as-code / in-repo RFC** family
([Write the Docs](https://www.writethedocs.org/guide/docs-as-code/),
[rust-lang/rfcs](https://github.com/rust-lang/rfcs)) — the spec lives next to the code,
in the same tool as the tickets, no separate app to maintain. But it substitutes a
GitHub **Issue** for what a true in-repo RFC would be a **repo markdown file reviewed
via pull request**. That substitution keeps the "lives with the code, linked natively
to tickets" benefit (via sub-issues) but gives up the "spec text gets PR-style diff
review and a formal merge gate" benefit that Rust's actual RFC process has.

This repo's `docs/decisions/` ADR setup (see `docs/agents/domain.md`) is a **separate,
already-closer-to-best-practice pattern** — genuine versioned markdown files, numbered,
superseded-not-deleted, matching Nygard's original convention almost exactly. It should
not be conflated with the spec-as-issue pattern: an ADR records one specific technical
decision and its rationale, after that decision is made; a spec/PRD describes what to
build and why, before the work starts, at feature scope. They're different documents
answering different questions, and this repo already has good primary-source-aligned
tooling for one of them (ADRs) and a lighter, GitHub-native approximation for the other
(specs).

## 6. Recommendation

**Keep doing, solo:** spec-as-GitHub-issue via `/to-spec`, tickets as native sub-issues
via `/to-tickets`. None of the tradeoffs in section 4 apply to a one-person learner —
there's no non-engineering audience, no sign-off requirement, no org-standardized tool
to align with, and the GitHub-native sub-issue linking is objectively good tracking
hygiene for the ticket side. Keep `docs/decisions/` exactly as-is for ADRs — it's
already the real pattern, not an approximation of it.

**If this project ever grew into a multi-person team, move specs when any of these
becomes true:**

- **If non-engineering stakeholders (PM, design, leadership) need to read or comment on
  specs without a GitHub account** → move specs to Confluence or Notion, and link out
  to GitHub issues the way [Atlassian's Jira+Confluence integration](https://support.atlassian.com/confluence-cloud/docs/use-jira-and-confluence-together/)
  does, or to Linear Documents linked to Linear Issues
  ([Linear docs](https://linear.app/docs/documents)) if the team standardizes on Linear
  instead of GitHub Issues for tracking.
- **If spec text itself needs formal review/approval before it's "final,"** the way
  Rust's RFC process gates via a 10-day final-comment-period on a PR
  ([rust-lang/rfcs](https://github.com/rust-lang/rfcs)) → move specs into
  `docs/specs/` (or similar) as markdown files reviewed via pull request, keeping them
  in-repo but gaining the diff-review and formal-merge-gate properties a GitHub issue
  body can't provide. This is the smallest structural change from the current approach
  and preserves the "lives with the code" property this repo already values.
- **If the org already standardizes on Jira/Confluence or Linear for other teams** →
  don't fight that gravity; move specs there so non-engineering stakeholders have one
  place to look, and keep GitHub issues (or Linear issues) as the linked, disposable
  implementation-tracking layer underneath, per the linking patterns in section 3.

Absent any of those triggers, the current setup already matches the shape real
engineering orgs use for engineering-only specs — it just uses GitHub's issue-body
primitive instead of a repo markdown file for the spec text itself, which is a
reasonable simplification for a one-person project with no reviewers to gate against.

**Tool preference, if/when this triggers (2026-08-04):** Linear Documents or a Notion
page — not Confluence/Jira. Reasoning given: it keeps the spec in a tool built for (or
adjacent to) engineering workflows rather than a general enterprise wiki, while still
giving it a home separate from the issue tracker for the reasons in section 4. Linear
Documents would be the tighter fit if the team also moves issue-tracking to Linear (see
section 3 for the `@`-mention linking pattern); a Notion page is the fallback if the
team stays on GitHub Issues for tracking and just wants a lighter-weight doc tool than
Confluence.
