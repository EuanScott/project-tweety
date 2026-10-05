# Navigation: guidelines alignment handoff

This document is the brief for a fresh implementation session. It covers the
app's top-level navigation: the tab bar, the navigation bar, the rail, the
sidebar and the drawer. Read all of it before you start.

- Companion work: [`theme_colours_implementation.md`](theme_colours_implementation.md).
  Do this navigation work **first**. The theme colour work assumes it has landed (section 7.6).
- Style: [`docs/design/visual_style.md`](../design/visual_style.md)
- Package: `packages/navigation` (the shell) and `packages/design_system` (the themes).

## 1. Goal and scope

Navigation must look native on each platform and must stay neutral in every
theme colour. Only the selected item carries the brand colour. The navigation
background never does.

The current code has three problems:

1. Navigation backgrounds and the Android light app bar carry brand colour.
2. Some styles break the platform guidelines (Apple Human Interface Guidelines
   and Material 3).
3. An iPhone in landscape gets an iPad sidebar. This is a behaviour bug.

**In scope**

- Verify the two uncertain guideline points first (section 3).
- Neutral backgrounds for the Material navigation bar, rail, drawer and app bar (section 7.2 to 7.4).
- The Cupertino sidebar: remove the checkmark, fix the selection tint (section 7.5).
- Layout choice on iOS by shortest side, not width (section 7.1).
- Remove the brand navigation colour tokens from `DesignBrand` (section 7.6).
- Tests, docs and one ADR (sections 8 and 9).

**Out of scope**

- The theme colour presets and the settings picker. They are in the companion document.
- Liquid Glass (iOS 26) and Material 3 Expressive components. Section 3 decides
  only whether they need a follow-up ticket.
- Page content. The mocks show a placeholder.

## 2. Design references

Read Claude Design links with the Artifact tool (`action: "read"`), never with
a web fetch. They are private to the repository owner.

