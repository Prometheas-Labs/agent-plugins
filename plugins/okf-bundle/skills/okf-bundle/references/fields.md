# Frontmatter fields

Only `type` is required. A concept with just `type` is conformant, so add other fields when you have evidence for them.

## Core

| Field | Meaning |
| --- | --- |
| `type` | Required. Short, descriptive kind, such as `Metric` or `Playbook`. There is no fixed list. |
| `title` | Display name. |
| `description` | One sentence. Indexes reuse it. |
| `resource` | URI of the underlying asset. Omit for abstract concepts. |
| `tags` | YAML list of short strings. |

## Timestamps

Every timestamp field is an ISO 8601 datetime with an explicit offset, such as `2026-06-30T14:00:00Z`. Dates alone are valid only in `log.md` headings. If a source gives only a date, append `T00:00:00Z` and report the time as assumed. Use block-style YAML for mappings that hold timestamps, because some parsers reject them in `{ }` form.

## Actors

`generated.by` and `verified[].by` use one of these forms:

| Who | Form | Example |
| --- | --- | --- |
| Agent or tool | `<producer>/<version>` | `claude-code/claude-opus-5-5` |
| Person | `human:<id>` | `human:jsmith` |
| Automated process | `process:<id>` | `process:finance-nightly` |

Name yourself as the agent when you write the content. Use `human:` only for a person who wrote or confirmed it, and ask for their ID if you don't have it.

## Trust

```yaml
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-06-20T14:00:00Z
verified:
  - by: human:jsmith
    at: 2026-06-25T09:00:00Z
```

- `generated` records who last changed the content and when. `by` is required. Update it on every meaningful content change.
- `verified` records a check against the sources or `resource` that actually happened. Writing a concept doesn't verify it, so add an entry only when a person or process has confirmed the content.
- Consumers derive the trust tier from `verified`, so never store a tier or score.

## Lifecycle

- `status`: `draft`, `stable`, or `deprecated`. Absent means `stable`, so write `draft` until someone has reviewed the concept. Mark retired concepts `deprecated` and keep the file.
- `stale_after`: the instant the content stops being reliable. Set it only when a source or the user gives a reason, such as an annual policy reissue.

## Sources

```yaml
sources:
  - id: finance-handbook
    resource: https://example.com/finance/handbook
    title: Finance reporting handbook
    author: human:jsmith
    last_modified: 2026-06-01T00:00:00Z
    usage_count: 5000
usage_window:
  from: 2026-06-01T00:00:00Z
  to: 2026-06-30T00:00:00Z
```

- List only sources you read or the user named.
- `resource` is required in each entry. It's a URL, a bundle path, or a scope descriptor such as `all queries in BigQuery project X`. For a local file outside the bundle, use a scope descriptor that names it.
- `author`, `usage_count`, and `last_modified` are optional facts about the source. Copy them from the source, leaving out any you can't find. `author` uses the actor forms, or `team:<id>` for a team.
- `usage_window` frames every `usage_count` and sits beside `sources`. An entry can carry its own to override it.

## Per-claim attribution

Give the source an `id`, then cite it with a footnote using that `id` as its label:

```markdown
The `events_` table is sharded daily.[^ga4-schema]

[^ga4-schema]: GA4 BigQuery Export schema
```

Footnote labels are what link a claim to its source, so they must match exactly.
