# Explicit Cubit Variant

Read this reference only when the user explicitly requests `controller: cubit`.

Create exactly:

- `lib/presentation/pages/<feature_name>/<feature_name>.page.dart`
- `lib/presentation/pages/<feature_name>/cubit/<feature_name>.cubit.dart`
- `lib/presentation/pages/<feature_name>/cubit/<feature_name>.state.dart`

Inspect `lib/presentation/pages/app_preferences/cubit/` only for current Cubit, Freezed, Injectable, and error-reporting syntax. Derive feature behavior from the user request and verified dependency; do not copy app-preferences policy or payload fields.

Use a Cubit only for direct commands where event names add no vocabulary. Name the initial command for its intent, such as `loadPreferences()`, rather than a generic bootstrap placeholder. Keep one feature-scoped Freezed state and status enum. Resolve the Cubit with `GetIt.I<FeatureCubit>()` and trigger the initial command during page-owned provider creation when required.

**Gate:** Confirm no event file or BLoC file exists, the Cubit exposes only requested commands, and its tests cover command-to-state behavior.
