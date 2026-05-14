# AGENTS.md

## Scope
- This file applies to shared widgets under `lib/presentation/widgets/`.

## Purpose
- This folder is for reusable app-level widgets such as app bars, modals, layout wrappers, rows, and small UI building blocks.
- Keep widgets focused, theme-backed, and reusable across pages.

## Skill Hints
- Users can build or update widgets manually. Skills are optional helpers for matching work.
- If creating a new shared widget from a human-readable brief or screenshot/mockup, prefer `$shared-widget`.
- If updating an existing shared widget while preserving its current behavior by default, prefer `$update-widget`.
- If the user is unsure how a skill works, `$shared-widget --help` or `$update-widget --help` should explain the inputs and example usage without editing files.
- Use human judgement. If manual edits are simpler or safer for the task, do that instead of forcing a skill.

## Widget Conventions
- Prefer narrow public APIs over large configurable surfaces.
- Prefer `Theme.of(context)` and shared component themes over local ad hoc styling.
- Preserve open-for-extension, closed-for-modification structure where it fits the widget, for example additive entrypoints or variants over breaking edits to an existing contract.
- Keep caller-owned state outside the widget unless local transient UI state is the point of the abstraction.
