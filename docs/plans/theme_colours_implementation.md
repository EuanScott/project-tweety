# Theme colours: implementation handoff

This document is the brief for a fresh implementation session. It covers theme
colours: seven colour palettes, a stored preference, a picker on the Display
and language page, and a water scene that follows the chosen palette. Read all
of it before you start.

The work has two parts, and they can land as separate changes:

1. **Apply the theme colours.** Presets, the stored preference, the theme and
   the water scene (sections 4 to 7 and 9).
2. **The Display and language page and the theme colour picker.** The page
   redesign, the new design-system controls and the picker (sections 8 and 10).

Tickets: [`tickets/theme_colours_01_presets_and_preference.md`](tickets/theme_colours_01_presets_and_preference.md)
and [`tickets/theme_colours_02_settings_page_and_picker.md`](tickets/theme_colours_02_settings_page_and_picker.md).

- Companion work: [`navigation_guidelines_alignment.md`](navigation_guidelines_alignment.md).
  It has landed (section 3).
- Style: [`docs/design/visual_style.md`](../design/visual_style.md)
- Glossary: `docs/CONTEXT.md`

## 1. Goal and scope

A person chooses a **theme colour** in settings. The theme colour sets the
app's primary and secondary colours, its surfaces, and the colours of the
water scene. Light and dark mode stay a separate setting. Each theme colour has
a light version (day) and a dark version (night).

The seven theme colours are named after places and plants from the four
cultures of the family behind the app: Norway, South Africa, Scotland and
Portugal. Each name is a place or a plant, so it works by day and by night.

| Name | Origin | Primary | Secondary |
|---|---|---|---|
| **Fjord** (default) | Norway | Teal | Plum |
| **Fynbos** | South Africa | Olive | Protea pink |
| **Kalahari** | South Africa | Red ochre | Desert-sky blue |
| **Lyng** (Norwegian for heather) | Norway | Heather purple | Cloudberry gold |
| **Whin** (Scots for gorse) | Scotland | Gorse gold (dark mustard in light mode) | Slate blue |
| **Douro** (the port-wine valley) | Portugal | Port-wine red | Tile blue |
| **Cuillin** (the mountains on Skye) | Scotland | Near-black (near-white in dark mode) | Sea-loch blue |

Fjord is today's palette, renamed. Its values do not change.

Three of the new palettes need care:

- **Whin.** White text fails on bright yellow, so light mode uses a dark
  mustard primary (`#7A5C00`). The bright gorse yellow is the dark mode primary.
  Whin's gold sits close to Lyng's gold secondary (`#8A6100`). Leave both as
  they are (section 13).
- **Douro.** The wine red is darker and bluer than the error red (`#D32F2F`),
  so a primary button never reads as an error. Error messages keep their icon,
  so colour is never the only signal.
- **Cuillin.** A monochrome theme: near-black primary in light mode, near-white
  in dark mode. A near-black primary has no contrast on a dark page, so the
  dark value must invert.

**In scope**

- Seven `DesignBrand` presets. Replace `tweetyB2c` (section 5).
- Status colours: keep `success` and `warning`, remove `info` (section 5.3).
- A contrast test over every preset (section 6).
- The tinted secondary button fix (section 6.2).
- A stored theme colour preference (section 7).
- The Display and language page redesign and the theme colour picker
  (section 8).
- A water scene palette per theme colour (section 9).
- Strings in English, Spanish and Hebrew (section 10).
- Tests, docs and an ADR (sections 11 and 12).

**Out of scope**

- **App icon per theme colour.** Possible on iOS (alternate icons) and on
  Android (activity aliases), but with visible costs: iOS shows an alert that
  the app cannot hide, and some Android launchers restart the app or lose
  shortcuts. Deferred: no ticket for now.
- **Splash screen per theme colour.** Not possible. The operating system draws
  the native splash before any app code runs, so it cannot read the
  preference. The splash stays Fjord. Record this in the ADR (section 12).
- **Seasonal or event themes.** All seven theme colours are permanent.
- Navigation colours. Navigation surfaces are neutral (section 3). Only the
  selected destination takes `primary`.
- Syncing the in-app language with the system per-app language setting
  (Android 13+ `LocaleManager`, iOS Settings). Separate ticket, later.
- A list-detail layout for Settings. Settings has one row today. Revisit at
  about three categories.

## 2. Design references

Read Claude Design links with the Artifact tool (`action: "read"`), never with
a web fetch. They are private to the repository owner.

Each mock's script holds the exact values it draws (`SCENES`, `UI`, `NAMES`,
`BLURBS`). This document repeats them in sections 4, 9 and 10. **If they
differ, this document wins.**

### 2.1 Theme colours page

