---
description: Contract distinguishing working changes, commits, synchronization, and independent backup.
---

# Sync and backup contract

These states are distinct:

1. **working-tree change** — local, uncommitted, and not durable authority;
2. **locally committed** — durable local Git history;
3. **synchronized** — an approved upstream ref has been updated or integrated;
4. **independently backed up** — a verified off-repository copy can recover the commit.

A local commit is not a push, cloud synchronization, or off-machine backup. Core operation requires no remote.

## Remotes and backup

Remotes are optional, credential-free in repository content, and owner-approved. Never create or reconfigure one automatically. Ordinary Git remotes and verified Git bundles are portable mechanisms; report what commit/ref was included and how verification was performed. Authentication belongs to the operator or adapter.

Each shared attachment is an independent sync domain with its own repository, access mode, refs, conflicts, authorization policy, and backup status. Descriptor access is only an upper bound; private-store write authorization never grants shared-repository writes.

## Safe fetch and integration

1. Record the current branch/commit, remote/ref, and working-tree status.
2. Require a clean parent; never stash, reset, clean, or discard changes automatically.
3. Fetch before integration. Do not use destructive reset.
4. Integrate only according to approved policy, preserving conflicts for manual resolution.
5. Validate after integration and report the resulting commit.

## Safe push

Push only committed, validated changes under the applicable repository's selected write model and owner authorization. Report the exact remote, source/destination ref, and resulting commit. Never infer push success from a local commit. For attachments, require the attachment repository's own policy or owner authorization and remain read-only when it is absent, even when the private store uses `auto_write_with_git` or the descriptor says `read_write`.

Never use a force push or force-with-lease push without separate, explicit destructive-history authorization naming the repository, remote/ref, and intended rewritten range. Ordinary push approval, write-policy approval, or descriptor `read_write` is not that authorization.

## Native/cloud adapters

An adapter must declare directionality, trigger timing, conflict handling, authentication ownership, offline/stale behavior, retry behavior, and whether synchronization recompiles system context. When unavailable or offline, report that state; do not simulate synchronization.
