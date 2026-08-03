---
description: Read-only memory health audit and policy-gated repair procedure.
---

# Memory doctor

Doctor audits are read-only by default. A repair is a separate operation requiring the active write policy to authorize it; use [WORKTREES.md](WORKTREES.md) when isolating an authorized repair.

## Stable severities

- `error`: structural, authority, safety, or validation failure requiring correction.
- `warning`: likely retrieval, freshness, duplication, or lifecycle problem needing review.
- `info`: bounded observation or optional improvement.

## Audit checks

Run checks in stable path order and record evidence:

1. profile-aware structural validation and managed symlinks/placement;
2. `system/` size as a portable bootstrap guard, plus content that does not influence ordinary work;
3. broken/malformed links and weak progressive navigation;
4. duplicated or contradictory facts;
5. stale project indexes and provenance, distinguishing unchecked from verified stale facts;
6. attachment descriptor structure, checkout availability, resolved commit, and optional network reachability only when separately approved;
7. parent Git status, branch/commit, remotes, and preserved worktrees;
8. pending proposals, approval states, and deduplication keys.

Use [templates/doctor-report.md](templates/doctor-report.md). Do not invent missing facts or treat unavailable external checks as proof of failure.

## Repair lifecycle

Name each affected file and explain why the change preserves meaning. Prefer moving detail out of `system/`, splitting by topic, and updating links. Before mutation, re-check policy and parent status. For worktree repairs, record the base, validate and commit focused worker changes, and permit only the safe fast-forward lifecycle in `WORKTREES.md`. Dirty, advanced, conflicting, or invalid work is preserved for manual resolution—never stashed, reset, cleaned, forced, or discarded.
