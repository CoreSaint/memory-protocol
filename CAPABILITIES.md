---
description: Capability profiles and explicit host-overlay declarations for the portable memory protocol.
---

# Capability profiles

Profiles are additive descriptions, not promises that a host supplies every feature.

## Portable profiles

### `portable-core`

Requires only filesystem access and Git:

- Markdown with validated descriptions;
- explicit bootstrap through `AGENT_MEMORY.md`;
- committed Git history as durable authority;
- path/tree discovery and root-relative wiki links;
- literal keyword retrieval from committed `HEAD`.

### `portable-workflow`

Adds the optional Bash/GNU-userland validator, owner-approved Git remotes, and safe external Git worktrees. Remotes and worktrees are optional even when this profile is selected.

### `qmd-search`

Adds a derived semantic/hybrid QMD index over a committed snapshot containing exactly Markdown from `system/`, `projects/`, `reference/`, and `skills/`. The index is outside Git and never canonical. QMD absence or failure falls back to `portable-core` keyword retrieval.

## Native capability overlays

Runtime adapters may independently declare these capabilities:

- `system_prompt_injection`
- `conversation_keyword_search`
- `conversation_semantic_search`
- `conversation_hybrid_search`
- `conversation_scheduling`
- `cloud_sync`
- `repository_attachment`
- `worktree_automation`
- `qmd_search`

Injection, conversation stores, schedules, cloud identity/sync, and attachment APIs are runtime-owned. An adapter must mark each capability `supported`, `unsupported`, or `unavailable`; it must not imply support for a bundle merely because it is native or Letta-based. See [ADAPTERS.md](ADAPTERS.md).

## Capability boundaries

Directory placement alone does not inject a prompt, modify the current turn, create recall memory, synchronize cloud state, schedule reflection, register a skill, or attach a repository. Generic operation remains available under `portable-core`; optional failures must be reported rather than simulated.
