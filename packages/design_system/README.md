# design_system

Shared Flutter design system package for Tweety applications.

This package is the beginning of the app modularization journey. It owns reusable theming and
design-level presentation concerns so multiple apps can share the same visual foundation without
copying code.

## What lives here

- shared `ThemeData` construction
- shared color and surface tokens
- shared typography
- shared component theme configuration
- shared brand definitions
- adaptive UI primitives, which own the Material and Cupertino branching
- branded controls whose look a third party owns

## What does not live here

- app-specific widgets
- routes and navigation flows
- feature BLoCs
- data or domain logic
- business rules

## Current public API

`lib/design_system.dart` is the full list of exports. In summary:

- Theme: `DesignSystemTheme.light(...)`, `DesignSystemTheme.dark(...)`,
  `DesignBrand`, `DesignBrands`, the bottom-sheet theme, and the status-colour
  and text-theme extensions.
- Adaptive primitives in `src/adaptive/`: buttons (`AppButton`,
  `AppIconButton`, `AppFloatingActionButton`), inputs (`AppTextField`,
  `AppPickerField`, `AppSwitch`, `AppSegmentedControl`, `AppSwatchPicker`,
  `AppSelectionRow`), lists (`AppListSection`, `AppListTile`), feedback
  (`showAppConfirmationDialog`, `AppLoadingIndicator`, `AppRefreshIndicator`),
  page layout (`AppPageIntro`, `AppPrimaryActionPane`, `PaneLayoutScope`,
  `PaneLayoutMode`), and
  platform and size helpers (`AppDesignPlatform`, `DisplayMetrics`).
- Branded: `AppGoogleSignInButton`, the official "Sign in with Google" button.

## Usage

Add the package as a local path dependency in the consuming app:

```yaml
dependencies:
  design_system:
    path: packages/design_system
```

Then use it in `MaterialApp`:

```dart
import 'package:design_system/design_system.dart';

MaterialApp(
  theme: DesignSystemTheme.light(
    brand: DesignBrands.fjord,
  ),
  darkTheme: DesignSystemTheme.dark(
    brand: DesignBrands.fjord,
  ),
)
```

## Branding

The package is built around a shared theme structure with brand-specific tokens.

That means:

- several brands can use the same theme logic
- only brand values need to differ
- apps stay visually aligned while still being distinguishable

Current bundled brands, one per theme colour:

- `DesignBrands.fjord` (the default)
- `DesignBrands.fynbos`
- `DesignBrands.kalahari`
- `DesignBrands.lyng`
- `DesignBrands.whin`
- `DesignBrands.douro`
- `DesignBrands.cuillin`

`DesignBrands.all` lists every bundled brand. Its order means nothing.
Status colours, error colours, the outline and the text on surfaces are the
same in every preset.

## Adding a new brand

1. Create a new `DesignBrand` in `lib/src/theme/design_brands.dart`
2. Supply the required brand tokens. `primary`, `onPrimary`, `secondary` and
   `onSecondary` each have a light and a dark value, so each theme can pass
   contrast. Give the same value to both when a brand needs no change.
   `onError` is its own token, because a dark `onPrimary` can fail contrast on
   the error red. `errorContainer` and `onErrorContainer` colour inline error
   messages in each theme.
3. Add it to `DesignBrands.all`, so the contrast tests cover it.
4. Pass that brand into `DesignSystemTheme.light(...)` and `DesignSystemTheme.dark(...)`

## Branded controls

A branded control looks the same on Material and Cupertino, because a third
party owns its look. `AppGoogleSignInButton` follows Google's branding
guidelines: colours, Google Sans Medium 14/20 and a 1 px border. Its 12 px
corner radius, 16 px side padding and 48 px height match `AppButton`, inside
the rectangular shape the guidelines allow. Only the press feedback and the
gap after the mark (10 px Android, 12 px iOS) follow the platform.

The "G" mark in `assets/google/` comes unchanged from Google's sign-in asset
kit (<https://developers.google.com/identity/branding-guidelines>). The kit
draws the mark with effects that Flutter cannot render from SVG, so the asset
is the kit's PNG renders at 1x to 4x. Its transparency is recovered by
comparing the kit's light-tile and dark-tile renders of the same mark. Do not
redraw or recolour it.

## Package structure

```text
lib/
  design_system.dart
  src/adaptive/
    app_button.dart, app_text_field.dart, ... (one primitive per file)
  src/branded/
    app_google_sign_in_button.dart
  src/theme/
    design_brand.dart
    design_brands.dart
    design_color_schemes.dart
    design_system_theme.dart
    components/
    extensions/
```

## Notes for future extraction

The current scope is shared theming and adaptive UI primitives.

The next candidates for shared extraction are:

- spacing and radius tokens
- shared reusable widgets
- icon and asset strategy

Keep the package focused on reusable presentation concerns rather than turning it into a dumping
ground for anything "shared".
