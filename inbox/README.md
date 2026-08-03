---
description: Non-canonical storage contract for proposals and temporary session notes.
---

# Memory inbox

Everything under `inbox/` is non-canonical, including committed files.

## Proposals

Under `propose_then_approve`, create one focused proposal per durable lesson under `inbox/proposals/` where practical, using [templates/proposal.md](../templates/proposal.md). Existing stores may retain legacy proposal files directly under `inbox/`; do not move them merely to satisfy the preferred layout, and continue to label them non-canonical proposals.

Proposal frontmatter contains only `description`. Record operational state in the body: operation, target, source kind, source pointer/hash, observed range, scope, confidence, deduplication key, and approval state. State the rationale and exact proposed text. Keep raw transcripts and secrets out.

Pending or rejected proposals are not bootstrap context or canonical memory. Promotion requires explicit approval and the selected write-policy lifecycle; update the body approval state without representing that alone as promotion.

## Session notes

Under `session_notes_only`, store notes only at `inbox/session-notes/<date-or-session-id>.md`, using [templates/session-note.md](../templates/session-note.md). Each note must have normal description frontmatter and identify its bounded session/source, date, and temporary purpose. Minimize content, exclude raw transcript bulk and secrets, and close or supersede stale notes explicitly rather than silently treating them as current truth.

Session notes are always non-canonical, even when committed. A later durable lesson must be deduplicated, converted into a proposal or separately approved canonical edit under the then-active policy, validated, and committed. Promotion never happens automatically; retention or deletion follows explicit owner policy, and absence of such policy means retain without canonical use.
