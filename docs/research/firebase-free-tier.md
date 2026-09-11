# Firebase Free Tier (Spark Plan) Research — Cards App

Date checked: 2026-09-09 (per issue #22, `EuanScott/project-tweety`)

## Question

For the `cards` feature (a single developer, one device, a Firestore
`cards` collection of a few dozen documents, read on app launch and
written on edit), does Firebase's free "Spark" plan cover this workload
without hitting quota limits or requiring a paid ("Blaze") plan or a
billing account, and does Google sign-in work on Spark without extra
cost?

## Findings

### Authentication (Spark)

Source: https://firebase.google.com/pricing (fetched 2026-09-09)

- Standard Firebase Authentication providers — email/password, **Google
  sign-in (OAuth)**, and other standard identity providers — are included
  at no cost on Spark, free up to **50,000 MAUs** ("No-cost up to 50K
  MAUs").
- SAML/OIDC federated identity providers have a much lower free
  allowance: **no-cost up to 50 MAUs** only.
- **Phone Authentication** (SMS-based) is billed per SMS sent regardless
  of plan — it is not covered by the flat Spark/free allowance.
- MFA features tied to Identity Platform are billed once you're using
  Identity Platform's paid tier.
- Upgrade to the paid Identity Platform / Google Cloud pricing
  (https://cloud.google.com/identity-platform/pricing) is triggered by:
  crossing 50K MAU on standard providers, crossing 50 MAU on SAML/OIDC,
  using phone-number verification, or using Identity-Platform-only MFA
  features.
- I could **not** independently confirm the exact numbers directly from
  `cloud.google.com/identity-platform/pricing` — that fetch returned
  truncated content and no pricing table was visible to me. The 50K/50
  MAU figures above come from `firebase.google.com/pricing` only.

**For this app**: one developer, one device, Google sign-in only → this
is nowhere near 50K MAU (it's 1 MAU), so Authentication is free with no
qualifying condition triggering an Identity Platform upgrade.

### Cloud Firestore (Spark)

Source: https://firebase.google.com/docs/firestore/quotas (fetched
2026-09-09, page footer shows "Last updated 2026-09-08 UTC") and
https://firebase.google.com/pricing (fetched 2026-09-09, consistent
numbers).

Free (Spark) daily/monthly quotas, Standard Edition:

| Resource | Free quota |
|---|---|
| Stored data | 1 GiB total |
| Document reads | 50,000 / day |
| Document writes | 20,000 / day |
| Document deletes | 20,000 / day |
| Network egress (outbound data transfer) | 10 GiB / month |

- Quotas are **daily** for reads/writes/deletes and reset **around
  midnight Pacific time**.
- Network egress is a **monthly** allowance (10 GiB/month), not daily.
- Only **one free database per project** is permitted.
- Some Firestore features are never free regardless of plan: TTL
  deletes, point-in-time-recovery (PITR) data, backup data, restore
  operations, and clone operations — these require billing to be
  enabled even if you stay under the base read/write/delete quotas.

### Billing account requirement

Source: https://firebase.google.com/docs/projects/billing/firebase-pricing-plans
(fetched 2026-09-09, page footer shows "Last updated 2026-09-08 UTC").

- Spark explicitly requires **no payment information**: "No payment
  information needed to get started or to use only the no-cost Firebase
  products."
- Cloud Firestore is one of the products Spark's no-cost quota explicitly
  covers ("No-cost usage quotas for paid Firebase products (like Cloud
  Firestore, Cloud Storage, and Hosting)") — so Firestore can be enabled
  on a pure Spark project with **no credit card / no billing account**
  attached.
- If a Spark quota is exceeded, the product is **shut off** for the rest
  of the period (not silently billed): "If you exceed the no-cost quota
  limit in a calendar month for any product, your project's usage of
  that specific product will be shut off for the remainder of that
  month." (Note: this "calendar month" shutoff language is the general
  Spark-plan framing; Firestore's own quota doc specifies its read/write/
  delete quotas specifically reset **daily**, not monthly — the monthly
  framing applies to products/metrics that are monthly, such as
  Firestore's own network egress allowance.)
- To resume before the reset, or to exceed quota permanently, the project
  must be upgraded to Blaze (which does require a billing account), but
  staying within Spark's quotas costs nothing and needs no card at all.

### Verdict — does Spark cover this workload?

Workload: single developer, one device, `cards` collection with a few
dozen (say up to ~100) documents, read on app launch, written on edit.
Worst case assumed: 50–100 app launches/edits per day by one person.

Assume worst case per launch/edit cycle:
- One "read" launch = read the whole `cards` collection: up to ~100 docs
  → 100 document reads.
- One "write" edit = write/update one document → 1 document write (or a
  handful if editing multiple cards in one session — assume up to 10
  writes per edit session to be conservative).

Reads:
- 100 launches/day × 100 reads/launch = **10,000 reads/day**
- Free quota: 50,000 reads/day
- Headroom: (50,000 − 10,000) / 50,000 = **80% headroom** (using only 20%
  of the free daily read quota)

Writes:
- 100 edit sessions/day × 10 writes/session = **1,000 writes/day**
  (even a pessimistic single-card-per-write model: 100 writes/day)
- Free quota: 20,000 writes/day
- Headroom: (20,000 − 1,000) / 20,000 = **95% headroom** (using only 5%
  of the free daily write quota) — or 99.5% headroom in the 100
  writes/day case.

Deletes: negligible for this workload (occasional card removal), nowhere
close to 20,000/day.

Stored data: a few dozen small JSON-like documents (cards) will be
well under 1 GiB — likely under 1 MB total for tens of documents unless
each document embeds large media, which is not implied by the described
workload.

Network egress: at ~100 reads/day of small documents, monthly data
transferred is trivially under 10 GiB/month for plain text/structured
card data.

**Conclusion: none of Spark's daily/monthly Firestore quotas are at
meaningful risk for this workload.** Even under generous worst-case
assumptions (100 launches/day, 100 docs read per launch, 10 writes per
edit session), usage sits at roughly 20% of the daily read quota and 5%
of the daily write quota, with storage and egress far under their caps.
Authentication (Google sign-in, single user) is also free and nowhere
near the 50K MAU threshold. Firestore can be enabled on Spark with no
billing account attached.

## Confidence

**(a) Directly confirmed from a primary source, with URL cited:**
- Spark plan free MAU limits for standard providers (50K) and SAML/OIDC
  (50 MAU) — https://firebase.google.com/pricing
- Firestore Spark quotas: 1 GiB storage, 50,000 reads/day, 20,000
  writes/day, 20,000 deletes/day, 10 GiB/month egress — confirmed on
  both https://firebase.google.com/pricing and
  https://firebase.google.com/docs/firestore/quotas
- Daily Firestore quota reset timing ("around midnight Pacific time") —
  https://firebase.google.com/docs/firestore/quotas
- Spark requires no billing account/credit card, and Firestore is
  explicitly included in Spark's no-cost quota coverage —
  https://firebase.google.com/docs/projects/billing/firebase-pricing-plans
- Exceeding a Spark quota shuts the product off rather than billing —
  https://firebase.google.com/docs/projects/billing/firebase-pricing-plans

**(b) Could not verify from a primary source / left uncertain:**
- The exact figures on `cloud.google.com/identity-platform/pricing`
  (Identity Platform's own paid-tier pricing table) — this fetch
  returned truncated content with no visible pricing table. The 50K/50
  MAU thresholds above are taken only from `firebase.google.com/pricing`,
  which references Identity Platform pricing as the "beyond this"
  destination but doesn't itself show Identity Platform's tiered rates.
  If precise Identity Platform overage pricing is needed later, this
  page should be re-fetched or checked manually.
- The apparent inconsistency between "shut off for the remainder of that
  month" (general Spark billing-plans page) versus "resets daily" for
  Firestore reads/writes/deletes specifically (Firestore quotas page) is
  noted above but not fully reconciled from a single authoritative
  source — it's plausible the "calendar month" framing is a generic
  description that doesn't override each product's own stated reset
  cadence, but I did not find one page that explicitly states both
  together.
- The workload math (100 launches/day, documents-per-launch, writes per
  edit session) is an estimate per the issue's own assumptions, not a
  measured or documented figure — flagged as an assumption, not a fact.
