---
description: Pasteable prompt directing a capable AI agent to safely install an independent memory-protocol store.
---

# Installation prompt

Copy the prompt below in full into the chat of the agent that will perform the installation.

```text
You are installing a portable, global agent-memory store from the template repository:

https://github.com/CoreSaint/memory-protocol

This is an installation task, not a request to use the source checkout as live memory. Follow these rules exactly.

## First: ask me these questions in one message, then wait for my answers

Reproduce all six questions and every option below exactly as written, including each option's explanatory description. Do not summarize, paraphrase, abbreviate, or omit any text. Ask them together in one message, then wait for my answers. Make the option values stand out.

1. What absolute destination directory should contain the independent global memory store? This must be a dedicated directory, not a project checkout or your home directory.
2. If that destination already exists, which handling do you want? Never replace it silently.
   - stop — leave the existing destination unchanged and report it.
   - backup_then_replace — rename the existing memory store to a timestamped sibling, then install the new store.
3. Which write model should the store use?
   - propose_then_approve — agents draft memory changes in `inbox/proposals/` where practical; promotion requires explicit approval.
   - auto_write_with_git — agents may update canonical memory and commit focused Git changes.
   - session_notes_only — agents may record temporary notes only in `inbox/session-notes/`; they remain non-canonical even if committed.
   - read_only — agents may retrieve memory but must not modify it.
4. Which initialization depth should be used after the baseline is installed? This controls how much project research the agent performs; it does not change the selected memory write model.
   - quick — scan rules, README, manifests, Git state, and create a minimal project index.
   - standard — also trace key flows, tests, CI, conventions, and known footguns.
   - deep — also research history and subsystems; use approved session analysis or subagents when available.
5. Which project roots are initially in scope? This bounds what the agent may inspect. May it inspect prior agent-session history? (Default: no.)
6. Should host-specific activation be configured now?
   - no — install the store only; do not change Pi, Letta, or another host's startup/configuration.
   - yes — configure the approved host to load the store; explain the exact host change before applying it.

Do not ask questions whose answers can be safely discovered from the destination or selected project roots.

## After I answer: perform the installation

1. Obtain a clean local checkout of the specified template repository. If you cannot access it, stop and report the exact access problem. Do not place credentials, tokens, or private keys in the template or installed store.
2. Treat the checkout as source only. Never initialize it as the live store and never make it the destination.
3. Canonicalize the source, destination, and destination parent paths, resolving symlinks only for overlap checks. Reject the request if the lexical destination is a symlink, `/`, the current user's home directory, the source checkout, inside the source checkout, or an ancestor of the source checkout. Reject any staging/source/destination path overlap. If an existing destination does not contain `AGENT_MEMORY.md`, `system/memory-policy.md`, and a passing `scripts/validate-memory.sh`, stop rather than backing it up.
4. Use an isolated Git environment for every Git operation on both source and staging: do not inherit system/global/source-local configuration, hooks, signing commands, filters, or fsmonitor commands; explicitly disable hooks, signing, and fsmonitor. Verify that the source working tree has no changes or untracked files, then copy only its committed `HEAD` revision (for example, through `git archive HEAD`), never the source working tree. This prevents ignored, untracked, or modified local content entering the memory store.
5. Before creating staging, preflight Bash 4 or newer plus Git and the Unix tools required by `scripts/validate-memory.sh` (`find`, GNU `sort` with `-z`, `awk`, `wc`, `mktemp`, and `rm`). If any is unavailable or incompatible, stop before touching the destination or creating installation state and report the missing requirement. Build and validate the new store in a temporary sibling staging directory. Do not touch the requested destination while staging.
6. The block below is the authoritative installed-content allowlist. Copy every `copy-file` and complete `copy-tree` entry from committed source `HEAD`; create each `generate` entry exactly from its matching `BEGIN <path>`/`END <path>` block below. Copy nothing else.

BEGIN INSTALLATION MANIFEST
copy-file: .gitignore
copy-file: AGENT_MEMORY.md
copy-file: ADAPTERS.md
copy-file: CAPABILITIES.md
copy-file: DOCTOR.md
copy-file: DREAM.md
copy-file: HISTORY_INGEST.md
copy-file: INIT.md
copy-file: MEMFS_COMPATIBILITY.md
copy-file: SEARCH.md
copy-file: SYNC.md
copy-file: WORKTREES.md
copy-tree: system
copy-tree: projects
copy-tree: reference
copy-tree: skills
copy-tree: inbox
copy-tree: shared
copy-tree: templates
copy-file: scripts/validate-memory.sh
generate: README.md
generate: AGENTS.md
END INSTALLATION MANIFEST

Do not include `.git/`, `.letta/`, `.pi-subagents/`, `.memory-protocol-template`, `INSTALL_PROMPT.md`, the source `README.md` or `AGENTS.md`, or source-only `scripts/test-validate-memory.sh`. Create the staging `README.md` with exactly the text between `BEGIN README.md` and `END README.md`, without the marker lines or any leading presentation indentation:

BEGIN README.md
---
description: Root overview for an installed active agent-memory store.
---

# Agent memory store

This is an active, independent Git-backed memory store. Committed Markdown under `system/`, `projects/`, `reference/`, and `skills/` is canonical private-memory authority. Committed inbox artifacts and protocol metadata remain non-canonical.

Before work, follow the explicit bootstrap in [AGENT_MEMORY.md](AGENT_MEMORY.md), then read [system/overview.md](system/overview.md) and [system/memory-policy.md](system/memory-policy.md). Review [CAPABILITIES.md](CAPABILITIES.md), [SEARCH.md](SEARCH.md), and [SYNC.md](SYNC.md) before claiming optional runtime, retrieval, synchronization, or backup behavior. Do not add a remote or share this repository unless its owner explicitly approves it.
END README.md

   - create the staging `AGENTS.md` with exactly the text between `BEGIN AGENTS.md` and `END AGENTS.md`, without the marker lines or any leading presentation indentation:

BEGIN AGENTS.md
---
description: Repository-local agent instructions for an installed active memory store.
---

# Active memory-store instructions

Before any retrieval or change, follow the explicit bootstrap in [AGENT_MEMORY.md](AGENT_MEMORY.md). Treat [system/memory-policy.md](system/memory-policy.md) as the authority for whether and how memory can be written. Follow [CAPABILITIES.md](CAPABILITIES.md), [SEARCH.md](SEARCH.md), and [SYNC.md](SYNC.md) when reporting adapter, search, sync, or backup behavior.

Do not place secrets in this store. Do not configure remotes, global hooks, host adapters, QMD, schedules, or external integrations without explicit owner approval.
END AGENTS.md
7. Set `write_model` in `system/memory-policy.md` to the selected value. Do not ask again or silently change it during initialization.
8. Run `scripts/validate-memory.sh --profile installed <staging-directory>`. Fix only structural installation errors; do not invent user or project facts.
9. Initialize staging as an independent local Git repository and make one initial commit for the approved baseline. Supply an explicit per-command identity of `Memory Protocol Installer <noreply@localhost>` so this works without user Git configuration. If you cannot use the isolation required in step 4, stop and report the limitation.
10. Verify that staging has a clean working tree and no remote. Immediately recheck that the lexical destination is unchanged and still passes the path rules from step 3. Only then promote it: if the destination exists and I approved backup, move it to a timestamped sibling immediately before an atomic same-parent rename of staging into place. Do not recursively delete any destination during recovery; if promotion fails and the destination is absent, restore the backup, otherwise stop and report the conflict. Successful promotion completes the installation transaction; do not roll it back because later initialization or optional host activation fails. Instead stop and report that later failure.

## Initialization and activation

11. Run the selected depth from `INIT.md` against only the approved project scope. Reuse answers 3–5; ask no duplicate questions unless a required fact remains unknown. Do not inspect prior session history unless I approved it. Under `read_only`, inspect and report only; under `session_notes_only`, write only bounded non-canonical notes under `inbox/session-notes/` and do not create canonical project memory.
12. Configure a host adapter only if I explicitly chose activation in answer 6. For a generic host, make its startup instruction read `<destination>/AGENT_MEMORY.md` before work. For Letta, inspect and back up existing MemFS before adapting anything; never blindly overwrite `$MEMORY_DIR`. Installation alone does not configure QMD, conversation access, schedules, cloud sync, or repository attachments.

## Report

Report the destination, selected write model and init depth, whether an existing store was backed up, files created, installed-profile validation result, initial commit ID, Git-remote status, and whether host activation was performed. If activated, name each adapter capability actually configured and its bootstrap method; report unavailable features explicitly. Do not claim that installation is prompt injection, cloud sync, QMD setup, scheduling, attachment, backup, or that proposals/session notes are canonical memory.
```
