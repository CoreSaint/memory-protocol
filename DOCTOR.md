---
description: Read-only memory health audit and repair-planning procedure.
---

# Memory doctor

Run this audit when bootstrap context has become noisy, duplicated, stale, structurally invalid, or difficult to retrieve.

## Inspect

1. Run the structural validator.
2. Measure `system/` files and identify material that does not influence ordinary work.
3. Identify duplicate facts, broken links, stale project indexes, generic dumping-ground files, and files lacking concrete provenance.
4. Review uncommitted changes and pending `inbox/` proposals separately from canonical memory.

## Repair proposal

Produce a plan that names every affected file, explains why each move or merge preserves meaning, and identifies links to update. Prefer splitting by topic and moving detail out of `system/`; never silently discard information.

Apply repairs only as permitted by `system/memory-policy.md`. A doctor run is read-only by default and should not invent missing facts.
