#!/usr/bin/env bash
# GNU-userland regression suite for validate-memory.sh.
set -euo pipefail
export LC_ALL=C

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo=$(cd "$script_dir/.." && pwd)
validator="$script_dir/validate-memory.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
base="$tmp/installed-base"

root_docs=(README.md AGENTS.md AGENT_MEMORY.md ADAPTERS.md CAPABILITIES.md DOCTOR.md DREAM.md HISTORY_INGEST.md INIT.md MEMFS_COMPATIBILITY.md SEARCH.md SYNC.md WORKTREES.md)
managed_dirs=(system projects reference skills inbox shared templates)
required_files=(
  .gitignore "${root_docs[@]}"
  system/overview.md system/persona.md system/memory-policy.md projects/overview.md
  reference/README.md skills/README.md inbox/README.md shared/README.md
  templates/memory-file.md templates/project-overview.md templates/proposal.md
  templates/session-note.md templates/shared-attachment.md templates/doctor-report.md templates/skill/SKILL.md
  skills/memory-search/SKILL.md scripts/validate-memory.sh
)

# Build the installed fixture from INSTALL_PROMPT.md itself. A passing installed
# validation is the consistency assertion between its one manifest authority,
# generated README/AGENTS contract, and validator requirements.
manifest="$tmp/installation-manifest"
awk '/^BEGIN INSTALLATION MANIFEST$/ { inside=1; next } /^END INSTALLATION MANIFEST$/ { inside=0 } inside { print }' "$repo/INSTALL_PROMPT.md" > "$manifest"
[[ -s "$manifest" ]] || { printf 'TEST FAILURE: INSTALL_PROMPT manifest missing\n' >&2; exit 1; }
mkdir -p "$base"
while IFS= read -r entry; do
  kind=${entry%%:*}; path=${entry#*: }
  case "$kind" in
    copy-file) parent=${path%/*}; [[ "$parent" == "$path" ]] || mkdir -p "$base/$parent"; cp "$repo/$path" "$base/$path" ;;
    copy-tree) cp -a "$repo/$path" "$base/$path" ;;
    generate)
      awk -v begin="BEGIN $path" -v end="END $path" '$0 == begin { inside=1; next } $0 == end { inside=0 } inside { print }' "$repo/INSTALL_PROMPT.md" > "$base/$path"
      [[ -s "$base/$path" ]] || { printf 'TEST FAILURE: generated contract block missing: %s\n' "$path" >&2; exit 1; }
      ;;
    *) printf 'TEST FAILURE: unsupported installation manifest entry: %s\n' "$entry" >&2; exit 1 ;;
  esac
done < "$manifest"

fail_test() { printf 'TEST FAILURE: %s\n' "$*" >&2; exit 1; }
run_valid() {
  local root=$1 profile=${2:-installed}
  "$validator" --profile "$profile" "$root" >/dev/null || fail_test "expected valid $profile fixture: $root"
}
snapshot() {
  local root=$1
  find "$root" -type f -print0 | sort -z | xargs -0 sha256sum
  find "$root" -type l -print0 | sort -z | while IFS= read -r -d '' link; do printf 'LINK %s -> %s\n' "${link#"$root/"}" "$(readlink "$link")"; done
}
expect_invalid() {
  local root=$1 expected=$2 name=$3 out1="$tmp/$name.1" out2="$tmp/$name.2" before="$tmp/$name.before" after="$tmp/$name.after"
  snapshot "$root" > "$before"
  if "$validator" --profile installed "$root" >"$out1" 2>&1; then fail_test "$name was accepted"; fi
  if "$validator" --profile installed "$root" >"$out2" 2>&1; then fail_test "$name was accepted on repeat"; fi
  cmp -s "$out1" "$out2" || fail_test "$name diagnostics were nondeterministic"
  grep -Fq "$expected" "$out1" || { cat "$out1" >&2; fail_test "$name lacked expected diagnostic: $expected"; }
  snapshot "$root" > "$after"
  cmp -s "$before" "$after" || fail_test "$name modified its fixture"
}
fresh() { local name=$1; cp -a "$base" "$tmp/$name"; printf '%s\n' "$tmp/$name"; }

# Positive profiles and ignored runtime trees.
run_valid "$repo" template
run_valid "$base" installed
run_valid "$base" # deterministic installed auto-detection
mkdir -p "$base/.git/x" "$base/.letta/worktrees/x" "$base/.pi-subagents/runtime/x"
printf '# invalid runtime markdown\n[[missing.md]]\n' > "$base/.git/x/bad.md"
printf '# invalid runtime markdown\n' > "$base/.letta/worktrees/x/bad.md"
printf '# invalid runtime markdown\n' > "$base/.pi-subagents/runtime/x/bad.md"
run_valid "$base"

# Positive links, every write model, and valid tracking/pinned descriptors.
cat >> "$base/projects/overview.md" <<'EOF'

Alias and anchor examples: [[system/persona.md#persona|persona]] and [[reference/README.md|reference]].
EOF
for model in propose_then_approve auto_write_with_git session_notes_only read_only; do
  sed -E "s/^write_model: .*/write_model: $model/" "$repo/system/memory-policy.md" > "$base/system/memory-policy.md"
  run_valid "$base"
done
cp "$repo/system/memory-policy.md" "$base/system/memory-policy.md"
cat > "$base/shared/attachments/tracking.md" <<'EOF'
---
description: Valid tracking attachment fixture.
---
```memory-attachment
id: tracking
remote: https://example.invalid/tracking.git
ref: refs/heads/main
access: read_only
update_policy: tracking
required: false
```
EOF
cat > "$base/shared/attachments/pinned.md" <<'EOF'
---
description: Valid pinned attachment fixture.
---
```memory-attachment
id: pinned
remote: git@example.invalid:pinned.git
ref: 0123456789abcdef0123456789abcdef01234567
access: read_write
update_policy: pinned
required: true
```
EOF
before="$tmp/positive.before"; after="$tmp/positive.after"
snapshot "$base" > "$before"; run_valid "$base"; snapshot "$base" > "$after"
cmp -s "$before" "$after" || fail_test "validation modified the positive fixture"
# An in-store TMPDIR must not cause even transient validator state inside the store.
before="$tmp/in-store-tmp.before"; after="$tmp/in-store-tmp.after"
snapshot "$base" > "$before"
TMPDIR="$base" "$validator" --profile installed "$base" >/dev/null || fail_test "validator rejected safe fallback from in-store TMPDIR"
find "$base" -maxdepth 1 -name 'validate-memory.*' -print -quit | grep -q . && fail_test "validator created temporary state inside the store"
snapshot "$base" > "$after"; cmp -s "$before" "$after" || fail_test "in-store TMPDIR validation modified the fixture"

# Every installed-profile required file and directory is enforced.
for target in "${required_files[@]}"; do
  name="missing-file-${target//\//_}"; root=$(fresh "$name"); rm -f "$root/$target"
  expect_invalid "$root" "required regular file missing" "$name"
done
for target in "${managed_dirs[@]}" shared/attachments scripts; do
  name="missing-dir-${target//\//_}"; root=$(fresh "$name"); rm -rf "$root/$target"
  expect_invalid "$root" "required directory missing" "$name"
done
# Template-only requirements, built without copying source-runtime trees.
template_base="$tmp/template-base"; cp -a "$base" "$template_base"
cp "$repo/.memory-protocol-template" "$template_base/.memory-protocol-template"
cp "$repo/INSTALL_PROMPT.md" "$template_base/INSTALL_PROMPT.md"
cp "$repo/scripts/test-validate-memory.sh" "$template_base/scripts/test-validate-memory.sh"
root="$tmp/template-missing-install"; cp -a "$template_base" "$root"; rm "$root/INSTALL_PROMPT.md"
if "$validator" --profile template "$root" >"$tmp/template-missing.1" 2>&1; then fail_test "template accepted missing INSTALL_PROMPT.md"; fi
grep -Fq 'required regular file missing' "$tmp/template-missing.1" || fail_test "template missing-file diagnostic absent"
root="$tmp/template-missing-tests"; cp -a "$template_base" "$root"; rm "$root/scripts/test-validate-memory.sh"
if "$validator" --profile template "$root" >/dev/null 2>&1; then fail_test "template accepted missing regression script"; fi
root="$tmp/template-missing-marker"; cp -a "$template_base" "$root"; rm "$root/.memory-protocol-template"
if "$validator" --profile template "$root" >/dev/null 2>&1; then fail_test "template accepted missing stable template marker"; fi
# Auto-detection treats any remaining source marker as a damaged template.
root="$tmp/auto-template-missing-install"; cp -a "$template_base" "$root"; rm "$root/INSTALL_PROMPT.md"
if "$validator" "$root" >"$tmp/auto-template-missing-install.out" 2>&1; then fail_test "auto profile treated damaged template as installed"; fi
grep -Fq 'INSTALL_PROMPT.md: required regular file missing for template profile' "$tmp/auto-template-missing-install.out" || fail_test "remaining regression-script marker did not select template profile"
root="$tmp/auto-template-missing-tests"; cp -a "$template_base" "$root"; rm "$root/scripts/test-validate-memory.sh"
if "$validator" "$root" >"$tmp/auto-template-missing-tests.out" 2>&1; then fail_test "auto profile treated damaged template as installed"; fi
grep -Fq 'scripts/test-validate-memory.sh: required regular file missing for template profile' "$tmp/auto-template-missing-tests.out" || fail_test "remaining INSTALL_PROMPT marker did not select template profile"
root="$tmp/auto-template-missing-both-legacy-markers"; cp -a "$template_base" "$root"; rm "$root/INSTALL_PROMPT.md" "$root/scripts/test-validate-memory.sh"
if "$validator" "$root" >"$tmp/auto-template-missing-both.out" 2>&1; then fail_test "stable marker did not identify doubly damaged template"; fi
grep -Fq 'INSTALL_PROMPT.md: required regular file missing for template profile' "$tmp/auto-template-missing-both.out" || fail_test "stable marker did not select template profile"

# Frontmatter cases.
root=$(fresh fm-opening); sed -i '1d' "$root/projects/overview.md"; expect_invalid "$root" 'frontmatter opening delimiter' fm-opening
root=$(fresh fm-closing); sed -i '3s/^---$/not-a-delimiter/' "$root/projects/overview.md"; expect_invalid "$root" 'frontmatter closing delimiter missing' fm-closing
# Letta-compatible plain, single-quoted, and double-quoted descriptions remain valid.
root=$(fresh fm-positive-quotes)
sed -i 's/^description:.*/description: "Double-quoted description."/' "$root/projects/overview.md"; run_valid "$root"
sed -i 's/^description:.*/description: "# quoted text is not a comment"/' "$root/projects/overview.md"; run_valid "$root"
sed -i "s/^description:.*/description: 'Owner''s single-quoted description.'/" "$root/projects/overview.md"; run_valid "$root"
sed -i "s/^description:.*/description: 'null'/" "$root/projects/overview.md"; run_valid "$root"
sed -i 's/^description:.*/description: Plain single-line description./' "$root/projects/overview.md"; run_valid "$root"
root=$(fresh fm-empty); sed -i 's/^description:.*/description:/' "$root/projects/overview.md"; expect_invalid "$root" 'description must be a supported non-empty' fm-empty
root=$(fresh fm-duplicate); sed -i '2a description: Duplicate.' "$root/projects/overview.md"; expect_invalid "$root" 'exactly one description' fm-duplicate
root=$(fresh fm-multiline); sed -i 's/^description:.*/description: |/' "$root/projects/overview.md"; expect_invalid "$root" 'single-line scalar' fm-multiline
scalar_case=0
for value in '# comment only' null Null NULL '~' true false yes no on off 123 2025-01-01 0xFF 0o755 0b1010 2025-01-01T00:00:00Z '[]' '{}' '"   "' '"\t"' "'   '" '"unclosed' "'unclosed" '!tag value' '&anchor value' '*alias'; do
  scalar_case=$((scalar_case+1)); name="fm-scalar-$scalar_case"; root=$(fresh "$name")
  escaped=${value//\\/\\\\}; escaped=${escaped//&/\\&}
  sed -i "s|^description:.*|description: $escaped|" "$root/projects/overview.md"
  expect_invalid "$root" 'description must be a supported non-empty single-line scalar' "$name"
done
root=$(fresh fm-malformed-single-quote); sed -i "s/^description:.*/description: 'owner's description'/" "$root/projects/overview.md"; expect_invalid "$root" 'description must be a supported' fm-malformed-single-quote
root=$(fresh fm-block-folded); sed -i 's/^description:.*/description: >-/' "$root/projects/overview.md"; expect_invalid "$root" 'single-line scalar' fm-block-folded
root=$(fresh fm-body-only); sed -i '2d' "$root/projects/overview.md"; printf '\ndescription: body decoy\n' >> "$root/projects/overview.md"; expect_invalid "$root" 'exactly one description' fm-body-only
root=$(fresh fm-unsupported); sed -i '2a status: pending' "$root/projects/overview.md"; expect_invalid "$root" 'unsupported frontmatter key' fm-unsupported
root=$(fresh skill-name-missing); sed -i '/^name:/d' "$root/skills/memory-search/SKILL.md"; expect_invalid "$root" 'exactly one name' skill-name-missing
root=$(fresh skill-name-mismatch); sed -i 's/^name:.*/name: other/' "$root/skills/memory-search/SKILL.md"; expect_invalid "$root" 'does not match parent directory' skill-name-mismatch

# Policy block cannot be satisfied by body decoys, duplicates, invalid, or misplaced fields.
root=$(fresh policy-invalid); sed -i 's/write_model: propose_then_approve/write_model: impossible/' "$root/system/memory-policy.md"; expect_invalid "$root" "invalid write_model 'impossible'" policy-invalid
root=$(fresh policy-duplicate); sed -i '/write_model:/a write_model: read_only' "$root/system/memory-policy.md"; expect_invalid "$root" 'exactly one allowed write_model' policy-duplicate
root=$(fresh policy-misplaced); sed -i '/write_model:/d' "$root/system/memory-policy.md"; printf '\nwrite_model: read_only\n' >> "$root/system/memory-policy.md"; expect_invalid "$root" 'exactly one allowed write_model' policy-misplaced
root=$(fresh policy-duplicate-block); cat >> "$root/system/memory-policy.md" <<'EOF'
```memory-policy
write_model: read_only
```
EOF
expect_invalid "$root" 'exactly one closed memory-policy block' policy-duplicate-block
# A block shown inside a longer outer code fence is not a policy block.
root=$(fresh policy-fenced-only); sed -i '/^```memory-policy$/,/^```$/d' "$root/system/memory-policy.md"; cat >> "$root/system/memory-policy.md" <<'EOF'
````markdown
```memory-policy
write_model: read_only
```
````
EOF
expect_invalid "$root" 'exactly one closed memory-policy block' policy-fenced-only
# A shown duplicate/invalid block does not interfere with the real visible block.
root=$(fresh policy-fenced-decoy); cat >> "$root/system/memory-policy.md" <<'EOF'
````markdown
```memory-policy
write_model: impossible
```
````
EOF
run_valid "$root"

# Wiki-link failures.
root=$(fresh link-broken); printf '\n[[missing.md]]\n' >> "$root/projects/overview.md"; expect_invalid "$root" 'broken wiki link' link-broken
root=$(fresh link-empty); printf '\n[[]]\n' >> "$root/projects/overview.md"; expect_invalid "$root" 'malformed empty wiki-link target' link-empty
root=$(fresh link-absolute); printf '\n[[/system/persona.md]]\n' >> "$root/projects/overview.md"; expect_invalid "$root" 'absolute wiki link' link-absolute
root=$(fresh link-traversal); printf '\n[[../README.md]]\n' >> "$root/projects/overview.md"; expect_invalid "$root" 'traverses parent' link-traversal
root=$(fresh link-malformed); printf '\n[[system/persona.md]\n' >> "$root/projects/overview.md"; expect_invalid "$root" 'malformed wiki link' link-malformed
root=$(fresh link-stray-close); printf '\nsystem/persona.md]]\n' >> "$root/projects/overview.md"; expect_invalid "$root" 'malformed wiki link' link-stray-close
root=$(fresh link-alias); printf '\n[[system/persona.md|]]\n' >> "$root/projects/overview.md"; expect_invalid "$root" 'malformed wiki link alias' link-alias
root=$(fresh link-anchor); printf '\n[[system/persona.md#]]\n' >> "$root/projects/overview.md"; expect_invalid "$root" 'malformed empty wiki-link anchor' link-anchor
root=$(fresh link-directory); printf '\n[[system]]\n' >> "$root/projects/overview.md"; expect_invalid "$root" 'malformed root-relative wiki link' link-directory
# A syntactically valid .md path resolving to a directory exercises directory rejection.
root=$(fresh link-directory-target); mkdir "$root/projects/directory.md"; printf '\n[[projects/directory.md]]\n' >> "$root/projects/overview.md"; expect_invalid "$root" 'targets a directory' link-directory-target
# Fenced examples are ignored, while a visible link after a fence is still checked.
root=$(fresh link-fenced-decoy); cat >> "$root/projects/overview.md" <<'EOF'

````markdown
[[missing.md]]
malformed]]
````
~~~text
[[also-missing.md]]
~~~
EOF
run_valid "$root"
root=$(fresh link-after-fence); cat >> "$root/projects/overview.md" <<'EOF'

