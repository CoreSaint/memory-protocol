---
description: Stable severity-based template for a read-only memory doctor audit report.
---

# Memory doctor report

- Profile: `portable-core` or `portable-workflow`
- Root: `<reported without credentials>`
- Audited commit: `<object id>`
- Parent status: clean | dirty
- External checks approved: yes | no

## Findings

- `error` — `<path>: <check> — <evidence and required repair>`
- `warning` — `<path>: <check> — <evidence and review action>`
- `info` — `<path>: <check> — <bounded observation>`

## Unchecked or unavailable

List every external, attachment, provenance, or reachability item that was not verified. Unavailable evidence is not evidence of absence.

## Repair proposal

No repair occurs during the audit. List separately authorized targets, base commit, validation, and worktree/manual-resolution status.
