# Lifecycle Review and Handoff Workflows Design

## Goal

Improve the `product-development` plugin so it captures the repeated lifecycle patterns from the CompleteSportsCorp/platform #13 run: milestone reviews, gate transitions, open-question triage, downstream comments, technology decision canonization, compliance research, and implementation handoff issue drafting.

The update should make these behaviors first-class skill workflows without turning product-development into an AI-only spec generator. Human review and approval remain required at lifecycle gates.

## Current Context

The plugin already has a portable canonical skill tree under:

```text
plugins/product-development/skills/product-development/
```

It also ships thin shared agent wrappers under:

```text
plugins/product-development/agents/shared/
```

Existing shared agents are:

- `product-researcher`
- `spec-reviewer`
- `plan-reviewer`
- `implementation-auditor`

These files exist on `origin/main`, were added in commit `583ba9a` on 2026-06-01, and currently act as thin wrappers only. The product-development skill does not yet recommend these agents by name at lifecycle milestones.

The compatibility matrix says agent support is currently "documented adapter only"; runtime loading is not claimed for Codex, Claude Code, or GitHub Copilot. That constraint should remain unless runtime smoke tests prove otherwise.

## Selected Approach

Use skill reference docs as the canonical implementation surface. Add or update thin agent wrappers only as adapter prompts that route to the canonical skill.

This approach fits the researched harness capabilities:

- Skills/reference docs are the strongest shared substrate across Codex, Claude Code, and GitHub Copilot.
- Codex custom prompts are deprecated; reusable behavior should live in skills.
- Custom agents/subagents are active capabilities, but schemas, loading paths, and runtime behavior differ by harness.
- Commands are useful convenience entrypoints, but command semantics are less portable than skills.

The product-development skill should recommend relevant agents at meaningful lifecycle milestones. It should not run agent reviews continuously or replace human approval.

## Review Philosophy

Reviews are milestone offers, not every-turn automation.

At lifecycle milestones, the skill should make an encouraging recommendation such as:

```text
Recommended milestone review: run `prd-reviewer` before advancing. This is not mandatory, but it is the expected quality path for human-reviewed feature specs.
```

This framing intentionally splits the difference between mandatory automation and weak opt-in prompts. It sets a quality expectation while preserving human control.

Human responsibility is explicit:

- Review agents support human decision-making.
- Human approval gates remain required.
- If a team wants fully automated spec production without human accountability, that is outside this plugin's philosophy.

## Reviewer Protocol

Reviewer agents should always be adversarial and should run as subagents/custom agents when the harness supports that. If subagents or custom agents are unavailable, the workflow should disclose the fallback before continuing.

Each reviewer starts by presenting a review charter:

1. Standard review scope for that artifact type.
2. Contextual review scope based on recent changes, current research, downstream concerns, and user-provided context.
3. A prompt asking whether the user wants to add or amend review considerations.
4. A prompt asking whether to adjust reasoning level.
5. A prompt asking whether to add context, source artifacts, or external references.

Reviewer reasoning levels are portable human-readable labels:

- `low`
- `medium`
- `high`
- `extra high`

Default reasoning levels:

| Milestone | Default |
| --- | --- |
| PRD review | `high` |
| TRD review | `high` |
| Final pre-approval review | `high` |
| Implementation handoff review | `high` |
| Compliance, standards, security, or legal-adjacent review | `extra high` |
| Story review | `medium`, unless high-risk |
| Scenario review | `medium`, unless high-risk |
| Downstream preparedness review | `high` when dependencies or future owners are affected |

Review output should lead with findings ordered by severity. Severity labels should include at least:

- `BLOCKER`
- `MATERIAL RISK`
- `NON-BLOCKING`

Findings should include file, section, or line references when local artifacts are reviewed.

## Agent Strategy

Add named reviewer agents for core milestone reviews:

- `prd-reviewer`
- `trd-reviewer`
- `story-reviewer`
- `scenario-reviewer`
- `preparedness-reviewer`
- `final-approval-reviewer`
- `handoff-reviewer`

Keep `spec-reviewer` as a compatibility/router wrapper. It should detect artifact type from path, content, or lifecycle state and route to the relevant named reviewer. If artifact type is ambiguous, it should ask one clarifying question. It should not perform the deep review itself unless no named reviewer exists, and it must disclose that fallback.

Refine existing agents so the skill recommends them at appropriate lifecycle moments:

