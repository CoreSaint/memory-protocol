---
description: Safe local installation guide for creating an independent global memory store from this template.
---

# Install a global memory store

This repository is a template. Install a **copy** into a dedicated location; never use the checkout itself as active memory.

The installer is intentionally conservative:

- requires an explicit destination whose parent already exists;
- refuses an existing destination unless `--backup-existing` is selected;
- copies only committed source content; ignored and untracked files never enter the store;
- initializes an independent local Git repository with no remote;
- validates the installed memory tree before it becomes active;
- does not configure an agent host, inspect history, create schedules, or access a network.
- isolates Git configuration and disables hooks/signing during the initial commit.

## Prerequisites

- Bash, Git, Python 3, `tar`, `find`, `grep`, `sed`, `awk`, `mktemp`, and standard file utilities.
- A local checkout of this repository. Clone it using the access method appropriate for the private repository; do not place credentials in this repository or in command history.

## Install

Choose a destination that is separate from project repositories. For example:

```sh
git clone https://github.com/CoreSaint/memory-protocol.git ~/src/memory-protocol
mkdir -p ~/.local/share
~/src/memory-protocol/scripts/install.sh \
  --destination ~/.local/share/agent-memory \
  --write-model propose_then_approve
```

Supported write models:

- `propose_then_approve` — default; lessons enter `inbox/` until explicit promotion approval.
- `auto_write_with_git` — agents may write canonical memory and create focused commits.
- `session_notes_only` — agents record non-canonical session notes only.
- `read_only` — agents retrieve memory but never change it.

If the chosen destination already exists and you have reviewed it, request an explicit backup rather than overwriting it:

```sh
scripts/install.sh --destination ~/.local/share/agent-memory --backup-existing
```

## After installation

1. Review `<destination>/system/memory-policy.md`.
2. Direct a dedicated agent to read `<destination>/AGENT_MEMORY.md` before any work.
3. Ask that agent to run the selected-depth `INIT.md` process. It must retain the already selected write model and ask before reading prior-session history. With `read_only`, it can only inspect and report; with `session_notes_only`, it cannot create canonical project memory.
4. Configure a **host-specific adapter** only after this baseline is working. See [ADAPTERS.md](ADAPTERS.md).

For a generic installation agent, provide this instruction:

> Use `<destination>` as the independent global memory store. Read `AGENT_MEMORY.md` and follow its bootstrap rules before work. Retain the selected `system/memory-policy.md`; do not re-run installation, configure remotes, create global hooks, or inspect history without my approval.

## Letta-specific caution

Letta has its own agent MemFS. Do not copy files into `$MEMORY_DIR` blindly. Ask the Letta agent to inspect and back up its existing memory first, then adapt the template according to Letta's native memory model. The generic installed store can also remain an external source of policy and reference material.
