#!/usr/bin/env bash
# Deterministic, offline structural validator for memory-protocol templates and stores.
set -euo pipefail
export LC_ALL=C

if (( BASH_VERSINFO[0] < 4 )); then
  printf 'ERROR: validate-memory.sh requires Bash 4 or newer.\n' >&2
  exit 2
fi
for required_command in find sort awk wc git mktemp rm; do
  command -v "$required_command" >/dev/null 2>&1 || {
    printf 'ERROR: required validator command is unavailable: %s\n' "$required_command" >&2
    exit 2
  }
done
if ! sort -z </dev/null >/dev/null 2>&1; then
  printf 'ERROR: validate-memory.sh requires GNU-compatible sort with -z support.\n' >&2
  exit 2
fi

usage() {
  printf 'Usage: %s [--profile template|installed] [ROOT]\n' "${0##*/}" >&2
  exit 2
}

profile=auto
if [[ ${1:-} == --profile ]]; then
  [[ $# -ge 2 ]] || usage
  profile=$2
  shift 2
fi
[[ $# -le 1 ]] || usage
case "$profile" in auto|template|installed) ;; *) usage ;; esac
root=${1:-.}
[[ -d "$root" ]] || { printf 'ERROR: root is not a directory: %s\n' "$root" >&2; exit 2; }
root=$(cd "$root" && pwd -P)
if [[ "$profile" == auto ]]; then
  # Any source-only marker identifies a template, including a damaged template.
  # Installed stores contain none of these markers.
  if [[ -e "$root/.memory-protocol-template" || -e "$root/INSTALL_PROMPT.md" || -e "$root/scripts/test-validate-memory.sh" ]]; then
    profile=template
  else
    profile=installed
  fi
fi

temp_base=${TMPDIR:-/tmp}
if [[ -d "$temp_base" ]]; then temp_base=$(cd "$temp_base" && pwd -P); else temp_base=''; fi
case "$temp_base/" in "$root/"*) temp_base='';; esac
if [[ -z "$temp_base" ]]; then
  temp_base=$(cd "$root/.." && pwd -P)
  [[ "$temp_base" != "$root" ]] || {
    printf 'ERROR: no validator temporary directory is available outside the store.\n' >&2
    exit 2
  }
fi
validation_tmp=$(mktemp -d "$temp_base/validate-memory.XXXXXX") || {
  printf 'ERROR: could not create validator temporary directory outside the store.\n' >&2
  exit 2
}
case "$validation_tmp/" in
  "$root/"*) rm -rf "$validation_tmp"; printf 'ERROR: validator temporary directory resolved inside the store.\n' >&2; exit 2 ;;
esac
trap 'rm -rf "$validation_tmp"' EXIT

fatal_traversal() {
  printf 'ERROR: %s traversal failed; validation is incomplete.\n' "$1" >&2
  exit 1
}

collect_sorted_find() {
  local label=$1 output=$2 raw
  raw="$output.raw"
  shift 2
  find "$@" -print0 > "$raw" || fatal_traversal "$label"
  sort -z "$raw" > "$output" || fatal_traversal "$label sorting"
}

failures=0
fail() {
  printf 'ERROR: %s\n' "$*" >&2
  failures=$((failures + 1))
}

managed_dirs=(system projects reference skills inbox shared templates)
common_files=(
  .gitignore README.md AGENTS.md AGENT_MEMORY.md ADAPTERS.md CAPABILITIES.md DOCTOR.md
  DREAM.md HISTORY_INGEST.md INIT.md MEMFS_COMPATIBILITY.md SEARCH.md SYNC.md
  WORKTREES.md system/overview.md system/persona.md system/memory-policy.md
  projects/overview.md reference/README.md skills/README.md inbox/README.md
  shared/README.md templates/memory-file.md templates/project-overview.md
  templates/proposal.md templates/session-note.md templates/shared-attachment.md
  templates/doctor-report.md templates/skill/SKILL.md skills/memory-search/SKILL.md
)
root_docs=(README.md AGENTS.md AGENT_MEMORY.md ADAPTERS.md CAPABILITIES.md DOCTOR.md DREAM.md HISTORY_INGEST.md INIT.md MEMFS_COMPATIBILITY.md SEARCH.md SYNC.md WORKTREES.md)
if [[ "$profile" == template ]]; then
  common_files+=(.memory-protocol-template INSTALL_PROMPT.md scripts/test-validate-memory.sh)
  root_docs+=(INSTALL_PROMPT.md)
