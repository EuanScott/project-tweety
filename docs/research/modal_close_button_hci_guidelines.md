# Modal close-button HCI guidelines

Research note for `AppModal` (`lib/presentation/widgets/app_modal.dart`).
`AppModal` has three call sites — `page`, `compact`, `blocking` — and
currently exposes no visible close/X/Done affordance on any of them;
dismissal is swipe-down, tap-outside, or system back only. This note
gathers primary-source guidance on when an explicit close control is
required, to inform a follow-up implementation plan.

**Access caveat, stated up front.** Apple's HIG pages and Material's M3 spec
pages are JS-rendered SPAs; this environment's fetch tool could retrieve only
page titles from them, not body text. Findings below for those two sources are
reconstructed from search-engine result summaries that themselves quote and
paraphrase the live pages — not from a direct fetch of the primary text. This
is weaker than the direct-source verification method used elsewhere in this
repo's research notes (see `docs/research/dart_flutter_lint_rules.md`, which
read package source directly), and it is flagged per-claim below. The WCAG
Understanding documents came back as fuller, closer paraphrases and are the
strongest sourcing in this note.

---

## 1. Apple Human Interface Guidelines

Sources: <https://developer.apple.com/design/human-interface-guidelines/sheets>,
<https://developer.apple.com/design/human-interface-guidelines/modality>
(titles confirmed live; body text via secondary summarization — see caveat
above).

**Modality — an obvious way out.** The Modality page's core framing: modality
"presents content in a separate, dedicated mode that prevents interaction with
the parent view and requires an explicit action to dismiss." The guidance
explicitly recommends restraint before reaching for a modal at all: "minimize
the use of modality... consider creating a modal context only when it's
critical to get someone's attention, when a task must be completed or
abandoned to continue using the app, or to save important data." An archived
mirror of the HIG (not the live page, so treat as lower confidence) preserves
the specific instruction: "Provide an obvious and safe way to exit a modal
task." The word "obvious" is the operative one — it implies a visible
affordance, not a gesture the user has to already know about.

**Sheets — dismiss-button placement, when one exists.** Where a sheet does
have Done/Cancel/OK buttons, HIG's positioning rule (LTR layout) is: Cancel in
the top-left, Done/Dismiss in the top-right. This is a placement rule, not a
requirement that every sheet must have one of these buttons — the "requires
one" question is answered by the Modality page's "obvious way to exit," not by
the Sheets page's button-anatomy section.

**Swipe-to-dismiss is additive, not a replacement for a visible control.**
HIG frames pull-down-to-dismiss as an *expected convenience gesture on top of*
a button-based exit, not a substitute for one — consistent with "provide an
obvious... way," which a hidden gesture does not satisfy on its own.

**Unsaved changes → confirm, don't just block.** HIG's guidance for sheets
with in-progress edits: if dismissing (by any method — swipe or button) would
discard user-generated content, the app should intervene with a confirmation
(e.g., an action sheet offering to save), rather than silently discarding or
silently refusing to close.

**`isModalInPresentation` (UIKit, not itself an HIG page).** This is an
API-level mechanism, documented in Apple's *developer* docs (not the HIG
proper) rather than the HIG. Setting it `true` disables swipe-to-dismiss and
tap-outside; attempts to dismiss trigger
`presentationControllerDidAttemptToDismiss(_:)` instead of closing, which apps
use to show a confirmation UI. The pattern only makes sense paired with a
visible way forward — a save/discard prompt, or a button that performs that
prompt — because turning off every gesture without adding a button
directly contradicts the Modality page's "obvious and safe way to exit"
principle. **This is the direct analogue of `AppModal`'s `blocking` variant**
(`canPop: false`, `isDismissible: false`, `enableDrag: false`): HIG's own
pattern for the non-dismissable case pairs it with a UI element that resolves
the block, not with silence.

---

## 2. Material Design 3

Sources: <https://m3.material.io/components/bottom-sheets/specs>,
Material dialog specs (via `m3.material.io`, reached through search summary —
see caveat above).

**Bottom sheets — standard vs. modal.** M3 distinguishes the two variants
mainly by blocking behaviour: "Modal bottom sheets appear in front of app
content, disabling all other app functionality when they appear, and
remaining on screen until confirmed, dismissed, or a required action has been
taken," and sit above a scrim; standard sheets have no scrim and don't block
the rest of the screen. `AppModal`'s Android path (`showModalBottomSheet`) is
always the modal variant, regardless of the `page`/`compact`/`blocking` split
— all three currently produce a scrimmed, blocking sheet on Android.

