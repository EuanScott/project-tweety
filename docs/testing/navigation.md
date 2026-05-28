# Navigation Testing

Use this guide to check deep links and the temporary Settings route guard.

## Quick Checks

Run the navigation widget tests:

```sh
flutter test test/widget_test.dart
```

Run only the Settings guard test:

```sh
flutter test test/widget_test.dart --plain-name "explains denied settings deep links"
```

## Manual Guard Test

Settings is accessible by default:

```sh
flutter run
```

Disable Settings access:

```sh
flutter run --dart-define=CAN_ACCESS_SETTINGS=false
```

Expected result when disabled:

- `/settings` redirects to `/access-denied`
- `/settings/app-preferences` redirects to `/access-denied`
- the access-denied page explains the block and offers Go home

## Web Deep-Link Test

Flutter web is the easiest manual path test because the browser URL drives
`go_router` directly.

```sh
flutter run -d chrome
```

Try:

```text
http://localhost:<port>/#/settings/app-preferences
http://localhost:<port>/#/cards/card-1
http://localhost:<port>/#/missing
```

With the guard disabled:

```sh
flutter run -d chrome --dart-define=CAN_ACCESS_SETTINGS=false
```

Open:

```text
http://localhost:<port>/#/settings/app-preferences
```

Expected result: Access denied.

## Current Routes

- `/` redirects to `/home`
- `/home`
- `/access-denied`
- `/cards`
- `/cards/:cardId`
- `/settings`
- `/settings/app-preferences`

## Important Limitation

Android and iOS external link registration is not configured yet. These tests
verify router-level paths once Flutter receives a location.

When platform links are added, extend this guide with concrete `adb shell am
start` and `xcrun simctl openurl` commands for the chosen scheme or domain.

## Guard Rule Of Thumb

Redirect users to the route that helps them recover:

- signed out: login
- incomplete profile: profile completion
- missing role or entitlement: access denied, request access, or upgrade
- unknown auth state: loading or splash gate

Preserve the original route when the user should return after completing a
journey.
