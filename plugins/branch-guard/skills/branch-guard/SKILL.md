---
name: branch-guard
description: Use when a tool call is blocked or annotated with a reason mentioning branch-guard, or when starting work and you want to check whether the current branch is protected before making changes.
---

# branch-guard

This repository has branch-guard installed. On Claude Code and Copilot
CLI, mutating actions on a protected branch (`main`, `master`,
`production`, `develop`/`development`, the repo's detected default
branch, or anything listed in `.config/branch-guard/protected-branches`)
trigger the harness's own approval prompt, every time, with no memory
of a prior approval. On Codex, the action proceeds with a reminder
note attached instead of a prompt — Codex doesn't block here.

If you're asked to confirm or see a reminder: tell the user which
branch you're on. If they didn't ask for this branch specifically,
switch to a feature branch instead. If they do want the change here,
say so and continue.