**M3 does not mandate a close button on every modal bottom sheet.** The
spec's stated dismissal set for a modal bottom sheet is: tap the scrim, swipe
down, or take the sheet's "required action." A close icon is not listed as a
mandatory anatomy element for the base modal-bottom-sheet component — it
appears in *implementation guidance* (e.g., Android's Material Components
library patterns, and Compose examples pairing a `CenterAlignedTopAppBar` with
a Close navigation icon and a Check/Done action icon) rather than as a spec
requirement for the sheet itself.

**Dialogs — the close affordance is explicit for one specific type.**
M3's dialog anatomy documentation calls out an "Icon (close affordance)" as
part of the **full-screen dialog** header anatomy specifically — i.e., once a
dialog (or, by extension, a full-height sheet used the way `AppModal.page`
is used) occupies the full screen and removes all peripheral visual context
(no visible edge of the underlying page, no scrim gap), Material's own
component anatomy adds an explicit close icon as a first-class element, not an
optional extra. Basic (non-full-screen) dialogs rely on their labelled action
buttons (e.g., Cancel/OK) instead.

**Read together:** M3's operative distinction is screen coverage /
peripheral-context loss, not "sheet vs. dialog." A component that covers the
whole screen and removes all external visual reference gets an explicit close
icon in Material's own anatomy; a component that leaves surrounding context
visible (partial-height sheet, non-full-screen dialog) relies on labelled
buttons or the scrim/swipe/tap-outside set instead.

---

## 3. Platform convention for button placement

No single canonical spec page states this as one rule; it is the consistent
pattern across both platforms' own component guidance already cited above:

- **Top-left** = X / Cancel — a *negative* or *exit-without-committing*
  action. HIG: Cancel goes top-left (LTR). Android/Material full-screen
  dialog pattern: the close/X affordance sits in the header's leading
  position, paired with a trailing confirm action.
- **Top-right** = Done / Save / checkmark — the *positive*, *commit* action.
  HIG: Done/Dismiss goes top-right (LTR). The Compose modal-bottom-sheet
  pattern cited under M3 above pairs a leading Close icon with a trailing
  Check icon for exactly this reason.
- **Which one a screen needs depends on whether there is committable state.**
  A read-only or already-committed view (e.g., a detail sheet, an info
  panel) needs only a neutral "Close" (visually and semantically distinct
  from "Cancel," which implies discarding something) — HIG explicitly
  distinguishes Close (neutral) from Cancel (discards) even though both sit
  top-left. A form or edit flow with in-progress state needs the Cancel/Done
  (or Cancel/Save) pair so users can explicitly choose to discard or commit,
  rather than a single ambiguous close icon.

This section is the weakest-sourced of the five — it is a synthesis across the
two platform guidelines above rather than a single citable "placement
convention" document, and should be read as inference from primary sources
rather than a directly quoted rule.

---

## 4. Accessibility (WCAG, and platform accessibility services)

