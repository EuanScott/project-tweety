# Label taxonomy for a solo learning side-project

> **Superseded**: after this research, the repo settled on an even simpler scheme —
> `docs/agents/triage-labels.md` is the current source of truth. The triage-state labels
> discussed below (`needs-info`, `wontfix`, etc.) are not used in this repo; only the
> type labels (`bug`, `enhancement`, `investigation`, `documentation`) are. Left here as
> the research trail for why that decision was made.

Researched to answer: what labels should a small, one-person side-project use, given
we already have a kanban Status field (Todo/Doing/Done) on the "Pecking" project board
and a triage-state scheme from the Matt Pocock skills setup?

## 1. GitHub's own default labels

Source: [GitHub Docs — Managing labels](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels)

Every new repo ships with 9 default labels: `bug`, `documentation`, `duplicate`,
`enhancement`, `good first issue`, `help wanted`, `invalid`, `question`, `wontfix`.

## 2. Matt Pocock skills plugin — canonical triage roles

Primary source (installed plugin, v1.2.0):
`~/.claude/plugins/cache/claude-plugins-official/mattpocock-skills/1.2.0/skills/engineering/triage/SKILL.md`
and its `setup-matt-pocock-skills/triage-labels.md` template.

- **Two category roles only**: `bug` ("something is broken"), `enhancement` ("new
  feature or improvement"). The plugin does **not** define `investigation` or
  `new feature` — those are extensions this repo has layered on informally.
- **Five state roles**: `needs-triage`, `needs-info`, `ready-for-agent`,
  `ready-for-human`, `wontfix`. These already match [`docs/agents/triage-labels.md`](../triage-labels.md)
  in this repo 1:1 — that file's template inside the plugin confirms it's the
  correct place to rename/consolidate the right-hand column.
- State machine: unlabeled → `needs-triage` → one of (`needs-info`,
  `ready-for-agent`, `ready-for-human`, `wontfix`); `needs-info` loops back to
  `needs-triage` once the reporter replies.
- Every triaged issue carries **exactly one category role + one state role**
  simultaneously — category and state are already two orthogonal label
  dimensions by design in the plugin itself.

## 3. This repo's current state

- [`docs/agents/triage-labels.md`](../triage-labels.md) — maps the 5 state roles 1:1 to
  identical label strings today.
- [`docs/agents/issue-tracker.md`](../issue-tracker.md) — GitHub issues via `gh`, plus
  the "Pecking" project board (#2), and a separate `wayfinder:map` /
  `wayfinder:<type>` label namespace (`research`/`prototype`/`grilling`/`task`)
  used only by `/wayfinder`, not part of triage.
- Issues currently on the board use ad hoc labels (`enhancement`, `investigation`)
  and none of the 5 canonical state labels yet — no issue has been through `/triage`.

## Recommendation

Keep three independent label/field axes per issue, none duplicating another:

**A. Type** (what kind of change) — small, solo-project set:
- `bug`, `enhancement` (the plugin's two canonical roles)
- `investigation` — your existing addition; not a GitHub default nor a plugin
  role, but harmless as a repo-specific extension
- Skip `new feature` as a separate label — GitHub's own `enhancement`
  description already covers "new feature requests"; a second label just
  invites redundant decisions on a repo with one triager
- Optionally pull in `documentation` or `question` from GitHub's defaults only
  if you actually hit that case — don't pre-create labels you won't use

**B. State** (has this been vetted, is it fit to start) — keep the existing 5
from `docs/agents/triage-labels.md` verbatim; this is what `/triage` reads and
already matches the plugin's canonical roles. Don't rename unless you want
different tracker-facing strings.

**C. Kanban Status** (Todo/Doing/Done on the Pecking board) — answers "where is
accepted work in flight." Independent of the above; issues that reach
`ready-for-agent`/`ready-for-human` are generally the ones you'd expect to also
sit in Status: Todo.

No repo files need to change to adopt this — it's already the shape
`triage-labels.md` and `issue-tracker.md` describe. The only gap is that none
of the 6 existing issues have been run through `/triage` yet to pick up a
state label.
