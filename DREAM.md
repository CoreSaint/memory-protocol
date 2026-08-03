---
description: Optional bounded reflection procedure for producing auditable memory proposals or edits.
---

# Reflection protocol

Dreaming/reflection is optional. This repository does not schedule runs, access transcripts, execute models, or recompile prompts; those capabilities remain adapter-owned.

## Approved boundary

Before retrieval, record approved source kinds and providers, date/message range, purpose, maximum item count, and operation scope. Never expand the range or access conversation history without explicit approval. A scheduler's transcript cursor/watermark is runtime state outside canonical memory.

Extract only durable preferences, repeated correction loops, proven commands, project boundaries, and reusable procedures. Exclude transient status, unsupported assumptions, secrets, and copied conversation bulk.

## Output and provenance

Follow the active write policy. Normally create focused proposals under `inbox/proposals/` using [templates/proposal.md](templates/proposal.md). Each item records operation, target, source kind, source pointer, observed range, scope, confidence, deduplication key, and approval state. Raw transcripts do not enter canonical memory by default.

For isolated mutation, follow [WORKTREES.md](WORKTREES.md): record the base and clean parent, use a unique external worktree, validate, commit one focused result, and fast-forward only if the parent remains clean and unchanged. Preserve conflicts or advanced-parent work for manual review; never force cleanup.
