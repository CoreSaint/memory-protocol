#!/usr/bin/env bash
# Structural validator for a copied memory-protocol repository. It is read-only.
set -euo pipefail

root=${1:-.}
root=$(cd "$root" && pwd)
failures=0

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  failures=$((failures + 1))
}

require_file() {
  [[ -f "$root/$1" ]] || fail "required file missing: $1"
}

require_file system/overview.md
require_file system/persona.md
require_file system/memory-policy.md

while IFS= read -r -d '' file; do
  rel=${file#"$root/"}
  base=$(basename "$file")
  if [[ "$base" == "SKILL.md" && "$rel" == skills/* ]]; then
    if ! grep -qE '^name: .+' "$file" || ! grep -qE '^description: .+' "$file"; then
      fail "skill lacks name or description frontmatter: $rel"
    fi
    continue
  fi
  if ! head -n 1 "$file" | grep -qx -- '---'; then
    fail "Markdown lacks YAML frontmatter: $rel"
  elif ! sed -n '2,/^---$/p' "$file" | grep -qE '^description: .+'; then
    fail "Markdown lacks non-empty description: $rel"
  fi
done < <(find "$root" -type f -name '*.md' -print0)

while IFS= read -r -d '' file; do
  stem=${file%.md}
  if [[ -d "$stem" ]]; then
    fail "file/directory conflict: ${file#"$root/"} conflicts with ${stem#"$root/"}/"
  fi
done < <(find "$root" -type f -name '*.md' -print0)

policy="$root/system/memory-policy.md"
if [[ -f "$policy" ]] && ! grep -qE '^write_model: (propose_then_approve|auto_write_with_git|session_notes_only|read_only)$' "$policy"; then
  fail "system/memory-policy.md lacks a valid write_model"
fi

# Template links intentionally contain placeholders, so only validate runtime content.
while IFS= read -r -d '' file; do
  rel=${file#"$root/"}
  [[ "$rel" == templates/* ]] && continue
  while IFS= read -r link; do
    target=${link%%#*}
    [[ -z "$target" ]] && continue
    if [[ "$target" = /* ]]; then
      fail "absolute wiki link is not portable: $rel -> $target"
    elif [[ ! -e "$root/$target" ]]; then
      fail "broken wiki link: $rel -> $target"
    fi
  done < <(grep -oE '\[\[[^]|]+(\|[^]]+)?\]\]' "$file" | sed -E 's/^\[\[//; s/\]\]$//; s/\|.*$//')
done < <(find "$root" -type f -name '*.md' -not -path "$root/templates/*" -print0)

system_bytes=0
while IFS= read -r -d '' system_file; do
  system_bytes=$((system_bytes + $(wc -c < "$system_file")))
done < <(find "$root/system" -type f -name '*.md' -print0)
if (( system_bytes > 49152 )); then
  fail "system/ is ${system_bytes} bytes; move detailed material to reference/"
fi

if (( failures > 0 )); then
  printf 'Validation failed with %d error(s).\n' "$failures" >&2
  exit 1
fi
printf 'Memory structure valid (%s; system=%s bytes).\n' "$root" "$system_bytes"
