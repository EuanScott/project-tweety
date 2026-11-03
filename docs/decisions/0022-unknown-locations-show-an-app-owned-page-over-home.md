# ADR-0022: Unknown locations show an app-owned page over Home

Status: accepted
Date: 2026-11-03
Decision maker: Euan Scott

## Context

The route error page shows when the router cannot resolve a location. Most
often this is a deep link to a page that does not exist.

The router showed that page through `errorBuilder`, using
`NavigationRouteErrorPage` from `packages/navigation`. The page replaced the
whole app. It had no tab bar and nothing beneath it, so a back gesture had
nowhere to go, and "Go home" was the only way out.

A new design for the page needs `design_system`, translated text, the device's
tilt and compass sensors, and its own theme palettes.
`packages/navigation` must stay independent of `design_system` and
localization, and it should be usable by another Flutter app.

This decision came from a review of the new design.

## Decision

**We will redirect a location that no route matches to `/home/not-found`, an
app-owned page over Home, and the navigation package will have no default error
page.** The launch gate runs first, so a signed-out person still goes to sign-in.
`errorBuilder` stays required and shows the same page, for the case that the
redirect does not cover.

## Alternatives

- **Show the page through `errorBuilder` only.** This was the existing behaviour
  and the first plan for the new design. Rejected, because the page is a dead
  end: the iOS swipe-back and the Android back button have no page to return to.
- **Move the new page into `packages/navigation`.** Rejected, because the package
  would then depend on `design_system`, localization and the sensors. Another app
  would inherit one app's design to get routing.
- **Keep a generic default page in the package, with an optional
  `errorBuilder`.** Rejected, because a forgotten error page would still compile
  and ship with no brand and fixed text. A required parameter fails at compile
  time. The old page also needed text and an action from the caller, so it saved
  little.

## Consequences

- A person who opens a broken link can leave with "Go home", the iOS swipe-back or
  the Android back button.
- The app must keep a route for `/home/not-found` under Home, on the root
  navigator, so that the page covers the tab bar.
- One location case still reaches `errorBuilder`. After sign-in, go_router does
  not redirect the location carried from sign-in again. The page then shows alone,
  and "Go home" goes to Home. There are two paths to one page, and both need tests.
- "Go home" leaves the page by popping when it can. From a page other than Home,
  such as the Settings preview, it returns to that page.
- The redirect does not keep the location that failed. Nothing reads it today.
  Measuring broken links would need a new parameter.
- A new app that uses the package must write an error page before its first run.
  The package README shows a minimal one.
- Re-evaluate if external deep links are registered with the operating system, if
  broken links must be measured, or if a second app needs this page. That page
  would then become its own package, not part of `packages/navigation`.

## Confirmation

- `test/presentation/navigation/route_access.policy_test.dart` covers the redirect
  target and the launch gate order.
- `test/presentation/navigation/route_error_navigation.flow_test.dart` covers the
  page over Home, both back gestures, "Go home", and the case after sign-in.
- `packages/navigation/test/navigation_router_test.dart` shows an unknown location
  through `errorBuilder`, on a native page, using its own test page.
- `createNavigationRouter` requires `errorBuilder`, and `packages/navigation` exports
  no error page. A review that finds a page added to the package contradicts this
  decision.
