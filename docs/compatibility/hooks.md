# Hook Compatibility

Runtime hooks are deferred for V1.

No lifecycle hook declarations are shipped in the marketplace root or in
`plugins/product-development/`. Hooks remain deferred until a separate hook
implementation issue is approved.

The marketplace and plugin package must not ship runtime hook configuration or
runtime hook code in this release. That means:

- no `hooks.json`
- no `hooks/hooks.json`
- no hook scripts
- no manifest hook declarations

Future hooks require a separate design, security review, and per-harness schema
validation before any hook file, script, or manifest hook field is added.
