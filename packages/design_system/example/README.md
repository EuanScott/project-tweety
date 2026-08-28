# design_system Component Gallery

A Flutter web app that renders every `design_system` adaptive widget in
simultaneous Material (Android) and Cupertino (iOS) comparison panes, for
visual evaluation without running the full `project_tweety` app.

See [ADR-0005](../../../docs/decisions/0005-design-system-example-app-location.md)
for why this lives inside the package.

## Run

```sh
flutter pub get
flutter run -d chrome
```

This is a dev-only POC — no automated tests, no deployment. See the
[component gallery spec](https://github.com/EuanScott/project-tweety/issues/15)
for full scope and the deferred backlog.
