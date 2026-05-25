# Product Vision

## Purpose

Use this reference to create, approve, version, maintain, and apply `docs/product/vision.md` as the product north star for the product-development lifecycle.

The vision defines long-horizon product direction, target users, value proposition, platform principles, surface philosophy, success measures, and known assumptions. It is not a feature PRD, roadmap, backlog, architecture decision record, or glossary.

## When to use this reference

Use this reference when:

- `docs/product/vision.md` is missing.
- The user asks to create, review, update, or supersede the product vision.
- The agent is about to create the first feature PRD.
- A proposed PRD, TRD, story, scenario, implementation plan, or delivery result appears to change strategic product direction.
- A product-planning task needs to check alignment with the approved vision.

## Foundation Gate before first PRD

First feature PRD work is blocked until both foundation documents exist and are approved:

- `docs/product/constitution.md` — approved product governance principles.
- `docs/product/vision.md` — approved, versioned product north star.

Do not create the first feature PRD while either document is missing, unapproved, or unversioned. Clear requirements may skip brainstorming only after Foundation Gate passes.

## Preferred dependency: grill-with-docs

Use `grill-with-docs` when it is installed. It is the preferred dependency for interview discipline, repo-aware questioning, and context/ADR coordination.

Keep the user interview in the main context because it is one-question-at-a-time and requires tight collaboration. Answer from repo evidence instead of asking the user when the answer is discoverable from project files, source artifacts, existing docs, tickets, or linked research.

The product-development skill still owns the product artifact rules:

- Product vision lives at `docs/product/vision.md`.
- Approved immutable versions live under `docs/product/visions/`.
- Product glossary/domain context, when needed, lives at `docs/product/CONTEXT.md`.
- ADRs default to `docs/adr/` unless the repository already uses another ADR convention.

## If grill-with-docs is missing

Notify the user up front that `grill-with-docs` is not installed and recommend installing it before continuing. Explain that it improves the interrogation and helps keep context/ADR updates compatible with repo docs.

Continue with the fallback workflow only if the user declines installation or explicitly asks to proceed without it. In fallback mode, preserve the same rules: one question at a time, repo evidence first, source-labeled synthesis, red-team review, and explicit user ratification before approval.

## Vision Grill workflow

1. Inspect repo evidence: existing product docs, README files, source artifacts, tickets, design docs, research notes, roadmap material, architecture docs, and prior decisions.
2. Check whether `grill-with-docs` is installed and handle the dependency behavior above.
3. Build a research synthesis before drafting the vision. Label each material claim as one of:
   - `Source-backed` — directly supported by repo/source evidence.
   - `User-stated` — stated by the user in the interview.
   - `Assumption` — plausible but thinly evidenced.
   - `Open question` — unresolved and not safe to treat as true.
4. Ask only for information that cannot be reasonably discovered from repo evidence. Ask one question at a time.
5. Draft candidate vision material from the evidence and interview answers.
6. Run a source-evidence pass. If evidence is thin, label the item as an assumption instead of inventing certainty.
7. Run a red-team review that challenges target users, problem framing, differentiation, platform principles, success metrics, business constraints, and assumptions.
8. Revise the draft and present the vision, research synthesis, red-team findings, and any proposed side-effect docs for user ratification.
9. Write or update `docs/product/vision.md` only after the user approves the content and version.

## Vision document anatomy

Use these concise prompts to structure `docs/product/vision.md`. Consult the source guide for exact worksheets and deeper explanation.

- Executive vision statement: What future change does the product create, for whom, and why does it matter?
- Target users and customer segments: Which user/customer groups matter, what surfaces do they use, and which segments are strategically primary?
- Core problems and user needs: What jobs, pains, and desired outcomes are source-backed?
- Value proposition and differentiation: Why choose this product over competitors, workarounds, or doing nothing?
- Platform principles: What durable rules guide product, design, and engineering tradeoffs across surfaces?
- Experience vision by surface: What should each known surface feel like for its primary users?
- Multi-surface design philosophy: What remains coherent across surfaces, and where should each surface adapt?
- Architecture vision: What high-level technical/product philosophy enables the platform direction without turning the vision into a TRD?
- Success metrics and north star metric: Which outcome measures show progress toward the vision?
- Business goals and constraints: What commercial, regulatory, timing, budget, or operating constraints shape the direction?
- Open questions and assumptions: What is unknown, how confident are we, how will it be validated, and what is the risk if wrong?

