# branch-guard

Directs agents away from directly editing a repository's protected
branch. On Claude Code and Copilot CLI, a mutating action on a
protected branch triggers the harness's own approval prompt, every
time, with no memory of a prior approval. On Codex, the action
proceeds with a model-visible reminder attached instead, since Codex's
hooks can't yet show an approval prompt.

This is a best-practices nudge, not a security boundary. It trusts the
branch and directory the harness reports and doesn't defend against
deliberate evasion. For an actual block, install the repo-side
pre-commit hook below, or use server-side branch protection on your
git host.

## Support status

See `docs/compatibility/harness-matrix.md` in the marketplace repository
for the current support tier of each harness.

## Protected branches

Always protected: the repository's detected default branch, plus
`master`, `production`, `develop`, and `development`. To protect more,
create `.config/branch-guard/protected-branches` in the repo, one
branch name or glob pattern (`*` supported) per line; `#` starts a
comment. These are added on top of the built-in list, not a
replacement for it.

## Defense-in-depth pre-commit hook

Run `sh plugins/branch-guard/scripts/install-defense-hook.sh /path/to/repo`
to install a repository-side `pre-commit` hook that blocks direct
commits to a protected branch. If the repo already has a `pre-commit`
hook, this installs nothing and tells you how to call the guard script
from your own hook instead. `git commit --no-verify` remains a
deliberate, visible bypass.

## Codex setup

Codex treats plugin-bundled hooks as untrusted until a human reviews
and trusts them. Until that review happens, this plugin's Codex hook
does not run at all.

## Copilot CLI setup

Copilot CLI does not load plugin-bundled hooks automatically. Copy
`copilot-hooks/preToolUse.json` to `.github/hooks/branch-guard.json`
(repo scope) or `~/.copilot/hooks/branch-guard.json` (user scope),
replacing `PLUGIN_INSTALL_PATH` with the absolute path this plugin was
installed to.
