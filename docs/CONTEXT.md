# Cards context

This glossary gives the Cards feature a shared language. It describes product
state rather than how that state is represented or stored.

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
