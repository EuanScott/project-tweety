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
- shared brand definitions such as B2C and B2B

## What does not live here

- app-specific widgets
- routes and navigation flows
- feature BLoCs
- data or domain logic
- business rules

## Current public API

- `DesignSystemTheme.light(...)`
- `DesignSystemTheme.dark(...)`
- `DesignBrand`
- `DesignBrands`

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
    brand: DesignBrands.tweetyB2c,
  ),
  darkTheme: DesignSystemTheme.dark(
    brand: DesignBrands.tweetyB2c,
  ),
)
```

## Branding

The package is built around a shared theme structure with brand-specific tokens.

That means:

- B2C and B2B can use the same theme logic
- only brand values need to differ
- apps stay visually aligned while still being distinguishable

Current bundled brands:

- `DesignBrands.tweetyB2c`
- `DesignBrands.tweetyB2b`

## Adding a new brand

1. Create a new `DesignBrand` in `lib/src/theme/design_brands.dart`
2. Supply the required brand tokens
3. Pass that brand into `DesignSystemTheme.light(...)` and `DesignSystemTheme.dark(...)`

## Package structure

```text
lib/
  design_system.dart
  src/theme/
    design_brand.dart
    design_brands.dart
    design_color_schemes.dart
    design_system_theme.dart
    components/
    extensions/
```

## Notes for future extraction

The current scope is intentionally narrow: shared theming first.

Once this package is stable, the next candidates for shared extraction are:

- spacing and radius tokens
- shared UI primitives
- shared reusable widgets
- icon and asset strategy

Keep the package focused on reusable presentation concerns rather than turning it into a dumping
ground for anything "shared".
