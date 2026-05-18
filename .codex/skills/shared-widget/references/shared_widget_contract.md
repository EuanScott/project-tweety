# Shared Widget Contract

Use this reference when creating shared widgets for Project Tweety.

A human-readable widget description is required before scaffolding.
Do not scaffold from a widget name alone.

Screenshots or mockups can be used as visual references, but they do not
replace the need for a text description of behaviour and interaction.

This contract is for app-specific reusable widgets under:
- `lib/presentation/widgets/`

It is not the default contract for:
- page-scoped widgets that belong under a specific page folder
- low-level design-system primitives that should live in `packages/design_system/`

## Placement

Prefer `lib/presentation/widgets/<widget_name>.dart` when the widget:
- is reused across multiple app areas
- encodes an app-specific presentation pattern
- should stay close to page code instead of becoming a design-system primitive

Examples from the repo:
- `lib/presentation/widgets/app_modal.dart`
- `lib/presentation/widgets/webview_modal.dart`
- `lib/presentation/widgets/page_scaffold.dart`
- `lib/presentation/widgets/app_bar.dart`

Theme references in this repo:
- `lib/main.dart`
- `packages/design_system/lib/src/theme/design_system_theme.dart`
- `packages/design_system/lib/src/theme/components/`

## Naming

- widget filenames should stay in snake_case, for example `webview_modal.dart`
- public widget classes should use PascalCase, for example `WebviewModal`
- helper types should be specific and typed, for example `CustomAppBarAction`

## Public API Style

Default to a narrow public API.
Prefer an opinionated widget with strong defaults over a reusable-looking widget with many escape hatches.

When the request arrives as a plain-English brief, infer the smallest useful public contract from that description before writing code.

If a screenshot or mockup is attached:
- use it to infer layout, grouping, spacing, and visual hierarchy
- do not use it as the only source of truth for behaviour or state ownership

If no description is provided:
- stop instead of guessing
- ask for a short description of the widget's role, inputs, and interaction behaviour
- keep the failure message human-readable and non-technical

Prefer:
- one main widget class
- one or more static entrypoints when the widget is presented through a modal or controlled interaction flow
- small typed helper classes when a single structured extension point improves clarity
- a constrained first version that can grow later through new variants

Avoid by default:
- long constructors with many optional overrides
- exposing every spacing, color, or typography choice
- builder callbacks for cases that do not yet need them
- boolean flags that create many unrelated modes in one constructor
- mirroring the underlying Flutter API just to appear flexible

Preferred patterns from current source:
- `AppModal.page`, `AppModal.blocking`, and `AppModal.compact`
- `WebviewModal.show`
- `CustomAppBarAction` as a typed trailing action instead of loosely structured parameters
- `DesignSystemTheme.light(...)` and `DesignSystemTheme.dark(...)` as the `ThemeData` entrypoints
- separate helper classes such as `DesignSystemCardTheme` for concrete theme implementation

Preferred inference patterns for descriptive briefs:
- `tappable row`, `line item`, or `cell` often maps to a small stateless widget with `VoidCallback onTap`
- `title and body text` often maps to required string fields rather than text widgets passed from the caller
- `icon at the end` often maps to a fixed trailing icon when the icon communicates a stable app pattern
- `opens` or `breaks out to` another experience should usually remain a caller-owned callback, not embedded navigation logic

When visuals and text are both available:
- use the screenshot for visual fidelity
- use the text brief for behaviour, contract, and ownership decisions
- prefer the text brief if the two conflict

Preferred patterns for controlled widgets:
- single-selection widgets should usually be caller-controlled
- radio widgets should usually take `options`, `selectedOption`, and a typed callback such as `ValueChanged<String>`
- checkbox widgets should usually take the current value and `ValueChanged<bool>`
- the widget should render from caller-owned state and emit changes back up, not retain long-lived selection state internally

## Constructor Safety

Public widget constructors should fail early in debug mode when callers build an invalid widget contract.

Use assertions for constraints the type system cannot express, such as:
- required display strings that must not be empty
- option lists that must contain at least one item
- selected values that must exist in the available options
- numeric values that must stay within a meaningful range
- mutually exclusive parameters that cannot be provided together

Keep assertions targeted and actionable:
- include a clear assertion message
- do not assert what the Dart type system already guarantees
- do not replace runtime error handling for user or network data with constructor assertions

Preferred shape:

```dart
const ExampleWidget({
  super.key,
  required this.title,
  required this.options,
  required this.selectedOption,
  required this.onChanged,
}) : assert(title.length > 0, 'title must not be empty'),
     assert(options.length > 0, 'options must not be empty'),
     assert(
       options.contains(selectedOption),
       'selectedOption must be included in options',
     );
```

## Key Strategy

Public widgets should expose normal Flutter identity by accepting `super.key`.

When the widget generates repeated children, provide stable keys when identity matters across rebuilds.
Prefer keys derived from durable values already present in the contract, such as option ids, route names, or stable labels.

Prefer:
- `super.key` on the public widget constructor
- `ValueKey(option.id)` or `ValueKey(option.value)` for repeated generated children
- caller-provided keys when the caller owns the identity

Avoid:
- creating `UniqueKey()` in `build`, because it changes identity on every rebuild
- adding keys to every private child when there is no list, reorder, animation, state retention, or test identity need
- deriving keys from indexes when the list can reorder

## ThemeData Contract

Shared widgets should consume a defined app `ThemeData`.

Prefer:
- reading presentation values from `Theme.of(context)`
- using the existing app theme entrypoint instead of local visual definitions
- extending theme helper classes when a new shared visual treatment is needed
- wiring standard Material controls through their matching `ThemeData` slots when the widget introduces that control pattern

Avoid by default:
- hardcoded colors when a themed color is appropriate
- bespoke text styles inside widget files when `textTheme` should own them
- creating styling parameters to sidestep missing shared theme structure

If a theme structure does not already exist:
- create a minimal theme entrypoint for the app's `MaterialApp`
- keep the `ThemeData` builder mostly declarative
- move concrete component styling into separate helper classes

For Project Tweety, the preferred shape is:
- a top-level theme class that builds `ThemeData`
- separate theme helper classes under `packages/design_system/lib/src/theme/components/`
- widgets consuming those values through `Theme.of(context)` or themed Material components

Examples:
- radio selection widgets should prefer `radioTheme`
- app bars should prefer `appBarTheme`
- shared card-like surfaces should prefer `cardTheme`

## Responsibility Boundaries

Shared widgets should:
- own layout and presentation of a reusable UI pattern
- standardize common calling patterns
- keep internal implementation details private when possible

Shared widgets should not:
- own business workflows
- dispatch feature events
- fetch data
- make navigation decisions beyond returning values to the caller

Use wording similar to the existing widgets:
- the widget is responsible only for rendering or hosting the pattern
- workflow-specific behavior should remain in the caller or a dedicated child widget

## Documentation Style

Follow the widget documentation style already used in the repo.

Document:
- each public class
- each public constructor
- each public field
- each static entrypoint

Documentation should:
- describe the widget's responsibility
- explain what the caller still owns
- document parameters in concise prose
- note return values for modal helpers or async entrypoints
- include examples only when they add real clarity

Final scaffold output should include:
- a short usage snippet showing the widget constructed from a calling page
- the callback handling pattern expected by the scaffold

## Widget Test Contract

New shared widgets should include focused widget tests by default.

Place tests under:
- `test/presentation/widgets/<widget_name>_widget_tests.dart`

Tests should cover the public contract instead of private implementation detail:
- visible text, icons, or layout markers that define the widget's output
- callback behaviour and caller-owned state updates
- important variants, static entrypoints, or helper objects
- constructor assertions for invalid inputs when assertions were added
- stable keys for repeated generated children when those keys are part of the implementation contract

If there is no practical widget test for the generated widget, state the reason in the final response and run the closest targeted validation.

## Open-Closed Heuristics

Favor extension through new public entrypoints, typed helper types, or child composition.
Open for extension does not mean open for endless constructor configuration.

Good first-pass choices:
- add `show()` to present a modal consistently
- add a private `_show()` implementation behind multiple public variants
- add a small helper type for actions or options that belong together

Avoid premature flexibility:
- theming every aspect of the widget up front
- adding optional callbacks for future scenarios that do not exist yet
- turning a shared widget into a generic framework
- exposing customization points that have no active caller in the app
- bypassing the shared theme because adding a proper theme hook feels slower

## Default Output Shape

For most new shared widgets, the first version should be a single Dart file that contains:
- the public widget
- any tiny typed helper type if required
- private implementation details that do not need their own file

Split into multiple files only when the widget grows beyond a small, readable unit or when the user explicitly asks for that structure.