Sources: <https://www.w3.org/WAI/WCAG21/Understanding/pointer-gestures.html>
(primary, reached via search summary that closely tracks the document's own
language — this is the strongest-sourced section of the note), Android
Developers accessibility principles
(<https://developer.android.com/guide/topics/ui/accessibility/principles>).

**WCAG 2.5.1 Pointer Gestures (Level A).** Requirement: "All functionality
that uses multipoint or path-based gestures for operation can be operated
with a single pointer without a path-based gesture, unless a multipoint or
path-based gesture is essential." A directional flick/swipe — "recognized
only when the user moves in a mostly straight line from the start-point to
the end-point" — is exactly this kind of path-based gesture. Swipe-to-dismiss
on `AppModal` is therefore in scope for 2.5.1, and it is **not exempt as
"essential"**: the Understanding document notes gesture-only dismissal
"would almost never qualify as essential" precisely because a single-pointer
alternative (tap a button) is always feasible to add.

**Why `AppModal` is not automatically compliant despite having tap-outside.**
2.5.1 is satisfied if *any* single-pointer, non-path alternative exists — and
tap-outside-to-dismiss (a plain tap, not a directional gesture) is arguably
already such an alternative for the `page`/`compact` variants. The gap is
elsewhere: 2.5.1 governs *pointer* gestures; it does not, by itself, guarantee
that the alternative is *discoverable* or operable by non-pointer interaction
(a screen-reader user navigating by swipe-based element focus, or a
switch-control user cycling focusable elements). "Tap outside the sheet" is
not a discrete, named, focusable element for VoiceOver/TalkBack — it is
"tap anywhere on the dimmed area behind the sheet," which is not something
these tools present as an actionable item at all in the same way a labelled
button is. This is the crux of "user gets stuck": a sighted mouse/touch user
finds tap-outside by trial; a screen-reader or switch-control user has no
equivalent action surfaced in their tool's focus/actions list unless the
developer explicitly exposes one.

**Related criterion: 2.5.7 Dragging Movements (WCAG 2.2, Level AA).**
Per the same Understanding-document family, a pure drag (defined by
start/end point, not path) is carved out of 2.5.1 and covered separately by
2.5.7, which requires a non-dragging alternative for any drag-operated
function — directly applicable to drag-to-dismiss.

**Android: exposing gesture actions to accessibility services.** Android's
accessibility principles guidance: where an app relies on drag/swipe gestures,
"you can provide an alternate way to complete these user flows by exposing the
action to accessibility services, so users of TalkBack, Voice Access, or
Switch Access can perform actions that might otherwise be available only
through gestures" — in Compose, via `customActions` in the `semantics`
modifier. This is the Android-native version of the same requirement: a
gesture needs an exposed, actionable equivalent, not just a visual affordance.

**Apple's `BottomSheetDragHandleView` precedent (Android Material Components,
cited for the general pattern it embodies, not as an Apple source).** Even
platform component libraries that ship a drag handle give that handle actual
accessibility semantics (tap-to-cycle-state, double-tap-to-hide, 48dp minimum
touch target) rather than leaving swipe as the only interaction — reinforcing
that "a draggable handle exists" is not itself considered sufficient;
component authors add explicit tap/double-tap actions to it.

**Net accessibility conclusion.** The requirement is not merely "have some
alternative to the gesture" (2.5.1's own bar is arguably already met by
tap-outside) — it is "have an alternative that is a real, focusable,
actionable element with a name a screen reader announces and an action a
switch-control/TalkBack/VoiceOver user can select from their tool's action
list." A dimmed barrier is not that. A labelled close button is.

---

## 5. Synthesis and recommendation, by `AppModal` variant

| Variant | `canPop` / dismiss modes | Should it have an explicit close/Done control? |
| --- | --- | --- |
| `blocking` | `canPop: false`, `isDismissible: false`, `enableDrag: false` — **no gesture dismissal at all** | **No header icon — a caller-provided resolving action is required instead.** HIG's own analogue (`isModalInPresentation: true`) is documented as always paired with a UI path forward, but that path is specifically "a save/discard prompt, or a button that performs that prompt" (§1) — i.e. content-level, not a generic header icon. `AppModal.blocking` therefore has no `showCloseButton` at all: every call site must give its own `child` a dedicated CTA (as `webview_modal.dart`'s Cancel/Confirm row already does) that calls `Navigator.pop`. This is a stricter, contract-based reading of the same HIG requirement than a bare icon would be. |
| `page` (full-height task modal) | `canPop: true` by default, drag + tap-outside enabled | **Yes, as standard practice, not just as a fallback.** Under M3's own component anatomy, a component occupying the full screen with no visible surrounding context is exactly the case Material gives an explicit "Icon (close affordance)" in its anatomy. `page` no longer defaults to a near-full-height sheet (see the height-default note below), but the same close-affordance reasoning applies whenever a caller opts into a larger `maxHeightFactor` for committable content (a form) — which under the platform-convention section above calls for a labelled Cancel/Done pair rather than a bare X, so users can distinguish discard-in-progress-edits from confirm. |
| `compact` (quick content/actions) | `canPop: true` by default, drag + tap-outside enabled | **Depends on content, not a blanket yes.** M3's split is about scrim/screen-coverage, not sheet size — but a small, non-full-height sheet with visible surrounding context does *not* match the M3 "full coverage → explicit close icon" trigger the way `page` does. If `compact` content is read-only/no committable state, tap-outside + swipe is closer to compliant already, provided the accessibility gap in §4 is closed (a discoverable, focusable dismiss action, even if visually minimal — it does not have to be a full labelled button in the same place as `page`'s). If a given `compact` usage does carry an action with a distinct confirm step (not just "view info and close"), it inherits the same Cancel/Done argument as `page`. |

