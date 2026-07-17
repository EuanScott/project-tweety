# Navigation guidance

Read the [package README](README.md) for the generic navigation concepts and integration path.

- Keep this package independent of `project_tweety`, localization, analytics, and `design_system`.
- Export public types from `lib/navigation.dart`; keep implementation under `lib/src/`.
- The consuming app supplies routes, labels, page builders, redirects, and analytics.
- Keep reselect behaviour UI-local; do not add app refresh policy here.
