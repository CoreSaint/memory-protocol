---
description: Project overview and adoption guide for the portable agent-memory protocol template.
---

# Memory Protocol

An inactive Git-backed Markdown template for portable, auditable agent memory. It implements the artifact and safe-lifecycle parts of Letta MemFS while keeping runtime behavior explicit. It is a **MemFS-compatible portable repository**, not a MemFS-equivalent runtime.

This repository is a template, not an installed store. Do not place personal, project, or secret data here. Installation copies an approved allowlist into an independent Git repository.

## Portable core

- Committed Markdown in `system/`, `projects/`, `reference/`, and `skills/` is canonical private-memory authority; committed inbox artifacts and protocol metadata remain non-canonical.
- Generic agents explicitly follow [AGENT_MEMORY.md](AGENT_MEMORY.md); directory placement alone never injects a prompt.
- `system/` is compact bootstrap context. Other managed roots are progressively discovered.
- Every managed Markdown file has strict description frontmatter.
- Literal committed-`HEAD` search is the baseline; QMD is an optional derived overlay.
- Conversation stores, schedules, cloud sync, native injection, and repository attachment require declared adapters.

Profiles and adapter overlays are defined in [CAPABILITIES.md](CAPABILITIES.md). Exact Letta correspondence and non-goals are in [MEMFS_COMPATIBILITY.md](MEMFS_COMPATIBILITY.md).

## Layout

```text
system/       compact context explicitly loaded by bootstrap or a declared native adapter
projects/     on-demand project indexes and project-specific memory
reference/    detailed on-demand knowledge
skills/       portable reusable procedures
inbox/        non-canonical proposals and temporary session notes
shared/       descriptors for independent shared Git repositories
attachments/  (under shared/) credential-free repository declarations
templates/    copyable managed-document templates
scripts/      optional structural validation and regression tests
```

Read [SEARCH.md](SEARCH.md), [WORKTREES.md](WORKTREES.md), and [SYNC.md](SYNC.md) for retrieval, isolated edits, and sync/backup distinctions. Shared Git repositories are not Letta shared memory blocks.

## Validation

```sh
scripts/test-validate-memory.sh
scripts/validate-memory.sh .
scripts/validate-memory.sh --profile template .
```

The optional validator is offline, deterministic, read-only with respect to the store, and profile-aware. It accepts a deliberately small YAML subset: plain descriptions begin with a letter, while descriptions beginning with other characters must be quoted. It scans the repository for Markdown and accepts it only in declared managed roots/root documents, ignoring exactly `.git/`, `.letta/`, and source-runtime `.pi-subagents/`. It requires Bash 4+, Git, `find`, GNU `sort` with `-z`, `awk`, `wc`, `mktemp`, and `rm`. The development regression script assumes GNU userland behavior for `sort -z`, `sed -i`, `dd status=none`, and `sha256sum`, and additionally uses `cp`, `grep`, `cmp`, `tr`, `xargs`, and `readlink`. Preflight these tools and fail without validation if they are unavailable.

The portable core itself needs only filesystem access and Git; scripts are optional except in the documented guided installation, which preflights and requires the validator. To install an independent store with a capable agent, use [INSTALL_PROMPT.md](INSTALL_PROMPT.md). Installation does not configure QMD, Letta, remotes, schedules, cloud services, or attachments.
