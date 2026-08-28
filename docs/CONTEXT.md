# Project Tweety context

This glossary gives the app a shared language. It describes product state and
UI concepts rather than how they are represented or implemented.

## Cards

## Card

A **Card** is a saved, visible item in the Cards collection. It has a stable
identity and the title and description that a person can view or edit.

## CardDraft

A **CardDraft** is the proposed title and description for a Card. It is the
value being edited, whether it will create a new Card or revise an existing
one. A draft can be invalid without changing a saved Card.

## Unsaved draft

An **unsaved draft** is a CardDraft with edits that have not been saved. It is
an editor-state term: it can belong to either a new Card or an existing Card.
Leaving an unsaved draft can discard those edits.

## Dirty card

A **dirty card** is a saved Card whose local change has not yet been reconciled
with its external record. It is synchronization state, not editor state. A Card
can be dirty without having an unsaved draft, and an unsaved draft does not by
itself make a Card dirty.

## Tombstone

A **tombstone** is the retained record of a deleted Card while that deletion
still needs reconciliation. It is not a visible Card and cannot be edited or
selected as one.

## Modal presentation

Vocabulary for `AppModal` (`lib/presentation/widgets/app_modal.dart`) and how
it presents content over the rest of the app.

### Modal variant

A **modal variant** is one of `AppModal`'s three named presentation modes:
`page`, `compact`, or `blocking`. Each variant is a fixed bundle of defaults
for height, drag/dismiss behavior, and close affordance — not just a visual
size preset.
_Avoid_: modal type, sheet style.

### Dismissal contract

A **dismissal contract** is the combination of `canPop`, tap-outside
dismissal, drag-to-dismiss, and close-affordance settings that together
determine every way a given modal presentation can be closed. Comparing two
variants means comparing their dismissal contracts, not any single flag in
isolation.

### Close affordance

A **close affordance** is a visible, always-present control (the "X" icon)
whose only job is dismissal, with no side effect on the modal's content.
Distinct from a **resolving action**.

_Open question, not yet resolved:_ `AppModal`'s Cupertino presentation puts
the close affordance on the left, Material on the right. Nothing in
`docs/research/modal_close_button_hci_guidelines.md` specifies this — the
note only sources a Cancel-left/Done-right convention for *labelled,
valenced* actions (discard vs. commit), which doesn't obviously extend to a
single neutral close icon. Treat the current left/right split as an
unconfirmed implementation choice, not a settled convention, until a real
decision is made.

### Resolving action

A **resolving action** is a caller-supplied control inside a modal's `child`
(e.g. `webview_modal.dart`'s Cancel/Confirm row) that both closes the modal
and commits its outcome. The `blocking` variant requires every call site to
provide one instead of getting a close affordance, per
`docs/research/modal_close_button_hci_guidelines.md`.

### Design language

See `AppDesignPlatform`
(`packages/design_system/lib/src/adaptive/app_design_platform.dart`) for the
canonical definition — branch on Material vs. Cupertino presentation, not raw
`TargetPlatform`. Defined here only as a pointer so this glossary doesn't
drift from that doc comment.

### Windowed presentation

A **windowed presentation** is the choice between an edge-anchored sheet and
a centered, fixed-max-width dialog. It is a dimension orthogonal to **modal
variant** and to **design language**: it is driven purely by
`DisplayMetrics.isExpandedSurface`
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
