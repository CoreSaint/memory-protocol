---
description: Shared safe Git worktree lifecycle for bounded dreaming and policy-authorized doctor repairs.
---

# Safe worktree lifecycle

Worktrees are optional `portable-workflow` tooling. A worker worktree and branch must be unique and outside the memory root. Do not standardize a host's internal names.

## Before work

1. Read the active write policy and confirm the operation is permitted.
2. Record the parent branch, exact base commit, and `git status --short`.
3. Refuse automated worktree mutation if the parent is dirty. Never stash, reset, clean, overwrite, or delete parent changes.
4. Create a unique branch and linked worktree from the recorded base outside the memory root.

## Worker contract

Bound sources and outputs before work. Make focused edits, run structural and operation-specific validation, and create one focused worker commit. Record the commit and validation result. A failed or uncommitted worker is not eligible for integration.

## Integration contract

Automatic integration is allowed only when the parent is still clean, remains on the expected branch, and is exactly at the recorded base. Verify the worker commit descends from that base, then fast-forward the parent—never force, rebase, or auto-resolve conflicts. Validate the integrated state.

If the parent advanced, became dirty, validation failed, or any conflict/invariant appears, stop. Preserve the worker branch and worktree and report their location, base, commit, and manual resolution needed.

## Cleanup

Remove the linked worktree and branch only after confirming that the worker commit is integrated and the integrated repository validates. Never use forced worktree removal or branch deletion after a failed run. Stale worktrees remain explicit review items rather than being silently discarded.
