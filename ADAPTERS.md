---
description: Integration guidance for making the portable protocol available to different agent hosts without changing memory authority.
---

# Host adapters

An adapter exposes this protocol to a host; it does not become a second memory authority. It must point the host at one explicit memory root and preserve Git-backed Markdown as canonical state.

## Minimum adapter

A minimal adapter supplies the memory-root path and a startup instruction equivalent to:

> Read `<memory-root>/AGENT_MEMORY.md`, then complete its bootstrap procedure before work.

Filesystem and Git access are sufficient. If those are unavailable, the adapter must state that durable memory cannot be used rather than simulating it.

## Optional capabilities

| Capability | Portable behavior |
| --- | --- |
| System-prompt injection | Inject only the compact `system/` tree; still retain bootstrap checks and Git authority. |
| Shell/search | Use for `INIT.md` standard/deep research and validation; never make them a prerequisite for quick scan. |
| Subagents | Partition research or reflection by independent scope; collect proposals before canonical edits. |
| Schedules | Invoke `DREAM.md` only with a user-approved cadence and consented session scope. |
| Session stores | Follow `HISTORY_INGEST.md`; require explicit consent before reading them. |
| Worktrees | Isolate concurrent doctor/reflection edits, then combine reviewed changes. |

## Native hosts

A Letta adapter may map the root to MemFS and map `system/` to native always-on memory. Other hosts may point their native instruction file or launcher at `AGENT_MEMORY.md`. These integrations are conveniences only: no adapter may silently change `system/memory-policy.md` or write outside its selected model.
