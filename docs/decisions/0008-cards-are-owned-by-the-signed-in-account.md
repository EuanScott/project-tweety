# ADR-0008: Cards are owned by the signed-in Account

Status: proposed
Date: 2026-09-09
Decision maker: Euan Scott

## Context

Cards are app-owned today. `CardDto` has no owner field, the SQLite schema is at
version 3, and `_seedSampleCardsV3` seeds ten sample cards into an empty table on
database creation. Introducing Google sign-in as a hard launch gate forces the
question of who a Card belongs to, and what happens to the Cards already sitting on a
device the first time someone signs in.

The forces are fixed by decisions already made on
[the map](https://github.com/EuanScott/project-tweety/issues/21):

- [ADR-0007](0007-cards-local-source-of-truth.md) puts truth in SQLite. Firestore is a
  driven replica, written by a person-initiated, push-only, best-effort sync.
- **Restoring Cards from Firestore is out of scope.** There is no path back from the
  replica to the device in this phase. Any local deletion is therefore permanent.
- Single device, single Account signed in at a time. No multi-device conflict
  resolution.
- No backend code. Firestore Security Rules are the only authorisation boundary.

`CardsLocalDataSource` is registered as an injectable `@LazySingleton` taking only
`AppDatabase`, so a Card query has no access to the signed-in identity today.

## Decision

**We will make the Account the owner of every Card, carried locally as a `user_id`
column on `cards` at schema version 4 and remotely as the Firestore subcollection path
`users/<uid>/cards/<cardId>`.** The first Account to sign in adopts every Card already
on the device; automatic sample-card seeding is removed, so every subsequent Account
starts empty.

The eight parts of that decision:

1. **Local representation is a `user_id` column**, schema version 4. Every read in
   `CardsLocalDataSource` filters on the signed-in uid.
2. **Existing Cards are adopted** by the first Account to sign in. Adoption is a
   one-time backfill that runs at first sign-in, not during the version-4 migration —
   the uid does not exist when the database opens. The column lands nullable and is
   total in practice after that backfill.
3. **Automatic seeding is removed.** A new Account gets an empty Cards list.
4. **The seed is removed by gutting `_seedSampleCardsV3` to a no-op**, not by deleting
   the case-3 branch (the `default:` branch throws `StateError` for a missing version)
   and not by having version 4 delete rows `card-1` through `card-10`.
5. **Sign-out retains local rows.** Nothing is wiped.
6. **The uid reaches the datasource through an injected session holder**, read at query
   time. It throws when read with nobody signed in rather than returning null.
7. **`CardDto` gains a `userId` field; the app-facing `Card` value does not.**
8. **Firestore encodes ownership in the path**, not in an `ownerId` document field.

## Alternatives

**No local ownership at all** — one database, implicitly belonging to whoever is signed
in, wiped on sign-out. The cheapest option, and honest to the single-device assumption.
Rejected because it collides with the out-of-scope ruling on restore: sign out and back
in as the *same* Account and the Cards are gone with no recovery path. Two individually
reasonable decisions meeting to produce data loss.

**A database file per Account** (`tweety_<uid>.db`). Perfect isolation, no `WHERE`
clause anywhere, no backfill. Rejected because it makes opening the database depend on
knowing the uid, dragging database initialisation behind the auth gate and into
`lib/core/di/di_init.service.dart` ordering. It also hides ownership from the schema, so
the Firestore side has to reintroduce the concept regardless.

**Leaving pre-existing Cards unowned and invisible.** Rejected outright: it creates rows
nobody can see, edit, or delete, and forces the read path to tolerate a null `user_id`
permanently rather than for one migration window.

**Discarding pre-existing Cards.** Defensible as a clean slate, but destroys
user-created Cards from before the gate existed for no gain.

**Seeding every new Account with ten sample cards.** Rejected on two counts: it means
lifting seeding out of `AppDatabaseMigrations` into an Account-provisioning step, which
is real structural work; and an empty second Account is the only way to exercise
`cards_empty.widget.dart` and drive the sync loop from zero.

**Version 4 deletes rows `card-1` through `card-10`.** Rejected because it contradicts
the adoption decision and because delete-by-hardcoded-id is a migration that ages badly.

**Passing the uid as a per-call parameter** on every `CardsDataSource` method. Explicit
and trivially testable, but puts a session-constant value into seven signatures and
makes the repository responsible for knowing who is signed in.

**Constructor-injecting the uid** into `CardsLocalDataSource`. Rejected as the most
fragile option available: it fights `@LazySingleton` and turns every sign-in and
sign-out into a DI unregister/re-register lifecycle event.

**Keeping ownership entirely inside SQL** — the datasource stamps the column on write
and filters on read, and `CardDto` never carries it. Rejected because
`toDatabaseRow`/`fromDatabaseRow` *is* the row mapping; leaving one column out of it and
stamping it elsewhere splits the mapping across two places.

**Putting `userId` on the app-facing `Card`.** Rejected: the repository is already
Account-scoped, so the field would hold the same value on every instance, and a field the
UI can see is a field someone eventually renders.

**A top-level Firestore `cards` collection with an `ownerId` field.** Rejected on rules
safety. Path partitioning is one rule, `request.auth.uid == uid`, with ownership
structural and unspoofable. The field approach needs `resource.data.ownerId ==
request.auth.uid` for reads, updates and deletes *and* a separate
`request.resource.data.ownerId == request.auth.uid` for creates — two conditions that are
easy to get subtly wrong. A single top-level collection would also make Card ids globally
unique, so two Accounts holding seeded ids would overwrite each other.

## Consequences

**Rewriting an already-run migration is a deliberate exemption, not an oversight.**
Gutting `_seedSampleCardsV3` means a version-3 database created by old code holds ten
sample cards while a version-3 database created by new code holds none — same version,
different contents. That is normally a serious error: migration history is supposed to be
append-only precisely so that version number implies content. The rule binds shipped
software, and nothing here has shipped; there is one developer and no installed base. The
exemption is recorded rather than assumed, and a `TODO` at the gutted method points at the
open research question of what the disciplined options actually are (backfill-safe no-ops,
squashing a baseline schema, version floors) before the trick is used again.

**Sign-out becomes non-destructive and account switching works structurally for free** —
the uid filter is the entire mechanism. It is nonetheless **out of scope**: not exercised,
no UI to switch Accounts, and no test proving the second-Account path. No work in this
phase may assume it works.

**Sync is scoped to the signed-in Account, never "everything pending".** A dirty card
belonging to a signed-out Account stays dirty and is pushed the next time that Account
signs in and syncs.

**The same fact is carried in two representations**, a local column and a remote path.
That is correct rather than duplication: the local side has one table and needs a
discriminator column; the remote side has a namespace and does not. It does mean the
remote document body carries no owner field, so nothing in Firestore is self-describing
about ownership outside its path.

**A session holder becomes a dependency of the data layer.** Testing a Card query now
requires a uid, satisfied by a one-line fake in `test/support/`. Its throw-on-absent-uid
contract is what stops a null uid falling through to `WHERE user_id IS NULL` and silently
querying the wrong rows.

**Re-evaluate** if multi-device sync, Firestore-to-local restore, or genuine Account
switching enters scope. Restore in particular changes the calculus on sign-out wiping,
since local deletion would stop being permanent.

## Confirmation

- `AppDatabaseMigrations.latestVersion` is 4, version 4 adds `user_id`, and
  `_seedSampleCardsV3` inserts nothing.
- A `CardsLocalDataSource` test proves reads exclude rows owned by another uid, and that
  a query with no signed-in Account throws rather than returning rows.
- A migration test proves an existing version-3 database with sample rows has them
  backfilled to the first signing-in uid, and that a freshly created database has no
  Cards.
- `Card` in `lib/data/repositories/card/cards.repository.dart` has no owner field.
- Firestore Security Rules authorise on the path segment, and no rule reads
  `resource.data` to establish ownership.
