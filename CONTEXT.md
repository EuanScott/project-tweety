# project-tweety

A Flutter playground app for exploring ideas, patterns, and experiments
outside of production work.

## Language

**Component Gallery**:
The `packages/design_system/example` app that renders every `design_system`
widget for visual evaluation.
_Avoid_: Storybook, component library

**Showcase**:
One Component Gallery page dedicated to a single widget, rendered
simultaneously in both platform panes.
_Avoid_: Demo, example page

**Comparison pane**:
One half of a showcase's two-pane layout, rendering the widget under one
platform's design language (Material or Cupertino) via a `Theme.platform`
override.
_Avoid_: Preview, panel
