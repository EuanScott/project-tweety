---
name: shared-widget
description: Scaffold a shared widget for Project Tweety under lib/presentation/widgets using the repo's focused wrapper style. Use when adding reusable app widgets such as modals, page shells, app bars, or small UI building blocks that should have rich dart doc comments, narrow public APIs, and opinionated defaults. A human-readable widget description is required. Prefer extension-friendly structure without turning the widget into a highly customizable surface.
---

# Shared Widget Scaffold

Scaffold a shared widget in `lib/presentation/widgets/`.
Use this when the work is a reusable app widget such as a modal, page shell, app bar, or similar shared presentation building block.

## Help mode

If the user invokes this skill with `--help`:
- do not scaffold or edit files
- return a short, human-readable help response
- explain what the skill does
- list the required and optional inputs
- mention that screenshots or mockups can be supplied as visual references
- show one or two example invocations

A natural-language widget description is required.
The user may still provide a widget name, but the name alone is not enough to scaffold from safely.

Attached screenshots or mockups can be used as visual references.
They help infer layout, hierarchy, spacing, and visual intent, but they are
not enough on their own to safely infer behaviour or API shape.

Start by reading:
- Root `AGENTS.md`
- `lib/AGENTS.md`

Then inspect the closest existing widget in `lib/presentation/widgets/`.
Prefer current source examples over older written guidance.

Inspect the active app theme before finalising widget styling.
For this repo, also read:
- `packages/design_system/AGENTS.md` when the widget needs theme-backed styling or the theme structure may need to be created or extended
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

Collect or infer these inputs before scaffolding:
- widget name in snake_case, if explicitly provided
- a natural-language widget brief describing the widget's UI, behaviour, and affordances
- optional screenshot or mockup reference for the desired visual design
- the widget's single responsibility
- whether it is a plain wrapper widget, a stateful interaction widget, or a widget with static entrypoints such as `show`
- whether a small typed helper object is needed, such as an action or config value object
- whether the widget belongs in `lib/presentation/widgets/` or should live in `packages/design_system/`
- whether the widget can be fully styled from the existing `ThemeData` or needs a new theme hook

When the user gives a descriptive brief, infer these implementation details before scaffolding:
- the most likely widget name and filename
- the minimum public inputs, such as `title`, `body`, `onTap`, or a destination label
- whether the interaction should be exposed as a callback instead of the widget directly performing navigation or business logic
- the simplest visual affordance that matches the description
- whether any visual treatment should come from `Theme.of(context)` or from a dedicated theme helper instead of inline values

If a screenshot or mockup is attached, also infer from it:
- layout and spacing relationships
- content hierarchy such as title, subtitle, supporting text, and actions
- icon placement and likely visual affordances
- whether the widget feels like a row, card, modal, section, or grouped control

For controlled widgets, also infer:
- which value is owned by the calling page
- which callback communicates the updated value back to the caller
- whether the widget should remain stateless and render purely from caller-owned inputs

If the user does not provide a descriptive brief:
- do not scaffold the widget
- stop and return a short, human-readable message explaining that a widget description is required
- ask for the missing description in plain language

Use wording like:
- `I need a short description of the widget before I can scaffold it. For example: what it shows, what inputs it takes, and what should happen when the user interacts with it.`

Ask a short clarifying question only if ownership or placement is genuinely ambiguous, or if the brief implies multiple equally plausible interaction contracts.

## Workflow

### 1. Confirm the widget belongs here

Default to `lib/presentation/widgets/` when the widget is app-specific and tied to Project Tweety flows.

If the widget is a low-level design primitive that should be broadly themeable across apps, pause and consider `packages/design_system/` instead.
Do not silently move the work there unless the user asked for that package.

### 2. Inspect the closest existing pattern

Read the nearest widget that matches the requested shape before generating files.

Use these repo examples intentionally:
- `app_modal.dart` for shared entrypoints and internal implementation reuse
- `webview_modal.dart` for focused modal widgets with a `show` helper
- `page_scaffold.dart` for narrow page-shell wrappers
- `app_bar.dart` for typed helper classes and concise widget APIs

Inspect the current theme structure too:
- `lib/main.dart` for how `MaterialApp` receives theme data
- `packages/design_system/lib/src/theme/design_system_theme.dart` for the current `ThemeData` entrypoint
- `packages/design_system/lib/src/theme/components/` for the preferred helper-class pattern

If the current source tree already has a theme system, align with it instead of inventing a local styling approach inside the widget.

If a screenshot or mockup is attached:
- use it as the primary visual reference for layout and presentation
- still use the repo's existing widgets and theme files as the structural and code-style reference

### 3. Translate a plain-English brief into a widget contract

If the user provides a descriptive brief instead of a concrete API, convert it into a small widget contract before writing code.

Infer:
- the widget name and filename from the widget's purpose
- the smallest public constructor that supports the described use case
- whether interactions should be emitted as callbacks
- the trailing affordance or static decoration implied by the brief

Prefer these interpretations:
- `when tapped it should emit some kind of event` usually becomes a required `VoidCallback onTap`
- descriptive text content usually becomes narrow string inputs such as `title` and `body`
- `shows this goes to the web view` usually becomes a fixed trailing icon that signals external navigation, not a configurable icon parameter

For controlled widgets, prefer these interpretations:
- radio groups should usually take `options`, the currently selected value, and a typed change callback such as `ValueChanged<String>`
- checkbox-style widgets should usually take the current boolean value and a typed change callback such as `ValueChanged<bool>`
- segmented, tab-like, or single-selection widgets should usually take the current selected value and a typed change callback
- the shared widget should not own persistent selection state unless the brief explicitly asks for local transient UI state
- callback names should describe the interaction clearly, preferring `onChanged` or a typed callback over an unstructured event concept when the control already has an established Material pattern

