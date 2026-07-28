---
description: Universal bootstrap and operating contract for agents using a memory-protocol repository.
---

# Universal agent-memory contract

## Bootstrap: do this before work

1. Locate the memory root supplied by the host, user, or project adapter.
2. Read `system/overview.md`, then every file it explicitly identifies as always-read.
3. Read `system/memory-policy.md` and apply its selected write model.
4. Read relevant project-local instructions before using memory to change that project.
5. Identify the relevant project from the task or working directory, then load its `projects/<project-name>/overview.md` when it exists.
6. Discover detailed knowledge through paths, descriptions, and `double-bracket links`; do not bulk-load `projects/` or `reference/`.
7. Check `git status --short` before proposing or making memory edits.

If the memory root, required bootstrap files, or policy are missing, say so and operate without pretending that memory was loaded. Do not create a new live store unless the user explicitly requests initialization.

## Retrieval rules

- Treat committed memory as guidance, not proof of live external state. Verify mutable facts when the task requires it.
- Prefer the narrowest relevant file. Follow `double-bracket path links` deliberately.
- Distinguish source facts, user decisions, inferred conclusions, and proposals.
- Never surface secrets from memory; redact operational values in notes and proposals.

## Memory-write rules

The active model in `system/memory-policy.md` controls writes:

- `propose_then_approve`: write a focused proposal under `inbox/`; request explicit promotion approval.
- `auto_write_with_git`: update the appropriate canonical file, validate, and create a focused Git commit.
- `session_notes_only`: create or update a session note outside `system/`; do not promote it automatically.
- `read_only`: do not create, edit, stage, or commit memory.

In every model, memory changes must be small, attributable, non-secret, and placed by scope. Put compact, repeatedly needed rules in `system/`; put detailed evidence and architecture in `reference/`; put reusable procedures in `skills/`.

## Completion report

When memory changed, report the policy applied, files proposed or changed, validation performed, and whether the result is committed. Never report a proposal as durable memory.
