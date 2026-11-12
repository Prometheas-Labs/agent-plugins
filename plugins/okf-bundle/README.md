# okf-bundle

Guides agents through authoring [Open Knowledge Format](https://github.com/GoogleCloudPlatform/open-knowledge-format/blob/0b87c52c6ef999286c745e19998fdfcd03d5dbee/SPEC.md) (OKF) v0.2 bundles: directories of markdown concepts with YAML frontmatter. It also migrates v0.1 bundles and checks conformance.

The plugin is instructions only, with no scripts, hooks, or runtime dependencies. Conformance checks are done by hand, and the agent says so in its report. Tool-backed validation is tracked in [#33](https://github.com/Prometheas-Labs/agent-plugins/issues/33).

Consuming bundles, conversion from other formats, and visualization are out of scope.

## Use

Ask your agent to work on a bundle:

```text
Document our billing service as an OKF bundle in docs/knowledge
Migrate docs/knowledge from OKF v0.1 to v0.2
Check whether docs/knowledge is a conformant OKF bundle
```

## Support status

See `docs/compatibility/harness-matrix.md` in the marketplace repository for the current support tier of each harness.

## Licensing

This plugin is licensed under Apache-2.0; see [LICENSE](LICENSE). The skill summarizes and adapts the OKF specification, which is also Apache-2.0. See [NOTICE](NOTICE) for attribution.