fi

for dir in "${managed_dirs[@]}" shared/attachments scripts; do
  [[ -d "$root/$dir" ]] || fail "$dir: required directory missing for $profile profile"
done
for rel in "${common_files[@]}" scripts/validate-memory.sh; do
  [[ -f "$root/$rel" && ! -L "$root/$rel" ]] || fail "$rel: required regular file missing for $profile profile"
done

is_root_doc() {
  local needle=$1 item
  for item in "${root_docs[@]}"; do [[ "$item" == "$needle" ]] && return 0; done
  return 1
}
is_managed_path() {
  local rel=$1 dir
  if [[ "$rel" != */* ]] && is_root_doc "$rel"; then return 0; fi
  for dir in "${managed_dirs[@]}"; do [[ "$rel" == "$dir/"* ]] && return 0; done
  return 1
}

# Discover Markdown everywhere except the three exact runtime roots, then reject unknown placement.
markdown_list="$validation_tmp/all-markdown"
collect_sorted_find "managed Markdown discovery" "$markdown_list" "$root" \
  \( -path "$root/.git" -o -path "$root/.letta" -o -path "$root/.pi-subagents" \) -prune -o \
  \( -type f -o -type l \) -name '*.md'
managed_markdown=()
while IFS= read -r -d '' file; do
  rel=${file#"$root/"}
  if is_managed_path "$rel"; then
    managed_markdown+=("$file")
  else
    fail "$rel: Markdown is outside declared managed roots/root documents"
  fi
done < "$markdown_list"

# Symlinks can escape traversal and are forbidden anywhere in managed roots.
for dir in "${managed_dirs[@]}"; do
  [[ -d "$root/$dir" ]] || continue
  link_list="$validation_tmp/symlinks-${dir//\//_}"
  collect_sorted_find "managed symlink discovery in $dir/" "$link_list" "$root/$dir" -type l
  while IFS= read -r -d '' link; do
    fail "${link#"$root/"}: symlink is forbidden in managed memory"
  done < "$link_list"
done

validate_description_scalar() {
  local value=$1 trimmed inner reduced i char next lower
  trimmed=$value
  trimmed="${trimmed#"${trimmed%%[![:space:]]*}"}"
  trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
  [[ -n "$trimmed" ]] || return 1

  lower=${trimmed,,}
  case "$lower" in
    \#*|'~'|'null'|'true'|'false'|'yes'|'no'|'on'|'off'|'.nan'|'.inf'|'+.inf'|'-.inf'|\[*|\{*|\|*|\>*|\&*|\**|\!*|\?*|\@*|\`*) return 1 ;;
  esac
  if [[ "$trimmed" == \'* ]]; then
    [[ ${#trimmed} -ge 2 && "${trimmed: -1}" == "'" ]] || return 1
    inner=${trimmed:1:${#trimmed}-2}
    reduced=${inner//\'\'/}
    [[ "$reduced" != *"'"* ]] || return 1
    inner=${inner//\'\'/\'}
    [[ -n "${inner//[[:space:]]/}" ]] || return 1
    return 0
  fi
  if [[ "$trimmed" == \"* ]]; then
    [[ ${#trimmed} -ge 2 && "${trimmed: -1}" == '"' ]] || return 1
    inner=${trimmed:1:${#trimmed}-2}
    reduced=''
    for ((i=0; i<${#inner}; i++)); do
      char=${inner:i:1}
      if [[ "$char" == '"' ]]; then return 1; fi
      if [[ "$char" == \\ ]]; then
        i=$((i+1)); (( i < ${#inner} )) || return 1
        next=${inner:i:1}
        case "$next" in
          t|n|v|f|r|' '|N|_|L|P) reduced+=' ' ;;
          0|a|b|e|\"|\\|/) reduced+=x ;;
          *) return 1 ;;
        esac
      else
        reduced+=$char
      fi
    done
    [[ -n "${reduced//[[:space:]]/}" ]] || return 1
    return 0
  fi
  # Quotes at only one edge, YAML comments, mapping separators, and complex
  # indicators are not accepted as Letta-compatible plain description scalars.
  if [[ "$trimmed" == *\' || "$trimmed" == *\" || "$trimmed" == *' #'* ]] ||
     [[ "$trimmed" =~ :[[:space:]] ]] || [[ "$trimmed" =~ ^-[[:space:]] ]] ||
     [[ ! "$trimmed" =~ ^[[:alpha:]] ]]; then
    return 1
  fi
  return 0
}

validate_frontmatter() {
  local file=$1 rel line close=-1 i key value
  local -a lines=() keys=() values=()
  rel=${file#"$root/"}
  [[ -f "$file" && ! -L "$file" ]] || return
  mapfile -t lines < "$file"
  if [[ ${lines[0]:-} != '---' ]]; then
    fail "$rel: frontmatter opening delimiter must be line 1"
    return
  fi
  for ((i=1; i<${#lines[@]} && i<=100; i++)); do
    if [[ ${lines[$i]} == '---' ]]; then close=$i; break; fi
  done
  if (( close < 0 )); then
    fail "$rel: frontmatter closing delimiter missing within first 101 lines"
    return
  fi
  for ((i=1; i<close; i++)); do
    line=${lines[$i]}
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ ^([A-Za-z][A-Za-z0-9_-]*):[[:space:]]*(.*)$ ]]; then
      key=${BASH_REMATCH[1]}; value=${BASH_REMATCH[2]}
      keys+=("$key"); values+=("$value")
    else
      fail "$rel:$((i+1)): unsupported or multiline frontmatter syntax"
    fi
  done
  local skill=false expected_name='' desc_count=0 name_count=0 unsupported=0
  if [[ "$rel" =~ ^skills/([^/]+)/SKILL\.md$ ]]; then
    skill=true; expected_name=${BASH_REMATCH[1]}
  fi
  for ((i=0; i<${#keys[@]}; i++)); do
    key=${keys[$i]}; value=${values[$i]}
    case "$key" in
      description)
        desc_count=$((desc_count+1))
        if ! validate_description_scalar "$value"; then
          fail "$rel: description must be a supported non-empty single-line scalar"
        fi
        ;;
      name)
        name_count=$((name_count+1))
        if [[ "$skill" != true ]]; then fail "$rel: unsupported frontmatter key: name"; unsupported=$((unsupported+1)); fi
        if [[ "$skill" == true && "$value" != "$expected_name" ]]; then
          fail "$rel: skill name '$value' does not match parent directory '$expected_name'"
        fi
        ;;
      *) fail "$rel: unsupported frontmatter key: $key"; unsupported=$((unsupported+1)) ;;
    esac
  done
  (( desc_count == 1 )) || fail "$rel: frontmatter must contain exactly one description (found $desc_count)"
  if [[ "$skill" == true ]]; then
    (( name_count == 1 )) || fail "$rel: skill frontmatter must contain exactly one name (found $name_count)"
    (( ${#keys[@]} == 2 )) || { (( unsupported > 0 )) || fail "$rel: skill frontmatter must contain exactly name and description"; }
  else
    (( ${#keys[@]} == 1 )) || { (( unsupported > 0 )) || fail "$rel: ordinary frontmatter must contain only description"; }
  fi
}

for file in "${managed_markdown[@]}"; do validate_frontmatter "$file"; done

# A file and directory may not share a stem.
for file in "${managed_markdown[@]}"; do
  [[ -f "$file" && ! -L "$file" ]] || continue
  stem=${file%.md}
  [[ ! -d "$stem" ]] || fail "${file#"$root/"}: file/directory stem conflict with ${stem#"$root/"}/"
done

parse_fence_open() {
  local text=$1 char count=0
  FENCE_CHAR=''; FENCE_LEN=0
  if [[ "$text" == '   '* ]]; then text=${text:3}
  elif [[ "$text" == '  '* ]]; then text=${text:2}
  elif [[ "$text" == ' '* ]]; then text=${text:1}
  fi
  char=${text:0:1}
  [[ "$char" == '`' || "$char" == '~' ]] || return 1
  while [[ ${text:count:1} == "$char" ]]; do count=$((count+1)); done
  (( count >= 3 )) || return 1
  FENCE_CHAR=$char; FENCE_LEN=$count
  return 0
}

is_fence_close() {
  local text=$1 char=$2 minimum=$3 count=0 rest
  if [[ "$text" == '   '* ]]; then text=${text:3}
  elif [[ "$text" == '  '* ]]; then text=${text:2}
  elif [[ "$text" == ' '* ]]; then text=${text:1}
  fi
  while [[ ${text:count:1} == "$char" ]]; do count=$((count+1)); done
  (( count >= minimum )) || return 1
  rest=${text:count}
  [[ -z "${rest//[[:space:]]/}" ]]
}

validate_policy() {
  local file="$root/system/memory-policy.md" rel=system/memory-policy.md
  [[ -f "$file" && ! -L "$file" ]] || return
  local openings=0 closings=0 in_block=0 models=0 valid=0 line_no=0 line value
  local outer_char='' outer_len=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no+1))
    if [[ -n "$outer_char" ]]; then
      if is_fence_close "$line" "$outer_char" "$outer_len"; then outer_char=''; outer_len=0; fi
      continue
    fi
    if (( in_block )); then
      if [[ "$line" == '```' ]]; then closings=$((closings+1)); in_block=0; continue; fi
      [[ -z "$line" ]] && continue
      if [[ "$line" =~ ^write_model:[[:space:]]*([^[:space:]]+)[[:space:]]*$ ]]; then
        models=$((models+1)); value=${BASH_REMATCH[1]}
        case "$value" in propose_then_approve|auto_write_with_git|session_notes_only|read_only) valid=$((valid+1));; *) fail "$rel:$line_no: invalid write_model '$value'";; esac
      else
        fail "$rel:$line_no: unsupported content in memory-policy block"
      fi
      continue
    fi
    if [[ "$line" == '```memory-policy' ]]; then openings=$((openings+1)); in_block=1; continue; fi
    if parse_fence_open "$line"; then outer_char=$FENCE_CHAR; outer_len=$FENCE_LEN; fi
  done < "$file"
  (( openings == 1 && closings == 1 && in_block == 0 )) || fail "$rel: must contain exactly one closed memory-policy block"
  (( models == 1 && valid == 1 )) || fail "$rel: memory-policy block must contain exactly one allowed write_model"
}
validate_policy

# Emit one token per visible wiki link and a marker for unmatched/malformed
# syntax. Content inside Markdown code fences is intentionally ignored.
extract_wiki_links() {
  awk '
  function fence(line,    s,c,n) {
    s=line
    if (substr(s,1,3)=="   ") s=substr(s,4)
    else if (substr(s,1,2)=="  ") s=substr(s,3)
    else if (substr(s,1,1)==" ") s=substr(s,2)
    c=substr(s,1,1)
    if (c!="`" && c!="~") return 0
    n=0; while (substr(s,n+1,1)==c) n++
    fence_char=c; fence_len=n; fence_rest=substr(s,n+1)
    return n>=3
  }
  {
    if (in_fence) {
      if (fence($0) && fence_char==outer_char && fence_len>=outer_len && fence_rest ~ /^[[:space:]]*$/) in_fence=0
      next
    }
    if (fence($0)) { in_fence=1; outer_char=fence_char; outer_len=fence_len; next }
    rest=$0
    while (length(rest)) {
      start=index(rest,"[["); stray=index(rest,"]]" )
      if (stray && (!start || stray < start)) {
        print NR "\t__MALFORMED__"; rest=substr(rest,stray+2); continue
      }
      if (!start) break
      rest=substr(rest,start+2)
      stop=index(rest,"]]" )
      if (!stop) { print NR "\t__MALFORMED__"; break }
      token=substr(rest,1,stop-1)
      if (token ~ /\[|\]/) print NR "\t__MALFORMED__"
      else print NR "\t" token
      rest=substr(rest,stop+2)
    }
  }' "$1"
}

template_placeholder_allowed() {
  local rel=$1 target=$2
  case "$rel:$target" in
    templates/memory-file.md:path/to/file.md|\
    templates/project-overview.md:reference/projects/project-name/architecture.md|\
    templates/project-overview.md:projects/project-name/conventions.md) return 0 ;;
  esac
  return 1
}

for file in "${managed_markdown[@]}"; do
  [[ -f "$file" && ! -L "$file" ]] || continue
  rel=${file#"$root/"}
  while IFS=$'\t' read -r line_no token; do
    if [[ "$token" == __MALFORMED__ ]]; then fail "$rel:$line_no: malformed wiki link"; continue; fi
    if [[ "$token" == *'|'*'|'* || "$token" == '|'* || "$token" == *'|' ]]; then
      fail "$rel:$line_no: malformed wiki link alias: [[$token]]"; continue
    fi
    target=${token%%|*}
    if [[ "$target" == *'#'* ]]; then
      anchor=${target#*#}; target=${target%%#*}
      [[ -n "$anchor" ]] || { fail "$rel:$line_no: malformed empty wiki-link anchor"; continue; }
    fi
    if [[ -z "$target" ]]; then fail "$rel:$line_no: malformed empty wiki-link target"; continue; fi
    if [[ "$target" == /* || "$target" == *://* ]]; then fail "$rel:$line_no: absolute wiki link is forbidden: $target"; continue; fi
    if [[ "$target" == '..' || "$target" == ../* || "$target" == */../* || "$target" == */.. ]]; then fail "$rel:$line_no: wiki link traverses parent: $target"; continue; fi
    if [[ "$target" == ./* || "$target" == *//* || "$target" == *\\* || ! "$target" =~ ^[A-Za-z0-9._/-]+\.md$ ]]; then
      fail "$rel:$line_no: malformed root-relative wiki link: $target"; continue
    fi
    if [[ -d "$root/$target" ]]; then fail "$rel:$line_no: wiki link targets a directory: $target"
    elif [[ ! -f "$root/$target" ]]; then
      template_placeholder_allowed "$rel" "$target" || fail "$rel:$line_no: broken wiki link: $target"
    fi
  done < <(extract_wiki_links "$file")
done

validate_attachment() {
  local file=$1 enforce_id=$2 rel line line_no=0 in_block=0 openings=0 closings=0 key value
  local outer_char='' outer_len=0
  rel=${file#"$root/"}
  local -a keys=() values=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no+1))
    if [[ -n "$outer_char" ]]; then
      if is_fence_close "$line" "$outer_char" "$outer_len"; then outer_char=''; outer_len=0; fi
      continue
    fi
    if (( in_block )); then
      if [[ "$line" == '```' ]]; then closings=$((closings+1)); in_block=0; continue; fi
      [[ -z "$line" ]] && continue
      if [[ "$line" =~ ^([a-z_]+):[[:space:]]*(.*)$ ]]; then
        keys+=("${BASH_REMATCH[1]}"); values+=("${BASH_REMATCH[2]}")
      else fail "$rel:$line_no: malformed memory-attachment field"; fi
      continue
    fi
    if [[ "$line" == '```memory-attachment' ]]; then openings=$((openings+1)); in_block=1; continue; fi
    if parse_fence_open "$line"; then outer_char=$FENCE_CHAR; outer_len=$FENCE_LEN; fi
  done < "$file"
  (( openings == 1 && closings == 1 && in_block == 0 )) || { fail "$rel: must contain exactly one closed memory-attachment block"; return; }
  local required_keys=(id remote ref access update_policy required) wanted count i id='' remote='' ref='' access='' update_policy='' required=''
  for wanted in "${required_keys[@]}"; do
    count=0
    for ((i=0;i<${#keys[@]};i++)); do
      if [[ ${keys[$i]} == "$wanted" ]]; then count=$((count+1)); value=${values[$i]}; printf -v "$wanted" '%s' "$value"; fi
    done
    (( count == 1 )) || fail "$rel: attachment key '$wanted' must occur exactly once (found $count)"
  done
  for key in "${keys[@]}"; do
    case "$key" in id|remote|ref|access|update_policy|required) ;; *) fail "$rel: unsupported attachment key: $key";; esac
  done
  [[ "$id" =~ ^[a-z0-9][a-z0-9._-]*$ ]] || fail "$rel: attachment id is invalid: $id"
  if [[ "$enforce_id" == true ]]; then
    expected=${file##*/}; expected=${expected%.md}
    [[ "$id" == "$expected" ]] || fail "$rel: attachment id '$id' does not match filename '$expected'"
  fi
  [[ "$access" == read_only || "$access" == read_write ]] || fail "$rel: attachment access must be read_only or read_write"
  [[ "$update_policy" == tracking || "$update_policy" == pinned ]] || fail "$rel: attachment update_policy must be tracking or pinned"
  [[ "$required" == true || "$required" == false ]] || fail "$rel: attachment required must be true or false"
  if [[ "$update_policy" == tracking ]]; then
    if [[ ! "$ref" =~ ^refs/(heads|tags)/[^[:space:]]+$ ]] || ! git check-ref-format "$ref" >/dev/null 2>&1; then
      fail "$rel: tracking attachment ref must be a valid explicit heads/tags ref"
    fi
  fi
  if [[ "$update_policy" == pinned && ! "$ref" =~ ^([0-9A-Fa-f]{40}|[0-9A-Fa-f]{64})$ ]]; then fail "$rel: pinned attachment ref must be a full 40- or 64-hex object id"; fi
  if [[ -z "$remote" || "$remote" =~ [[:space:]] || "$remote" == /* || "$remote" == ~* || "$remote" == file:* || "$remote" == *'?'* || "$remote" == *'#'* ]]; then
    fail "$rel: attachment remote must be a non-empty credential-free non-local Git URL"
  elif [[ "$remote" =~ ://[^/]*@ ]]; then
    fail "$rel: attachment remote embeds credentials or userinfo"
  elif [[ ! "$remote" =~ ^(https?|ssh|git)://[^/[:space:]]+/.+ && ! "$remote" =~ ^[^@[:space:]]+@[^:[:space:]]+:.+ ]]; then
    fail "$rel: attachment remote syntax is unsupported"
  fi
}

# Real descriptors are direct children only; nested Markdown attachment placement is invalid.
attachment_direct_list="$validation_tmp/attachment-direct"
attachment_nested_list="$validation_tmp/attachment-nested"
collect_sorted_find "attachment descriptor discovery" "$attachment_direct_list" "$root/shared/attachments" -mindepth 1 -maxdepth 1 -type f -name '*.md'
collect_sorted_find "nested attachment discovery" "$attachment_nested_list" "$root/shared/attachments" -mindepth 2 -type f -name '*.md'
while IFS= read -r -d '' file; do validate_attachment "$file" true; done < "$attachment_direct_list"
while IFS= read -r -d '' file; do fail "${file#"$root/"}: attachment descriptor must be directly under shared/attachments/"; done < "$attachment_nested_list"
[[ -f "$root/templates/shared-attachment.md" ]] && validate_attachment "$root/templates/shared-attachment.md" false

system_bytes=0
if [[ -d "$root/system" ]]; then
  system_list="$validation_tmp/system-markdown"
  collect_sorted_find "system size discovery" "$system_list" "$root/system" -type f -name '*.md'
  while IFS= read -r -d '' file; do
    if ! bytes=$(wc -c < "$file"); then fatal_traversal "system size read"; fi
    system_bytes=$((system_bytes + bytes))
  done < "$system_list"
fi
(( system_bytes <= 49152 )) || fail "system/: portable bootstrap guard exceeded ($system_bytes > 49152 bytes)"

if (( failures > 0 )); then
  printf 'Validation failed with %d error(s) (profile=%s).\n' "$failures" "$profile" >&2
  exit 1
fi
printf 'Memory structure valid (profile=%s; root=%s; system=%s bytes).\n' "$profile" "$root" "$system_bytes"
