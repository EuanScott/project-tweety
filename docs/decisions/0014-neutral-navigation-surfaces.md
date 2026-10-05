# ADR-0014: Navigation uses neutral surfaces; only the selected item carries the brand colour

Status: accepted
Date: 2026-10-05
Decision maker: Euan Scott

## Context

The app's top-level navigation is a tab bar or sidebar on iOS, and a
navigation bar, rail or drawer on Android. Before this decision, the rail,
the drawer and the light Android app bar were filled with brand colour. Each
brand carried eight `navigation*` tokens for this. The Android indicator was a
filled `primary` pill. The iPad sidebar marked the selected row with a
checkmark. An iPhone in landscape got the iPad sidebar.

Both platforms show navigation on neutral surfaces. The design system also has
a "quiet surfaces" principle. A planned set of theme colours would need eight
more tokens per theme colour if navigation stayed branded.

The guideline sources are in
[`docs/research/navigation-platform-guidelines-2026.md`](../research/navigation-platform-guidelines-2026.md).
The Material 3 colour roles were verified against Flutter's generated token
defaults in `material_ui` 1.0.0. The Apple findings come from search summaries
of Apple's pages, not from a full reading of them.

## Decision

**We will draw every navigation surface in a neutral colour, in every theme
colour and mode, and only the selected item will carry the brand colour.**

- **D1. Neutral surfaces.** The navigation bar, rail and drawer use one
  derived surface: the page colour darkened 4% in light mode, and the raised
  surface in dark mode. It is stored in the colour scheme's
  `surfaceContainerHigh`. The brand has no navigation tokens.
- **D2. Soft primary indicator.** The Android selected item uses the Material 3
  structure: a fully rounded, soft tinted pill and neutral labels.
  - The tint comes from `primary`, not from `secondary`. The style guide keeps
    `secondary` for small marks only.
  - The tint is `primary` at 12% (light) or 24% (dark) over the navigation
    surface. It is stored in `primaryContainer`.
  - The selected icon is `primary` in light mode and `onSurface` in dark mode.
    It is stored in `onPrimaryContainer`. A dark-mode `primary` can be too
    dark on its own tint.
- **D3. No sidebar checkmark.** The iPad sidebar shows the selected row with a
  6% `primary` tint only. Apple uses checkmarks for choices in lists and menus,
  not for navigation. At 12%, Fjord `primary` text is 4.25:1 on the tint. At
  6% it is 4.59:1, which passes the 4.5:1 text rule (Web Content
  Accessibility Guidelines, level AA).
- **D4. iOS chooses its layout by the shortest side.** Side navigation shows
  only when the window's shortest side is at least 600. An iPhone keeps the
  tab bar in both orientations. Android keeps the width rule, because Material
  window size classes are based on width.
- **D5. Titles stay bold and in `primary`.** This is a brand choice, not the
  native look. iOS large titles use the label colour, and Material titles use
  `onSurface`. The app bar itself is `surface` in both modes.

## Alternatives

- **Branded navigation surfaces (the old design).** Strong brand, but not
  native, and it needs eight tokens per theme colour.
- **Literal Material 3 `secondaryContainer` indicator.** Native, but here it
  puts the plum accent on a large area, against the style guide.
- **Filled `primary` pill.** Strongest brand on the selected item, but not the
  Material 3 look.
- **Per-component Material containers** (`surfaceContainer` for the bar,
  `surface` for the rail, `surfaceContainerLow` for the drawer). Native, but in
  this palette `surfaceContainer` is the white card colour, lighter than the
  page. One shared, darker surface gives every navigation component a visible
  edge. It also matches the Navigation page of the "Tweety app screens"
  design canvas.

## Consequences

- Some roles differ from the Material 3 baseline on purpose:
  - All three components use one container colour.
  - The indicator is a `primary` tint, not `secondaryContainer`.
  - The drawer's selected label is `onSurface`, not the container ink. In
    light mode, `primary` on the tint is about 4.0:1. That fails the 4.5:1
    text rule.
- The rail's unselected label is `onSurface`, as the Material 3 rail token
  says. The bar and the drawer use `onSurfaceVariant` for unselected labels.
- `surfaceContainerHigh`, `primaryContainer`, `onPrimaryContainer` and
  `onSurfaceVariant` are app-wide colour scheme roles. Other Material widgets
  read them too. In light mode the Android alert dialog now uses the
  navigation surface. List-tile subtitles and text-field labels use the 60%
  muted ink.
- The navigation shell no longer recolours the app bar next to the rail or
  drawer. The app bar shows the page surface beside the navigation surface.
- A narrow iPad window (Split View or Slide Over) with a shortest side under
  600 gets the tab bar, as iPadOS does.
- New theme colours need no navigation tokens.
- Re-evaluate when the app adopts Liquid Glass on iOS 26, or the Material 3
  Expressive expanded rail in place of the drawer. Flutter's `cupertino_ui`
  and `material_ui` do not provide either yet. Both are follow-up work.

## Confirmation

- `packages/design_system/test/theme/design_system_navigation_theme_test.dart`
  checks the navigation roles, the indicator shape and the light app bar. It
  also checks the contrast of every navigation label and icon for every
  brand.
- `packages/navigation/test/navigation_router_test.dart` checks the iPhone and
  iPad landscape layouts, the missing checkmark, and that the shell leaves the
  app bar theme unchanged.
- `DesignBrand` has no `navigation*` fields. Adding one back needs a new ADR.
