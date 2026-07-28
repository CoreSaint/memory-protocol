---
description: Project overview and adoption guide for the portable agent-memory protocol template.
---

# Memory Protocol

An inactive, Git-backed Markdown template for giving any capable coding agent durable, auditable memory. It mirrors Letta's memory model without requiring Letta: compact always-read memory, progressive reference memory, reusable skills, Git history, shared-memory boundaries, initialization, reflection, and health checks.

This repository is a **template**, not an installed global memory store. Do not place personal, project, or secret data here. A future installer must copy it to an explicit destination and initialize that copy as a Git repository.

## Core contract

- Markdown committed to Git is the only durable authority.
- `system/` is compact bootstrap context. Agents must read `system/overview.md` before work.
- Other content is progressive memory: discover it from the tree and links; load it only when relevant.
- Every managed memory Markdown file has YAML frontmatter with a non-empty `description`.
- `system/memory-policy.md` selects the write model. Agents must obey it.
- Never store credentials, access tokens, private keys, or copied secret values.

Read [AGENT_MEMORY.md](AGENT_MEMORY.md) for the universal agent procedure, then [INIT.md](INIT.md) for first-time setup.

To create an independent global store from this template, follow [INSTALL.md](INSTALL.md).

## Layout

```text
system/       compact bootstrap context and policy
reference/    detailed, on-demand knowledge
skills/       versioned reusable procedures
inbox/        proposals awaiting review (for approval-based policies)
shared/       attachment contract for a separate shared-memory repository
templates/    copyable file templates
scripts/      optional local validators; never required by the protocol
```

## Portability boundary

Hosts such as Letta may inject `system/` into every prompt. Generic agents cannot assume that capability. Their adapter, launch instruction, or repository rule must instead require the bootstrap read defined in [AGENT_MEMORY.md](AGENT_MEMORY.md). Native integrations may add automatic injection but must not change the Markdown authority model.

## Validation

```sh
scripts/validate-memory.sh .
```

The script checks structural invariants only; it does not evaluate truth, retrieve external state, or modify memory.

## Related Letta concepts

The design is based on Letta's documented MemFS and memory lifecycle: https://docs.letta.com/concepts/memfs/index.md and https://docs.letta.com/configuration/memory/index.md.
