# Ticket 1: Theme colour presets, stored preference and scene palettes

- **Spec:** [`../theme_colours_implementation.md`](../theme_colours_implementation.md).
  Read it all before you start. Where this ticket and the spec differ, the spec wins.
- **Depends on:** nothing. The navigation work it needed has landed.
- **Blocks:** [Ticket 2](theme_colours_02_settings_page_and_picker.md).
- **Size:** medium. One session.

## Goal

The app can draw any of the seven theme colours, in light and dark mode,
chosen by a stored preference. The water scene follows the theme colour.

After this ticket nothing in the UI lets a person choose a theme colour. That
comes in ticket 2. Tests prove the behaviour here.

## In scope

| Work | Spec section |
|---|---|
| Seven `DesignBrand` presets (`fjord`, `fynbos`, `kalahari`, `lyng`, `whin`, `douro`, `cuillin`) with the brand and surface values | 4, 5.1 |
| Replace `tweetyB2c` with `fjord` (same values). `tweetyB2b` is already gone. `DesignSystemTheme` defaults to `fjord` | 3, 5.1 |
| `DesignBrands.all` lists all seven | 5.2 |
| Remove the unused `info` status colour. Keep `success` and `warning` unchanged | 5.3 |
| Contrast test over every preset, light and dark | 6.1 |
| Cupertino tinted secondary button: 12% to 6% tint | 6.2 |
| `AppPreferencesThemeColour` enum and `themeColour` field (default `fjord`) | 7.1 |
| Storage field, JSON key `themeColour`; missing or unknown reads as `fjord` | 7.2 |
| Repository mapping both ways | 7.2 |
| `AppPreferencesCubit.updateThemeColour` | 7.3 |
| `main.dart` maps the theme colour to a preset with an exhaustive `switch` | 7.3 |
| `ScenePalette` becomes a `ThemeExtension` with a palette per theme colour and brightness; keep the night flag | 9 |
| Docs: `visual_style.md`, `CONTEXT.md`, the new ADR | 12 |

## Out of scope

- Any change to the Display and language page, strings, or new UI controls.
  Those are ticket 2.
- Everything in spec section 13. Do not reopen those decisions.

## Acceptance criteria

- [ ] `DesignBrands` has the seven presets with the values in spec section 4,
      and no `tweetyB2c`.
- [ ] `DesignBrands.all` has seven entries. The app does not depend on its order.
- [ ] `DesignStatusColors` has no `info`. Nothing else referenced it.
- [ ] The contrast test passes for every pair in spec 6.1, in every preset,
      light and dark.
- [ ] The Cupertino secondary `AppButton` uses a 6% tint.
- [ ] A saved preference without `themeColour`, or with an unknown value, loads
      as `fjord`. No migration.
- [ ] Changing the preference through the cubit rebuilds the app theme.
      Choosing Kalahari gives `colorScheme.primary` `#A8441F` in light mode.
      Choosing Cuillin in dark mode gives `#E6E8EA`.
- [ ] `ScenePalette.of(context)` returns the matching palette for the theme
      colour and brightness, and reports night in dark mode. Birds still paint
      by day only.
- [ ] Both `DesignStatusColors` and `ScenePalette` extensions are present on the
      theme (the `copyWith(extensions:)` trap in spec 9.1).
- [ ] Fjord looks the same as before this ticket, in light and dark.
- [ ] The ADR, `CONTEXT.md` and `visual_style.md` are updated (spec 12).

## Tests

From spec section 11: design system (contrast, presets, no `info`), storage,
repository, cubit, app and scene. Follow `docs/testing/README.md`.

## Files you will touch

- `packages/design_system/lib/src/theme/design_brands.dart`
- `packages/design_system/lib/src/theme/extensions/design_status_colors.dart`
- `packages/design_system/lib/src/adaptive/app_button.dart`
- `packages/design_system/test/` (new contrast test)
- `lib/domain/entities/app_preferences/app_preferences.entity.dart` (+ regenerate)
- `lib/core/storage/app_preferences.storage.dart`
- `lib/data/repositories/app_preferences/app_preferences.repository_impl.dart`
- `lib/presentation/pages/app_preferences/cubit/app_preferences.cubit.dart`
- `lib/main.dart`
- `lib/presentation/widgets/water_scene/scene_palette.model.dart`
- `docs/design/visual_style.md`, `docs/CONTEXT.md`, `docs/decisions/` (new ADR)

## Done when

- `flutter analyze --no-fatal-infos` and `tool/hooks/bloc_lint.sh lib test packages`
  are clean.
- `flutter test` passes, and the design system package tests pass.
- Generated files are regenerated, not hand-edited.
- Commits follow Conventional Commits (for example
  `feat(theme): add seven theme colour presets`).
