---
description: Three-depth initialization procedure for creating a project memory baseline in a copied memory store.
---

# Initialization protocol

`/init` is a host command or natural-language trigger; this document defines its portable behavior. It never installs this source repository in place.

## Required opening questions

Ask only facts that cannot be safely discovered:

1. Which depth: `quick`, `standard`, or `deep`?
2. Which write model: `propose_then_approve`, `auto_write_with_git`, `session_notes_only`, or `read_only`?
3. Is prior-session history available and approved for analysis?
4. Which repositories or project roots are in scope?

Persist the selected model in `system/memory-policy.md` only under the chosen policy. For `read_only`, report the required change rather than writing it.

## Quick scan

Read local agent instructions, README files, manifests, top-level layout, Git status, and recent commits. Create or propose only a compact project index with verified entry points and links. Do not infer architecture from filenames.

## Standard research

Perform quick scan work, then inspect key entry points, trace one important flow, read representative tests, and inspect CI/build configuration. Capture concrete commands, conventions, hard boundaries, and known footguns in focused files. Use shell search when available.

## Deep research

Perform standard work, then optionally analyze approved prior sessions, inspect history and major subsystems, and delegate independent subsystem exploration to subagents when available. Synthesize specific findings into linked reference files. Do not let subagents concurrently edit the same canonical file; collect their proposals first.

## Common completion checks

- Create a real-name project directory under `system/projects/`, never a generic `project/` directory.
- Keep `system/` as an index and durable rules; move detailed material to `reference/`.
- Add `double-bracket links` from overview files to deeper material.
- Validate the copied store with `scripts/validate-memory.sh <memory-root>` when available.
- Under approval policy, leave findings in `inbox/` and request promotion approval.