````markdown
[[missing.md]]
````
[[still-missing.md]]
EOF
expect_invalid "$root" 'broken wiki link: still-missing.md' link-after-fence

# Layout, bounds, and visibility.
root=$(fresh stem-conflict); mkdir "$root/projects/overview"; expect_invalid "$root" 'file/directory stem conflict' stem-conflict
root=$(fresh managed-symlink); ln -s overview.md "$root/projects/alias.md"; expect_invalid "$root" 'symlink is forbidden' managed-symlink
root=$(fresh bootstrap-budget); dd if=/dev/zero bs=49153 count=1 status=none | tr '\0' x >> "$root/system/persona.md"; expect_invalid "$root" 'portable bootstrap guard exceeded' bootstrap-budget
root=$(fresh unknown-markdown); mkdir "$root/.unknown"; printf '%s\n' '---' 'description: Hidden invalid placement.' '---' > "$root/.unknown/file.md"; expect_invalid "$root" 'outside declared managed roots' unknown-markdown
# Exercise fatal traversal behavior only when permissions are enforceable (root may bypass mode 000).
root=$(fresh unreadable-managed); mkdir "$root/projects/unreadable"; chmod 000 "$root/projects/unreadable"
if (cd "$root/projects/unreadable") 2>/dev/null; then
  chmod 700 "$root/projects/unreadable"
  printf 'SKIP: unreadable managed-path traversal test (platform/user bypasses mode 000).\n'
