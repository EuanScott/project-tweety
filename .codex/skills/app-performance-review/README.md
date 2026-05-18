# App Performance Review Skill

This project-local Codex skill helps review a specific app page, screen, feature, or route for performance problems. It is designed for focused investigations like:

- "Why is `order_details` causing Application Not Responding errors?"
- "Review this feature for Flutter jank."
- "Find expensive rebuilds and layout issues on this page."
- "Use telemetry and code to explain why this screen is slow."

## How It Works

When invoked, the skill guides Codex through a narrow performance review workflow:

1. Identify the exact page or feature being reviewed.
2. Read the repository instructions and local code around that page.
3. Inspect the page's widget tree, state management, data-loading path, and nearby dependencies.
4. Check dependency versions before making package-specific assumptions.
5. Use telemetry or logs when available, such as Coralogix RUM errors, ANRs, app versions, platforms, devices, and view names.
6. Rank likely causes by impact and confidence.
7. Recommend small, targeted fixes and verification steps.

The skill does not automatically rewrite UI or broaden the investigation unless the user asks for implementation work.

## What It Looks For

The skill checks for common app performance risks, especially in Flutter screens:

- Eager rendering such as `SingleChildScrollView` with large `Column` children.
- Hidden content that is still built or laid out while collapsed.
- Expensive layout such as repeated `IntrinsicHeight` or `IntrinsicWidth`.
- Large synchronous work during `build`, including formatting, filtering, grouping, sorting, regex, or JSON transformation.
- Whole-page skeletonizers or shimmer trees that make loading states expensive.
- Over-broad BLoC, provider, or `setState` rebuilds.
- Missing or unstable `Key`s in dynamic lists, expandable rows, tabs, or stateful child widgets.
- Duplicate network calls from lifecycle or route re-entry mistakes.
- Missing lazy rendering for long lists, transaction histories, or schedule rows.
- Telemetry mismatches where an ANR is reported on one view but may have originated from another.

## Keys Guidance

Keys can help Flutter preserve widget/element identity when a list or subtree changes. They are most useful when the UI contains inserted, removed, reordered, expandable, animated, or stateful children.

Use Keys selectively:

- Prefer stable domain IDs, such as `ValueKey(order.id)` or `ValueKey(transaction.id)`.
- Avoid using list indexes when items can be inserted, removed, sorted, or filtered.
- Avoid `UniqueKey`, random keys, or timestamp-based keys unless the goal is to force Flutter to discard old state.
- Consider `PageStorageKey` for scroll position or expandable page sections that should preserve state.
- Treat Keys as an identity/state-preservation tool, not a replacement for lazy rendering or removing expensive layout.

## Help Mode

If a user includes `--help` in the prompt, the skill should return a short usage guide instead of inspecting code.

Example:

```text
Use $app-performance-review --help
```

## Example Prompts

Investigation only:

```text
Use $app-performance-review to investigate the `order_details` page for Application Not Responding errors. Look only at this page and nearby dependencies. Do not change code.
```

Telemetry-assisted investigation:

```text
Use $app-performance-review to review the `order_details` page for ANRs on app version 4.16.1 across iOS and Android. Use Coralogix if available and summarize likely causes plus fixes.
```

Implementation request:

```text
Use $app-performance-review to improve the performance of `order_details`. Keep the UI visually unchanged, make the smallest focused changes, and run targeted validation if available.
```

Help:

```text
Use $app-performance-review --help
```
