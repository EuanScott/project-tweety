# AGENTS.md

## Scope

This file governs every project-local skill under `.codex/skills/`.

## Objective

Optimise for predictable process: correct invocation, branch-specific context,
checkable completion, and one authoritative home for each rule.

## Information ownership

- Frontmatter owns invocation: what the skill does and the distinct requests
  that select it.
- `SKILL.md` owns ordered execution steps and completion gates.
- References own detail needed by only one branch. Link them directly before
  the step that needs them and state the condition for reading them.
- `agents/openai.yaml` owns UI metadata and invocation policy.
- Root and scoped `AGENTS.md` files own durable repository architecture,
  naming, boundaries, and verification conventions.

Keep each meaning in one place. A skill points to repository policy instead of
copying it. Remove stale examples and auxiliary files such as skill README,
installation, quick-reference, or changelog documents.

## Invocation and metadata

- Keep each frontmatter description at 35 words or fewer and the local catalog
  at 175 words or fewer.
- Front-load one distinct action and make sibling skill boundaries mutually
  exclusive.
- Include only `name` and `description` in `SKILL.md` frontmatter.
- Give every skill an `agents/openai.yaml` with quoted interface strings, a
  25-64 character `short_description`, a one-sentence `default_prompt` that
  names `$skill-name` and captures its required inputs, and an intentional
  boolean `policy.allow_implicit_invocation`.

## Execution design

- Keep the body at 900 words or fewer and a normal activated path, including
  required references, at 1,200 words or fewer.
- Write imperative steps in execution order. End every step with an observable
  completion gate.
- Inspect the narrowest applicable repository guidance and nearest live
  implementation. Expand only when evidence requires another hop.
- Express desired output positively. Reserve prohibitions for safety,
  destructive behaviour, missing required inputs, or scope expansion.
- Specify behavioural changes red-first through the public seam. Documentation
  and other non-behavioural work records why TDD does not apply.
- Finish with exact scope, tests/checks, and remaining uncertainty. Conditional
  handoff content appears only when that branch ran.

## Validation

Run `dart run tool/skills/validate.dart` after every skill change. The validator
must pass before forward-testing. Run model evaluations from disposable
workspaces with `dart run tool/skills/eval.dart`; keep raw model artifacts
outside the repository.
