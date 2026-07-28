---
description: Boundary contract for separately attached shared-memory repositories.
---

# Shared memory attachment

Shared memory is a distinct Git repository, not a subdirectory containing another agent's private state. Attach it explicitly through the host or a documented filesystem location.

Use shared memory for team conventions, common product knowledge, and jointly maintained plans. Keep agent identity, personal preferences, and private session-derived memory in the agent-private store unless the owner explicitly authorizes sharing.
