---
description: Universal bootstrap and operating contract for agents using a memory-protocol repository.
---

# Universal agent-memory contract

## Bootstrap before work

1. Locate the memory root supplied by the host, user, or project adapter.
2. Read `system/overview.md`, then every file it explicitly identifies as always-read.
3. Read `system/memory-policy.md` and apply its selected write model.
4. Read relevant project-local instructions before changing that project.
5. Identify the project, then load `projects/<project-name>/overview.md` when it exists.
6. Discover canonical `projects/`, `reference/`, and `skills/` progressively through paths, descriptions, and explicit links. Inspect non-canonical `inbox/` artifacts or attached repositories only as separately labeled sources.
7. Check `git status --short` before proposing or making memory edits.

Directory placement alone has no runtime effect. Generic agents must execute this procedure; only a declared native adapter may attest that it injected `system/`. If the root, bootstrap files, or policy are missing, report that and do not pretend memory loaded. Never create a live store without an explicit initialization request.

## Retrieval

- Treat committed memory as guidance, not proof of mutable external state.
- Follow [SEARCH.md](SEARCH.md): canonical private search covers only committed Markdown in `system/`, `projects/`, `reference/`, and `skills/`. Report proposals, session notes, shared repositories, and working changes as separate result sets.
- QMD semantic/hybrid retrieval is optional derived output and must identify its indexed commit. Its failure never blocks keyword retrieval.
- Conversation search is a separate consent-gated adapter capability. It never searches or saves host history by default.
- Never surface secrets; redact operational values in notes and proposals.

## Authority and writes

An edit under the four-root canonical private corpus becomes portable durable memory authority only after commit. Committed protocol documents, descriptors, proposals, and session notes remain their labeled artifact types rather than canonical private memory. A canonical commit can affect a future bootstrap or native recompilation, never an already-compiled current turn.

The active `write_model` controls writes:

- `propose_then_approve`: create a focused proposal under `inbox/proposals/` when practical; accept legacy direct-`inbox/` proposal placement without reclassifying it. Await explicit promotion approval.
- `auto_write_with_git`: update canonical files, validate, and create a focused commit.
- `session_notes_only`: write temporary notes only under `inbox/session-notes/`; they stay non-canonical even if committed and require later explicit proposal/promotion authorization to become canonical.
- `read_only`: do not create, edit, stage, or commit memory.

Changes must be scoped, attributable, and non-secret. Keep repeatedly needed rules compact in `system/`; place project context and detailed evidence in progressive roots.

## Shared repositories

Descriptors under `shared/attachments/` identify separate Git repositories. Their checkouts remain outside this memory root, retain independent history/write policy, and are progressive by default. Descriptor `access` is only an upper bound. Private-store `auto_write_with_git` never authorizes attachment writes; the attachment repository's own policy or owner must separately authorize them, defaulting to read-only when that authority is absent. Report resolved commits, staleness, and availability. A descriptor does not perform network attachment or grant access.

## Completion report

When memory changed, report the policy, files, validation, commit status, and—separately—remote sync and backup status. Never report a proposal, uncommitted edit, local commit, push, backup, or cloud synchronization as another of those states.
