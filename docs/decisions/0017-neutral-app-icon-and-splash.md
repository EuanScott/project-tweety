# ADR-0017: App icon and splash screen are neutral across theme colours

Status: proposed
Date: 2026-10-06
Decision maker: Euan Scott

## Context

The app has seven theme colours
([ADR-0016](0016-theme-colours-are-complete-brand-presets.md)). Each theme
colour has its own water scene palette in the app.

The app icon and the native splash screen used the Fjord colours. The
operating system shows the splash before any app code runs, so the splash
cannot read the chosen theme colour. ADR-0016 accepted this. As a result, a
person who chose another theme colour saw Fjord for a moment at every start.

An icon for each theme colour is possible, but it has visible costs. iOS
shows an alert after each icon change, and the app cannot hide it. Some
Android launchers move home-screen shortcuts or restart the app when the
icon changes.

## Decision

**We will use one neutral app icon and one neutral splash screen for every
theme colour, each with a light and a dark version.** The assets show the
same water scene as before, in warm stone colours with a gold sun.

This decision replaces two statements in ADR-0016:

- "The native splash screen stays Fjord."
- "The splash screen shows Fjord for a moment before a different theme
  colour appears."

The rest of ADR-0016 still applies.

Each hill and water colour becomes a warm stone colour with the same
lightness as its Fjord colour. This keeps the depth of the scene: far layers
are pale and near layers are dark. The clouds and the shimmer become a warm
white.

| Layer | Light | Dark |
|---|---|---|
| Sky and splash background | `#F4EEE7` | `#2A2521` |
| Far hills | `#E3DDD6` | `#37322E` |
| Mid hills | `#CEC8C1` | `#47423E` |
| Back water | `#B6B0A9` | `#5A5551` |
| Near water | `#908A83` | `#6A6460` |
| Closest water | `#6C6761` | `#514C48` |
| Foam | `#E4DED7` | `#BDB7B2` |
| Clouds | `#FFFDF8` | `#3E3935` |
| Shimmer | `#FFFDF8` | `#CAC4BF` |
| Sun, moon and stars | `#FFD45C` | `#F7EBC6` |

The sun is the only strong colour. All seven in-app day scenes use
`#FFD45C` for the sun, so this colour already belongs to every theme colour.
The moon is a pale tint of the same gold.

## Alternatives

- **An icon for each theme colour.** Rejected because of the iOS alert and
  the Android launcher problems in the context.
- **A splash for each theme colour on Android.** Android 13 and later can
  save a splash style for the next start of the app. Rejected because iOS
  cannot do this, so the two platforms would behave differently.
- **Grey instead of warm stone.** Pure grey with a white sun was rejected,
  because the white sun almost disappears on a grey sky. Grey with a gold
  sun was also possible. The decision maker chose warm stone after a
  side-by-side comparison. Grey can also look like Cuillin, the theme colour
  that is black in light mode.
- **The average page background as the splash background** (`#F6F6F6` and
  `#131313`). This would make the change into the app smoother, but the edge
  of the scene circle would show. Not chosen, so the circle stays invisible
  on its sky colour.

## Consequences

- Every person sees the same splash. The splash no longer shows Fjord before
  a different theme colour appears.
- The icon and the splash no longer show the default theme colour.
- The splash background is a warm stone colour, not the page background of
  the chosen theme colour. There is a small change of colour when the app
  appears.
- A new theme colour needs no new icon or splash.
- The Android themed (monochrome) icon has no colour and does not change.
- Re-evaluate when a new theme colour is added, if the warm stone or the gold
  sun looks wrong next to it.

## Confirmation

- The sources in `assets/brand/source/` contain only the colours in the
  table, plus the colourless monochrome icon.
- `flutter_native_splash.yaml` uses `#F4EEE7` and `#2A2521` as the splash
  backgrounds.
- The generated files use the same backgrounds:
  `android/app/src/main/res/values-v31/styles.xml`,
  `android/app/src/main/res/values-night-v31/styles.xml` and the iOS
  `LaunchBackground` images. Regenerate them with
  `dart run flutter_native_splash:create`. Do not edit them by hand.
