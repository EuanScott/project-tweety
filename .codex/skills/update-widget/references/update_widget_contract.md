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
- adding `super.key` to public widget constructors when missing
- adding targeted constructor assertions when current callers already satisfy the intended contract
- adding stable keys for repeated generated children when identity matters across rebuilds

If a rename target is provided:
- copy forward the current behaviour into the new widget by default
- rename the file and class to match the requested target
- leave the original widget untouched unless explicitly asked to replace it

If adding assertions would fail against an existing caller:
- stop and explain the mismatch between the intended contract and current usage
- do not silently change the caller or weaken the assertion without user confirmation

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

## Constructor Assertions

Updated shared widgets should fail early in debug mode when callers build an invalid public contract.

Use assertions for constraints the type system cannot express, such as:
- non-empty labels or display strings
- non-empty option lists
- selected values that must be present in the available options
- ranges for numeric inputs
- mutually exclusive parameter combinations

Do not assert conditions already guaranteed by non-nullable types.
Do not use constructor assertions as a substitute for handling runtime data failures.
Keep assertion messages short and actionable.

Preferred shape:

```dart
const ExistingWidget({
  super.key,
  required this.title,
  required this.options,
  required this.selectedOption,
}) : assert(title.length > 0, 'title must not be empty'),
     assert(options.length > 0, 'options must not be empty'),
     assert(
       options.contains(selectedOption),
       'selectedOption must be included in options',
     );
```

## Key Strategy

Public widgets should accept `super.key` unless the existing constructor shape prevents that without a breaking change.

When an updated widget generates repeated children, use stable keys when identity matters across rebuilds.
Prefer keys derived from durable contract values, such as option ids, enum values, route names, or stable labels.

Avoid:
- creating `UniqueKey()` in `build`
- adding keys to every private child when identity does not matter
- using list indexes as keys when items can be reordered

## Widget Tests

Updates should add or refresh widget tests when the change touches:
- public API or constructor assertions
- callback behaviour or caller-owned state
- visual variants or static entrypoints
- theme-backed rendering that can be asserted without brittle pixel tests
- repeated generated children where stable keys are part of the contract

Place tests under:
- `test/presentation/widgets/<widget_name>_widget_tests.dart`

If the existing widget has no tests and the update materially changes behaviour or contract, add a focused test file.
If no practical test can be added, state why in the final response and run the closest targeted validation.

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
- verify constructor assertions catch invalid usage in debug builds
- verify generated repeated children keep stable identity when keys were added
