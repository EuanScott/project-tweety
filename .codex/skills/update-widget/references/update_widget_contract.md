# Update Widget Contract

Use this reference when updating an existing shared widget for Project Tweety.

This contract is for widgets that already exist under:
- `lib/presentation/widgets/`

Screenshots or mockups can be used as visual references for an update, but
they do not replace the need for a text description of what should change.

## Core Principle

Preserve existing behaviour by default.

The goal is to improve or extend the widget while keeping current callers working unless the user explicitly asks for a breaking change.

This skill supports two modes:
- in-place update of the existing widget
- renamed successor creation, for example `widget -> widget_v2`

## Required Inputs

Do not begin updating until both are available:
- the widget name or file path
- a human-readable description of what should change

Optional:
- a new widget name for the updated version

If either is missing:
- stop instead of guessing
- return a short, human-readable message
- include examples of the kinds of updates the user can request

Examples of acceptable update requests:
- align the widget to the current shared-widget style
- improve dart doc comments
- preserve the public API but move styling into `ThemeData`
- add a small capability without breaking current callers
- create a `widget_v2` version while keeping the original widget untouched

## Preserve By Default

Do not change these unless explicitly requested:
- public class name
- filename
- constructor parameter names
- callback names
- callback payload types
- state ownership model
- static entrypoints
- navigation behaviour

Prefer:
- internal refactors
- additive parameters
- doc improvements
- theme integration with the smallest surface-area change

If a rename target is provided:
- copy forward the current behaviour into the new widget by default
- rename the file and class to match the requested target
- leave the original widget untouched unless explicitly asked to replace it

## Usage Inspection

Before editing, inspect current usages to understand:
- how callers construct the widget
- whether the widget is controlled by the caller
- which callbacks or parameters are actively relied on

If usages imply conflicting contracts:
- stop and explain the ambiguity instead of guessing

If a screenshot or mockup is attached:
- use it as a visual target only
- prefer existing usage patterns over visual inference for behaviour and API decisions

## ThemeData Expectations

When visual behaviour is updated:
- prefer `Theme.of(context)`
- prefer existing themed Material controls
- extend the matching `ThemeData` slot when the widget introduces or updates a standard control pattern

For Project Tweety, prefer:
- `packages/design_system/lib/src/theme/design_system_theme.dart`
- helper implementations under `packages/design_system/lib/src/theme/components/`

Examples:
- radio updates should prefer `radioTheme`
- app bar updates should prefer `appBarTheme`
- shared surface updates should prefer `cardTheme`

## Controlled Widgets

If the widget is caller-controlled:
- preserve caller ownership by default
- keep the current value passed in from the caller
- emit changes back through a typed callback
- do not silently move state into the widget

Examples:
- radio widgets: `options`, current selected value, typed callback
- checkbox widgets: current value, typed callback

## Required Final Output

The final output should include:
- what was preserved
- what changed
- whether the original widget was updated in place or a renamed successor was created
- a short usage snippet
- a short manual review checklist
- a note about whether a screenshot or mockup was used as part of the update

Suggested manual review items:
- verify existing usages still compile
- verify callback semantics still match the old behaviour
- verify visual behaviour in light and dark theme
- verify any entrypoints or variants still behave correctly