- `product-researcher`: discovery, technology decisions, compliance and standards research.
- `spec-reviewer`: compatibility/router entrypoint.
- `plan-reviewer`: implementation-plan and handoff readiness.
- `implementation-auditor`: post-implementation alignment against approved product artifacts.

Agent wrappers must remain thin. They may describe their bounded role and direct the agent to the canonical skill, but they must not duplicate lifecycle methodology from reference docs.

## Product Researcher Protocol

`product-researcher` should use a lighter charter than reviewer agents because it gathers context before decisions rather than judging an artifact for approval.

The research charter should include:

- research question or decision under investigation
- planned sources or artifact classes
- constraints and non-goals
- a prompt asking whether the user wants to add sources, exclude assumptions, or provide more context

For technology, compliance, standards, security, or legal-adjacent research, the protocol becomes stricter:

- prefer primary sources when possible
- cite sources in any canonized artifact claim
- distinguish current-scope requirements from downstream work
- avoid claims of certification, legal sufficiency, or compliance completeness unless separately approved

## New Reference Files

Add these reference files under:

```text
plugins/product-development/skills/product-development/references/
```

### `review-workflows.md`

Central protocol for milestone review offers, reviewer charters, severity labels, reasoning levels, subagent fallback disclosure, and milestone-to-agent mapping.

This file should also own the reusable adversarial review prompt library. It must include artifact-specific prompt templates for:

- PRD review
- TRD review
- user story review
- BDD scenario review
- downstream preparedness review
- final pre-approval review
- implementation handoff review

Each prompt template must include:

- findings-first output
- `BLOCKER`, `MATERIAL RISK`, and `NON-BLOCKING` severity labels
- local file, section, or line citations when reviewing local artifacts
- explicit scope boundaries so PRD reviews do not drift into TRD, code, migration, or test feedback, and so later reviews do not reopen already approved upstream gates without a stated blocker
- stale terminology checks, including role names, lifecycle language, deprecated product vocabulary, and project-specific tokens from AGENTS guidance when present
- downstream ownership checks where the artifact affects future feature owners or dependency chains
- review-charter instructions requiring the reviewer to summarize standard and contextual review considerations before proceeding

Lifecycle docs should link to this file rather than restating the full review protocol.

### `gate-transition.md`

Workflow for approving PRD, TRD, stories, and scenarios.

Expected behavior:

- update artifact lifecycle status
- append changelog entries when requirements, architecture, acceptance criteria, or approval status change
- run configured or targeted validation checks
- report clean state and next lifecycle gate
- preserve implementation, code, migration, and test gates until explicitly approved

### `open-question-triage.md`

Workflow for processing open questions one at a time.

Expected behavior:

- enumerate open questions
- classify each as blocker, current-scope decision, or safe downstream deferral
- explain recommendation concisely
- apply approved artifact revisions
- draft downstream issue comments when future owners must revisit the decision

Product-development drafts comments only. Live GitHub posting is delegated to GitHub helper workflows after user approval.

### `downstream-cross-reference.md`

Workflow for identifying downstream issues or feature owners affected by current-feature decisions.

Expected behavior:

- inspect dependency tables, open questions, parent epic context, and linked downstream issues
- identify affected downstream issues or explicitly state when none are discoverable
- draft source-cited comments that explain the current decision, why downstream owners must revisit it, and which artifact sections to consult
- include explicit "revisit this document/decision when resolving this downstream issue" language
- route live posting, issue linking, and metadata updates to GitHub helper workflows after user approval

`open-question-triage.md`, `implementation-handoff.md`, and preparedness review guidance should link to this file instead of restating the full downstream workflow.

### `implementation-handoff.md`

Workflow for drafting implementation handoff issues after a feature spec PR merges.

Expected behavior:

- consume approved PRD, TRD, stories, and scenarios
- draft a rich issue body suitable for a one-shot Codex goal run
- include source artifacts, delivery scope, decisions, milestones, validation evidence, explicit non-scope, and acceptance criteria
- optionally draft parent epic or follow-up checklist updates

Product-development drafts the issue body. Live GitHub issue creation, linking, and metadata updates are delegated to GitHub helper workflows.

### `tech-decision-canonization.md`

Workflow for repeatable TRD technology decisions.

Expected behavior:

- use `product-researcher` with a research charter
- research viable alternatives
- summarize tradeoffs and recommendation
- get human approval before canonizing
- insert the approved decision with rationale, constraints, acceptance criteria, and proof metrics
- avoid importing downstream implementation models prematurely