Keep these as prompts. Do not paste long guide explanations into the operational vision reference or normal product vision drafts.

## Versioning and approval

Use explicit metadata at the top of every approved `docs/product/vision.md`:

```md
# Product Vision

Version: 1.0.0
Status: Approved
Approved: YYYY-MM-DD
Supersedes: None
```

Version rules:

- Initial approved vision is `1.0.0`.
- Patch versions are for non-strategic wording fixes.
- Minor versions are for material clarifications that preserve strategic direction.
- Major versions are for strategic pivots.
- Approved strategic meaning is immutable.
- Pivots supersede prior approved versions; they do not silently rewrite history.
- Immutable approved copies live under `docs/product/visions/vision-vX.Y.Z.md`.
- `docs/product/vision.md` is the current pointer containing the latest approved version and a link to the archived immutable copy.
- When superseding, archive the old approved version, update supersession metadata, and then update `docs/product/vision.md` to the new approved version.

The source guide describes the product vision as a living document. In this skill, the immutable-plus-supersede strategy overrides that language for approved strategic meaning. The vision can evolve, but approved strategic meaning changes through versioned supersession.

## Context and ADR coordination

Artifact boundaries:

- `docs/product/vision.md`: product north star, strategic direction, target users, value proposition, principles, surface vision, success metrics, business constraints, assumptions, and open questions.
- `docs/product/CONTEXT.md`: product-domain glossary and domain-language guidance only. Do not use it as a requirements scratchpad.
- ADRs: decisions and rationale that need durable decision records. Use `docs/adr/` by default unless the repository already has another ADR convention.

Assumptions belong in the vision or research synthesis. Decisions belong in ADRs. Glossary/domain-language guidance belongs in `docs/product/CONTEXT.md`.

If product context is not root-level and `docs/product/CONTEXT.md` exists or is proposed, root `CONTEXT-MAP.md` should point to it so Matt-style `grill-with-docs` agents can discover the product context.

Do not silently write side-effect docs during the interview. User approval is required before writing `CONTEXT-MAP.md`, `docs/product/CONTEXT.md`, or ADR side-effect docs unless the user explicitly asks for inline updates.

Before presenting final drafts, reconcile terminology across `vision.md`, `CONTEXT.md`, and ADRs. If they would define conflicting terms or decisions, ask the user to choose.

## Ongoing use during planning and delivery

Reference the approved vision during:

- PRD creation: verify target users, value proposition, platform principles, surface expectations, and success measures align with `docs/product/vision.md`.
- TRD creation: verify architecture choices support the architecture vision and platform principles without smuggling strategic pivots into implementation detail.
- User stories and scenarios: verify user intent and acceptance criteria trace to source-backed needs and the approved direction.
- Implementation planning: include checks for relevant principles, surface expectations, and metrics.
- Delivery validation: ask whether shipped behavior moved the product toward the north star, contradicted any principle, or exposed assumptions that need follow-up.

If planning or delivery reveals a strategic mismatch, stop the downstream artifact and update or supersede the vision first.

## Maintenance and maturity

Review the vision at major planning moments, after meaningful research, when entering new surfaces or markets, and when PRDs repeatedly expose strategic tension.

Use the maturity model from the source guide as an operating check:

- Initial: vision exists but has weak evidence or limited team adoption.
- Defined: vision is approved, source-labeled, and versioned.
- Operationalized: PRDs, TRDs, implementation plans, metrics, and delivery reviews trace back to the vision.
- Transformational: the vision consistently drives roadmap choices, product identity, and strategic pivots.

Do not use maturity review as permission to edit approved meaning in place. Use patch, minor, or major versioning according to the rules above.

## Source guide

The full source archive is preserved at [source/vision-document-guide.md](source/vision-document-guide.md).

Consult it when exact worksheet language, detailed anatomy guidance, anti-patterns, maturity model detail, or source fidelity is needed. Normal product-development work should start with this operational reference and load the source guide only for deeper detail.
