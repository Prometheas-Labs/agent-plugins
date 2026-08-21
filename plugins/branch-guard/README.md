# branch-guard

Nudges agents away from directly editing a repository's protected
branch (the detected default branch, typically `main`), by asking for
approval through the harness's own native permission prompt. Asks
every time a mutating action happens while the current branch is
protected; checking out a feature branch is what stops the prompts,
not answering one.

This is an MVP, intentionally scoped small. It is a best-practices
nudge, not a security boundary: it trusts the branch and working
directory the harness reports, checks a short explicit list of tool
names rather than a full cross-harness taxonomy, and fails open
whenever it can't cleanly determine the current branch (detached HEAD,
not a git repository, and so on). It does not defend against a
deliberately evading agent or injected prompt content. If that
stronger guarantee is ever needed, a more adversarially-hardened
Node.js implementation of this same idea exists on the
`branch-guard-hardened` branch of this repository's history and can be
revived.

## Requirements

POSIX `sh`, `git`. No other runtime dependency — this plugin does not
require Node.js, even on harnesses that are themselves built on it.

## Support status

See `docs/compatibility/harness-matrix.md` in the marketplace repository
for the current support tier of each harness. Claude Code, Codex, and
Copilot CLI ship real hook wiring; GitHub Copilot Cloud Agent and
Gemini/Antigravity are documented adapter targets only, with no runtime
hook support claimed yet.

## Protected branches

Defaults to the repository's detected default branch (via
`origin/HEAD`, falling back to `main`). To protect additional branches,
create `.config/branch-guard/protected-branches` in the repo, one
branch name or glob pattern (`*` supported) per line; `#` starts a
comment. This file entirely replaces the default-branch guess, so list
your actual default branch too if you use it.

## Defense-in-depth pre-commit hook

Run `sh plugins/branch-guard/scripts/install-defense-hook.sh /path/to/repo`
to install a repository-side `pre-commit` hook that blocks direct
commits to a protected branch, independent of which harness (or none)
made the commit. It preserves and chains any pre-existing `pre-commit`
hook regardless of language. `git commit --no-verify` remains a
deliberate, visible bypass.

## Codex setup

Codex treats plugin-bundled hooks as untrusted until a human reviews
and trusts them (see Codex's own hook-review flow). Until that review
happens, this plugin's Codex hook does not run at all. Also, unlike
Claude Code and Copilot CLI, Codex does not yet implement an
interactive approval prompt from a hook: the Codex adapter uses a hard
`deny` (exit code 2) instead, so a blocked action on Codex stops
outright with a message, rather than showing a prompt you can approve.
Switching to a feature branch is the way to proceed on Codex.

## Copilot CLI setup

Copilot CLI does not load plugin-bundled hooks automatically. Copy
`copilot-hooks/preToolUse.json` to `.github/hooks/branch-guard.json`
(repo scope) or `~/.copilot/hooks/branch-guard.json` (user scope),
replacing `PLUGIN_INSTALL_PATH` with the absolute path this plugin was
installed to.

## What this plugin does not do

It trusts the branch and directory the harness reports; it does not
resolve symlinks, detect a git target-override flag in a shell
command, or otherwise defend against deliberate evasion. It fails
open (does nothing) when it can't determine the branch, rather than
asking. This is by design at MVP scope — see the note above about the
hardened alternative if these gaps ever need closing.
