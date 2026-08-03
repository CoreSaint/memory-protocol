---
name: memory-search
description: Keyword-first canonical private-memory retrieval with optional QMD semantic and hybrid fallback.
---

# Memory search

## When to use

Use when durable private memory must be located without bulk-loading the repository.

## Procedure

1. Resolve the declared memory root and read its bootstrap/policy.
2. Limit canonical discovery to Markdown under exactly `system/`, `projects/`, `reference/`, and `skills/`.
3. Identify `HEAD`, then run literal search with a host tool or:

   ```sh
   git -C "$MEMORY_ROOT" grep -n -i -F -e "$QUERY" HEAD -- \
     ':(glob)system/**/*.md' ':(glob)projects/**/*.md' \
     ':(glob)reference/**/*.md' ':(glob)skills/**/*.md'
   ```

4. Label output `canonical private memory` with the searched commit. Never include `inbox/`, `templates/`, root protocol documents, shared descriptors, attachments, or working changes in that result set.
5. When useful, search and separately label committed proposals under `inbox/proposals/` (including identified legacy direct-inbox proposals), session notes under `inbox/session-notes/`, and uncommitted memory-store changes.
6. Search an authorized attachment checkout separately under its repository policy; label its attachment ID, resolved commit, and staleness. Descriptor matches are metadata, not shared-repository content.
7. If a declared QMD adapter is available and literal results are insufficient, preflight it and request semantic, then hybrid retrieval over a committed snapshot containing exactly the same four-root canonical corpus. Label the provider/indexed commit.
8. If QMD is absent, stale, or fails, report that and return to literal search. Do not install it or treat its failure as memory-search failure. Separate proposal, session-note, or attachment QMD indexes must never be merged into canonical output.

Conversation history is outside this skill's corpus. Use a separately approved conversation provider and [SEARCH.md](../../SEARCH.md).
