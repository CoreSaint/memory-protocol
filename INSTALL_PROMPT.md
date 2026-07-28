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

Ask all six sections below in one response, then wait for my complete answers before making filesystem, Git, configuration, or network changes.

=== 1. DESTINATION ===
What absolute destination directory should contain the independent global memory store?
It must be a dedicated directory, not a project checkout or your home directory.

=== 2. EXISTING DESTINATION — CHOOSE ONE ===
[STOP] Replace nothing. Leave the existing destination unchanged and report it.
[BACKUP_THEN_REPLACE] Rename the existing memory store to a timestamped sibling, then install the new store.

=== 3. WRITE MODEL — CHOOSE ONE ===
[PROPOSE_THEN_APPROVE] Agents draft memory changes in `inbox/`; promotion requires explicit approval.
[AUTO_WRITE_WITH_GIT] Agents may update canonical memory and commit focused Git changes.
[SESSION_NOTES_ONLY] Agents may record temporary notes, but do not promote canonical memory.
[READ_ONLY] Agents may retrieve memory but must not modify it.

=== 4. INITIALIZATION DEPTH — CHOOSE ONE ===
This controls how much project research the agent performs; it does not change the selected memory write model.
[QUICK] Scan rules, README, manifests, Git state, and create a minimal project index.
[STANDARD] Also trace key flows, tests, CI, conventions, and known footguns.
[DEEP] Also research history and subsystems; use approved session analysis or subagents when available.

=== 5. PROJECT AND HISTORY SCOPE ===
Which project roots are initially in scope? This bounds what the agent may inspect.
May it inspect prior agent-session history? Default: no.

=== 6. HOST ACTIVATION — CHOOSE ONE ===
[NO] Install the store only; do not change Pi, Letta, or another host's startup/configuration.
[YES] Configure the approved host to load the store; explain the exact host change before applying it.

Do not ask questions whose answers can be safely discovered from the destination or selected project roots.

## After I answer: perform the installation

1. Obtain a clean local checkout of the specified template repository. If you cannot access it, stop and report the exact access problem. Do not place credentials, tokens, or private keys in the template or installed store.
2. Treat the checkout as source only. Never initialize it as the live store and never make it the destination.
3. Canonicalize the source, destination, and destination parent paths, resolving symlinks only for overlap checks. Reject the request if the lexical destination is a symlink, `/`, the current user's home directory, the source checkout, inside the source checkout, or an ancestor of the source checkout. Reject any staging/source/destination path overlap. If an existing destination does not contain `AGENT_MEMORY.md`, `system/memory-policy.md`, and a passing `scripts/validate-memory.sh`, stop rather than backing it up.
4. Use an isolated Git environment for every Git operation on both source and staging: do not inherit system/global/source-local configuration, hooks, signing commands, filters, or fsmonitor commands; explicitly disable hooks, signing, and fsmonitor. Verify that the source working tree has no changes or untracked files, then copy only its committed `HEAD` revision (for example, through `git archive HEAD`), never the source working tree. This prevents ignored, untracked, or modified local content entering the memory store.
5. Build and validate the new store in a temporary sibling staging directory. Do not touch the requested destination while staging.
6. Copy the memory-template content into staging, excluding source-only and machine-local material:
   - exclude `.git/`, `.letta/`, `INSTALL_PROMPT.md`, this source `README.md`, and this source `AGENTS.md`;
   - include `.gitignore`, `AGENT_MEMORY.md`, `ADAPTERS.md`, `DOCTOR.md`, `DREAM.md`, `HISTORY_INGEST.md`, `INIT.md`, `system/`, `reference/`, `skills/`, `inbox/`, `shared/`, `templates/`, and `scripts/validate-memory.sh`;
   - create the staging `README.md` with exactly the text between `BEGIN README.md` and `END README.md`, without the marker lines or any leading presentation indentation:

BEGIN README.md
---
description: Root overview for an installed active agent-memory store.
---

# Agent memory store

This is an active, independent Git-backed memory store. Its committed Markdown is durable authority.

Before work, read [AGENT_MEMORY.md](AGENT_MEMORY.md), then [system/overview.md](system/overview.md) and [system/memory-policy.md](system/memory-policy.md). Do not add a remote or share this repository unless its owner explicitly approves it.
END README.md

   - create the staging `AGENTS.md` with exactly the text between `BEGIN AGENTS.md` and `END AGENTS.md`, without the marker lines or any leading presentation indentation:

BEGIN AGENTS.md
---
description: Repository-local agent instructions for an installed active memory store.
---

# Active memory-store instructions

Before any retrieval or change, follow [AGENT_MEMORY.md](AGENT_MEMORY.md). Treat [system/memory-policy.md](system/memory-policy.md) as the authority for whether and how memory can be written.

Do not place secrets in this store. Do not configure remotes, global hooks, host adapters, schedules, or external integrations without explicit owner approval.
END AGENTS.md
7. Set `write_model` in `system/memory-policy.md` to the selected value. Do not ask again or silently change it during initialization.
8. Run `scripts/validate-memory.sh <staging-directory>`. Fix only structural installation errors; do not invent user or project facts.
9. Initialize staging as an independent local Git repository and make one initial commit for the approved baseline. Supply an explicit per-command identity of `Memory Protocol Installer <noreply@localhost>` so this works without user Git configuration. If you cannot use the isolation required in step 4, stop and report the limitation.
10. Verify that staging has a clean working tree and no remote. Immediately recheck that the lexical destination is unchanged and still passes the path rules from step 3. Only then promote it: if the destination exists and I approved backup, move it to a timestamped sibling immediately before an atomic same-parent rename of staging into place. Do not recursively delete any destination during recovery; if promotion fails and the destination is absent, restore the backup, otherwise stop and report the conflict. Successful promotion completes the installation transaction; do not roll it back because later initialization or optional host activation fails. Instead stop and report that later failure.

## Initialization and activation

11. Run the selected depth from `INIT.md` against only the approved project scope. Reuse answers 3–5; ask no duplicate questions unless a required fact remains unknown. Do not inspect prior session history unless I approved it. Under `read_only`, inspect and report only; under `session_notes_only`, do not create canonical project memory.
12. Configure a host adapter only if I explicitly chose activation in answer 6. For a generic host, make its startup instruction read `<destination>/AGENT_MEMORY.md` before work. For Letta, inspect and back up existing MemFS before adapting anything; never blindly overwrite `$MEMORY_DIR`.

## Report

Report the destination, selected write model and init depth, whether an existing store was backed up, files created, validation result, initial commit ID, Git-remote status, and whether host activation was performed. Do not claim that proposals or session notes are canonical memory.
```
