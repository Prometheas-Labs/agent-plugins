---
type: Metric
title: Monthly Recurring Revenue
description: Active subscription revenue normalized to one month.
tags: [revenue, subscriptions]
status: stable
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-06-20T14:00:00Z
verified:
  - by: human:jsmith
    at: 2026-06-25T09:00:00Z
stale_after: 2027-01-01T00:00:00Z
sources:
  - id: finance-handbook
    resource: https://example.com/finance/handbook
    title: Finance reporting handbook
    author: human:jsmith
    last_modified: 2026-06-01T00:00:00Z
---

# Definition

MRR is the sum of active subscription values, normalized to one month. It excludes one-time fees and overages.[^finance-handbook]

[Logo Churn](/metrics/churn.md) counts lost customers and doesn't weight them by their share of MRR.

[^finance-handbook]: Finance reporting handbook
