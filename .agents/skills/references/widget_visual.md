# Widget Visual Branch

Read this reference only when a widget request includes a screenshot, mockup,
theme change, adaptive control, or other visible presentation work.

## Sources

- Treat the brief and callers as behavioural truth; visual references define
  layout, hierarchy, spacing, and visual intent.
- For app placement, read `lib/presentation/widgets/AGENTS.md`, inspect the
  public design-system exports, and read one closest app-widget example.
- For design-system placement, read `packages/design_system/AGENTS.md`, its
  public export, and one closest adaptive primitive with its focused test.
- Inspect the other branch only when the brief includes cross-boundary caller
  integration.

## Theme and primitive boundary

Use the existing app theme for colours, typography, surfaces, and standard
control styling. Structural spacing may stay local when it is specific to the
widget rather than a shared token.

Pages and app widgets express intent through exported design-system
primitives. When an app brief lacks one, add a narrow adaptive primitive, test
and export it, then consume it from the app widget. For a direct design-system
brief, stop after the tested public export unless caller integration was also
requested.

Keep `DesignSystemTheme` declarative. Put a reusable standard-control theme in
the matching component-theme helper rather than assembling it inside a widget.

## Verification gate

Finish this branch when:

- behavioural choices are traceable to text or existing callers;
- visual choices are traceable to the supplied reference or active theme;
- the public design-system export was checked before adding a control;
- targeted tests cover observable adaptive or theme-backed behaviour;
- residual light/dark or platform-specific checks are listed only when they
  cannot be automated.
