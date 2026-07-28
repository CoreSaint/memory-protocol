---
description: Always-read policy selecting the permitted memory-write workflow.
---

# Memory write policy

```yaml
write_model: propose_then_approve
```

Allowed values:

- `propose_then_approve` — use `inbox/` and wait for explicit approval before promotion.
- `auto_write_with_git` — edit canonical memory, validate, and commit focused changes.
- `session_notes_only` — record temporary notes without canonical promotion.
- `read_only` — retrieve only; do not modify memory.

Change this selection only through an explicit user decision. A policy change affects future writes; it does not retroactively reclassify existing commits or proposals.