[Tweety app screens](https://claude.ai/artifact/1E1Gc7Nrw9zEAZkscfEREL), page
**Theme colours**. An iOS phone settings screen with the water scene at the
top, one artboard per theme colour and brightness (14 in all).

- Row **Light**: `Main.dc.html` (Fjord), then
  `Colours-<Name>-light.dc.html` for Fynbos, Kalahari, Lyng, Whin, Douro and
  Cuillin.
- Row **Dark**: `Colours-<Name>-dark.dc.html` for all seven.
- In Play, tap a colour tile to change the whole screen. Tap Light or Dark to
  change the appearance. Tweaks: `palette`, `mode`.
- The page note (sticky, left of the rows) summarises the palettes and contrast.

Use this page for **colour**: the brand colours, the scene palettes, the
picker's look and the theme descriptions. Its layout is a preview, not the
settings page. Section 2.2 shows the real page.

The scene in these mocks follows the current widget: the soft wavy fade,
the gold day sun and no birds at night. Those changes are already in code
(commits `18db578` and `f7b8387`). Only the scene colours change in this work.

### 2.2 Display and language canvas

[Display and language](https://claude.ai/artifact/PZ2ARgg6e7hpCVqaB8VUJu). The
real `AppPreferencesPage` on eight device sizes, drawn from the code on `main`,
inside the navigation each size uses.

- Row **Today: the code on main**: `Main.dc.html` (iPhone), then
  `Today-AndroidPhone`, `Today-FoldCover`, `Today-FoldOpen`,
  `Today-AndroidTablet`, `Today-AndroidTabletLandscape`, `Today-iPad`,
  `Today-iPadLandscape` (each `.dc.html`).
- Row **With the theme colour picker**: the same eight devices as
  `Picker-<Device>.dc.html`. The picker added to today's layout. Superseded by
  the Proposed row; kept for comparison.
- Row **Proposed: research layout**: the same eight devices as
  `Proposed-<Device>.dc.html`. **This is the target design** for section 8.
  The segmented Theme control and the swatches work in Play.
- Tweaks: `mode` (the device appearance) on every artboard, and `palette` on
  the picker and Proposed rows.
- The Proposed mocks show the language row with "English" as its value and do
  not draw the selection list. Section 8.5 says what to build.

Use this canvas for **layout and platform behaviour**. The reasons behind the
layout are in
[`docs/research/display-language-settings-layout.md`](../research/display-language-settings-layout.md).

## 3. Before you start

The navigation work has landed (`dcfb381`). `DesignBrand` no longer has the
eight `navigation*` fields, and `tweetyB2b` is gone. The presets below are
written without navigation fields.

Already in code, so do not redo it:

- `DesignBrands.all` exists. It lists only `tweetyB2c` today.
- Fjord's light and dark primary and secondary (`#0E7474` / `#1BA6A6`,
  `#8E3B76` / `#D68FC2`) are in `design_brands.dart`.
- The iPad sidebar's selection tint is 6%, as a private constant in
  `packages/navigation/lib/src/navigation_shell.dart`. Nothing shares it.

## 4. Palette values

### 4.1 Brand colours

Contrast ratios are in brackets. Every pair passes WCAG AA (4.5:1).

| Token | Fjord L | Fjord D | Fynbos L | Fynbos D | Kalahari L | Kalahari D | Lyng L | Lyng D |
|---|---|---|---|---|---|---|---|---|
| `primary` | `#0E7474` | `#1BA6A6` | `#56691C` | `#B5C96A` | `#A8441F` | `#F39A74` | `#77449A` | `#D2A6EF` |
| `onPrimary` | `#FFFFFF` (5.6) | `#002020` (5.7) | `#FFFFFF` (6.1) | `#1C2200` (9.0) | `#FFFFFF` (6.0) | `#3A1405` (7.6) | `#FFFFFF` (6.8) | `#2A0F45` (8.3) |
| `secondary` | `#8E3B76` | `#D68FC2` | `#A3365F` | `#F2A3BF` | `#2F5F8A` | `#9CC3EE` | `#8A6100` | `#F2C14E` |
| `onSecondary` | `#FFFFFF` (6.9) | `#2E0A25` (7.2) | `#FFFFFF` (6.5) | `#3D0A20` (8.5) | `#FFFFFF` (6.7) | `#0A2540` (8.5) | `#FFFFFF` (5.5) | `#2A1F00` (9.7) |

| Token | Whin L | Whin D | Douro L | Douro D | Cuillin L | Cuillin D |
|---|---|---|---|---|---|---|
| `primary` | `#7A5C00` | `#F2C230` | `#8C1D3A` | `#F0A3B5` | `#1F2326` | `#E6E8EA` |
| `onPrimary` | `#FFFFFF` (6.3) | `#2A1F00` (9.7) | `#FFFFFF` (8.9) | `#3D0A1A` (8.4) | `#FFFFFF` (15.8) | `#1A1C1E` (13.9) |
| `secondary` | `#3D5A80` | `#A9C1E6` | `#2F5E9E` | `#A7C4EF` | `#3F7A8C` | `#8CC4D4` |
| `onSecondary` | `#FFFFFF` (7.1) | `#0D2240` (8.7) | `#FFFFFF` (6.5) | `#0A2245` (8.9) | `#FFFFFF` (4.8) | `#0A2A33` (7.9) |

Cuillin's light `secondary` with white text is the lowest pair, at 4.8.

### 4.2 Surfaces

These map onto the existing `DesignBrand` fields. In dark mode the colour
scheme's `surface` comes from `surfaceVariantDark`
(`design_color_schemes.dart`). That is why the raised dark colour sits in that row.

| `DesignBrand` field | Fjord | Fynbos | Kalahari | Lyng | Whin | Douro | Cuillin |
|---|---|---|---|---|---|---|---|
| `surfaceLight` (page) | `#F4F6F7` | `#F6F7F2` | `#F8F5F3` | `#F7F5F8` | `#F8F7F2` | `#F8F4F5` | `#F5F6F7` |
| `surfaceVariantLight` (fields) | `#EFF2F3` | `#F0F2EA` | `#F4EFEC` | `#F2EFF4` | `#F3F2EA` | `#F4EEF0` | `#F0F2F3` |
| `surfaceDark` (page) | `#121212` | `#121310` | `#141110` | `#141216` | `#13120F` | `#141012` | `#121314` |
| `surfaceVariantDark` (sheets, raised) | `#2C2C2C` | `#24261E` | `#2A2321` | `#28232D` | `#26241D` | `#2A2226` | `#262829` |

`surfaceVariantLight` for Whin, Douro and Cuillin is not drawn in any mock. It
follows Fjord's step from page to field colour. Check it on a device.

`primary` as text passes 4.5:1 on every page and raised colour above. The
lowest is Fjord dark on `#2C2C2C`, at 4.7. For the new palettes the lowest is
Whin light on its page, at 5.8.

### 4.3 Shared values

These stay the same in every preset. Keep them as private constants in
`design_brands.dart`, so they cannot drift between presets.

- `onSurfaceLight` black at 87%, `onSurfaceDark` white.
- `outline` `#BDBDBD`, `disabledColor` `#8A9A9A`.
- `error`, `onError` and the four `errorContainer` values: today's Fjord values.
- `success` `#388E3C`, `warning` `#FFA000` (section 5.3).

## 5. Design system changes

### 5.1 Presets

In `packages/design_system/lib/src/theme/design_brands.dart`:

- Add `DesignBrands.fjord`, `.fynbos`, `.kalahari`, `.lyng`, `.whin`, `.douro`
  and `.cuillin` with the values in section 4.
- Remove `tweetyB2c`. `fjord` replaces it with the same values.
- `DesignSystemTheme.light` and `.dark` default to `DesignBrands.fjord`.
- Set `name` on each preset: `'Fjord'`, `'Fynbos'`, `'Kalahari'`, `'Lyng'`,
  `'Whin'`, `'Douro'`, `'Cuillin'`.
- Update `packages/design_system/README.md` and its example app, if either names the old preset.

### 5.2 One list of presets

`DesignBrands.all` exists. Make it list all seven, so tests can loop over every
preset. Do not make the app depend on the list order. The app maps its own
enum to a preset (section 7.3).

### 5.3 Status colours

Material has no `success`, `warning` or `info` roles. These are custom tokens
in `DesignBrand`, exposed through the `DesignStatusColors` theme extension.

- **Keep `success` and `warning`.** The Account design uses them: "Verified" in
  `#388E3C` with a tick, and "Not verified" in a dark amber (`#B26A00`) with a
  warning sign. They stay the same in every theme colour. Status colours must
  not move with the brand.
- **Remove `info`.** Nothing uses it.
- `warning` `#FFA000` fails as text on a light background. The Account design
  uses `#B26A00` for its text. **Leave `warning` as it is** (section 13).

## 6. Contrast

### 6.1 The contrast test

Add a test in `packages/design_system/test/` that loops over every preset, in
light and dark. It computes the WCAG contrast ratio and expects at least 4.5
for each pair:

- `primary` / `onPrimary`, `secondary` / `onSecondary`
- `primary` as text on the page colour and on the raised colour
- `secondary` as text on the raised colour
- `onSurface` on the page colour
- `primary` as text on the tinted secondary button background (section 6.2)

Put the contrast function in the test support code, not in the package's
public API. This test protects the palettes when someone changes a value later.
It is the final word on contrast: the ratios in this document are design-time
estimates.

### 6.2 Tinted secondary button

The Cupertino secondary `AppButton` draws `primary` text on `primary` at 12%
(`packages/design_system/lib/src/adaptive/app_button.dart:106`,
`withAlpha(31)`). In light mode that fails today: Fjord is 4.25:1.

Change it to 6% (`withAlpha(15)`). It is the strongest tint that passes in
every theme colour:

| Tint | Fjord | Fynbos | Kalahari | Lyng | Whin | Douro | Cuillin |
|---|---|---|---|---|---|---|---|
| 12% | 4.25 | 4.68 | 4.51 | 5.14 | 4.92 | 6.64 | 11.54 |
| 6% | 4.59 | 5.07 | 4.95 | 5.64 | 5.39 | 7.40 | 13.12 |

The Whin, Douro and Cuillin values were measured over each page colour. The
first four came from an earlier pass that reads about 0.1 lower. The contrast
test settles any gap.

The navigation shell already uses 6% for the iPad sidebar, as a private
constant. Consider moving it to one shared design-system constant that both
places use.

If 6% looks too faint, the other fix is to keep 12% and use a darker text
colour on the tint. That needs a new token per preset. Ask the user before you
take that route.

## 7. The stored preference

Follow the existing theme mode path. It goes entity → storage → repository →
cubit → `MaterialApp`.

### 7.1 Domain

`lib/domain/entities/app_preferences/app_preferences.entity.dart`:

```dart
enum AppPreferencesThemeColour { fjord, fynbos, kalahari, lyng, whin, douro, cuillin }
```

Add `@Default(AppPreferencesThemeColour.fjord) AppPreferencesThemeColour themeColour`
to `AppPreferences`. Regenerate the `freezed` output.

The domain layer must not import `design_system`.

### 7.2 Storage

`lib/core/storage/app_preferences.storage.dart`:

- Add a `themeColour` field to the storage model, stored as its enum name under
  the JSON key `'themeColour'`.
- A missing or unknown value reads as `fjord`. Saved preferences from before
  this change therefore keep working with no migration.
- Follow the pattern of `_themeModeFromName`.

Update `lib/data/repositories/app_preferences/app_preferences.repository_impl.dart`
to map the field in both directions.

### 7.3 Cubit and app

- `AppPreferencesCubit`: add `updateThemeColour`, matching `updateThemeMode`.
- `lib/main.dart`: map `AppPreferencesThemeColour` to a `DesignBrand` and pass
  it to `DesignSystemTheme.light` and `.dark`. Use an exhaustive `switch`, so a
  new theme colour fails to compile until it has a preset.
- The `BlocBuilder` already rebuilds on any change to `effectiveAppPreferences`.
  Confirm that a theme colour change rebuilds the theme.

## 8. Display and language page and theme colour picker

The page is `AppPreferencesPage` in `lib/presentation/pages/app_preferences/`,
titled "Display and language". Today its content
(`widgets/app_preferences_content.widget.dart`) is one `ListView` with two
`AppPickerField`s, two read-only `AppListTile` rows and a filled
`AppButton.primary`. This section replaces that layout with the **Proposed**
row of the Display and language canvas (section 2.2). The research behind it is
[`docs/research/display-language-settings-layout.md`](../research/display-language-settings-layout.md).

### 8.1 Structure

Three grouped sections, on both platforms:

| Section | Rows | Text under the section |
|---|---|---|
| **Appearance** | Theme (segmented control), Theme colour (swatch row) | "Following device setting: Light." Only when System is selected. |
| **Language** | Language (value row) | "Text direction follows the language." |
| **Text and display** | Text size and bold text (link row) | "Change font size and bold text in your device settings." |

Removed: the read-only "Layout direction" row, the "Display and text settings"
row and the filled "Open settings" button. The link row replaces the last two.

Sentences never go in a row subtitle. `CupertinoListTile` cuts its subtitle to
one line, which is why the iOS description is truncated today. Put them in the
section's footer text, which wraps.

### 8.2 Platform styling

**iOS** (`CupertinoListSection.insetGrouped` style):

- Header: 13 px, upper case, secondary label colour, 16 px in from the card edge.
- Rows sit in a rounded card (10 px radius) in the raised colour, with
  0.5 px separators inset 16 px.
- Footer: 13 px, secondary label colour, under the card. It wraps.
- 28 px between sections. The column has 20 px padding at the top and 16 px at
  the sides.

**Android** (Material settings list):

- Header: a list subheader, 14 px, semibold, `primary`, 16 px side padding.
- Rows are flat, with 16 px side padding. No cards.
- A full-width 1 px divider between sections.
- The section text is 14 px, muted, under the rows.
- No side padding on the column itself. Rows and text carry their own 16 px.

### 8.3 Rows and controls

- **Theme:** `AppSegmentedControl` with System, Light, Dark. It is Material
  `SegmentedButton` on Android and `CupertinoSlidingSegmentedControl` on iOS.
  It has no label of its own: the "Appearance" header names it. Tapping a
  segment applies the mode at once. This replaces `AppPickerField`.
- **Theme colour:** the swatch row (section 8.4), inside the Appearance
  section under Theme. Its title line is "Theme colour" (17 px on iOS, 16 px
  on Android).
- **Language:** a value row. Title "Language", value the selected option's
  label ("System default", "English", "Español", "עברית"). When System default
  is selected, the section text starts "Following device setting: English."
  before "Text direction follows the language." On iOS the value sits on the
  right, followed by a chevron. On Android the value sits under the title, with
  no chevron, as Android settings rows do. Tapping opens the selection list
  (section 8.5).
- **Text size and bold text:** a link row that opens the system text
  settings, as "Open settings" does today (`SystemTextSettingsService.open`,
  with the same failure snack bar). iOS: chevron. Android: an open-in-new icon
  in `primary`.

### 8.4 The swatch picker control

The design system has no swatch control. `AGENTS.md` requires a design-system
primitive before the app uses raw controls. Add one to
`packages/design_system` (for example `AppSwatchPicker`). It must:

- Take a list of options (label, primary colour, secondary colour), the
  selected option and an `onChanged` callback. It knows nothing about theme
  colours.
- Draw each tile 72 px wide: a 40 px circle split diagonally between the
  primary and secondary colour, with the label under it (12 px). The selected
  tile has a ring (2 px gap, 2 px ring), a bold label and **a tick in a small
  disc in the centre of the circle**, so the choice never relies on colour
  alone.
- **Scroll only when the tiles do not fit.** Seven tiles need about 530 px. On
  a phone the row scrolls sideways, snaps to tiles and shows part of the next
  tile. In the 600 px column (section 8.6) all seven fit, so the row does not
  scroll. Decide from the width the control gets, not from the device.
- When it scrolls, bring the selected tile into view when it first builds.
- Use real buttons, at least 44 px tall, each with its label as the accessible
  name and its selected state announced.
- Work on Material and Cupertino. The tile layout is the same on both. Only the
  focus and press feedback follow the platform.

On the page, under the tiles:

- One line with two 10 px dots (primary and secondary) and the name with its
  colours, for example "Fjord · Teal with plum" (14 px, semibold).
- The theme's description under it (13 px, muted), from section 10. Mark it as
  a polite live region, so a screen reader reads the new description after a
  tap.

There is no separate card around the picker. The section is the container.
Each tile shows the colours of the **current** brightness. Choosing a tile
applies the theme colour at once. There is no confirm step.

### 8.5 The language selection list

Add a design-system value row, for example `AppSelectionRow` (title, options as
`AppPickerOption`, selected value, `onChanged`). It owns the platform branching:

- **iOS:** push a page with the title "Language" and one inset grouped section
  of the options, with a checkmark on the selected one. Push it with the
  navigator directly, so the app router does not change. Tapping an option
  selects it and returns.
- **Android:** open a dialog titled "Language" with a radio list of the
  options. Tapping an option selects it and closes the dialog.
- Show each language in its own name, as today. Test the row in right-to-left
  (Hebrew): the value and the chevron must flip.

The language choice still saves through `AppPreferencesCubit.updateLanguageCode`.
No change to how the language is stored.

### 8.6 Width and devices

- **One pane on every device.** The page has one view, so it never splits into
  two panes. This includes the open foldable. Do not add a `secondaryBody`.
- **Width:** on windows 600 px or wider, centre the content in a column at most
  600 px wide. On phones the column fills the width. Add this as an option on
  `PageScaffold` (it owns the body padding today) or as a small design-system
  wrapper. The column scrolls.
- **Open foldable:** the same centred 600 px column as a tablet. It crosses the
  hinge. This is a deliberate decision (section 13). The research recommends
  keeping content to one side of the hinge. The user chose one pane, as the app
  does today.

### 8.7 New design-system primitives

| Primitive | Purpose | Platform forms |
|---|---|---|
| `AppListSection` | Header, rows, footer text | iOS: `CupertinoListSection.insetGrouped`. Android: subheader, rows, text, divider. |
| `AppSelectionRow` | Value row that opens a selection list | iOS: pushed checkmark list. Android: radio dialog. |
| `AppSwatchPicker` | The colour tiles | Same layout on both; platform focus and press feedback. |

Each gets its own test in `packages/design_system/test/adaptive/`. Use
`AppListTile` for the link row; give it the trailing icon.

## 9. Water scene

The scene colours are `ScenePalette` in
`lib/presentation/widgets/water_scene/scene_palette.model.dart`. Today it is an
enum with `day` and `night`, chosen by brightness in `ScenePalette.of(context)`.
The scene, `sign_in_split.widget.dart` and `account_modal.widget.dart` read it.

The scene's shape is already current in code: the soft wavy fade, the sizing,
the gold day sun (`#FFD45C`) and no birds at night. This work changes only the
colours.

### 9.1 Shape of the change

Recommended: make `ScenePalette` a `ThemeExtension`. `main.dart` adds the
matching palette to the light and dark `ThemeData` for the chosen theme colour.
`ScenePalette.of(context)` then reads `Theme.of(context).extension<ScenePalette>()`.
No call site changes, and the scene follows the theme with no new plumbing.

Watch for: `DesignSystemTheme` already sets `extensions:
[DesignStatusColors…]`. `ThemeData.copyWith(extensions: …)` **replaces** the
list. Merge it: `[...theme.extensions.values, scenePalette]`. Add a test that
both extensions are present.

The palette must still say whether it is a night palette, because the scene
paints stars and a moon, and no birds, at night (`isNight`). Keep that
information when the enum becomes a class, for example as a `brightness` field.

The scene palette stays in the app, not in the design system. Its doc comment
says so: the colours belong to the illustration.

### 9.2 Values

Twelve colours per theme colour and brightness. Fjord is today's `day` and
`night`, unchanged.

**The day `sun` is `#FFD45C` in every palette.** The sun is a scene choice, not
a palette choice. The night `sun` (the moon and stars) keeps each palette's
own colour.

**Birds paint by day only.** Keep the `bird` field required, as it is today.
The night `bird` values below fill it, but nothing draws them (section 13).

| Field | Fynbos day | Fynbos night | Kalahari day | Kalahari night | Lyng day | Lyng night |
|---|---|---|---|---|---|---|
| `sky` | `#EEF2E3` | `#161B10` | `#F7EBE2` | `#1D1820` | `#F1EBF5` | `#1B1626` |
| `sun` | `#FFD45C` | `#EEF2E3` | `#FFD45C` | `#F7E6DA` | `#FFD45C` | `#EFE6F7` |
| `cloud` | `#FFFFFF` | `#252C1C` | `#FFF8F2` | `#33282C` | `#FFFFFF` | `#2C2440` |
| `bird` | `#9AA77A` | `#616B4C` | `#BB8A72` | `#7A6468` | `#9E88B4` | `#6C5F8A` |
| `farHills` | `#D6DFC0` | `#1D2415` | `#EDCDB8` | `#2C2124` | `#E0D3EC` | `#231D34` |
| `midHills` | `#B3C48A` | `#26301B` | `#DFA27F` | `#3C2925` | `#C4AAD9` | `#2E2544` |
| `backWater` | `#8CA35A` | `#2F3D1F` | `#CF7F58` | `#4F2D22` | `#A083C0` | `#3A2D59` |
| `shimmer` | `#FFFFFF` | `#C8D98A` | `#FFF3EA` | `#F39A74` | `#FFFFFF` | `#D2A6EF` |
| `nearWater` | `#6F8A35` | `#3B4C22` | `#BB5D37` | `#6A3220` | `#8A5FAE` | `#4A3572` |
| `closestWater` | `#56691C` | `#2B3818` | `#A8441F` | `#4E2416` | `#77449A` | `#36275C` |
| `foam` | `#E2EBC8` | `#A9BF62` | `#F5D4C0` | `#DF8A64` | `#E7D8F0` | `#BC98E0` |
| `ink` | `#3F4D12` | `#EEF2E3` | `#7A2E12` | `#F7E6DA` | `#552E70` | `#EFE6F7` |

| Field | Whin day | Whin night | Douro day | Douro night | Cuillin day | Cuillin night |
|---|---|---|---|---|---|---|
| `sky` | `#F6F1DC` | `#17150D` | `#F6E9EC` | `#1C1418` | `#E9ECEE` | `#111315` |
| `sun` | `#FFD45C` | `#F6F1DC` | `#FFD45C` | `#F6E4E9` | `#FFD45C` | `#E6E8EA` |
| `cloud` | `#FFFDF5` | `#2A2618` | `#FFF8F9` | `#33242B` | `#FFFFFF` | `#24282C` |
| `bird` | `#A99A62` | `#6E6648` | `#B0828E` | `#7A5F68` | `#8A949B` | `#5E666C` |
| `farHills` | `#ECE0B0` | `#211E13` | `#ECD0D7` | `#2A1C22` | `#D3D8DC` | `#1A1D20` |
| `midHills` | `#E0C96E` | `#2E2A17` | `#D6A0AE` | `#3A2229` | `#AAB3BA` | `#23272B` |
| `backWater` | `#C9A838` | `#3D3719` | `#BB6B80` | `#4C2533` | `#7F8B94` | `#2E3439` |
| `shimmer` | `#FFFBE8` | `#F2D76A` | `#FFF4F6` | `#F0A3B5` | `#FFFFFF` | `#B8C4CC` |
| `nearWater` | `#9C7A12` | `#4F4517` | `#A23C58` | `#66283D` | `#4B565E` | `#3A4249` |
| `closestWater` | `#7A5C00` | `#3A3210` | `#8C1D3A` | `#4A1C2C` | `#1F2326` | `#2A3035` |
| `foam` | `#F3E6B0` | `#D9BE52` | `#F2D0D9` | `#D98A9E` | `#CFD6DB` | `#8FA0AB` |
| `ink` | `#5C4500` | `#F6F1DC` | `#6E1530` | `#F6E4E9` | `#1F2326` | `#E6E8EA` |

`ink` is the heading colour over the sky in the split sign-in layout. No mock
draws it for Whin, Douro or Cuillin, so those values are new. Contrast against
`sky` (day / night): Fynbos 8.1 / 15.4, Kalahari 8.1 / 14.4, Lyng 8.9 / 14.6,
Whin 8.0 / 16.1, Douro 9.8 / 14.8, Cuillin 13.3 / 15.2. Fjord is 6.7 / 13.5.

In each day scene, `closestWater` equals the light `primary`, as in Fjord. Keep
that link if you adjust a value.

## 10. Strings

Add to `lib/l10n/app_en.arb`, `app_es.arb` and `app_he.arb`, then regenerate.

### 10.1 Labels and names

| Key (suggested) | English | Spanish | Hebrew |
|---|---|---|---|
| `appPreferencesThemeColourLabel` | Theme colour | Color del tema | צבע ערכת הנושא |
| `themeColourFjord` | Fjord | Fiordo | פיורד |
| `themeColourFynbos` | Fynbos | Fynbos | פינבוס |
| `themeColourKalahari` | Kalahari | Kalahari | קלהרי |
| `themeColourLyng` | Lyng | Brezo | אברש |
| `themeColourWhin` | Whin | Tojo | אולקס |
| `themeColourDouro` | Douro | Duero | דורו |
| `themeColourCuillin` | Cuillin | Cuillin | קולין |

Notes:

- English keeps the local names: Norwegian "Lyng" and Scots "Whin". Spanish and
  Hebrew use the plant's name (heather, gorse). This difference is deliberate.
- "Fynbos" has no native word in Spanish or Hebrew. Both use it as a loanword.
- Douro is "Duero" in Spanish, the river's Spanish name. Cuillin is a proper
  name and stays as it is.

### 10.2 Colour summaries

The line beside the two dots, after the name: "Fjord · Teal with plum".

| Key (suggested) | English | Spanish | Hebrew |
|---|---|---|---|
| `themeColourFjordColours` | Teal with plum | Turquesa con ciruela | טורקיז עם שזיף |
| `themeColourFynbosColours` | Olive with protea pink | Oliva con rosa protea | זית עם ורוד פרוטאה |
| `themeColourKalahariColours` | Red ochre with desert-sky blue | Ocre rojo con azul cielo del desierto | אדום אוקר עם כחול שמי מדבר |
| `themeColourLyngColours` | Heather with cloudberry gold | Brezo con oro de camemoro | אברש עם זהב פטל צפוני |
| `themeColourWhinColours` | Gorse gold with slate blue | Oro de tojo con azul pizarra | זהב אולקס עם כחול צפחה |
| `themeColourDouroColours` | Port wine with tile blue | Vino de Oporto con azul azulejo | יין פורט עם כחול אריחים |
| `themeColourCuillinColours` | Mountain black with sea-loch blue | Negro de montaña con azul de lago marino | שחור הרים עם כחול מפרץ ים |

### 10.3 Descriptions

The description under the tile row (section 8.4). English is decided. Spanish
and Hebrew are drafts.

| Key (suggested) | English |
|---|---|
| `themeColourFjordDescription` | Teal water and plum dusk from Norway's deep sea inlets. Calm and clear, like a still morning on the water. |
| `themeColourFynbosDescription` | Olive green and protea pink from the wild shrubland of the Cape. Fresh, green and full of bloom. |
| `themeColourKalahariDescription` | Red ochre dunes under a wide blue desert sky. Warm and earthy, from the great sands of southern Africa. |
| `themeColourLyngDescription` | Purple heather and cloudberry gold from the Norwegian hills. Soft and quiet, like late summer on the moor. |
| `themeColourWhinDescription` | Gorse gold from the Scottish hills, where the whin flowers almost all year. Sunny and bright, even on a grey day. |
| `themeColourDouroDescription` | Port-wine red and blue tiles from Portugal's Douro Valley. Rich and warm, like evening light on the vineyard terraces. |
| `themeColourCuillinDescription` | Black rock and grey mist from the mountains of Skye. Quiet and focused, with a touch of sea-loch blue. |

| Key | Spanish (draft) |
|---|---|
| `themeColourFjordDescription` | Agua turquesa y atardecer ciruela de los fiordos de Noruega. Tranquilo y claro, como una mañana en calma sobre el agua. |
| `themeColourFynbosDescription` | Verde oliva y rosa protea del matorral silvestre del Cabo. Fresco, verde y lleno de flores. |
| `themeColourKalahariDescription` | Dunas de ocre rojo bajo un amplio cielo azul del desierto. Cálido y terroso, de las grandes arenas del sur de África. |
| `themeColourLyngDescription` | Brezo morado y oro de camemoro de las colinas noruegas. Suave y sereno, como el final del verano en el páramo. |
| `themeColourWhinDescription` | El oro del tojo de las colinas escocesas, que florece casi todo el año. Soleado y luminoso, incluso en un día gris. |
| `themeColourDouroDescription` | Rojo vino de Oporto y azulejos azules del valle del Duero, en Portugal. Intenso y cálido, como la luz del atardecer en las terrazas de viñedos. |
| `themeColourCuillinDescription` | Roca negra y niebla gris de las montañas de Skye. Sereno y concentrado, con un toque azul de lago marino. |

| Key | Hebrew (draft) |
|---|---|
| `themeColourFjordDescription` | מים בגוון טורקיז ודמדומים בצבע שזיף מהפיורדים של נורווגיה. רגוע וצלול, כמו בוקר שקט על המים. |
| `themeColourFynbosDescription` | ירוק זית וורוד פרוטאה מהצמחייה הפראית של הכף. רענן, ירוק ומלא פריחה. |
| `themeColourKalahariDescription` | דיונות באדום אוקר תחת שמי מדבר כחולים ורחבים. חם וארצי, מהחולות הגדולים של דרום אפריקה. |
| `themeColourLyngDescription` | אברש סגול וזהב פטל צפוני מגבעות נורווגיה. רך ושקט, כמו סוף הקיץ בערבה. |
| `themeColourWhinDescription` | זהב האולקס מגבעות סקוטלנד, שפורח כמעט כל השנה. שמשי ומואר, גם ביום אפור. |
| `themeColourDouroDescription` | אדום יין פורט ואריחים כחולים מעמק הדורו שבפורטוגל. עשיר וחם, כמו אור ערב על טרסות הכרמים. |
| `themeColourCuillinDescription` | סלע שחור וערפל אפור מהרי האי סקיי. שקט וממוקד, עם נגיעה של כחול מפרץ ים. |

### 10.4 Rename "Theme" to "Appearance"

`appPreferencesThemeLabel` becomes the header of the Appearance section. Today
it says "Theme". A "Theme colour" row under it would be easy to confuse with
it. Change the text, and keep the key name:

| English | Spanish | Hebrew |
|---|---|---|
| Appearance | Apariencia | מראה |

### 10.5 Page strings for the new layout

New keys:

| Key (suggested) | English | Spanish (draft) | Hebrew (draft) |
|---|---|---|---|
| `appPreferencesTextDisplayHeader` | Text and display | Texto y pantalla | טקסט ותצוגה |
| `appPreferencesTextSizeRow` | Text size and bold text | Tamaño del texto y negrita | גודל טקסט וטקסט מודגש |
| `appPreferencesTextSizeFooter` | Change font size and bold text in your device settings. | Cambia el tamaño de letra y la negrita en los ajustes del dispositivo. | שינוי גודל הגופן והטקסט המודגש בהגדרות המכשיר. |
| `appPreferencesDirectionFooter` | Text direction follows the language. | La dirección del texto sigue al idioma. | כיוון הטקסט נקבע לפי השפה. |

Reused keys: `appPreferencesThemeSystem`, `…ThemeLight`, `…ThemeDark` (the
segments), `appPreferencesThemeFollowingSystem` (the Appearance footer; add the
full stop), `appPreferencesLanguageLabel`, `appPreferencesLanguageSystem`,
`appPreferencesLanguageFollowingSystem`, `appPreferencesSystemTextOpenFailed`.

Remove these keys, which nothing will use: `appPreferencesThemeSystemSelected`,
`appPreferencesThemeApplied`, `appPreferencesThemeDeviceSetting`,
`appPreferencesLanguageApplied`, `appPreferencesDirectionLabel`,
`appPreferencesDirectionLtr`, `appPreferencesDirectionRtl`,
`appPreferencesDirectionDescription`, `appPreferencesSystemTextTitle`,
`appPreferencesSystemTextDescription`, `appPreferencesSystemTextButton`. Check
with a search that no other code reads them first.

### 10.6 Review

A native speaker must check the Spanish and Hebrew before release. In Hebrew,
check especially פינבוס, אברש, אולקס, פטל צפוני, מראה and the section 10.5 rows. "אולקס" (gorse) is a
botanical name that many readers will not know. A transliteration of "Whin" is
the other option.

## 11. Tests

Follow `docs/testing/README.md`. Construct the subject directly. Use `GetIt`
only for tests that drive `MyApp`, through `useAppHarness()`.

- **Design system:** the contrast test (section 6.1). Each preset has the
  expected `primary` in light and dark. `DesignStatusColors` has no `info`.
- **Swatch picker:** shows every option, marks the selected one with a ring
  and a tick, calls `onChanged` on tap, announces the label and selected
  state. It scrolls when narrow, does not scroll when all tiles fit, and brings
  the selected tile into view when it starts off-screen.
- **List section:** header, rows and footer render on both platforms, and the
  footer wraps.
- **Selection row:** shows the selected label, opens the list (pushed page on
  iOS, dialog on Android), returns the tapped option, and flips in
  right-to-left.
- **Storage:** round trip of each theme colour. A missing key reads as `fjord`.
  An unknown value reads as `fjord`.
- **Repository:** maps every value both ways
  (`test/data/repositories/app_preferences.repository_impl_test.dart`).
- **Cubit:** `updateThemeColour` saves and emits. Choosing the current value does nothing.
- **Settings page** (`test/presentation/pages/settings/app_preferences.page_test.dart`):
  - Three sections in order: Appearance, Language, Text and display.
  - Tapping a Theme segment calls `updateThemeMode`. The "Following device
    setting" footer shows only for System.
  - The picker shows seven options, selecting one calls `updateThemeColour`,
    and the description changes to the selected theme's.
  - Choosing a language through the selection row calls `updateLanguageCode`.
  - The link row opens the system text settings, and shows the snack bar when
    that fails.
  - The Layout direction row and the Open settings button are gone.
  - On a wide window the content is at most 600 px wide.
  - Update any finder that used "Theme", the dropdowns or the old rows.
- **App:** choosing Kalahari changes `Theme.of(context).colorScheme.primary`
  to `#A8441F` in light mode. Choosing Cuillin in dark mode gives `#E6E8EA`.
- **Scene:** `ScenePalette.of(context)` returns the Lyng night palette under a
  Lyng dark theme, and that palette reports night. Both theme extensions are
  present.

## 12. Documentation

- `docs/design/visual_style.md`: replace the single colour table with the seven
  theme colours, or link to `design_brands.dart` as the source. Its note that
  primary and secondary "are not yet in code" is out of date. Remove it.
- `docs/CONTEXT.md`: add **Theme colour**. Define it as the person's chosen
  palette, separate from light and dark mode. List the seven names.
- New ADR in `docs/decisions/`, using `adr-template.md`: "Theme colours are
  complete brand presets named after places and plants." Record:
  - A theme colour is a whole preset, not an accent layer on one brand.
  - The names come from the family's four cultures: Norway, South Africa,
    Scotland and Portugal.
  - The names are places or plants, so they work by day and night. Sunrise and
    Sunset were rejected because they clash with dark mode. Seasonal names were
    rejected because seasons differ between hemispheres.
  - Status colours stay fixed across theme colours.
  - The native splash screen stays Fjord, and why.
- The Tweety design system artifact
  (`https://claude.ai/artifact/QyMAeXgoKf4DxVRegGCHvn`) still calls Fjord's
  colours "proposed". Update its tokens and README after this lands.

## 13. Decisions and deferred items

No questions are open. Do not change these in this work:

1. **Picker placement.** Inside the Appearance section, under the Theme
   segmented control (section 8.3).
2. **In-app appearance setting stays.** Apple's Dark Mode guidance advises
   against an app-specific appearance setting. The user keeps it. System stays
   the default.
3. **Language stays on this page**, as an in-app choice. Only its UI changes
   (section 8.5). Syncing with the system per-app language is a later ticket.
4. **One pane on every device**, including the open foldable, where the column
   crosses the hinge (section 8.6). This goes against the research's advice,
   by the user's choice.
5. **No list-detail Settings layout** until Settings has about three categories.
6. **Android language row has no chevron**, following Android settings rows.
   The research sketch shows one.
7. **The night `bird` field.** Stays required, with its existing doc comment.
   Do not make it nullable.
8. **Whin and Lyng golds.** Left as they are. The user will review them in the
   built app and may change Lyng's secondary later.
9. **The `warning` token.** Stays `#FFA000`. The Account work owns any change.
