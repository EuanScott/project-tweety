---
name: shared-widget
description: Create and correctly place reusable Project Tweety UI from a behavioural brief. Use for app widgets and broadly reusable adaptive design-system controls, not page-private details.
---

# Shared Widget

Create one focused reusable widget in the correct app or design-system layer.

## Input gate

Require a plain-language brief that states what the widget shows, what the
caller supplies, and what interaction the caller observes. A name, screenshot,
or mockup may supplement the brief but does not replace its behavioural detail.

Infer a snake_case filename when the brief makes the responsibility clear. Ask
one focused question only when placement, state ownership, or the public
interaction contract has multiple materially different answers.

Finish this gate when the brief and any remaining question identify one
responsibility and one observable caller contract. Otherwise stop with a short
request for the missing brief.

## Workflow

### 1. Place the widget

Place reusable Project Tweety presentation patterns in
`lib/presentation/widgets/`. Keep one-page implementation details with that
page. Put broadly reusable adaptive controls in `packages/design_system`.

For the app branch, read `lib/presentation/widgets/AGENTS.md` and one closest
app widget. For the design-system branch, read
`packages/design_system/AGENTS.md`,
`packages/design_system/lib/design_system.dart`, and one closest adaptive
primitive plus its focused test. Once placement is clear, inspect only that
branch.

Finish this step when the chosen package and reuse boundary are explicit.

### 2. Define the contract

Write down the proposed filename, public class, responsibility, constructor
inputs, state owner, callbacks, and any static entrypoint before editing.

Prefer a stateless, caller-controlled contract. Expose the capabilities the
current brief requires and keep navigation, business policy, persistence, and
workflow orchestration in the caller. Use typed helper values when several
fields form one concept; add named variants when they express real app
vocabulary more clearly than flags.

For screenshots, theme work, or adaptive controls, read
[widget_visual.md](../references/widget_visual.md). For selections, toggles,
reordered collections, or repeated stateful children, read
[widget_controlled.md](../references/widget_controlled.md).

Finish this step when every public input and callback traces to the brief and
the state owner is unambiguous.

### 3. Specify behaviour red-first

Add a focused test under `test/presentation/widgets/` for an app widget or
`packages/design_system/test/` for a design-system primitive. Specify one
observable slice: required output, callback, assertion, variant, or static
entrypoint. Run it and confirm the expected failure before production changes.

For a documentation-only request, record that behaviour is unchanged and skip
the red-green loop.

Finish this step with a reproducible red test or a documented non-behavioural
classification.

### 4. Implement the smallest widget

Create an app widget under `lib/presentation/widgets/`, or an adaptive primitive
under `packages/design_system/lib/src/` and export it from
`packages/design_system/lib/design_system.dart`. Follow current naming. Include
`super.key`, theme-backed presentation, and useful Dart documentation for each
public API. Keep private details beside the public widget while the file remains
a small readable unit.

Use assertions for invalid contracts the type system cannot express. Keep the
public surface narrow and extend later through composition, typed variants, or
new entrypoints when a concrete caller needs them.

Finish this step when the targeted test is green and the implementation adds no
capability outside the agreed contract.

### 5. Verify and hand off

Format affected Dart files, rerun the targeted tests, and analyse the affected
package and callers. Review the diff for out-of-scope theme, navigation,
analytics, state-management, or generated-file changes.

In the final response, report the contract, tests, and verification. Include a
usage snippet only when a new public calling pattern needs illustration;
include manual visual checks only for behaviour that automation cannot verify.

Finish when tests and analysis pass, the diff matches the agreed placement and
contract, and every residual check is explicit.
