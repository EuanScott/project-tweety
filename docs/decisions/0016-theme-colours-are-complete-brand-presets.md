# ADR-0016: Theme colours are complete brand presets named after places and plants

Status: accepted
Date: 2026-10-06
Decision maker: Euan Scott

## Context

A person can choose a theme colour for the app. Light and dark mode stay a
separate setting, so each theme colour needs a day version and a night
version.

The design system builds its theme from a `DesignBrand`. A brand holds the
primary, secondary and surface colours for light and dark mode. Before this
decision the app had one brand, `tweetyB2c`. Navigation already uses neutral
surfaces in every brand ([ADR-0014](0014-neutral-navigation-surfaces.md)),
so a brand does not need navigation colours.

The app belongs to a family with four cultures: Norway, South Africa,
Scotland and Portugal. The plan for this work is in
`docs/plans/theme_colours_implementation.md`.

## Decision

**We will make each theme colour a complete `DesignBrand` preset, and name
each one after a place or a plant from the family's four cultures.**

- There are seven presets: Fjord (the default, which was `tweetyB2c`),
  Fynbos, Kalahari, Lyng, Whin, Douro and Cuillin.
- Each preset sets its own primary, secondary and surface colours, for light
  and dark mode.
- The status colours (`success`, `warning`), the error colours, the outline
  and the text colours on surfaces are the same in every preset.
- The water scene has its own palette for each theme colour and brightness.
  It stays in the app, because the colours belong to the illustration.
- The native splash screen stays Fjord.

## Alternatives

- **An accent layer on one brand.** Only the primary colour changes, and the
  surfaces stay the same. This was rejected. A warm primary such as red ochre
  looks wrong on cool teal-grey surfaces, and some primaries need their own
  text colour to pass contrast.
- **Sunrise and Sunset as names.** Rejected. "Sunset" in light mode, or
  "Sunrise" at night, contradicts the brightness the person sees.
- **Seasonal names.** Rejected. The seasons are opposite in the two
  hemispheres the family lives in.
- **A splash screen per theme colour.** Not possible. The operating system
  draws the native splash before any app code runs, so it cannot read the
  stored preference.

## Consequences

- A new theme colour needs a full preset and two scene palettes. The app maps
  its theme colour enum to a preset with an exhaustive `switch`, so a new
  value does not compile until it has a preset.
- Status colours never move with the brand. A "Verified" mark looks the same
  in every theme colour.
- The contrast test in `packages/design_system/test/theme/design_brands_test.dart`
  covers every preset, so a later change to a value cannot quietly fail
  contrast.
- The Cupertino tinted secondary button uses a 6% tint instead of 12%. At
  12%, Fjord's primary text on its own tint failed 4.5:1 in light mode.
- The splash screen shows Fjord for a moment before a different theme colour
  appears. Re-evaluate if this flash becomes a visible problem.

## Confirmation

- `DesignBrands.all` lists every preset, and the contrast test loops over it.
- The app's theme colour test checks that a change through
  `AppPreferencesCubit` rebuilds the theme, and that the design-system and
  scene theme extensions are both present.
