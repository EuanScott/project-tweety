# project-tweety

A Flutter playground app for exploring ideas, patterns, and experiments
outside of production work. This glossary gives the app a shared language. It
describes product state and UI concepts rather than how they are represented
or implemented.

## Language

### Component Gallery

**Component Gallery**:
The `packages/design_system/example` app that renders every `design_system`
widget for visual evaluation. _Avoid_: Storybook, component library

**Showcase**:
One Component Gallery page dedicated to a single widget, rendered
simultaneously in both platform panes. _Avoid_: Demo, example page

**Comparison pane**:
One half of a showcase's two-pane layout, rendering the widget under one
platform's design language (Material or Cupertino) via a `Theme.platform`
override. _Avoid_: Preview, panel

### Logs

**Log**:
All of an Account's log entries, shown in the Logs tab. _Avoid_: Cards, journal

**Log entry**:
A saved, visible item in the Log. It has a stable identity and the title and
description that a person can view or edit. _Avoid_: Card, entry (on its own), record

**Log entry draft**:
The proposed title and description for a log entry. It is the value being
edited, whether it will create a new log entry or revise an existing one. A
draft can be invalid without changing a saved log entry. _Avoid_: card draft

**Unsaved draft**:
A log entry draft with edits that have not been saved. It is an editor-state
term: it can belong to either a new log entry or an existing one. Leaving an
unsaved draft can discard those edits.

**Dirty log entry**:
A saved log entry whose local change has not yet been reconciled with its
external record. It is synchronization state, not editor state. A log entry
can be dirty without having an unsaved draft, and an unsaved draft does not by
itself make a log entry dirty. _Avoid_: dirty card

**Tombstone**:
The retained record of a deleted log entry while that deletion still needs
reconciliation. It is not a visible log entry and cannot be edited or selected
as one.

**Sync**:
A person-initiated attempt to reconcile every dirty log entry and tombstone
with the external record. It is deliberate rather than automatic: it happens
because someone asked for it, not because a log entry changed. A sync is best
effort — reconciling only some of the pending changes leaves the rest dirty,
and the next sync attempts them again.

**Download**:
The automatic fetch that adds to the device every log entry the external
record holds but the device does not. It only adds: a log entry the device
already holds, including a tombstone, is never changed by a download. It runs
without anyone asking, each time the Session becomes signed in, and never at the
same time as a sync. A failed download is retried on the next one. _Avoid_: restore, pull, sync down

**Owner**:
The Account a log entry belongs to. Ownership is permanent for the life of
the log entry and is not something a person can see or change in the app. A
log entry whose owner is not the signed-in Account is not visible, not
editable, and not synced.

**Adoption**:
The one-time event where the first Account to use Logs on a device becomes
the owner of every log entry already there. An adopted log entry counts as
never synced, so the next sync pushes it. _Avoid_: claiming, migration

### Accounts

**Account**:
The Google identity a person signs in with, identified by a Firebase `uid`.
It is not the same as a person: one person may hold several Accounts, and
each is a separate Account here. Every log entry belongs to exactly one
Account.

**Profile**:
The display details of an Account: name, email, whether the email is
verified, photo, and phone number. Any of them can be missing. It is
read-only in this app. _Avoid_: account details, user info

**Session**:
The fact that an Account is signed in on this device now. A Session persists
across app restarts until sign-out. _Avoid_: login, auth state

**Sign-in attempt**:
One press of the sign-in button, from start until it succeeds, is cancelled,
or fails. A cancelled or failed sign-in attempt does not change the Session. _Avoid_: login flow

### Theme

**Theme colour**:
The palette a person chooses for the app. It sets the primary and secondary
colours, the surfaces and the colours of the water scene. It is separate from
light and dark mode: each theme colour has a day version and a night version.
The seven theme colours are Fjord (the default), Fynbos, Kalahari, Lyng, Whin,
Douro and Cuillin. Each is named after a place or a plant
([ADR-0016](docs/decisions/0016-theme-colours-are-complete-brand-presets.md)). _Avoid_: theme (that is light or dark
mode), accent, brand

### Modal presentation

Vocabulary for `AppModal` (`lib/presentation/widgets/app_modal.widget.dart`) and how
it presents content over the rest of the app.

**Modal variant**:
One of `AppModal`'s three named presentation modes: `page`, `compact`, or
`blocking`. Each variant is a fixed bundle of defaults for height,
drag/dismiss behavior, and close affordance — not just a visual size preset. _Avoid_: modal type, sheet style

**Dismissal contract**:
The combination of `canPop`, tap-outside dismissal, drag-to-dismiss, and
close-affordance settings that together determine every way a given modal
presentation can be closed. Comparing two variants means comparing their
dismissal contracts, not any single flag in isolation.

**Close affordance**:
A visible, always-present control (the "X" icon) whose only job is dismissal,
with no side effect on the modal's content. Distinct from a **resolving
action**.

_Open question, not yet resolved:_ `AppModal`'s Cupertino presentation puts
the close affordance on the left, Material on the right. Platform guidelines
only source a Cancel-left/Done-right convention for *labelled, valenced*
actions (discard vs. commit), which doesn't obviously extend to a single
neutral close icon. Treat the current left/right split as an unconfirmed
implementation choice, not a settled convention, until a real decision is
made.

**Resolving action**:
A caller-supplied control inside a modal's `child` (e.g.
`webview_modal.widget.dart`'s Cancel/Confirm row) that both closes the modal
and commits its outcome. The `blocking` variant requires every call site to
provide one instead of getting a close affordance.

**Design language**:
See `AppDesignPlatform`
(`packages/design_system/lib/src/adaptive/app_design_platform.dart`) for the
canonical definition — branch on Material vs. Cupertino presentation, not raw
`TargetPlatform`. Defined here only as a pointer so this glossary doesn't
drift from that doc comment.

**Windowed presentation**:
The choice between an edge-anchored sheet and a centered, fixed-max-width
dialog. It is a dimension orthogonal to **modal variant** and to **design
language**: it is driven purely by `DisplayMetrics.isExpandedSurface`
(`packages/design_system/lib/src/adaptive/display_metrics.dart`) — tablet-
sized shortest side or an active fold/hinge split — never by
`AppDesignPlatform`. A tablet in Cupertino mode still gets Cupertino-styled
content, just inside a windowed container instead of a sheet; all three
modal variants (`page`, `compact`, `blocking`) switch presentation together
on the same surface check.

The windowed presentation drops drag-to-dismiss entirely (no edge to drag
from) and, unlike the sheet presentation, renders the close affordance on
Material too whenever `showCloseButton` is true — sheet-mode Material relies
on its drag handle and tap-outside dismissal instead, but windowed mode has
no drag handle to fall back on, so both design languages get the icon there.