Do not infer behaviour from visuals alone when the interaction contract is unclear.
If the screenshot suggests an interaction but the brief does not explain it:
- keep the behaviour minimal and caller-owned by default
- ask a short clarifying question only when the ambiguity would materially affect the public API

Keep the contract app-specific and opinionated.
Do not invent extra parameters unless the brief clearly requires them now.

### 4. Route visual styling through ThemeData

Shared widgets should make use of a defined `ThemeData` for the app.
Do not treat widget files as the place to define the visual system.

Follow these rules:
- prefer `Theme.of(context)` for colors, text styles, icon themes, card styling, and other presentation values
- use existing theme-backed component widgets and styles before introducing new inline values
- avoid hardcoded colors, text styles, and visual constants when the current theme can own them
- allow small layout constants such as local spacing only when they are structural and not part of the visual token system

If the widget needs a new visual pattern that should be standardized:
- extend the existing theme structure instead of embedding bespoke styling in the widget
- keep the `ThemeData` entrypoint mostly declarative
- add the concrete implementation in a separate helper class that the `ThemeData` builder calls

If the widget introduces a standard Material control pattern such as radio,
checkbox, switch, card, app bar, or button styling:
- create or extend the matching `ThemeData` slot, even when the first version is minimal
- add a dedicated helper class for that control instead of styling the control locally in the widget
- wire that helper into the top-level theme builder before finishing the widget scaffold

If no theme structure exists yet for the app:
- create a minimal theme entrypoint that the `MaterialApp` can use
- keep the `ThemeData` definition mostly empty and delegate to separate helper classes
- mirror the current repo's style by using a dedicated theme class plus focused helper implementations

For this repo, prefer a structure like:
- `packages/design_system/lib/src/theme/design_system_theme.dart` as the `ThemeData` entrypoint
- `packages/design_system/lib/src/theme/components/<component>_theme.dart` for concrete theme builders

For example:
- a shared radio selection widget should typically route through `radioTheme`
- the radio theme should live in its own helper such as `design_system_radio_theme.dart`
- `DesignSystemTheme` should stay mostly declarative and call that helper

### 5. Create one focused public widget file

Create the widget in:
- `lib/presentation/widgets/<widget_name>.dart`

Follow these rules:
- use `feature_or_entity.role.dart` naming only when the file already fits that convention; otherwise mirror the existing widget naming style in this folder
- name the public widget class in PascalCase, for example `WebviewModal`
- keep one clear responsibility per widget file
- keep business logic out of the shared widget
- prefer `StatelessWidget` unless local UI state is genuinely required
- consume the active theme inside the widget instead of defining visual values ad hoc

### 6. Prefer open-closed structure over broad parameter surfaces

Keep the public API intentionally narrow.
Default to the least customizable shape that still solves the current use case well.

Follow these rules:
- do not expose a long list of styling and layout knobs by default
- do not add optional parameters just because a future caller might want them
- prefer well-named variants or static entrypoints such as `page`, `blocking`, `compact`, or `show` over boolean-heavy constructors
- prefer small typed helper objects when the caller needs one structured extension point, such as `CustomAppBarAction`
- keep shared internals private when only public entrypoints should vary
- allow extension by composing child widgets or adding new entrypoints later, not by making the first version endlessly configurable
- treat customizability as a cost; only add it when there is a current, concrete caller need
- do not add styling parameters merely to work around a missing theme hook; extend the theme structure instead when the styling should be shared

### 7. Write rich dart doc comments

Mirror the documentation style used in the existing widgets.

Follow these rules:
- add a file-level class doc comment for each public class
- document every public constructor, static entrypoint, and public field
- explain responsibility boundaries clearly, including what should remain in the caller
- document when the widget's appearance is intentionally driven by the app theme
- prefer short, useful prose over repeated boilerplate
- include small examples only when they materially clarify usage
- do not add inline comments unless the behavior is genuinely non-obvious

### 8. Keep the implementation small and opinionated

Do not over-generate.
Avoid adding:
- theme override parameters for every color, spacing, and text style
- pass-through parameters that simply mirror every Flutter primitive option
- generic builder hooks unless the widget truly needs them now
- dependency injection, BLoC wiring, analytics, or navigation decisions inside the widget
- extra files unless a typed companion object or test is clearly justified
- alternate constructor modes that do not correspond to a real app pattern
- local visual systems that bypass the app theme
- direct theme assembly inside the widget file

### 9. Finish cleanly

After creating source files:
- run formatting if needed
- run targeted tests when tests are part of the task
- if theme files were created or extended, summarize the new theme entrypoint and helper classes
- summarize any intentionally omitted customization points so the constrained API is explicit
- always include a small usage snippet in the final response that shows how the calling page should construct the widget and handle the callback
- if a screenshot or mockup was used, summarize which visual decisions were taken from it and which behavioural decisions still came from the text brief

## File Contract

Use [shared_widget_contract.md](references/shared_widget_contract.md) for the expected placement, API shape, documentation style, and extension heuristics for shared widgets.

## Brief Example

Input brief:
- `A line item that accepts a title and body text. When tapped it should emit an event. At the end I want an icon that shows tapping this item will break the user out to a web view.`

Reasonable first-pass scaffold:
- widget name such as `WebviewLineItem`
- file such as `lib/presentation/widgets/webview_line_item.dart`
- public inputs such as `title`, `body`, and `onTap`
- a fixed trailing launch-style icon
- tap handling exposed through the callback instead of embedding navigation logic in the widget
- title and body text styled from `Theme.of(context).textTheme` instead of ad hoc text styling
