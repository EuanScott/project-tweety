---
name: update-widget
description: Change an existing Project Tweety shared widget while preserving its callers. Use for in-place improvements or a named successor under lib/presentation/widgets.
---

# Update Widget

Evolve one existing app-level widget with its current behaviour as the baseline.

## Input gate

Require an existing widget name or file path and a plain-language change brief.
Accept an optional successor name. A screenshot or mockup may define the visual
target but does not define behaviour or ownership.

Resolve the target to exactly one file under `lib/presentation/widgets/`. Stop
with a precise message when it is missing; ask one focused question when more
than one file matches. Never invent a replacement for an unresolved target.

Finish this gate when one source widget and one requested change are explicit.

## Workflow

### 1. Snapshot the current contract

Read `lib/presentation/widgets/AGENTS.md`, the source widget, its focused tests,
and every current call site. Record the filename, class, constructors, public
fields, callbacks and payloads, state owner, static entrypoints, result
semantics, and observed caller assumptions.

When the request names a successor, read
[widget_successor.md](../references/widget_successor.md).

Finish this step when every public contract element and caller is accounted for.

### 2. Bound the requested difference

Classify the change as documentation-only, internal refactor, visual,
behavioural, additive API, breaking API, or successor creation. List the exact
properties that change and those that stay invariant.

Use the current contract as the default for class and file names, constructor
parameters, callbacks, state ownership, navigation, entrypoints, and results.
A breaking difference requires explicit user intent; an ambiguous conflict
requires one focused question.

Load [widget_visual.md](../references/widget_visual.md) for screenshot, theme,
or adaptive-control work. Use
[widget_controlled.md](../references/widget_controlled.md) when selection,
toggle, reorder, or repeated-child state remains caller-owned.

Finish this step when the requested delta is smaller than and unambiguous
against the preservation baseline.

### 3. Specify the delta red-first

For each behavioural or public-contract difference, add one focused failing
widget test and run it to confirm the expected red state. Keep existing tests
green where they specify preserved behaviour. Documentation-only changes record
why TDD does not apply.

Finish this step with a reproducible red test for the next difference or a
documented non-behavioural classification.

### 4. Make the smallest safe change

Implement only the specified delta. Prefer internal or additive changes that
keep callers compiling. Use theme-backed styling and the current exported
design-system primitives. Add `super.key`, assertions, stable identity, or Dart
documentation only where they strengthen the observed contract without
invalidating callers.

Keep durable state, navigation, business policy, and workflow orchestration in
the caller. In successor mode, keep the original file and its callers unchanged
unless migration is part of the brief.

Finish this step when the new test is green and preserved tests still pass.

### 5. Verify preservation

Format affected files, run the focused widget tests, and analyse the affected
package and all call sites. Review the diff against the contract snapshot:
every unrequested public difference is a defect.

Report what changed, what remained invariant, whether the change was in-place
or a successor, and the commands run. Include a usage snippet only when the
calling pattern changed; include manual checks only for residual visual or
interaction behaviour that tests cannot establish.

Finish when tests and analysis pass, every caller is accounted for, and the
diff contains only the agreed delta.
