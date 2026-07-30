#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
validator="$script_dir/validate-memory.sh"
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT

mkdir -p "$fixture/system" "$fixture/.git" "$fixture/.letta/worktrees/runtime"
for name in overview persona; do
  cat > "$fixture/system/$name.md" <<EOF
---
description: Test $name.
---

# Test
EOF
done
cat > "$fixture/system/memory-policy.md" <<'EOF'
---
description: Test policy.
---

```yaml
write_model: read_only
```
EOF

# Machine-local runtime Markdown must not enter the managed validation surface.
printf '# no frontmatter\n[[missing.md]]\n' > "$fixture/.git/ignored.md"
printf '# no frontmatter\n[[missing.md]]\n' > "$fixture/.letta/worktrees/runtime/ignored.md"
"$validator" "$fixture" >/dev/null

# A real managed Markdown violation must still fail.
printf '# no frontmatter\n' > "$fixture/bad.md"
if "$validator" "$fixture" >/dev/null 2>&1; then
  echo "ERROR: validator accepted invalid managed Markdown" >&2
  exit 1
fi

echo "Validator regression tests passed."
