# Review Passes and Red-Teaming

## Core Rule

Human approval decides each gate. Red-team review exists to make that approval informed instead of optimistic.

Use red-team review as the default automated pass for Gates G1-G4 on any feature with meaningful complexity, privacy or safety impact, cross-feature dependencies, or multiple artifacts.

## Standard Review Output

Every red-team pass should return:

- `Verdict:` `PASS` | `PASS WITH CONDITIONS` | `REVISE`
- Findings ordered by severity
- Each finding with: severity, category, artifact reference, description, and why it matters
- Open questions only when they block confidence

Severity rubric:

- `CRITICAL` — blocks the gate; contradiction, missing requirement, safety or privacy gap, or misleading status claim
- `MAJOR` — should be fixed before the next phase; missing coverage, weak traceability, unverifiable acceptance criteria, or speculative design
- `MINOR` — useful improvement, but not a gate blocker on its own

## Gate-by-Gate Strategy

### G1: Design Red-Team

Review the approved design for:

- hidden scope creep and undecomposed multi-system work
- assumptions that have no explicit decision or owner
- safety, privacy, or operational constraints missing from the design
- success criteria that are too vague to judge later

Do not drift into implementation details. The question at G1 is whether the design is coherent, bounded, and decision-ready.

### G2a: PRD Red-Team

Review the PRD for:

- missing or contradictory requirements
- non-functional requirements that are implied but not stated
- privacy, consent, safety, and data-minimization gaps
- "success metrics" that are really instrumentation plans
- unresolved cross-feature conflicts with neighboring product docs
- requirements that cannot be verified or traced downstream

The PRD pass should compare against governance docs and nearby feature docs in the same domain, not just the PRD in isolation.

### G2: TRD Red-Team

Review the TRD for:

- explicit traceability back to the PRD's FRs and NFRs
- speculative vendor or SDK behavior presented as settled design
- state-machine, storage, identity, queueing, and failure-mode gaps
- operational controls incorrectly described as app behavior
- architecture that does not actually satisfy the hard requirements
- missing test strategy for the riskiest behaviors

The TRD red-team should be aggressive about hidden implementation traps. A design that sounds plausible is not enough.

### G3: Story Red-Team

Review the story set for:

- complete FR/NFR coverage with no orphaned requirements
- stories that are too large or too implementation-shaped
- acceptance criteria that are vague, unobservable, or timing-ambiguous
- status or lifecycle claims that overstate readiness
- inconsistent story IDs, trace links, or ownership
- cross-story contradictions in states, permissions, or edge cases

The story pass should reject epics disguised as stories and "Draft but somehow phase-complete" nonsense.

### G4: Scenario Red-Team

Review the scenario set for:

- one-to-one coverage from acceptance criteria to scenarios
- missing negative paths, transitions, and edge conditions
- vague `Then` clauses that are not observable
- wrong placement between platform and surface-specific scenarios
- ops or deployment checks masquerading as app behavior
- scenarios that leak implementation details instead of specifying behavior

Scenarios should behave like executable contracts even before step definitions exist.

### Late-Gate Full-Chain Red-Team

Run a final review after G4 and before Phase 5. This pass reviews the full PRD -> TRD -> stories -> scenarios chain for:

- contradictions that only appear across artifact boundaries
- drift in terminology, states, entry paths, or policy
- orphan stories or orphan scenarios
- phase or status claims that overstate what is actually done
- unresolved findings from earlier passes

This pass should deduplicate already-fixed findings instead of re-reporting them.

## Shielded Review via Sub-Agent

Use a separate reviewer agent when the main context wrote or heavily shaped the artifact.

Rules:

- do not fork the full conversation into the reviewer
- pass only the artifacts, adjacent docs needed for consistency checks, the gate rubric, and the required output schema
- exclude prior rationalizations, preferred fixes, and "looks good" commentary from the writer
- require findings with file references and severity
- keep the reviewer read-only

The point is to reduce confirmation bias. A reviewer with the writer's full decision history is easier to steer and easier to satisfy.

## External CLI Review Backends

Use these when you want an independent review surface outside the main agent. Keep prompts review-only, scope filesystem access tightly, and prefer structured output.

### Claude Code CLI

Recommended pattern:

```bash
claude -p \
  --model opus \
  --effort max \
  --output-format json \
  --permission-mode dontAsk \
  --add-dir "$WORKTREE" \
  --allowedTools "<read-only tools>" \
  --disallowedTools "Edit Bash" \
  < review-prompt.txt
```

Use `-p` for non-interactive runs, `--output-format json` for machine-readable output, `--add-dir` to scope access, and tool restrictions to keep the review read-only. If you need stricter isolation, pass the artifact list in the prompt and do not grant broad repository access.

### Codex CLI

Recommended pattern:

```bash
codex exec \
  -C "$WORKTREE" \
  -m gpt-5.4 \
  -s read-only \
  --ephemeral \
  --json \
  --output-last-message /tmp/codex-red-team.json \
  < review-prompt.txt
```

Use `codex exec` for non-interactive review runs, `-s read-only` to block writes, `--ephemeral` to avoid persisting session state, and `--json` or `--output-last-message` for downstream processing. On Codex builds that support it, add `--output-schema` and a no-approval mode for tighter automation.

### GitHub Copilot CLI

Recommended pattern:

```bash
copilot \
  -p "$(cat review-prompt.txt)" \
  -s \
  --output-format json \
  --model gpt-5.4 \
  --reasoning-effort xhigh \
  --no-ask-user \
  --add-dir "$WORKTREE" \
  --deny-tool='write' \
  --deny-tool='shell(*)'
```

Use prompt mode for non-interactive runs, `--reasoning-effort xhigh` when available, `--no-ask-user` to avoid interactive follow-ups, and explicit tool restrictions so the run stays review-only. If your installed tool inventory uses different names, adapt the denied tool list accordingly.

## Prompt Construction Rules

For any backend:

- identify the gate explicitly
- list the exact files under review
- include adjacent docs needed for contradiction checks
- state the review scope and anti-scope
- demand findings first, ordered by severity
- require file references with line numbers
- forbid edits

Do not ask for a general review. That is how you get bland summaries and miss the defect that matters.

## Suggested Sources

Verify CLI details against official docs before standardizing command templates:

- Claude Code CLI reference
- OpenAI Codex non-interactive and CLI reference docs
- GitHub Copilot CLI reference and programmatic mode docs
