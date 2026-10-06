# Tweety visual style

This guide describes the visual language of Project Tweety, as set by the
sign-in screen. Use it to design new screens, starting with the account page,
so that they look and feel like the same app.

**Sources**

- Sign-in mocks: [Tweety sign-in screen](https://claude.ai/artifact/FdtMN7Effae6VsgvuJbstF) (Claude Design canvas, pages
  *Screens* and *Tilt depth*)
- Design system: [Tweety](https://claude.ai/artifact/QyMAeXgoKf4DxVRegGCHvn) (synced from `packages/design_system`)
- Implementation detail for sign-in: [`docs/plans/sign_in_implementation.md`](../plans/sign_in_implementation.md). It
  holds the exact scene geometry.

Both Claude Design links are private to the repository owner.

## 1. Character

- **Calm water, one chosen colour.** The app's identity is a quiet water landscape in the person's theme colour (Fjord
  teal by default). Screens feel open and unhurried.
- **Native on each platform.** One brand, two design languages. Controls are Material on Android and Cupertino on iOS,
  through the `design_system` primitives.
- **Day and night.** Light mode is a day scene. Dark mode is the same scene at night. Dark mode is never just "light
  mode with inverted colours".
- **Depth, not decoration.** Imagery is built from layers that read as near and far. Motion, where there is any, makes
  that depth felt.
- **Plain words.** Short sentences, no jargon, no exclamation marks.

## 2. Colour

### Theme colours (design system)

A person chooses one of seven theme colours. Each is a complete `DesignBrand`
preset, with its own light and dark values
([ADR-0016](../decisions/0016-theme-colours-are-complete-brand-presets.md)).
The source of truth for every value is
`packages/design_system/lib/src/theme/design_brands.dart`.

| Theme colour        | Primary (light / dark)  | Secondary (light / dark) |
|---------------------|-------------------------|--------------------------|
| Fjord (default)     | `#0E7474` / `#1BA6A6`   | `#8E3B76` / `#D68FC2`    |
| Fynbos              | `#56691C` / `#B5C96A`   | `#A3365F` / `#F2A3BF`    |
| Kalahari            | `#A8441F` / `#F39A74`   | `#2F5F8A` / `#9CC3EE`    |
| Lyng                | `#77449A` / `#D2A6EF`   | `#8A6100` / `#F2C14E`    |
| Whin                | `#7A5C00` / `#F2C230`   | `#3D5A80` / `#A9C1E6`    |
| Douro               | `#8C1D3A` / `#F0A3B5`   | `#2F5E9E` / `#A7C4EF`    |
| Cuillin             | `#1F2326` / `#E6E8EA`   | `#3F7A8C` / `#8CC4D4`    |

The roles are the same in every theme colour. Fjord's values are shown:

| Token         | Light        | Dark      | Use                                                        |
|---------------|--------------|-----------|------------------------------------------------------------|
| `primary`     | `#0E7474`    | `#1BA6A6` | Main action, headings, titles, Cupertino accent            |
| `onPrimary`   | `#FFFFFF`    | `#002020` | Text and icons on primary                                  |
| `secondary`   | `#8E3B76`    | `#D68FC2` | Accent. Use sparingly: small marks, never large areas      |
| `onSecondary` | `#FFFFFF`    | `#2E0A25` | Text on secondary                                          |
| `background`  | `#F4F6F7`    | `#121212` | Page background                                            |
| `surface`     | `#F4F6F7`    | `#2C2C2C` | Sheets, dialogs, raised areas                              |
| `surfaceContainer` | `#FFFFFF` | `#383838` | Cards and other areas raised on a sheet                |
| `onSurface`   | black at 87% | `#FFFFFF` | Body text                                                  |
| `error`       | `#D32F2F`    | `#D32F2F` | Errors and destructive actions only                        |
| `onError`     | `#FFFFFF`    | `#FFFFFF` | Text on error                                              |

These stay the same in every theme colour: `onSurface`, `surfaceContainer`,
`outline`, the error colours, and the status colours `success` (`#388E3C`) and
`warning` (`#FFA000`).

Rules:

- One primary action per screen.
- `error`, `success` and `warning` mean state only. Never decorate with them. They do not change with the
  theme colour.
- In dark mode, `error` red is too dark for text on the page (3.7:1). Show error text in `onSurface` and mark it with a
  red icon instead.

### Scene palette (illustration only)

These colours belong to the water scene, not to the design system. Do not use
them for controls or text, except the scene ink.

Each theme colour has its own day and night scene palette, in
`lib/presentation/widgets/water_scene/scene_palette.model.dart`. The day sun is
`#FFD45C` in every palette. In each day palette, closest water equals the light
`primary`. Fjord's values are shown:

| Element                       | Day       | Night     |
|-------------------------------|-----------|-----------|
| Sky                           | `#E3F2F3` | `#0D2A30` |
| Sun or moon                   | `#FFD45C` | `#E7F5F5` |
| Clouds                        | `#FFFFFF` | `#1A3F46` |
| Birds                         | `#7FB3BA` | `#4F7F86` |
| Far hills                     | `#C6E4E7` | `#143840` |
| Mid hills                     | `#9FD2D8` | `#1A4950` |
| Back water                    | `#6DBDC7` | `#1F5E66` |
| Shimmer                       | `#FFFFFF` | `#7FD3D3` |
| Near water                    | `#2A98A4` | `#13707A` |
| Closest water                 | `#0E7474` | `#0B555D` |
| Foam                          | `#BFE6EA` | `#5CC8C8` |
| Scene ink (text over the sky) | `#0F5D5D` | `#E7F5F5` |

**Atmospheric perspective:** far layers sit close to the sky colour, and near
layers are deeper and more saturated. Keep that order if you add or change a layer.

### Contrast

Every text pair must reach 4.5:1 (3:1 for text 24 px and larger). Check each
new pair in both themes. The contrast test in
`packages/design_system/test/theme/design_brands_test.dart` checks every theme colour.

## 3. Typography

Open Sans everywhere. Headings are bold and use `primary` (or scene ink over the sky).

| Style          | Size / line height | Weight | Typical use                     |
|----------------|--------------------|--------|---------------------------------|
| Display small  | 28 / 1.18          | 700    | Screen title on phones          |
| Display large  | 36 / 1.12          | 700    | Title over the scene on tablets |
| Headline large | 24 / 1.2           | 700    | Section or pane heading         |
| Title medium   | 16 / 1.25          | 700    | List item title                 |
| Body large     | 16 / 1.45          | 400    | Main text                       |
| Body medium    | 14 / 1.45          | 400    | Secondary text, message bodies  |
| Label medium   | 14 / 1.3           | 600    | Message titles                  |
| Body small     | 12 / 1.4           | 400    | Footnotes, at 60% (dark: 70%)   |
| Button         | 16 / 1.25          | 700    | All button labels               |

## 4. Shape, spacing and size

- Corner radius 12 px: buttons, cards, messages. The Cupertino filled button uses 8 px.
- Buttons: at least 48 px tall and full width in their column.
- Spacing: 8 px between a heading and its subtitle; 16 px between items in a block; 24–32 px between blocks.
- Page gutter: 24 px on phones (20 px under 360 px wide); 48 px inside tablet panes; 64 px top and bottom on tablets.
- Content columns on wide screens: at most 400 px wide.
- Cards use shadow, not borders.

## 5. Components and patterns

Use `design_system` primitives for every visible control. Add a missing
primitive to `packages/design_system` before using a raw Material or Cupertino control.

- **Buttons:** `AppButton.primary`, `.secondary`, `.text`, `.destructive`.
- **Loading:** `AppLoadingIndicator`, inside the control that is busy, with a short label such as "Signing in…". Disable
  the control while it works.
- **Lists and settings rows:** `AppListSection` groups rows under a header, with footer text for sentences.
  Inside it: `AppListTile`, `AppSwitch`, `AppSelectionRow` (a value that opens a selection list), and
  `AppListSectionContent` for custom content such as `AppSegmentedControl` or `AppSwatchPicker`.
- **Confirmation:** `AppConfirmationDialog`, for actions the person should think about once.
- **Message block** (from sign-in):
    - Padding 12 × 16 px, radius 12 px.
    - A 20 px icon at the start: a red circle with "!" for errors.
    - A title (14 px semibold), then a body (14 px).
    - Background: light `#FDECEC`, dark `#2C2C2C` for errors.
    - Place it directly above the action that resolves it. Announce it to screen readers.
- **Footnote:** one short, reassuring line under the main action, 12 px, centred. Example: "Your Cards stay on this
  device until you sync them."
- **One action does one job.** After a failure, the same button retries. Do not add a second "Try again" button.

## 6. Imagery: the water scene

### Structure

The scene is a stack of layers, back to front:

1. Sky, with sun (day) or crescent moon and stars (night), two clouds and three distant birds
2. Far hills
3. Mid hills
4. Back water, with shimmer lines
5. **The subject** (on sign-in: Dash)
6. Near water, with foam
7. Closest water, with foam

The two front layers cover the subject's lower part, so it sits *in* the scene
and not on top of it.

### Rules

- **Flat shapes, no gradients** inside the scene. The fade at its edge is four wavy bands of the background colour, each
  more solid than the one before and with a soft, blurred edge, so it follows the water.
- **The day sun is yellow**, so it reads as the sun and not as a third cloud against the pale sky.
- **The scene is never cut into.** It fades **out into blank space** past its edge: below it on phones, toward the
  content side on tablets. The composed scene itself stays at full strength.
- **Text over the scene** goes only on open sky, in scene ink. Keep the sun, clouds and birds clear of it.
- **One subject per scene.** Nothing else floats on the water.
- **Dash** (`assets/app_icon/dash.png`) is the app's mascot:
    - Use it unchanged: never recolour it, crop off its Card, or place it on a busy background.
    - Dash belongs to Google (Flutter brand). It is fine for this personal app; a published app would need its own
      mascot.

## 7. Layout

| Surface | When                                                             | Layout                                                                                              |
|---------|------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Compact | Phones and the folded cover screen (portrait only)               | One column. Scene band on top, its fade below it, then content                                      |
| Split   | Tablets (both orientations), any screen split by a vertical fold | Two panes. Scene fills the start pane and fades into the end pane; content sits in the end pane     |

- On sign-in in the compact layout, the scene starts below the status bar, and sky colour fills behind the status bar.
  Below the status bar, the scene and its fade take 60% of the height and the content takes 40%.
- On sign-in in the split layout, the scene takes 55% of the width. It never takes less than half, and it never leaves
  the content pane less than 360 px wide.
- On a foldable, never place content across the hinge. The scene and its fade may cross it. Text over the scene ends
  before the hinge, and the content pane starts after it.
- **Right-to-left (Hebrew):** mirror the whole layout. The scene pane is on the start side (the right).
- On small phones, if content overflows, the scene becomes a scrolling hero and the main action stays pinned at the
  bottom.

### Navigation

- Navigation surfaces are neutral in every theme colour. Only the selected item
  carries the brand colour. See
  [ADR-0014](../decisions/0014-neutral-navigation-surfaces.md).
- Android: the bar, rail and drawer share one surface (the page darkened 4% in
  light, the raised surface in dark). The selected item has a soft `primary`
  pill. Labels are neutral; the selected label is bold.
- iOS: the tab bar uses the system bar colours. The sidebar marks the selected
  row with a 6% `primary` tint and `primary` text, with no checkmark.
- Titles stay bold and in `primary`. This is a brand choice, not the native look.

iOS chooses by the window's shortest side:

| Shortest side | iOS |
|---|---|
| Under 600 | Tab bar |
| 600 or more | Sidebar (304 px, collapses to 72 px) |

Android chooses by the window's width:

| Width | Android |
|---|---|
| Under 600 | Navigation bar |
| 600 to 1199 | Rail, labels shown |
| 1200 or more | Drawer (304 px, collapses to a rail without labels) |

An iPhone keeps the tab bar in landscape. Android uses width, so a phone in
landscape gets the rail.

## 8. Motion

- **Depth motion.** Scene layers move by depth: far layers barely, near layers most.

  | Layer | Scroll factor | Tilt: maximum shift |
    |---|---|---|
  | Sky and its details | 0.70 | 2 px |
  | Far hills | 0.55 | 4 px |
  | Mid hills | 0.42 | 6 px |
  | Back water | 0.30 | 9 px |
  | Subject | 0.18 | 11 px |
  | Near and closest water | 0 | 16 px |

- Tilt applies on every device. Scroll applies only where content overflows.
- Movement is small and smooth. It glides and never jumps.
- **Reduce Motion:** when the system setting is on, nothing moves.

## 9. Words

- Second person, present tense: "Sign in to keep your Cards and back them up."
- "Card" and "Cards" are capitalised: they are the app's main domain term.
- Error messages: a short title saying what happened ("Sign-in didn't work"), then one sentence saying what to do (
  "Check your connection and try again.").
- Reassure about data where it matters: say where Cards are and what happens to them.
- Every visible string goes in the ARB files for English, Spanish and Hebrew.

## 10. Accessibility checklist

- [ ] Every text pair passes contrast in light and dark.
- [ ] Touch targets are at least 44 px; buttons at least 48 px.
- [ ] Images that carry meaning have a description; decorative layers are hidden from screen readers.
- [ ] Messages that appear after an action are announced.
- [ ] The layout works at large text sizes (it may scroll; the main action stays reachable).
- [ ] Reduce Motion stops all movement.
- [ ] Right-to-left mirrors correctly.

## 11. Applying this to the account page

The account page ([Prototype: the minimal account page](https://github.com/EuanScott/project-tweety/issues/29))
proves that real profile data arrived and gives a way to sign out. These are
suggestions that fit the style. The decisions belong to that ticket.

**Header**

- Reuse the water scene as a **shorter band**, about 28–32% of the height on phones, so the details get most of the
  screen.
- Make the **profile photo the subject**: a circle of about 96 px with a 4 px ring in the page colour, sitting on the
  waterline where Dash stands on sign-in. The front water does not cover a photo; let the circle overlap the band's fade
  instead.
- Keep the same day and night scene, so moving from sign-in to the account page feels continuous.

**Details**

- Display name as the heading (24 px bold, `primary`), email under it (16 px body).
- Further fields as `AppListTile` rows with a small label above each value.

**Missing data**

- No photo: a circle in `primary` with the person's initials in `onPrimary`. With no name either, use a person icon.
- No display name: use the email as the heading.
- No email, or an unverified one: say so plainly in the row ("No email on this Account"). Do not leave it blank.

**Sign out**

- Use `AppButton.secondary`, not `.destructive`. Signing out keeps the local Cards (ADR-0008), so nothing is lost.
- Confirm once with `AppConfirmationDialog`. Say what happens to the Cards, for example: "Your Cards stay on this
  device. Sign in again to see them."
- Put a footnote-style line under the button, in the same voice as on sign-in.

**Split layout**

- Scene pane on the start side with the photo as its subject; details and sign-out in the end pane. This mirrors
  sign-in, so the two screens read as a pair.

**Motion**

- The same depth motion can apply. The photo moves with the subject factor.

## 12. Designing in Claude Design

1. Start a new **Design** canvas and attach the **Tweety** design system, so colours, type and spacing match.
2. To reuse the scene, read a sign-in screen from the sign-in canvas (for example `project/Main.dc.html`) and copy its
   scene markup. The geometry is the same on every screen.
3. Keep the day and night versions side by side, and include at least one phone, one tablet and the open foldable.
