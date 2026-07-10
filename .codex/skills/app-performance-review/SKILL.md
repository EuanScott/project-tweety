---
name: app-performance-review
description: Audit one Project Tweety Flutter view proactively for evidence-backed performance risks. Use for scoped, read-only reviews without a reported regression.
---

# App Performance Review

Audit one named page or feature and rank evidenced performance risks without
changing code.

## Routing gate

Require one named page, route, or feature. Narrow whole-app requests to an
explicitly bounded first target.

Use this audit for proactive review. A measured slowdown, dropped frame rate,
hang, Android ANR, iOS watchdog termination, regression, or intermittent
failure enters `$diagnosing-bugs` so work begins with a red feedback loop. A
requested fix enters `$implement` after evidence identifies the behaviour to
protect.

Finish this gate with one target and the proactive-audit branch; otherwise hand
off to the appropriate flow.

## Workflow

### 1. Trace the hot path

Read the applicable `AGENTS.md`, locate the target entrypoint, and trace its
render/state/data path plus direct dependencies. Expand one additional hop only
when local evidence points there.

Read a lockfile only for a package-version-dependent claim. Query telemetry
only when the user supplies a relevant scope or local evidence requires
production confirmation. Consult official framework documentation only for
unstable API semantics.

Finish when every inspected file belongs to the named hot path or has an
explicit evidence link to it.

### 2. Inspect six lenses

- **Frame construction:** eager trees, non-lazy collections, repeated expensive
  layout, oversized image decode, or animation-driven layout work.
- **Invalidation:** broad rebuild boundaries, work started from `build`,
  recreated futures/controllers, or state changes invalidating unrelated UI.
- **Main isolate:** synchronous parsing, sorting, filtering, formatting,
  serialization, or other work proportional to payload size.
- **I/O:** duplicate requests, route re-entry loops, missing pagination, or
  blocking persistence/network orchestration.
- **Memory and lifecycle:** retained controllers/subscriptions, unbounded
  caches, oversized retained payloads, or disposal mismatches.
- **Measurement integrity:** stale route attribution, correlation presented as
  causality, unrepresentative fixtures, or missing frame/timeline evidence.

Keys are an identity and state-preservation mechanism. Report them only when
insertion, removal, reordering, or stateful-child churn creates an observed
mechanism; they are not a generic performance recommendation.

Finish when each lens has either a concrete observation or an explicit
evidence-based reason it does not apply.

### 3. Rank findings

Include only findings supported by local code or scoped telemetry. Each finding
contains:

- observation with file/component or telemetry scope;
- causal mechanism;
- likely impact and confidence;
- smallest purposeful correction;
- verification method such as a frame chart, timeline trace, rebuild tracing,
  allocation profile, targeted test, or telemetry comparison.

Separate proven causes from plausible risks and correlations. Omit generic
framework advice that has no observation on this path.

Finish when every claim has evidence and every recommendation has a measurable
verification method.

## Output gate

Report the scope, outcome, ranked findings, and verification plan. State clearly
when the target is not established as the cause. If no material risk is found,
say so and list the evidence reviewed rather than manufacturing findings.

Finish with a read-only, evidence-ranked report or a precise handoff to
`$diagnosing-bugs`/`$implement`.
