---
description: Canonical keyword-first memory retrieval and separate labeled searches for non-canonical or external sources.
---

# Search contract

## Canonical private-memory corpus

The canonical private corpus is committed Markdown under exactly `system/`, `projects/`, `reference/`, and `skills/`. It excludes `inbox/`, `templates/`, root protocol documents, `shared/` descriptors, working-tree changes, and every attached repository. Those excluded artifacts can be durable Git records, but they are not canonical private-memory results.

Search the canonical corpus in this order:

1. discover likely files from paths, frontmatter descriptions, and explicit links within those four roots;
2. run literal keyword search against committed `HEAD`;
3. optionally query a semantic index;
4. optionally query a hybrid index.

A dependency-free Git form is:

```sh
git -C "$MEMORY_ROOT" grep -n -i -F -e "$QUERY" HEAD -- \
  ':(glob)system/**/*.md' ':(glob)projects/**/*.md' \
  ':(glob)reference/**/*.md' ':(glob)skills/**/*.md'
```

Use argument-safe tool invocation when possible. Treat `QUERY` as data, not shell code. Label results `canonical private memory` and include the searched commit. Do not silently mix excluded or working-tree material into those results.

## Separate repository searches

Search other sources only when relevant and report each result set separately:

- label committed `inbox/proposals/**/*.md` results `committed proposals (non-canonical)`; legacy stores may keep proposal files directly under `inbox/`, which must be identified and labeled the same way;
- label committed `inbox/session-notes/**/*.md` results `committed session notes (non-canonical)`;
- label working-tree results `uncommitted memory-store changes` and identify their base commit;
- search an attached shared repository only through its separately authorized checkout and policy, then label results `shared repository <attachment-id>` with its resolved commit and stale/availability state. Searching `shared/attachments/` descriptors is protocol-metadata search, not a search of the shared repository.

Never combine these result sets under a generic `committed memory` label.

## Optional QMD overlay

A QMD adapter must:

- preflight the installed CLI and supported commands without installing or upgrading it;
- keep indexes, caches, models, and configuration outside the managed repository;
- index a committed snapshot containing exactly Markdown from `system/`, `projects/`, `reference/`, and `skills/`, excluding every other path;
- identify the indexed commit and refresh after relevant canonical commits;
- label semantic/hybrid output as a derived canonical-private-corpus result;
- use separate indexes and labels for proposals, session notes, or authorized shared repositories if it supports those searches at all;
- degrade to literal committed-`HEAD` canonical search when unavailable, stale, or failing.

Baseline initialization and validation never invoke QMD. The adapter owns CLI-version details and must not imply that vector search is intrinsic to MemFS.

## Conversation search is separate

Conversation search operates only over a declared host-owned session/message store. It uses distinct capabilities: `conversation_keyword_search`, `conversation_semantic_search`, and `conversation_hybrid_search`. Before access, obtain explicit approval and bound the source, date/message range, and purpose. Include source pointers or hashes when the provider exposes them.

Conversation output is ephemeral evidence. Searching does not save it, add it to QMD, or authorize transcript ingestion. Durable lessons follow [HISTORY_INGEST.md](HISTORY_INGEST.md) and the active write policy. Raw transcripts are not copied into canonical memory by default.

If no approved conversation provider or capability exists, report conversation search as unavailable. Never substitute repository files or durable-memory search and claim that conversation history was searched.
