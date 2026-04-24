---
name: update-widget
description: Update an existing shared widget for Project Tweety while preserving its current behaviour by default. Use when modifying a widget that already exists under lib/presentation/widgets and you want to improve structure, docs, theme usage, or API shape without breaking current callers unless explicitly requested. Optionally accept a new widget name to create a renamed successor instead of editing the original in place.
---

# Update Widget

Update an existing shared widget in `lib/presentation/widgets/`.
Use this when the widget already exists and the task is to evolve it safely rather than scaffold it from scratch.

## Help mode

If the user invokes this skill with `--help`:
- do not update or edit files
- return a short, human-readable help response
- explain what the skill does
- list the required and optional inputs
- mention the in-place mode and the `widget -> widget_v2` renamed-successor mode
- mention that screenshots or mockups can be supplied as visual references
- show one or two example invocations

A human-readable change description is required.
The user must provide either:
- the widget name
- or the widget file path

Optionally, they may also provide a new widget name for the updated version.
Examples:
- `app_bar`
- `app_bar -> app_bar_v2`
- `webview_modal -> legal_webview_modal`

And they must also describe what should change.

Attached screenshots or mockups can be used as visual references for the
desired update, but they are not enough on their own to safely define what
behaviour, ownership, or API changes should happen.

Start by reading:
- Root `AGENTS.md`
- `lib/AGENTS.md`

Then inspect:
- the existing widget file
- current usages of that widget in the repo
- the active app theme when visual changes are involved
- any attached screenshot or mockup when the request includes a visual target

For this repo, also read:
- `packages/design_system/AGENTS.md` when the widget needs theme-backed styling or theme changes
- the current `MaterialApp` theme wiring in `lib/main.dart`
- the current theme entrypoint under `packages/design_system/lib/src/theme/`

Use `webview_modal.dart`, `app_modal.dart`, `page_scaffold.dart`, and `app_bar.dart` as the default style references for:
- rich dart doc comments
- small, focused widget responsibilities
- typed helpers or variants
- extension through composition instead of broad customization
- opinionated defaults with minimal public knobs

Use `DesignSystemTheme` and the existing component theme builders as the default theme reference for:
- keeping widget styling aligned with the app's `ThemeData`
- separating `ThemeData` assembly from component theme implementation
- avoiding hardcoded presentation values when the app theme should own them

If the written guidance and the current source tree disagree, follow the current source tree.

## Inputs

Collect or infer these inputs before updating:
- existing widget name or file path
- optional new widget name for a renamed successor widget
- a natural-language change brief describing what should change
- optional screenshot or mockup reference for the desired visual update
- whether the change is visual only, behavioural, or both
- whether the widget is controlled by the caller
- whether the change requires a theme hook or can use the existing `ThemeData`

If the user does not provide a change brief:
- do not update the widget
- stop and return a short, human-readable message explaining that a change description is required
- include a short list of common update types they can choose from

Use wording like:
- `I need a short description of what should change in this widget before I can update it. You can tell me things like: align it to the current shared-widget style, improve the docs, move styling into ThemeData, preserve the public API while cleaning up the internals, or add a small new capability without breaking callers.`

If the widget cannot be found:
- stop and return a short, human-readable message

If multiple widgets plausibly match the given name:
- stop and ask which one should be updated

## Workflow

### 1. Locate the existing widget first

Find the existing widget before planning the update.
Prefer exact file matches under `lib/presentation/widgets/`.

Do not invent a replacement widget if the existing one cannot be found.

If the request includes a rename target such as `widget -> widget_v2`:
- treat the source widget as the behavioural reference
- create the updated widget under the new name
- preserve current behaviour by default unless the brief explicitly asks for changes
- do not silently delete or rewrite the original widget unless the user explicitly asks for an in-place replacement

### 2. Inspect the widget's current contract

Read the widget and infer its current public contract before editing.

Inspect:
- constructor parameters
- public fields
- callback names and payloads
- state ownership
- static entrypoints such as `show`, `page`, `blocking`, or `compact`
- any existing theme usage
- whether the current layout materially differs from any attached screenshot or mockup

### 3. Inspect current usages

Read current call sites before changing the widget.

Use the usages to understand:
- how callers construct the widget
- which parameters are relied on
- whether the widget is controlled by the caller
- whether changing callback semantics would break existing behaviour

If a screenshot or mockup is attached:
- use it to guide visual changes only
- do not let it override the observed behaviour of current callers unless the user explicitly asks for that change

### 4. Preserve behaviour by default

Preserving current functionality is the default.

Do not change these unless the user explicitly asks:
- public class name
- filename
- constructor parameter names
- callback semantics
- state ownership model
- navigation behaviour
- modal entrypoint behaviour

Prefer additive or internal refactors over breaking changes.

If a new widget name was provided:
- preserve the source widget's behaviour as the default baseline for the new widget
- rename the class and file to the requested target name
- update copied docs and examples to match the new name
- do not mutate existing callers unless the user explicitly asks for usage migration too

If the requested change conflicts with current behaviour:
- explain the conflict clearly
- make the smallest safe change that satisfies the request
- if there are multiple plausible interpretations, stop and ask

Do not infer behavioural changes from visuals alone when current usage suggests otherwise.

### 5. Apply shared-widget standards carefully

When updating the widget, improve it using the same standards as `$shared-widget`:
- richer dart doc comments
- narrow public API
- open-for-extension structure
- theme-backed styling
- small, focused responsibility

Do not "clean up" the widget by removing behaviour that callers currently depend on.

### 6. Route visual changes through ThemeData

When the update changes a standard Material control or shared visual pattern:
- use the existing `ThemeData` where possible
- extend the matching theme slot when needed
- keep the `ThemeData` entrypoint mostly declarative
- add concrete implementation in a separate helper class

For Project Tweety, prefer:
- `packages/design_system/lib/src/theme/design_system_theme.dart`
- `packages/design_system/lib/src/theme/components/<component>_theme.dart`

### 7. Handle controlled widgets explicitly

If the widget is controlled by the caller:
- preserve that model by default
- keep the selected/current value caller-owned
- keep the callback typed and explicit
- do not introduce internal long-lived state unless explicitly requested

Typical controlled patterns:
- radio widgets: current selected value plus typed callback
- checkbox widgets: current boolean value plus typed callback
- segmented selection widgets: current selected value plus typed callback

### 8. Finish with review-friendly output

After updating source files:
- run formatting if needed
- run targeted tests when tests are part of the task
- if a new widget name was provided, summarize whether the original widget was left untouched
- summarize what was intentionally preserved
- summarize what changed
- include a small usage snippet showing the updated calling pattern
- include a short manual review checklist
- if a screenshot or mockup was used, summarize which visual changes were guided by it and which behaviours were intentionally preserved from the original widget

The manual review checklist should usually cover:
- existing callers still compile
- callback behaviour is unchanged unless intentionally updated
- state ownership is still correct
- light and dark theme appearance still look right
- any static entrypoints still behave the same

## File Contract

Use [update_widget_contract.md](references/update_widget_contract.md) for the default preservation rules, theme expectations, and manual review checklist shape for existing widgets.
