#!/usr/bin/env bash
# Install an independent memory-protocol store from a clean template checkout.
# This script is intentionally local-only: it neither configures a host nor
# creates a remote.
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/install.sh --destination PATH [--write-model MODEL] [--backup-existing]

Create a new independent Git-backed memory store from this template.

Required:
  --destination PATH       New memory-store directory. Its parent must exist.

Optional:
  --write-model MODEL      propose_then_approve (default), auto_write_with_git,
                           session_notes_only, or read_only.
  --backup-existing        Move an existing destination to PATH.backup-<UTC timestamp>.
  -h, --help               Show this help.

The source template must be a clean Git checkout. The installer copies committed
content only, creates no remote, and does not configure an agent host.
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

write_model=propose_then_approve
backup_existing=false
destination=

while (($#)); do
  case "$1" in
    --destination)
      (($# >= 2)) || fail '--destination requires a path'
      destination=$2
      shift 2
      ;;
    --write-model)
      (($# >= 2)) || fail '--write-model requires a value'
      write_model=$2
      shift 2
      ;;
    --backup-existing)
      backup_existing=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *) fail "unknown argument: $1" ;;
  esac
done

[[ -n "$destination" ]] || { usage >&2; exit 2; }
case "$write_model" in
  propose_then_approve|auto_write_with_git|session_notes_only|read_only) ;;
  *) fail "invalid write model: $write_model" ;;
esac

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source_root=$(cd "$script_dir/.." && pwd)

stage=
backup_path=
installed=false
preflight_home=
cleanup() {
  local status=$?
  if [[ -n "$stage" && -d "$stage" ]]; then
    rm -rf "$stage" || printf 'WARNING: could not remove staging directory: %s\n' "$stage" >&2
  fi
  if [[ -n "$preflight_home" && -d "$preflight_home" ]]; then
    rm -rf "$preflight_home" || printf 'WARNING: could not remove preflight directory: %s\n' "$preflight_home" >&2
  fi
  if [[ "$installed" != true && -n "$backup_path" && ! -e "$destination" && ! -L "$destination" ]]; then
    mv "$backup_path" "$destination" || \
      printf 'WARNING: installation failed and backup remains at %s\n' "$backup_path" >&2
  fi
  return "$status"
}
trap cleanup EXIT

# Do not let source-checkout configuration run fsmonitor commands or otherwise
# affect preflight. The committed archive is read through the same isolated Git.
preflight_home=$(mktemp -d)
source_git() {
  env -i PATH="$PATH" HOME="$preflight_home" GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null \
    git -c core.fsmonitor=false -c core.hooksPath=/dev/null -C "$source_root" "$@"
}
source_git rev-parse --is-inside-work-tree >/dev/null 2>&1 || \
  fail 'template source must be a Git working tree'
[[ -z "$(source_git status --porcelain --untracked-files=all)" ]] || \
  fail 'template source is not clean; commit, stash, or remove every change before installing'

destination_parent=$(dirname "$destination")
destination_name=$(basename "$destination")
[[ "$destination_name" != '.' && "$destination_name" != '/' ]] || fail 'destination must name a directory'
[[ -d "$destination_parent" ]] || fail "destination parent does not exist: $destination_parent"
destination_parent=$(cd "$destination_parent" && pwd)
destination="$destination_parent/$destination_name"
[[ "$destination" != "$source_root" && "$destination" != "$source_root"/* ]] || \
  fail 'destination must not be the template source or a directory inside it'

if [[ -e "$destination" || -L "$destination" ]]; then
  if [[ "$backup_existing" != true ]]; then
    fail "destination already exists: $destination (use --backup-existing to move it aside)"
  fi
  timestamp=$(date -u +%Y%m%dT%H%M%SZ)
  backup_path="$destination.backup-$timestamp"
  [[ ! -e "$backup_path" && ! -L "$backup_path" ]] || fail "backup path already exists: $backup_path"
  mv "$destination" "$backup_path"
  printf 'Backed up existing destination to %s\n' "$backup_path"
fi

stage=$(mktemp -d "$destination_parent/.${destination_name}.install.XXXXXX")
# Archive only committed source content; do not copy ignored, untracked, Git, or
# Letta worktree files from the checkout.
source_git archive --format=tar HEAD | tar -C "$stage" -xf -

# Source-repository guidance must not govern the active store. Keep only its
# runtime contract and replace the root documentation with active-store copies.
rm -f "$stage/AGENTS.md" "$stage/INSTALL.md" "$stage/scripts/install.sh"
mv "$stage/templates/active-store-README.md" "$stage/README.md"
mv "$stage/templates/active-store-AGENTS.md" "$stage/AGENTS.md"

policy="$stage/system/memory-policy.md"
python3 - "$policy" "$write_model" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
model = sys.argv[2]
text = path.read_text()
updated, count = re.subn(r'^write_model: [^\n]+$', f'write_model: {model}', text, flags=re.MULTILINE)
if count != 1:
    raise SystemExit('memory policy did not contain exactly one write_model value')
path.write_text(updated)
PY

"$stage/scripts/validate-memory.sh" "$stage"

# Use an empty Git environment and disable hooks/signing. This prevents ambient
# user config, hooks, and filters from executing during the installation commit.
safe_home="$stage/.installer-home"
mkdir "$safe_home"
safe_git() {
  env -i PATH="$PATH" HOME="$safe_home" GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null \
    git "$@"
}
safe_git init -q "$stage" >/dev/null
safe_git -C "$stage" symbolic-ref HEAD refs/heads/main
safe_git -C "$stage" config core.hooksPath /dev/null
safe_git -C "$stage" config commit.gpgSign false
safe_git -C "$stage" add .
safe_git -C "$stage" -c core.hooksPath=/dev/null -c commit.gpgSign=false \
  -c user.name='Memory Protocol Installer' -c user.email='noreply@localhost' \
  commit -m 'chore: initialize memory store' >/dev/null
[[ -z "$(safe_git -C "$stage" remote)" ]] || fail 'new store unexpectedly has a Git remote'
rm -rf "$safe_home"

mv "$stage" "$destination"
stage=
installed=true
printf 'Installed independent memory store at %s\n' "$destination"
printf 'Selected write model: %s\n' "$write_model"
printf 'Next: configure the chosen agent host to read %s/AGENT_MEMORY.md before work.\n' "$destination"
