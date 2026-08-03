---
description: Testable host-adapter declaration and runtime responsibility contract.
---

# Host adapters

An adapter exposes one explicit memory root while preserving committed Markdown in `system/`, `projects/`, `reference/`, and `skills/` as the canonical private-memory corpus. A minimum generic adapter supplies the root and directs the agent to read `AGENT_MEMORY.md`; it cannot claim prompt injection.

## Required declaration

An adapter must report, in inspectable text or machine-readable configuration:

- resolved memory root;
- active portable profile: `portable-core`, optional `portable-workflow`, and optional `qmd-search`;
- every capability overlay as `supported`, `unsupported`, or `unavailable`;
- bootstrap method and attestation (`explicit_read` or a named native injection implementation);
- durable-memory search providers and indexed commit when applicable;
- conversation provider and independently supported keyword/semantic/hybrid modes;
- attachment mechanism;
- safe-worktree support;
- sync/backup mechanism;
- unavailable features and fallback behavior.

A declaration is testable only when a reviewer can compare each claim with configuration/preflight output without exercising unrelated services. Host activation must not silently change `system/memory-policy.md`.

## Runtime-owned responsibilities

Adapters, not the repository format, own:

- injection ordering/limits and post-commit recompilation timing;
- QMD CLI preflight, exact four-root canonical-corpus snapshot indexing, refresh, and external index storage;
- conversation authorization, bounded queries, provider identity, and source pointers;
- schedule triggers, transcript cursors/watermarks, and model execution;
- cloud identity, authentication, retries, directionality, offline behavior, and conflict recovery;
- attachment APIs, checkout location, credentials, access control, and resolved-commit reporting;
- remote configuration and sync reporting.

Derived indexes, caches, transcript cursors, schedules, and cloud/runtime state may live outside the repository but never become canonical memory.

## Failure behavior

When a capability is absent, denied, stale, offline, or fails preflight, report it as unavailable and use only an explicitly documented fallback. Do not simulate injection, QMD results, conversation access, attachment, sync, or scheduling success. Filesystem and Git alone satisfy `portable-core`; if they are unavailable, durable memory is unavailable.

A Letta adapter may implement native overlays, but must declare them individually. Being a Letta host does not itself prove prompt injection, cloud sync, session search, dreaming, or repository attachment.
