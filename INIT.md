---
description: Capability-aware three-depth initialization procedure for a copied memory store.
---

# Initialization protocol

`/init` is a host trigger or natural-language request. It operates on an installed copy, never this source template, and installs no dependencies.

## Opening decisions

Ask only unknown facts that cannot be discovered safely:

1. depth: `quick`, `standard`, or `deep`;
2. write model: `propose_then_approve`, `auto_write_with_git`, `session_notes_only`, or `read_only`;
3. whether prior-session history is available and explicitly approved, including bounds;
4. repositories/project roots in scope.

Reuse approved installation answers. The currently committed model remains effective throughout initialization unless the owner explicitly decides to change it and authorizes the transition below.

## Write-model transition

An explicit owner decision selecting a different model authorizes exactly one focused transition: edit only `system/memory-policy.md`, validate the store, and commit that policy-only change. The new model applies only after that commit succeeds. Do not bundle initialization findings, proposals, session notes, or canonical edits into the transition commit. If there is no explicit decision, validation fails, or the commit cannot be created, retain the old policy unchanged.

This narrow authorization is also the only safe way to leave `read_only`: until the policy-only commit succeeds, perform no other memory write. When entering `read_only`, finish no unrelated write in the same commit; once the policy-only commit succeeds, stop all memory creation, editing, staging, and committing. During guided installation, the approved installation answer is applied before the initial baseline commit as specified by [INSTALL_PROMPT.md](INSTALL_PROMPT.md), so it is not a later live-store transition.

## Capability detection

After scope and policy are known, detect filesystem/Git and report `portable-core`. Without installing or configuring anything, preflight optional validator, remote/worktree support, QMD provider, conversation provider/modes, scheduler, cloud sync, injection, and repository attachments. Select the strongest safe additive profile actually available and declare every overlay per [ADAPTERS.md](ADAPTERS.md). Missing capabilities degrade explicitly; they never simulate success or alter the write model.

## Research depths

- **Quick:** read local instructions, README/manifests, top-level layout, Git status, and recent commits. Create/propose only a compact verified project index.
- **Standard:** also inspect key entry points, trace one important flow, representative tests, and CI/build configuration. Capture concrete commands and boundaries.
- **Deep:** also inspect approved history and major subsystems; optional subagents may explore independent scopes. Collect proposals before any shared canonical edit.

History is never accessed without explicit consent. QMD, schedules, remotes, native activation, and attachments are never installed/configured merely because they are detectable.

## Completion

Use a real project directory under `projects/`. Keep global compact rules in `system/` and detail in progressive roots. Add root-relative wiki links. Follow the write policy, validate with `scripts/validate-memory.sh --profile installed <root>` when available, and report active profiles, capability statuses/fallbacks, files/proposals, validation, and commit/sync/backup states separately.
