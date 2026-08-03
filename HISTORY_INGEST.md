---
description: Consent-gated separation between ephemeral conversation retrieval and durable history ingestion.
---

# History ingestion

Conversation search and durable memory search are separate. A host-owned session/message store is not part of the Markdown or QMD corpus.

## Ephemeral conversation retrieval

Before access, obtain explicit approval and record the provider/source, date or message range, purpose, and maximum scope. Use only declared `conversation_keyword_search`, `conversation_semantic_search`, or `conversation_hybrid_search` capabilities. If unavailable, report that state; do not search unrelated repository files as a substitute.

Search results remain ephemeral evidence. Searching never authorizes saving, indexing into memory QMD, or copying raw transcripts. Retain provider source pointers or hashes where available.

## Durable ingestion

A separate approved ingestion operation may extract durable preferences, repeated corrections, verified project facts, or proven workflows. Bound the same source/range, minimize quotations, and never copy raw transcript bulk into canonical memory by default. Treat history as evidence rather than automatic truth.

Route each extracted lesson through `system/memory-policy.md`. Record the operation, target, source kind/pointer, observed range, scope, confidence, deduplication key, and approval state in a proposal. Under approval policy it remains non-canonical until explicitly promoted.
