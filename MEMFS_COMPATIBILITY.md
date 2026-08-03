---
description: Dated correspondence between portable protocol features and Letta MemFS behavior and limits.
---

# MemFS correspondence

This correspondence was reviewed against Letta documentation and public source on 2026-08-03. Letta behavior can change; adapters must preflight current behavior. This project targets portable artifact and lifecycle compatibility, not runtime equivalence.

| Capability | Portable mapping | Explicit limitation / owner |
| --- | --- | --- |
| System memory | Compact `system/` files loaded by the bootstrap procedure | Placement does not inject or recompile a prompt; only a declared native adapter can do that |
| Progressive memory | `projects/`, `reference/`, `skills/`, `inbox/`, and attached repositories discovered by path, description, and links | Loading and link-aware tool use depend on the agent/host |
| Skills | Versioned `skills/<name>/SKILL.md` artifacts | Registration, invocation, precedence, permissions, and secrets are host-owned |
| Keyword search | Literal host search or committed-`HEAD` Git search | No semantic/vector index is intrinsic to MemFS |
| QMD search | Optional derived committed-snapshot index | QMD installation, models, index lifecycle, and CLI compatibility are adapter-owned |
| Conversation search | Separate, consent-gated adapter over a host session store | Not searched in the Markdown/QMD corpus and not durable ingestion by default |
| Git history | Commits, refs, branches, diffs, and ordinary conflict handling | A local commit is neither remote sync nor independent backup |
| Shared repositories | Credential-free descriptors for separate Git repositories | Not Letta shared memory blocks; access control and persistent attachment are adapter-owned |
| Dreaming | Bounded reflection procedure and proposal/worktree outputs | Scheduling, transcript cursor, model execution, and recompilation are adapter-owned |
| Doctor | Deterministic read-only audit and policy-gated repair workflow | No automatic repair or host health API is implied |
| Sync | Owner-approved Git fetch/push or verified Git bundle contracts | Cloud agent identity, triggers, retries, and directionality require an adapter |
| Adapters | Testable declaration of bootstrap and individual capabilities | No generic adapter can claim native runtime behavior without implementing and attesting it |

## Deliberate differences

- Portable durable authority is committed Markdown and Git history, not runtime blocks, recall/message stores, derived indexes, or cloud state.
- Shared Git repositories have independent histories and write policies. Letta shared blocks are always-in-context API objects with different identity and concurrency semantics.
- The 49,152-byte `system/` validation budget is this protocol's conservative bootstrap guard, not a Letta token or character limit.
- File changes become portable authority only after commit. They can affect future bootstrap or native recompilation, never an already-compiled turn.

## Non-goals

This protocol does not reproduce Letta prompt formatting/order, persistent agent identity, live block propagation, recall storage, cloud authorization, attachment APIs, background execution, or product-specific limits. It does not install QMD, Letta, models, hooks, schedulers, or services.

Current reference points: [MemFS](https://docs.letta.com/concepts/memfs), [memory and dreaming](https://docs.letta.com/configuration/memory/), [skills](https://docs.letta.com/configuration/skills), and [cloud repositories](https://docs.letta.com/agent-sdk/repositories/).
