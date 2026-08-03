---
description: Copyable descriptor for a separately checked out shared Git repository attachment.
---

# Shared attachment: team-handbook

Copy to `shared/attachments/team-handbook.md`. Do not add credentials or a local checkout path. `access` is only an upper bound; absent separate repository policy/owner write authorization, adapters must remain read-only.

```memory-attachment
id: team-handbook
remote: https://example.invalid/team-handbook.git
ref: refs/heads/main
access: read_only
update_policy: tracking
required: false
```
