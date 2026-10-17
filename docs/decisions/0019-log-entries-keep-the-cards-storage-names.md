# ADR-0019: Log entries keep the `cards` storage names

Status: accepted
Date: 2026-10-17
Decision maker: Euan Scott

## Context

The Cards feature is renamed to Logs. One item is now a log entry, and the
code, UI, routes and current-state documents change to match. The feature
grew into a log book, and "Card" no longer describes it.

Stored data still uses the old name in four places:

- the SQLite table `cards` and its index `cards_user_id`,
- the five migrations that create and change that table,
- the Firestore path `users/<uid>/cards/<cardId>`,
- the `match` block in `firestore.rules` that guards that path.

Log entries already exist on the device and in Firestore. Firestore cannot
rename a collection. Moving the data means copying every document to a new
path and deleting the old one, together with a hand-deployed rules change.
There is no backend code to run that copy
([ADR-0008](0008-cards-are-owned-by-the-signed-in-account.md)), so the app
would have to do it, on every device, while the rules and the app version
agree. Migrations are append-only, so the existing migrations keep their
literal `cards` SQL whatever is decided.

## Decision

**We will rename the feature in code, UI, routes and current-state documents,
and keep every stored name as `cards`.** Each stored name that running code
uses is held in one named constant with a comment that links here.

## Alternatives

**Rename the SQLite table only**, with a version-6 migration using
`ALTER TABLE cards RENAME TO log_entries`. SQLite does this safely in one
transaction. It was rejected because it gives the person nothing they can see,
adds one more change to on-device data, and leaves the two stores with
different names.

**Rename both stores**, with a client-side copy from `users/<uid>/cards` to a
new path. It was rejected because it puts the backend data at risk for a
naming change, needs a coordinated rules deploy, and needs code that runs once
per device and must handle a copy interrupted part of the way.

## Consequences

Code says `LogEntry`, and storage says `cards`. A reader who opens the
database or the Firestore console must know about this decision. A search for
"card" still finds the storage constants, the migrations, `firestore.rules`
and the historical ADRs; those results are expected.

The rename touches no stored data, so it needs no migration and cannot lose a
log entry.

Re-evaluate when a later change rebuilds the `cards` table or changes the
Firestore layout for another reason, for example separate logs per Account.
The rename then costs little extra.

## Confirmation

- The literal `cards` appears in running code only in the storage-name
  constants, plus the existing migrations and `firestore.rules`.
- Repository and datasource tests continue to read and write the `cards`
  table.
- A review that finds a changed table name without a migration, or a changed
  Firestore path without a data copy, contradicts this decision.
