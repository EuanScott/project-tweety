# AGENTS.md

## Scope
- This file applies to all project-local skills under `.codex/skills/`.

## Purpose
- Skills in this repo should be easy to discover and safe to use without the user needing to open `SKILL.md` first.
- Skill behaviour should stay consistent across the repo so users can learn one invocation style and reuse it.

## Required Help Mode
- Every new skill created under `.codex/skills/` must support a `--help` mode.
- Treat this as a required default, not an optional enhancement.
- If the user invokes a skill with `--help`:
  - do not scaffold, update, or edit files
  - return a short, human-readable help response
  - explain what the skill does
  - list the required and optional inputs
  - show one or two example invocations

## Help Mode Style
- Keep help output concise and practical.
- Assume the user has not read the skill source.
- Prefer plain language over internal terminology when both would work.
- If a skill accepts optional richer inputs such as screenshots, mockups, sample responses, or `curl` requests, mention them in `--help`.

## Skill Authoring Expectations
- Add a `## Help mode` section near the top of every `SKILL.md`.
- Describe the `--help` behaviour explicitly in the skill body.
- If the skill has a companion reference file under `references/`, keep the help expectations aligned with the main skill instructions.
- Keep new skills consistent with existing repo conventions for naming, safety, and scope control.

## Safety
- Do not let `--help` mode perform real work.
- If a future skill needs special invocation syntax, explain that syntax in `--help`.
