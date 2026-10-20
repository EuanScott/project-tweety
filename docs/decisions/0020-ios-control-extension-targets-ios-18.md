# ADR-0020: The iOS control extension targets iOS 18

Status: accepted
Date: 2026-10-20
Decision maker: Euan Scott

## Context

A person can start a new log entry from a "New log" control. They can add it
to Control Center, the Lock Screen or the Action button. iOS added controls
in iOS 18. A control lives in a WidgetKit app extension, so that extension
must target iOS 18.0.

The app's minimum iOS version is 17.0. The project rule is that the minimum
versions stay the same in every platform setting. That rule was written for
the app.

The control runs an App Intent that opens the app. A spike on iOS 26.5 showed
that iOS runs this intent in the app process, on warm and cold launch. The
intent can therefore reach the app's code directly.

## Decision

**We will give the `NewLogControls` extension a deployment target of iOS 18.0
and keep the app at iOS 17.0.** This is a stated exception to the rule on
minimum versions. The rule still covers the app.

Because the intent runs in the app process, it hands the "new log" action to
the same in-app holder that the home screen quick action uses. The holder
keeps the action until Dart takes it, and Dart opens the editor.

## Alternatives

**Raise the app to iOS 18.0.** This removes the exception, but it drops
people on iOS 17 for a convenience feature.

**Pass the action through an App Group or a deep link.** These work across
processes. The intent already runs in the app process, so the extra
entitlement or URL scheme gives nothing.

## Consequences

- People on iOS 17 do not get the control. They still have the home screen
  quick action.
- The app and the extension have different deployment targets. A change to the
  app minimum must not change the extension target, and the reverse.
- If a later iOS version runs the intent in the extension process, the
  control opens the app but not the editor. Then use an App Group to pass the
  action, and update this record.
- Re-evaluate when the app minimum reaches iOS 18.0. The exception then goes
  away.

## Confirmation

- In the Xcode project, only the `NewLogControls` build configurations set
  the deployment target to iOS 18.0. The app's configurations stay at 17.0.
- A release archive of the app builds with the extension embedded.
