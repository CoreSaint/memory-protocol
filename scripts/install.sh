#!/usr/bin/env bash
# Install an independent memory-protocol store from this template. This script is
# intentionally local-only: it neither configures a host nor creates a remote.
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

The source template is never modified. The installed store has no Git remote and
no agent host is configured automatically.
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
    *)
      fail "unknown argument: $1"
      ;;
  esac
done

[[ -n "$destination" ]] || { usage >&2; exit 2; }
case "$write_model" in
  propose_then_approve|auto_write_with_git|session_notes_only|read_only) ;;
  *) fail "invalid write model: $write_model" ;;
esac

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source_root=$(cd "$script_dir/.." && pwd)
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
cleanup() {
  if [[ -n "$stage" && -d "$stage" ]]; then
    rm -rf "$stage"
  fi
}
trap cleanup EXIT

# Do not copy source Git metadata or Letta worktrees into the installed authority.
tar -C "$source_root" --exclude=.git --exclude=.letta -cf - . | tar -C "$stage" -xf -
rm -rf "$stage/.git" "$stage/.letta"

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
git init -b main "$stage" >/dev/null
git -C "$stage" add .
git -C "$stage" -c user.name='Memory Protocol Installer' -c user.email='noreply@localhost' \
  commit -m 'chore: initialize memory store' >/dev/null
[[ -z "$(git -C "$stage" remote)" ]] || fail 'new store unexpectedly has a Git remote'

mv "$stage" "$destination"
stage=
printf 'Installed independent memory store at %s\n' "$destination"
printf 'Selected write model: %s\n' "$write_model"
printf 'Next: configure the chosen agent host to read %s/AGENT_MEMORY.md before work.\n' "$destination"
