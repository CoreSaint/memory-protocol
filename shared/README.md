---
description: Contract for credential-free descriptors of separately checked out shared Git repositories.
---

# Shared Git repository attachments

Shared repositories are independent Git authorities, not nested private memory and not Letta shared memory blocks. Store descriptors at `shared/attachments/<attachment-id>.md`; copy [templates/shared-attachment.md](../templates/shared-attachment.md).

A descriptor has ordinary frontmatter containing only `description`, followed by exactly one fenced `memory-attachment` block with flat keys:

- `id`: identifier matching the descriptor filename;
- `remote`: non-empty credential-free Git URL, never a token, password, local mount, or machine-specific path;
- `ref`: explicit `refs/heads/...` or `refs/tags/...` for `tracking`, or a full 40/64-hex object ID for `pinned`;
- `access`: `read_only` or `read_write`, as an upper bound rather than a grant;
- `update_policy`: `tracking` or `pinned`;
- `required`: `true` or `false`.

The external checkout remains outside the private memory root. Never place its `.git` directory under `shared/`. Attachments are progressive context by default and must not be injected as private `system/` memory.

## Adapter behavior

An adapter chooses and reports an external checkout location, resolved commit, descriptor ref/policy, access mode, and availability/staleness. It may use an existing stale checkout offline only when identified as stale. A missing required attachment is an explicit unavailable capability; an optional one may degrade cleanly.

Descriptor access is only an upper bound. `read_only` forbids attachment writes, while `read_write` merely permits a separately authorized write workflow. The private store's `auto_write_with_git` model never grants writes to an attachment. Fetching may occur only within approved adapter/network scope; committing and pushing require the attachment repository's own write policy or explicit owner authorization. If that repository has no discoverable policy or authorization, default to read-only.

Tracking updates must preserve dirty/conflicting work and report conflicts; pinned attachments never advance without a descriptor change. The private store and each attachment have separate validation, commits, remotes, conflicts, authorizations, searches, and backups.

Letta repository IDs, persistent attachment, access control, credentials, cloud concurrency, and live APIs are adapter-owned and do not belong in this descriptor.