- **Mocks:** [Tweety app screens](https://claude.ai/artifact/1E1Gc7Nrw9zEAZkscfEREL), page **Navigation**.
  - Row **iOS · Light** and **iOS · Dark**: `Nav-iOS-iPhone-*` (tab bar),
    `Nav-iOS-iPad-*` and `Nav-iOS-iPad-landscape-*` (sidebar).
  - Row **Android · Light** and **Android · Dark**: `Nav-Android-phone-*` and
    `Nav-Android-fold-cover-*` (navigation bar), `Nav-Android-fold-open-*` and
    `Nav-Android-tablet-*` (rail), `Nav-Android-tablet-landscape-*` (drawer).
  - In Play, tap a tab to select it. The toggle at the top collapses the sidebar and the drawer.
  - Tweaks: `palette`, `mode`, `tab`, and `collapsed` on sidebars and drawers.
- The mocks show decision D1 (neutral backgrounds). They also still show two
  things this document changes: the sidebar checkmark (D3) and the filled
  primary pill on Android (D2, if you choose the Material 3 tint). Where the
  mocks and this document disagree, this document wins.
- Other pages on the same canvas (Sign-in, Account) still show the old tinted
  tab bars. Ignore their navigation.

## 3. Step 0: verify the guidelines

Two points rest on memory, not on a current reading of the guidelines. Check
them before you change code. Run `/research` against primary sources:

1. **Apple HIG, iOS 26 and iPadOS 26.** Does the tab bar now float as Liquid
   Glass? Do iPad apps now use a top tab bar that expands into a sidebar? Does
   Apple still show selection in a sidebar without a checkmark?
2. **Material 3 (m3.material.io).** Did Material 3 Expressive replace the
   navigation drawer with an expanded navigation rail? What are the current
   colour roles for the navigation bar, rail and drawer: container, active
   indicator, active and inactive icon, active and inactive label?

Save the findings in `docs/research/` with their sources.

What to do with the result:

- If the Material 3 colour roles differ from section 7.2, follow the research
  and note the difference in the ADR.
- If the drawer is deprecated, or Liquid Glass changes the native look, do
  **not** redesign in this session. Record it as a follow-up ticket and stop
  at the scope of this document. Flutter's `material_ui` and `cupertino_ui`
  libraries may not support the new components yet. Check that too.

## 4. Decisions

**Decided**

- **D1. Neutral navigation backgrounds (Option 1).** Every navigation surface
  uses a neutral colour in every theme colour. Only the selected item uses the
  brand colour. Reason: native look on both platforms, and the design system's
  "quiet surfaces" principle.

**Confirm with the user at the start of the session.** Each has a recommended default.

- **D2. Android selected-item style.** Recommended: follow Material 3. The
  indicator pill is a soft tint (`secondaryContainer`). The selected icon is
  `onSecondaryContainer`. The labels and unselected icons follow section 7.2.
  The alternative keeps today's filled primary pill with an `onPrimary` icon.
  That is stronger branding, but it is not native.
- **D3. Remove the sidebar checkmark.** Recommended: yes. Apple uses
  checkmarks for choices in lists and menus, not for navigation.
- **D4. iOS chooses its layout by shortest side.** Recommended: yes. See section 7.1.
- **D5. Titles stay bold and in `primary`.** Recommended: yes. This is a brand
  choice from the design system. It is not native: iOS large titles are 34 pt
  in the label colour. Record it in the ADR as a deliberate choice.

## 5. Current behaviour

The shell is `packages/navigation/lib/src/navigation_shell.dart`.

| Window width | iOS | Android |
|---|---|---|
| Under 600 | `CupertinoTabBar` | `NavigationBar` |
| 600 to 1199 | `_CupertinoSideNavigation` (304 px, collapses to 72 px) | `NavigationRail`, labels shown |
| 1200 and wider | `_CupertinoSideNavigation` | `_MaterialSideNavigation`: `NavigationDrawer`, collapses to a rail without labels |

Colours today:

- `CupertinoTabBar`: no colours set. Flutter uses the system bar background and
  the theme's primary colour for the selected tab. **Already neutral.** No change.
- `_CupertinoSideNavigation`: `systemGroupedBackground`, `separator`,
  selected row `primaryColor.withAlpha(31)` (12%), and a trailing checkmark.
- `NavigationBar` (`design_system_navigation_bar_theme.dart`): background
  `colorScheme.surface`, indicator `primary`, selected icon `onPrimary`,
  unselected icons and all labels `primary`.
- `NavigationRail` and `NavigationDrawer`
  (`design_system_navigation_rail_theme.dart`,
  `design_system_navigation_drawer_theme.dart`): background, indicator and
  colours come from the brand's `navigation*` tokens. The selected **label**
  uses `onIndicatorColor`. Drawer indicator radius is 8.
- `_NavigationContentTheme` recolours the app bar to match the rail or drawer
  when side navigation shows.
- `DesignSystemAppBarTheme.light` fills the app bar with `primary`.
  `DesignSystemAppBarTheme.dark` uses `surface`.

## 6. Guideline gaps found

| # | Gap | Guideline | Fix |
|---|---|---|---|
| G1 | Navigation backgrounds tinted with brand colour (rail, drawer) | Both: navigation containers are neutral surfaces | 7.3 |
| G2 | Android light app bar filled with `primary` | Material 3: top app bar uses `surface` | 7.4 |
| G3 | Android indicator filled `primary`, labels `primary` | Material 3: tinted indicator, neutral labels | 7.2 (D2) |
| G4 | Drawer indicator radius 8, width 304 | Material 3: fully rounded indicator, width up to 360 | 7.3 |
| G5 | Checkmark on the selected sidebar row | Apple: sidebars show selection by highlight only | 7.5 (D3) |
| G6 | iPhone in landscape (844 px or wider) gets the sidebar | Apple: iPhone always uses a tab bar | 7.1 (D4) |
| G7 | Selected sidebar row: Fjord light text is 4.3:1 on the 12% tint | WCAG AA: 4.5:1 for text under 18.66 px bold | 7.5 |

## 7. Changes

### 7.1 Layout choice on iOS (G6)

On iOS, show side navigation only when the window's **shortest side** is at
least 600. This keeps an iPhone on the tab bar in both orientations. Every iPad
has a shortest side above 600.

Android keeps the width rule. Material 3 window size classes are based on
width, and a rail on a landscape phone is correct for Android.

The design system already defines "expanded" by shortest side
(`DisplayMetrics.isExpandedSurface`, `packages/design_system/lib/src/adaptive/display_metrics.dart`).
`packages/navigation` does not depend on `design_system`. Do not add that
dependency for one comparison. Use `MediaQuery.sizeOf(context).shortestSide`
in the shell, and name the 600 constant to match.

Watch for: the iPad in Split View or Slide Over. A narrow iPad window can have
a shortest side under 600. It then gets the tab bar, which is what iPadOS does
too.

### 7.2 Material navigation bar (G3)

Background: `surfaceContainer`, not the page colour. Today the light bar is the
same colour as the page, so the bar has no visible edge. The mocks draw it 4%
darker than the page in light mode, and as the raised surface in dark mode.

With D2 as recommended:

| Part | Colour role |
|---|---|
| Container | `surfaceContainer` |
| Indicator | `secondaryContainer` |
| Selected icon | `onSecondaryContainer` |
| Unselected icon | `onSurfaceVariant` |
| Selected label | `onSurface`, bold |
| Unselected label | `onSurfaceVariant` |

The colour scheme does not define `surfaceContainer`, `secondaryContainer` or
`onSecondaryContainer` today (`design_color_schemes.dart`). Add them to
`DesignColorSchemes`, derived from the brand. Do not add new brand tokens for
them: derive them from `surface`, `secondary` and the brightness. Check every
pair in the contrast test from the companion document.

If D2 keeps the filled pill, keep today's indicator and icon colours, but set
the labels to `onSurface` and `onSurfaceVariant`.

### 7.3 Rail and drawer (G1, G4)

- Remove the `backgroundColor`, `onBackgroundColor`, `indicatorColor` and
  `onIndicatorColor` parameters from `DesignSystemNavigationRailTheme.build`
  and `DesignSystemNavigationDrawerTheme.build`. Both take their colours from
  the `ColorScheme` only, with the same roles as section 7.2.
- Fix the selected label. Today it uses `onIndicatorColor`. If the indicator
  becomes a filled colour, the label becomes invisible text on the background.
  The label must use `onSurface` (selected) and `onSurfaceVariant`
  (unselected), separate from the icon colours.
- Drawer indicator: fully rounded (`StadiumBorder`).
- Drawer width: keep 304 unless section 3 says otherwise. Material 3 allows up
  to 360. 304 is within the range.

### 7.4 App bar (G2)

- `DesignSystemAppBarTheme.light`: background `surface`, foreground
  `onSurface`, title in `primary` (D5). Match the dark version.
- `_NavigationContentTheme`: the rail and drawer are now neutral, so the app
  bar no longer needs special colours in side-navigation mode. Remove the
  recolouring if the app bar already matches. Keep it only if a visible seam
  remains between the app bar and the rail.

### 7.5 Cupertino sidebar (G5, G7)

- Remove the trailing checkmark from the selected row (D3).
- Change the selection tint from 12% (`withAlpha(31)`) to 6% (`withAlpha(15)`).
  6% is the strongest tint where `primary` text passes 4.5:1 in every theme
  colour, on both the page and `systemGroupedBackground`:

  | Tint | Fjord | Fynbos | Kalahari | Lyng |
  |---|---|---|---|---|
  | 12% | 4.25 | 4.68 | 4.51 | 5.14 |
  | 8% | 4.49 | 4.93 | 4.79 | 5.45 |
  | 6% | 4.59 | 5.07 | 4.95 | 5.64 |

  The same tint problem affects the Cupertino tinted secondary button. The
  companion document fixes that one. Use one shared constant for both if a
  natural home exists. Otherwise keep them separate.

### 7.6 Remove the brand navigation tokens

Delete these eight fields from `DesignBrand` and from every preset in
`DesignBrands`:

`navigationSurfaceLight`, `onNavigationSurfaceLight`,
`navigationSelectedLight`, `onNavigationSelectedLight`,
`navigationSurfaceDark`, `onNavigationSurfaceDark`,
`navigationSelectedDark`, `onNavigationSelectedDark`.

Update `DesignSystemTheme.light` and `.dark` to stop passing them. The theme
colour presets in the companion document are written without these fields.

## 8. Tests

`packages/navigation/test/navigation_router_test.dart`:

- **Change:** `uses rail colors for app bars at medium width` and `uses drawer
  colors for app bars at tablet width`. They expect the brand navigation
  colours. Update them to the neutral result, or delete them if section 7.4
  removes the recolouring.
- **Add:** an iPhone in landscape (`Size(844, 390)`, iOS) shows a
  `CupertinoTabBar` and no side navigation.
- **Add:** an iPad in landscape (`Size(1194, 834)`, iOS) shows side navigation.
- **Add:** the selected Cupertino sidebar row has no checkmark icon.

`packages/design_system/test/`:

- The navigation bar, rail and drawer themes use the colour roles in section 7.2.
- The selected rail label is readable: its colour differs from the rail
  background, and it passes 4.5:1 against it.
- The light app bar background is `surface`.

## 9. Documentation

- `docs/design/visual_style.md`: add a short **Navigation** section. Neutral
  backgrounds, brand colour on the selected item only, the layout table from
  section 5 with the iOS shortest-side rule.
- New ADR in `docs/decisions/`, using `adr-template.md`: "Navigation uses
  neutral surfaces; only the selected item carries the brand colour." Record
  D1 to D5, the guideline sources from section 3, and why titles stay in
  `primary`.
- Update the Tweety design system's README only if its owner asks. It says the
  `nav-*` tokens colour "the navigation rail, drawer and bar". That is no
  longer true.

## 10. Done when

- No navigation surface uses a brand colour except the selected item.
- An iPhone in landscape shows the tab bar.
- The sidebar has no checkmark, and its selected text passes 4.5:1.
- `DesignBrand` has no `navigation*` fields.
- `flutter analyze` is clean, and all tests pass in the app and in both packages.

## 11. Open questions

1. Section 3 may show that the drawer or the tab bar look is outdated. Which
   follow-up ticket comes first, if any?
2. D2: Material 3 tint or the filled primary pill?
3. Should the Sign-in and Account mocks be updated to neutral tab bars, so the
   canvas tells one story?
