---
description: Contribution rules for agents modifying this portable template repository.
---

# Repository rules

- This repository is a distributable template. Do not initialize it as a user's live memory store.
- Keep the protocol usable with filesystem access and Git alone. Shell, search, subagents, schedules, and host-specific adapters are optional enhancements.
- Preserve the distinction between `system/` bootstrap context and progressive memory.
- Every Markdown file that is part of the managed memory tree must have YAML frontmatter with a non-empty `description`.
- Do not add secrets, personal user facts, or machine-specific paths.
- Do not claim that generic agents receive automatic system-prompt injection. They must follow the bootstrap read in `AGENT_MEMORY.md` unless a native adapter provides injection.
- Run `scripts/test-validate-memory.sh`, `scripts/validate-memory.sh .`, and `scripts/validate-memory.sh --profile template .` after validator or structural changes. Validation ignores only machine-local `.git/`, `.letta/`, and source-runtime `.pi-subagents/` trees; arbitrary hidden Markdown remains managed and visible.