else
  if "$validator" --profile installed "$root" >"$tmp/unreadable-managed.out" 2>&1; then
    chmod 700 "$root/projects/unreadable"; fail_test "validator accepted unreadable managed path"
  fi
  chmod 700 "$root/projects/unreadable"
  grep -Fq 'managed Markdown discovery traversal failed' "$tmp/unreadable-managed.out" || { cat "$tmp/unreadable-managed.out" >&2; fail_test "unreadable path did not produce fatal traversal diagnostic"; }
fi

# Attachment schema branches.
make_attachment() {
  local root=$1 body=$2
  cat > "$root/shared/attachments/sample.md" <<EOF
---
description: Attachment test fixture.
---
$body
EOF
}
root=$(fresh attachment-unclosed); make_attachment "$root" $'```memory-attachment\nid: sample'; expect_invalid "$root" 'exactly one closed memory-attachment block' attachment-unclosed
root=$(fresh attachment-missing-key); make_attachment "$root" $'```memory-attachment\nid: sample\nremote: https://example.invalid/x.git\nref: refs/heads/main\naccess: read_only\nupdate_policy: tracking\n```'; expect_invalid "$root" "key 'required' must occur exactly once" attachment-missing-key
root=$(fresh attachment-duplicate-key); make_attachment "$root" $'```memory-attachment\nid: sample\nid: sample\nremote: https://example.invalid/x.git\nref: refs/heads/main\naccess: read_only\nupdate_policy: tracking\nrequired: false\n```'; expect_invalid "$root" "key 'id' must occur exactly once" attachment-duplicate-key
root=$(fresh attachment-access); make_attachment "$root" $'```memory-attachment\nid: sample\nremote: https://example.invalid/x.git\nref: refs/heads/main\naccess: admin\nupdate_policy: tracking\nrequired: false\n```'; expect_invalid "$root" 'access must be read_only or read_write' attachment-access
root=$(fresh attachment-policy); make_attachment "$root" $'```memory-attachment\nid: sample\nremote: https://example.invalid/x.git\nref: refs/heads/main\naccess: read_only\nupdate_policy: floating\nrequired: false\n```'; expect_invalid "$root" 'update_policy must be tracking or pinned' attachment-policy
root=$(fresh attachment-required); make_attachment "$root" $'```memory-attachment\nid: sample\nremote: https://example.invalid/x.git\nref: refs/heads/main\naccess: read_only\nupdate_policy: tracking\nrequired: sometimes\n```'; expect_invalid "$root" 'required must be true or false' attachment-required
root=$(fresh attachment-id); make_attachment "$root" $'```memory-attachment\nid: other\nremote: https://example.invalid/x.git\nref: refs/heads/main\naccess: read_only\nupdate_policy: tracking\nrequired: false\n```'; expect_invalid "$root" 'does not match filename' attachment-id
root=$(fresh attachment-id-syntax); make_attachment "$root" $'```memory-attachment\nid: Bad ID\nremote: https://example.invalid/x.git\nref: refs/heads/main\naccess: read_only\nupdate_policy: tracking\nrequired: false\n```'; expect_invalid "$root" 'attachment id is invalid' attachment-id-syntax
root=$(fresh attachment-pinned-ref); make_attachment "$root" $'```memory-attachment\nid: sample\nremote: https://example.invalid/x.git\nref: main\naccess: read_only\nupdate_policy: pinned\nrequired: false\n```'; expect_invalid "$root" 'pinned attachment ref must be' attachment-pinned-ref
root=$(fresh attachment-tracking-ref); make_attachment "$root" $'```memory-attachment\nid: sample\nremote: https://example.invalid/x.git\nref: main\naccess: read_only\nupdate_policy: tracking\nrequired: false\n```'; expect_invalid "$root" 'tracking attachment ref must be' attachment-tracking-ref
root=$(fresh attachment-invalid-ref-format); make_attachment "$root" $'```memory-attachment\nid: sample\nremote: https://example.invalid/x.git\nref: refs/heads/bad..name\naccess: read_only\nupdate_policy: tracking\nrequired: false\n```'; expect_invalid "$root" 'tracking attachment ref must be a valid explicit heads/tags ref' attachment-invalid-ref-format
root=$(fresh attachment-credentials); make_attachment "$root" $'```memory-attachment\nid: sample\nremote: https://user:secret@example.invalid/x.git\nref: refs/heads/main\naccess: read_only\nupdate_policy: tracking\nrequired: false\n```'; expect_invalid "$root" 'embeds credentials' attachment-credentials
root=$(fresh attachment-local-remote); make_attachment "$root" $'```memory-attachment\nid: sample\nremote: /home/example/repo\nref: refs/heads/main\naccess: read_only\nupdate_policy: tracking\nrequired: false\n```'; expect_invalid "$root" 'credential-free non-local Git URL' attachment-local-remote
root=$(fresh attachment-extra-key); make_attachment "$root" $'```memory-attachment\nid: sample\nremote: https://example.invalid/x.git\nref: refs/heads/main\naccess: read_only\nupdate_policy: tracking\nrequired: false\ncheckout: /tmp/x\n```'; expect_invalid "$root" 'unsupported attachment key' attachment-extra-key
# Fenced descriptor examples do not count as real blocks or duplicates.
root=$(fresh attachment-fenced-only); make_attachment "$root" $'````markdown\n```memory-attachment\nid: sample\nremote: https://example.invalid/x.git\nref: refs/heads/main\naccess: read_only\nupdate_policy: tracking\nrequired: false\n```\n````'; expect_invalid "$root" 'exactly one closed memory-attachment block' attachment-fenced-only
root=$(fresh attachment-fenced-decoy); make_attachment "$root" $'```memory-attachment\nid: sample\nremote: https://example.invalid/x.git\nref: refs/heads/main\naccess: read_only\nupdate_policy: tracking\nrequired: false\n```\n\n````markdown\n```memory-attachment\nid: wrong\n```\n````'; run_valid "$root"

echo "Validator regression tests passed (template + installed profiles; deterministic and read-only)."
