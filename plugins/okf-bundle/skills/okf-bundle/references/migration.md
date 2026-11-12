# Migrate from v0.1 to v0.2

Two v0.1 constructs were replaced: `timestamp` by `generated`, and the body `# Citations` list by `sources`. Everything else carries forward.

Edit files as text so key order, quoting, and comments survive. Change only what these steps name, and add no other v0.2 fields. A concept without `timestamp` gains no `generated`, because migrating isn't a content change. If no one can answer a question below, leave that construct in place and report it.

1. **Inventory.** List every concept with a frontmatter `timestamp` or a `# Citations` heading, and note any that already has `generated` or `sources`.
   *Done when* each one is on the list with the constructs it uses.
2. **Find the actor.** `generated.by` names who wrote the existing content, which is rarely you. Ask the user, showing them any evidence you found, such as frontmatter or git history. See [actor forms](fields.md#actors).
   *Done when* each listed concept has an actor the user supplied or confirmed, or is marked unknown.
3. **Replace `timestamp`.** Write a block-style `generated` mapping with `by` set to the actor and `at` set to the timestamp.
   - Already has `generated`: keep it. Delete `timestamp` only if it matches `generated.at`; otherwise leave both and report the conflict.
   - Unknown actor: leave `timestamp` in place and list the file in your report, whatever its format. `by` is required, and consumers still read the legacy field.
   - Date only: append `T00:00:00Z` and list the file in your report.
   - Datetime without an offset: ask the user for the offset.

   *Done when* every listed `timestamp` is replaced or reported.
4. **Replace `# Citations`.** Turn each item into a `sources` entry: the URL or path becomes `resource`, and any link text becomes `title`.
   - Already has `sources`: add to it, reusing any entry with the same `resource`.
   - Where the body cites an item, such as `[1]`, give the entry an `id`, change the citation to a `[^id]` footnote, and add its definition line.
   - Keep any other detail, such as a page number, in the footnote definition. If the body never cites that item, report the detail instead of dropping it.
   - If an item has no URL, path, or scope you can identify, ask the user and keep only that item until they answer.
   - Delete the section once it's empty.

   *Done when* every listed `# Citations` section is deleted, or kept and reported.
5. **Declare the version.** Set `okf_version: "0.2"` in the root `index.md` frontmatter, even if some constructs remain.
6. **Log it.** Add a dated `**Migration**` entry to the top of the root `log.md`, creating the file if needed, with the concept count and any constructs that remain.
7. **Check.** Run the conformance check in [SKILL.md](../SKILL.md).

Report the files migrated, assumed `T00:00:00Z` times, and every construct left in place with the reason.
