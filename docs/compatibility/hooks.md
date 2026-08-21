# Hook Compatibility

Runtime hooks are no longer deferred marketplace-wide.

`branch-guard` (`plugins/branch-guard/`) is the first hook-bearing plugin in
this marketplace, tracked by issue #29. It ships hook configuration for
Claude Code, Codex, and GitHub Copilot CLI, implemented as POSIX `sh` scripts
with no runtime dependency beyond `git`.

`plugins/product-development/` remains hook-free. The earlier blanket
deferral only ever applied while no hook-bearing plugin had gone through
review; it does not retroactively add hooks to `product-development`, and
does not mean any future plugin may add hooks without its own review.

Any future hook-bearing plugin should have a design proportionate to its own
risk profile, and per-harness schema validation. Before claiming a
`supported` tier in `docs/compatibility/harness-matrix.md`, a live smoke test
should prove the hook is discovered, trusted, and fires against the
currently installed CLI version of that harness.
