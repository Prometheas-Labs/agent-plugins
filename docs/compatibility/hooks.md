# Hook Compatibility

Runtime hooks are deferred for V1.

The package must not ship runtime hook configuration or runtime hook code in
this release. That means:

- no `hooks.json`
- no `hooks/hooks.json`
- no hook scripts
- no manifest hook declarations

Future hooks require a separate design, security review, and per-harness schema
validation before any hook file, script, or manifest hook field is added.