### `compliance-standards-research.md`

Workflow for legal, compliance, security, and standards questions.

Expected behavior:

- use `product-researcher` with stricter source requirements
- prefer primary sources
- cite canonized artifact claims in the artifact itself
- separate current-scope changes from downstream work
- avoid certification or legal sufficiency overclaims

## Lifecycle Integration

Update `SKILL.md` and lifecycle reference docs so they point to the new references at relevant milestones.

Recommended milestone hooks:

- PRD discovery: recommend `product-researcher` when problem context, users, market, compliance, or tech alternatives are unclear.
- PRD drafted: recommend `prd-reviewer`.
- PRD open questions processed: recommend `prd-reviewer` or `preparedness-reviewer` when decisions affect downstream owners.
- TRD drafted: recommend `trd-reviewer`.
- Technology decision canonized: recommend `trd-reviewer` and use `tech-decision-canonization.md`.
- Compliance, standards, or security research canonized: recommend `trd-reviewer` or `prd-reviewer` with `extra high` reasoning and use `compliance-standards-research.md`.
- Stories drafted: recommend `story-reviewer`.
- Scenarios drafted: recommend `scenario-reviewer`.
- Downstream readiness checked: recommend `preparedness-reviewer`.
- Final pre-approval pass: recommend `final-approval-reviewer`.
- Implementation handoff issue drafted: recommend `handoff-reviewer` and `plan-reviewer` when the issue includes execution sequencing.
- Implementation completed later: recommend `implementation-auditor` before claiming artifact alignment or release readiness.

## Responsibility Boundaries

Product-development owns:

- lifecycle methodology
- artifact edits
- review-offer timing
- review charter protocol
- handoff issue body drafts
- downstream comment drafts
- citation requirements for canonized claims

Project guidance owns:

- repository-local terminology and stale-token lists
- domain-specific quality bars
- local dependency, command, and validation conventions
- project-specific review instructions from AGENTS guidance or local configuration
- local ownership boundaries that identify downstream feature owners or issue-routing conventions

GitHub helpers own:

- creating GitHub issues
- posting comments
- linking issues or PRs
- updating GitHub metadata
- inspecting live PR review threads or CI state

Harness adapters own:

- runtime-specific command or agent loading
- model or reasoning knob mapping
- smoke-test evidence for support claims

## Validation Plan

Automated validation should cover:

- new reference files exist and are listed in `SKILL.md` reference map
- lifecycle docs mention relevant new references at milestone points
- agent wrappers remain thin and route to the canonical skill
- named reviewer wrappers exist
- wrappers include review charter expectations without duplicating full methodology
- compatibility docs still distinguish shared wrappers from validated runtime support
- existing marketplace and init tests still pass
- package tests enumerate new shared agent wrappers so missing reviewers fail deterministically
- thin-adapter tests cover all new reviewer wrappers and any updated compatibility/router wrappers
- reference-map checks cover `review-workflows.md`, `gate-transition.md`, `open-question-triage.md`, `downstream-cross-reference.md`, `implementation-handoff.md`, `tech-decision-canonization.md`, and `compliance-standards-research.md`

Manual validation should cover:

- read PRD/TRD/story/scenario lifecycle text and confirm review offers happen only at milestones
- verify review wording is encouraging recommendation, not forced automation
- verify GitHub live actions are delegated rather than performed by product-development guidance
- verify compliance/security guidance requires primary-source citations for canonized artifact claims

## Alternatives Considered

### Put workflow behavior in command prompts

Rejected. Commands are less portable, and Codex custom prompts are deprecated. Commands should remain convenience entrypoints, not methodology.

### Make reviewer agents canonical

Rejected. Custom agents are useful but harness-specific. Canonical behavior belongs in the skill tree and reference docs.

### Keep one generic reviewer

Rejected as the main path. A generic reviewer is useful for compatibility and routing, but named artifact reviewers give clearer scope and reduce review drift.

### Automate reviews at every turn

Rejected. The plugin is designed for deliberate human-reviewed feature specs, not continuous AI autopilot.

## Out Of Scope

- Claiming runtime support for agent loading in Codex, Claude Code, or GitHub Copilot without smoke tests.
- Creating live GitHub issues or comments directly from product-development workflows.
- Adding executable hooks.
- Beginning implementation planning, code, migrations, tests, or release work before the relevant human approval gate.
- Installing Matt Pocock's `grill-with-docs` skill automatically.
