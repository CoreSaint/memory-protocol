---
description: Always-read policy selecting the permitted memory-write workflow.
---

# Memory write policy

```memory-policy
write_model: propose_then_approve
```

Allowed values:

- `propose_then_approve` — use `inbox/proposals/` where practical and wait for explicit approval before promotion.
- `auto_write_with_git` — edit canonical memory, validate, and commit focused changes.
- `session_notes_only` — record temporary notes only under `inbox/session-notes/`; notes remain non-canonical even when committed.
- `read_only` — retrieve only; do not modify memory.

Change this selection only through an explicit owner decision and the transition procedure in [INIT.md](../INIT.md). The prior model remains active until a focused, validated policy-only commit succeeds. A policy change does not retroactively reclassify existing commits, proposals, or session notes.