**Cross-cutting requirement regardless of variant, and independent of the
size/placement question above:** every `AppModal` variant needs *some*
focusable, accessibility-service-exposed dismiss action per §4 — WCAG 2.5.1
is arguably satisfied today via tap-outside for `page`/`compact`, but tap-outside
is not an accessible-technology-discoverable action, and `blocking` has no
alternative at all, gestural or otherwise. This point holds even for a
`compact` variant that a sighted/pointer user could dismiss fine; a
VoiceOver/TalkBack/switch-control user cannot rely on an unlabelled dimmed
area the same way.

**What this note does not settle**, left for the follow-up implementation
plan: the exact placement/labelling scheme per variant (a single "X" vs. a
Cancel/Done pair), whether `compact` needs a visible button vs. an
accessibility-only exposed action, and how `blocking`'s required "resolving
action" (a button that itself performs the confirm/discard/complete step,
per the HIG pattern in §1) should be modelled given `blocking` is currently
generic over arbitrary child content with no framework-level place to hang a
required action button.

**Resolution adopted in the implementation that follows this note.** A bare
close icon (no title, no Cancel/Done header slot) is added to `page` and
`compact`, defaulting on and overridable via `showCloseButton`. `blocking`
does **not** get this icon — after initial review, the
icon-as-resolving-action approach for `blocking` was rejected in favor of
requiring every
`blocking` call site to supply its own dedicated CTA in `child` (matching
`webview_modal.dart`'s existing Cancel/Confirm row), on the basis that a
forced-decision flow should present its decision explicitly rather than
offer a generic escape hatch alongside it. `blocking`'s `canPop: false` still
only gates system-back/`maybePop` attempts, so a caller's own
`Navigator.pop()` call in its CTA is unaffected by it — this is what actually
resolves the "no exit at all" gap for this variant now.

**Height-default note, added after initial review.** `page` and `blocking`
both defaulted `maxHeightFactor` to a shared `standardMaxHeightFactor`
constant. That constant was initially set to `0.95` (near-full-screen) and,
combined with `Center`-wrapped demo content (which — per Flutter's
`Align`/`ConstrainedBox` constraint semantics — always expands to fill
whatever max height it is given, regardless of platform), rendered as an
effectively full-screen sheet by default. This reads as "into the app
header" rather than a partial overlay, contradicting §1's own "obvious...
way" framing, which implicitly assumes the surrounding page stays visible.
The constant was lowered to `0.8` so both variants default to a clearly
partial sheet; callers with genuinely large content can still opt into a
larger factor explicitly.

---

## Sources

**Primary — official documentation, reached via live fetch (title confirmed) +
search-engine content summary; body text could not be fetched directly in
this environment (JS-rendered pages)**

- <https://developer.apple.com/design/human-interface-guidelines/sheets>
- <https://developer.apple.com/design/human-interface-guidelines/modality>
- <https://m3.material.io/components/bottom-sheets/specs>
- Material dialog anatomy pages under `m3.material.io/components/dialogs` (exact
  URL not directly confirmed by fetch; reached via search summary)

**Primary — reached via search-engine summary that closely tracks and quotes
the source document's own language (highest confidence in this note)**

- <https://www.w3.org/WAI/WCAG21/Understanding/pointer-gestures.html> — WCAG
  2.5.1 Pointer Gestures
- <https://developer.android.com/guide/topics/ui/accessibility/principles> —
  Android accessibility principles, custom accessibility actions

**Secondary — cited for a supporting pattern, explicitly not treated as
platform-authoritative**

- Apple UIKit developer documentation on `isModalInPresentation` and
  `UIAdaptivePresentationControllerDelegate` (API reference, not HIG)
- Material Components Android `BottomSheetDragHandleView` documentation
  (implementation library, not the M3 spec itself)
- Nielsen Norman Group, "Bottom Sheets: Definition and UX Guidelines" —
  cited only for the empirical claim that grab-handle-only dismissal is
  frequently missed by users and ambiguous against OS-level swipe gestures;
  this is UX-research commentary, not a standards body, and is flagged as
  such rather than presented as HIG/WCAG-equivalent authority

**Could not be verified from a primary page directly in this environment**

- The exact phrase "Provide an obvious and safe way to exit a modal task" —
  found only in an archived/mirrored copy of the HIG, not on the current live
  `developer.apple.com` page. The underlying principle is corroborated by the
  live page's own "requires an explicit action to dismiss" and "minimize the
  use of modality" language, but the exact wording should be treated as
  unverified against the current source.
- M3's precise anatomy token list for the bottom-sheet close icon (sizing,
  spec-sheet position) — the *existence* of the pattern is corroborated by
  Compose/Android implementation guidance, but the base M3 spec page's own
  bytes were not directly read.
