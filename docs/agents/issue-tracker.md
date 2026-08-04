# Issue tracker: GitHub

Issues and PRDs for this repo live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..." --project "Pecking"`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --comments`, filtering comments by `jq` and also fetching labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from `git remote -v` — `gh` does this automatically when run inside a clone.

## Triage labels

Before applying a triage-state label a skill mentions (e.g. `ready-for-agent`,
`needs-triage`), check `docs/agents/triage-labels.md`. If that role maps to "none" in
this repo, skip the label step entirely — do not attempt `gh issue edit --add-label`
with a role name that has no corresponding label, since GitHub will reject it.

## Project board

Issues for this repo are also tracked on GitHub Project "Pecking" (#2): https://github.com/users/EuanScott/projects/2

- **Add an issue to the board on creation**: `gh issue create --title "..." --body "..." --project "Pecking"`
  (requires the `project` gh scope: `gh auth refresh -s project`)
- **Add an existing issue to the board**: `gh issue edit <number> --add-project "Pecking"`
- **Remove from the board**: `gh issue edit <number> --remove-project "Pecking"`

### Status field

New items default to `Backlog`. The Status field has 5 options: `Backlog`, `Ready`,
`In progress`, `In review`, `Done`. `Backlog` → `Ready` is the only transition any skill
sets automatically (see "When a skill says 'publish to the issue tracker'" and "Spec →
tickets" below) — `In progress`/`In review`/`Done` are moved manually by a human as a
deliberate confirmation step, never by a skill.

**Definition of Done**: an item is Done when a human drags its card to `Done` on the
board. That manual act *is* the Definition of Done — no separate checklist document.
The human is expected to have satisfied themselves the work is correct (tests pass,
`flutter analyze` clean, CI green) before making that move, but nothing enforces it
automatically; the decision to call something finished stays a human judgment call, not
a skill's.

IDs (looked up once, stable unless the project is recreated):
- Project node id: `PVT_kwHOA2dCz84BfWEj`
- Status field id: `PVTSSF_lAHOA2dCz84BfWEjzhZpnhQ`
- Option ids: `Backlog f75ad846`, `Ready 61e4505c`, `In progress 47fc9ee4`, `In review df73e18b`, `Done 98236657`

- **Find an item's project-item id** (distinct from the issue number, needed for the edit call):
  `gh project item-list 2 --owner EuanScott --format json --jq '.items[] | select(.content.number==<n>) | .id'`
- **Set Status**: `gh project item-edit --id <item-id> --project-id PVT_kwHOA2dCz84BfWEj --field-id PVTSSF_lAHOA2dCz84BfWEjzhZpnhQ --single-select-option-id <option-id>`

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; `/triage` reads this flag.)_

When set to `yes`, PRs run through the same labels and states as issues, using the `gh pr` equivalents:

- **Read a PR**: `gh pr view <number> --comments` and `gh pr diff <number>` for the diff.
- **List external PRs for triage**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments` then keep only `authorAssociation` of `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR`, or `NONE` (drop `OWNER`/`MEMBER`/`COLLABORATOR`).
- **Comment / label / close**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub shares one number space across issues and PRs, so a bare `#42` may be either — resolve with `gh pr view 42` and fall back to `gh issue view 42`.

## When a skill says "publish to the issue tracker"

Create a GitHub issue. If it's a **spec** (from `/to-spec`), after creating it set its
board Status to `Ready` — the spec document itself is done the moment it's published, so
there's no reason for it to sit in `Backlog`.

Before publishing a spec, check whether its Implementation Decisions rely on an existing
ADR under `docs/decisions/`. Add a line near the top of the spec body: `**Informed by:**
ADR-0003, ADR-0007` if one or more apply, or `**Informed by:** No existing ADR applies.`
if none do — always state it explicitly rather than omitting the line, so "was a
governing decision checked for" is visible on every spec, not an implicit gap.

### Strengthening "Implementation Decisions"

The `/to-spec` template's Implementation Decisions section (see the skill's own
template) asks for the decisions that were made — modules, interfaces, schema, API
contracts. In this repo, go further: for each non-trivial decision, also record the
**alternatives considered and why they were rejected**, not just the choice landed on.
This is what turns the section from a decision log into a lightweight technical design —
covering the ground a separate technical-design document would, without adding a fourth
artifact type to maintain. Concretely, add a short "Alternatives considered" note under
any decision where more than one real option existed; skip it for decisions with no
genuine alternative (e.g. "use the existing repository pattern" when that's the only
pattern in the codebase — nothing to weigh there). Also note any **integration points**
the decision touches (what else in the codebase has to change or be aware of this) if
not already obvious from the module/interface list.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments`.

## Spec → tickets

Used by `/to-spec` then `/to-tickets`. The **spec** is a single issue; each **ticket**
`/to-tickets` publishes from it becomes a native GitHub **sub-issue** of the spec — same
mechanism as the wayfinder map/child pattern below:

`gh api --method POST repos/<owner>/<repo>/issues/<spec>/sub_issues -F sub_issue_id=<ticket-db-id>`

where `<ticket-db-id>` is the ticket's numeric **database id** (`gh api
repos/<owner>/<repo>/issues/<n> --jq .id`, not the `#number`). This supersedes the
skill's own `## Parent` text-section instruction for this repo — the sub-issue link
already carries that reference, so omit the `## Parent` paragraph from the ticket body.

Ticket-to-ticket **blocking** edges (a ticket's "Blocked by" other tickets) are a
separate relationship — set those up exactly as documented below under Wayfinding
operations, using `dependencies/blocked_by`, not `sub_issues`.

After publishing each ticket, set its board Status to `Ready` too — tickets are
"agent-grabbable by construction" per the skill's own wording, so `Ready` is correct
immediately, not `Backlog`. The parent spec's Status was already set to `Ready` when it
was published (see above) and doesn't change again here — its sub-issues progress bar is
the signal for how decomposition/completion is going from this point on.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body. `gh issue create --label wayfinder:map --project "Pecking"`.
- **Child ticket**: an issue linked to the map as a GitHub sub-issue (`gh api` on the sub-issues endpoint). Where sub-issues aren't enabled, add the child to a task list in the map body and put `Part of #<map>` at the top of the child body. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: GitHub's **native issue dependencies** — the canonical, UI-visible representation. Add an edge with `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, where `<blocker-db-id>` is the blocker's numeric **database id** (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, _not_ the `#number` or `node_id`). GitHub reports `issue_dependencies_summary.blocked_by` (open blockers only — the live gate). Where dependencies aren't available, fall back to a `Blocked by: #<n>, #<n>` line at the top of the child body. A ticket is unblocked when every blocker is closed.
- **Frontier query**: list the map's open children (`gh issue list --state open`, scoped to the map's sub-issues / task list), drop any with an open blocker (`issue_dependencies_summary.blocked_by > 0`, or an open issue in the `Blocked by` line) or an assignee; first in map order wins.
- **Claim**: `gh issue edit <n> --add-assignee @me` — the session's first write.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, then `gh issue close <n>`, then append a context pointer (gist + link) to the map's Decisions-so-far.
