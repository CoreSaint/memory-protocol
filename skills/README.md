---
description: Contract for reusable portable procedures stored with memory.
---

# Skills

Each portable skill lives at `skills/<skill-name>/SKILL.md`. Its frontmatter contains exactly `name` matching `<skill-name>` and a non-empty `description`. A skill is a repeatable procedure, not enduring project facts.

The bundled [memory-search skill](memory-search/SKILL.md) implements path/description discovery and literal committed-`HEAD` search, then optionally delegates semantic/hybrid retrieval to a declared QMD adapter. It must degrade cleanly when QMD is absent.

Versioning a skill does not register or invoke it. Native registration, precedence, permissions, secret access, slash commands, and project/host skill scopes are adapter-owned capabilities.
