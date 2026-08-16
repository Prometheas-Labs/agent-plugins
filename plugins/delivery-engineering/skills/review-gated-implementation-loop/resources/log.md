# Update Log

## 2026-08-15 (pass 2)
- **Revision**: Second cross-vendor review pass.
  - STE: removed residual metaphors ("spine", "weight", "ships defects"), split
    two-instruction sentences, fixed fragments and vague pronouns, made the index
    concept list one consistent grammatical form.
  - Progressive disclosure: removed the duplicate full routing map from
    `SKILL.md`; `resources/index.md` is now the sole full resource map.
  - DRY: `dispatcher-orchestration.md` now points to the verification checklist
    instead of restating it; broadened the falsifiability load-cue; changed
    "model" to "reviewer" in the reviewer-independence cue.
  - Declined by judgment (recorded): full strict-STE certification (needs the
    controlled dictionary; would strip needed conceptual content); abstracting
    "pull request" and "commit" out of the loop (over-abstraction for a git
    audience — those live in `platform-adapters.md`); adding `description` to the
    reserved `index.md` files (OKF forbids frontmatter there).

## 2026-08-15
- **Revision**: Applied a cross-vendor STE and skill-authoring review.
  - Rewrote all files in ASD-STE100 style: short imperative sentences, one
    instruction each, active voice, consistent terms. Kept "altitude" as a
    defined term.
  - Slimmed `SKILL.md` to triggers, exclusions, and a routing map. Removed the
    duplicated procedures.
  - Made `planning-altitude.md` the single classifier. Resolved the AND/OR
    trigger conflict with a "highest matching row" rule.
  - Made `severity-and-never-defer.md` the single finding classifier. Added an
    explicit severity scale and a decision table.
  - Rewrote every frontmatter `description` as a load-trigger, not a summary.
  - Added `platform-adapters.md` to separate invariants from platform choices.
  - Moved war-stories to `rationale.md`, off the operational path.
  - Added `templates/`: draft-PR body, review prompt, ledger schema, verification
    checklist.
- **Creation**: Initial OKF v0.1 bundle, generalized from a single-repo
  adversarial-review-loop doc. Reviewer framed as independence tiers. Added the
  dispatcher-orchestration campaign layer.
