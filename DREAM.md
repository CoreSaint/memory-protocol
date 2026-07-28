---
description: Optional bounded reflection procedure for consolidating recent agent work into memory proposals.
---

# Reflection protocol

Reflection is optional. A host may schedule it, but this repository does not create schedules or invoke itself.

## Inputs and boundaries

- Use only approved recent conversation or session material.
- Extract durable preferences, repeated correction loops, proven commands, project boundaries, and reusable procedures.
- Do not promote transient task status, unsupported assumptions, secrets, or copied conversation bulk.

## Output

Create focused proposals under `inbox/` with source pointers and a rationale for durability. Follow `system/memory-policy.md` for any promotion. For concurrent workers, use separate Git worktrees if supported, then review and combine unique findings before canonical writes.
