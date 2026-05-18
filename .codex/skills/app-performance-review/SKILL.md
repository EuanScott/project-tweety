---
name: app-performance-review
description: Review a specific app page, feature, screen, or view for performance risks such as ANRs, jank, slow builds, excessive rebuilds, eager rendering, expensive layout, memory pressure, blocking work, and inefficient data loading. Use when asked to investigate why a page is broken/slow or to apply mobile/web app performance best practices and recommend or implement focused improvements.
---

# App Performance Review

## Overview

Use this skill to investigate one page or feature at a time and produce practical performance findings. Prefer evidence from the local code, telemetry/logs when available, package versions, and official framework guidance over generic advice.

## Help Mode

If the user's request includes `--help`, do not inspect code or make changes. Respond with a concise human-readable help message that explains:

- What this skill does: reviews a page/feature for performance risks and focused improvements.
- What input the user should provide: page/feature name, relevant route/view name, symptoms, app version, date range, device/platform, telemetry/error details, and whether they want investigation only or code changes.
- What the skill will output: scope reviewed, likely causes, ranked findings, recommended fixes, and verification steps.
- Example prompts the user can copy.

Use this help response template:

```text
$app-performance-review helps investigate one app page or feature for performance risks such as ANRs, jank, slow builds, excessive rebuilds, eager rendering, expensive layout, blocking work, and inefficient data loading.

Good inputs:
- Page or feature name, for example `order_details`.
- Symptom, for example `Application Not Responding`, slow scrolling, or poor first render.
- Optional telemetry scope: app version, platform, date range, route/view name, affected devices, or error message.
- Desired action: investigation only, recommendations, or implement fixes.

Example:
Use $app-performance-review to investigate `order_details` for ANRs on app version 4.16.1. Use Coralogix if available, inspect only this page and nearby dependencies, and recommend focused fixes without changing code.
```

## Workflow

1. Confirm the target page/feature and keep the scope narrow unless the user asks to expand it.
2. Read repository instructions first, including root and nearest `AGENTS.md` files.
3. Inspect the target page, its widgets/components, state management, data loading path, and immediately adjacent dependencies.
4. Check `pubspec.lock`, `package-lock.json`, or equivalent before relying on package-specific behavior.
5. If telemetry access exists, query only the relevant app/version/date/view/error scope and compare logs with code paths.
6. Identify root-cause candidates and rank them by likely impact and confidence.
7. Recommend the smallest purposeful fixes; implement only if the user asks for code changes.

## What To Look For

### Rendering and Layout

- Eager rendering: `SingleChildScrollView` + `Column`, mapped arrays, nested non-lazy lists, hidden content still built while collapsed.
- Expensive layout: `IntrinsicHeight`, `IntrinsicWidth`, deep nested rows/columns, large text trees, unbounded constraints, repeated global-key measurement.
- Animation cost: `AnimatedSize`, `SizeTransition`, automatic scroll-to-view, opacity/slide animations around large children, repeated layout during animation.
- Skeleton/loading cost: whole-page skeletonizers or shimmer wrappers that traverse large placeholder trees.
- Images/assets: oversized images, SVG/path-heavy icons, uncached remote images, image decoding on hot screens.

### Rebuilds and State

- Work started from `build`, selectors that are too broad, missing `buildWhen`/`listenWhen`, `setState` rebuilding large subtrees, unstable keys, recreated controllers/futures/streams.
- Page-owned state that causes full-screen rebuilds when only one row/button needs updating.
- Bloc/provider boundaries that make unrelated UI rebuild together.
- Missing or misused `Key`s in dynamic, reordered, inserted, removed, or stateful lists that can cause Flutter to match elements poorly and redo layout/state work.

### Data and Main-Thread Work

- JSON parsing, sorting, filtering, grouping, date/currency formatting, regex, or collection transforms done synchronously during `build`.
- Large responses decoded or transformed on the UI thread.
- Duplicate network calls from lifecycle/build mistakes, route re-entry, refresh loops, or multiple providers.
- Missing pagination/lazy loading for long lists or transaction histories.

### Mobile ANR/Jank Signals

- Treat ANR evidence as correlation until stack traces, view names, timestamps, and code paths align.
- Check whether telemetry route/view tracking is accurate; a reported view may be the previous screen if navigation tracking is stale.
- Prefer concrete measurements: event counts, affected users/sessions, representative stack traces, first/last seen, app version, OS/device, and view.

## Flutter-Specific Guidance

- Prefer lazy slivers or `ListView.builder` for potentially long content.
- Avoid `IntrinsicHeight`/`IntrinsicWidth` in repeated rows; use fixed geometry, constraints, or custom painting.
- Do not build collapsed card bodies unless they are visible or about to become visible.
- Use stable `Key`s selectively to preserve element identity in dynamic lists, expandable rows, tab/page content, and stateful child widgets. Prefer stable domain identifiers such as `ValueKey(order.id)` over indexes when item order can change. Avoid `UniqueKey`, random keys, or timestamp keys unless forced recreation is intentional.
- Keep builders pure; navigation, snackbars, dialogs, and one-off effects belong in listeners.
- Use `BlocSelector`, `buildWhen`, `listenWhen`, or smaller widget boundaries only where they materially reduce rebuild work.
- Cache or precompute display strings in state/view models when formatting happens repeatedly.
- Keep performance patches local; do not redesign UI unless explicitly requested.

## Output Format

When reporting findings, include:

- Scope reviewed: files/components and any telemetry filters used.
- Outcome: whether evidence proves the page is the source or only shows risk/correlation.
- Findings: ranked list with impact, confidence, and file/component references.
- Fixes: concrete changes ordered by expected payoff and implementation size.
- Verification: suggested profiling/tests such as Flutter DevTools frame chart, rebuild rainbow, timeline trace, targeted widget tests, or telemetry follow-up.

Use concise language. If exact line links are required by the environment, provide valid clickable file links according to the active tool/UI rules.
