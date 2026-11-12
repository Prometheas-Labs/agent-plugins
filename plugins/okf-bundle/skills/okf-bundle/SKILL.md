---
name: okf-bundle
description: Use when authoring or extending an Open Knowledge Format (OKF) bundle, migrating a bundle from OKF v0.1 to v0.2, or checking a bundle's conformance.
---

# OKF Bundle

An OKF *bundle* is a directory of markdown *concepts* with YAML frontmatter. This skill writes OKF v0.2. The [spec](https://github.com/GoogleCloudPlatform/open-knowledge-format/blob/0b87c52c6ef999286c745e19998fdfcd03d5dbee/SPEC.md) settles anything these files leave open.

Two rules apply to every run:

- **Evidence only.** Every claim and field value traces to material you read or something the user told you. Omit any field you can't support.
- **Preserve what you find.** Keep unknown frontmatter keys, custom `type` values, and links to concepts that don't exist yet.

## Author or extend a bundle

1. **Scope.** List the concepts to write and the source for each. Follow an existing bundle's layout; for a new bundle, ask where it should live.
   *Done when* every planned concept names a source you have read or a statement from the user.
2. **Write concepts.** Read [fields.md](references/fields.md), then copy the [concept template](templates/concept.md) for each one. Write one concept per file, grouped into directories by domain. The file's path without `.md` is its concept ID, and `index.md` and `log.md` are reserved names. Use `# Schema` and `# Examples` headings where they apply. See the [example bundle](references/example-bundle/index.md) for finished concepts.
   *Done when* every planned concept exists with a non-empty `type`.
3. **Sanction computations.** If a number must be produced a specific way, read [attestation.md](references/attestation.md) and write it as its own concept.
   *Done when* every such number has an `Attested Computation` concept or is reported as blocked.
4. **Link.** Use standard markdown links, preferring bundle-relative paths like `[customers](/tables/customers.md)`. State the relationship in the surrounding prose.
   *Done when* every mention of another concept in the bundle is a link.
5. **Index and log.** Add an [index](templates/index.md) to each directory, copying descriptions from the concepts. Add `okf_version: "0.2"` frontmatter to the root `index.md`. For a new bundle, or a deprecation or supersession, add a dated entry to the top of the root [log](templates/log.md), newest first.
   *Done when* every concept and subdirectory appears in its directory's index.
6. **Check.** Run the conformance check below.
   *Done when* it reports no failures.

## Migrate from v0.1 to v0.2

Follow [migration.md](references/migration.md).

## Check conformance

List every `.md` file with `find <bundle> -name '*.md'`, then read each one.

**Failures**, the only reasons a bundle is non-conformant:

- A file other than `index.md` or `log.md` lacks parseable YAML frontmatter.
- A concept's frontmatter has a missing or empty `type`.
- An `index.md` has frontmatter, unless it's the root `index.md` carrying only `okf_version`.
- An `index.md` body isn't one or more headed sections of link entries.
- A `log.md` isn't a flat list of entries grouped under `YYYY-MM-DD` date headings, newest first.

A missing `index.md` or `log.md` is never a failure.

**Warnings**, reported but never failing the bundle:

- Missing `title` or `description`.
- An `index.md` that leaves out a concept or subdirectory in its directory.
- Legacy `timestamp` or `# Citations`.
- Timestamps without an explicit offset, or actors outside the convention.
- Footnote labels with no matching `sources[].id`.
- An `Attested Computation` with no `runtime`.
- A `stale_after` that has passed.
- Links to files that don't exist, listed as not-yet-written knowledge.

Report the files checked against the `find` total, each failure and warning with its path, and this statement: "Checked by hand; no OKF validator ran."

*Done when* the files checked equal the `find` total.
