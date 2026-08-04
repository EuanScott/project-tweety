# Triage Labels

The skills speak in terms of five canonical triage roles (`needs-triage`, `needs-info`,
`ready-for-agent`, `ready-for-human`, `wontfix`). This repo doesn't use that vocabulary —
it's a solo project, so a separate triage-state axis doesn't pull its weight on top of
the project board's own Status field (Todo/Doing/Done).

Instead, this repo labels issues with a single **type** axis only:

| Label          | Meaning                  |
| -------------- |--------------------------|
| `bug`          | Something isn't working  |
| `enhancement`  | New feature or request   |
| `investigation`| How can we do something  |
| `documentation`| No forgetti, no regretti |
| `tech-debt`    | Known rough edge or shortcut, not yet fixed |

When a skill mentions a canonical triage role, map it to nothing on this repo — every
issue just carries a type label plus whatever Status the project board assigns it.

Edit the table above to match whatever vocabulary you actually use.
