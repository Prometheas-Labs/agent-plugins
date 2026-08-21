---
name: branch-guard
description: Use when a file edit or shell command is blocked with an ask/deny reason mentioning branch-guard, or when starting work in a repository and you want to check whether the current branch is protected before making changes.
---

# branch-guard

This repository has branch-guard installed. It asks for approval,
through your own harness's native permission prompt, before mutating
actions (file edits, most shell commands) while you are on the
repository's protected branch (usually `main`). It holds no memory of
a prior approval: approving one prompt does not stop the next one
from asking too. The only thing that stops the prompts is working on
a branch that isn't protected.

## If an action gets blocked (asked about)

The reason names branch-guard and the protected branch. There is no
separate command to run and no file to write yourself. What to do:

1. Tell the user which branch you are on and that it is protected.
2. If the user did not ask you to work on this branch directly, create
   or check out a feature branch (in a git worktree, if that is this
   user's usual workflow) and retry the action there. This is almost
   always the right move, and it makes the prompts stop entirely for
   that work.
3. If the user does want changes made directly on the protected branch
   for this task, say so back to them, then retry the action. Your
   harness will show its own approval prompt every time.

## What this does not do

This is a best-practices nudge, not a security boundary. It trusts the
branch and directory your harness reports, does not defend against
deliberate evasion, and a repository-side `pre-commit` hook (if
installed) is a simple, best-effort backstop, not a guarantee. Server-
side branch protection on the git host remains the real enforcement
mechanism for anything that actually needs to be enforced.
