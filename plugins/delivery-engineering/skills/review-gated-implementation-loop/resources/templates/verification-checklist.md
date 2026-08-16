---
type: Template
title: Claim verification checklist
description: Load to verify an owner's "done" or "green" claim before you trust it.
tags: [template, verification, campaign]
timestamp: 2026-08-15T00:00:00Z
---

# Claim verification checklist

Run this before you trust any "done" or "green" report. See
[dispatcher-orchestration](../dispatcher-orchestration.md).

```text
[ ] The check ran on the EXACT head that will merge (compare the sha).
[ ] Each required check passed, and it actually ran work (not zero tests, not excluded, not skipped).
[ ] The automated review posted a body dated after the last push (a "pass" can mean it reviewed nothing).
[ ] Every review thread is resolved (enumerated from the API, not a summary count).
[ ] The independent review ran under YOUR control, not only the owner's report of it.
[ ] The claimed fix is present in the code at the named lines (you read it).
[ ] Deferred items each have a tracked issue and an owner.
```

## Rule

A report is a claim. The code, the check log, and the API are the facts. When a
report and a fact disagree, the fact wins.
