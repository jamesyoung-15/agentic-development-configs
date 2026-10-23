#!/usr/bin/env bash
# Install instruction fragments and skills into a target project.
#
# Usage:
#   scripts/install.sh <target> <item>...     install these
#   scripts/install.sh <target> --preset NAME install a named set, see presets/
#   scripts/install.sh <target>               pick from a list (needs fzf)
#   scripts/install.sh <target> --update      reinstall what the manifest lists
#
#   <item>  path relative to this repo, e.g.
#             instructions/python.md
#             skills/create-pr
#             templates/adr.md
#
#   --copy  copy skills into harness dirs instead of symlinking
#           (use if a harness does not follow symlinked skill dirs)
#
# Every run records what the project has in .agents/manifest. Only the picker
# needs fzf; presets and explicit lists have no dependencies.
#
# Layout created in the target:
#   .agents/instructions/*.md     canonical copies
#   .agents/skills/<name>/        canonical copies
#   .claude/skills/<name>         link or copy
#   .opencode/skill/<name>        link or copy
#   .agents/templates/...         canonical copies
#   .agents/manifest              what this project has installed
#   opencode.json                 instructions array, eager fragments only
#   AGENTS.md                     from templates/agents-md.md if missing
#   CLAUDE.md                     symlink to AGENTS.md
#
# Each instruction declares how it loads, on its first line:
#   <!-- load: eager  | when: ... -->   becomes an @import, in context always
#   <!-- load: routed | when: ... -->   becomes a row in "Where to look"
# No directive means routed, since eager costs context on every turn.
#
# Copies are stamped with a provenance comment so scripts/sync.sh can
# report drift later. Edit the copies, not this repo.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(cat "$REPO/VERSION" 2>/dev/null || echo unknown)"
SHA="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo nogit)"
STAMP="$VERSION+$SHA"

MODE=link
PRESET=
UPDATE=0
args=()
while [ $# -gt 0 ]; do
  case "$1" in
    --copy)     MODE=copy ;;
    --update)   UPDATE=1 ;;
    --preset)   [ $# -ge 2 ] || { echo "--preset needs a name" >&2; exit 1; }
                PRESET=$2; shift ;;
    --preset=*) PRESET=${1#*=} ;;
    *)          args+=("$1") ;;
  esac
  shift
done

[ ${#args[@]} -ge 1 ] || { sed -n '2,32p' "$0" | sed 's/^# \?//'; exit 1; }

TARGET="$(cd "${args[0]}" 2>/dev/null && pwd)" || { echo "no such directory: ${args[0]}" >&2; exit 1; }
items=(${args[@]+"${args[@]:1}"})
MANIFEST="$TARGET/.agents/manifest"

# One repo-relative path per line, # for comments. Same shape as a preset file.
read_list() { # file -> appends to items
  local l
  while IFS= read -r l || [ -n "$l" ]; do
    case "$l" in ''|'#'*) ;; *) items+=("$l") ;; esac
  done < "$1"
}

presets() { ls "$REPO/presets/" 2>/dev/null | sed 's/\.txt$//' | tr '\n' ' '; }

no_picker_help() {
  cat >&2 <<HELP
no picker available (fzf not installed)

  install.sh <target> --preset <name>     $(presets)
  install.sh <target> <item>...           see catalog.md
  install.sh <target> --update            reinstall what the manifest lists
HELP
}

# "path  [installed]  description", so the picker needs no preview subprocess.
list_installable() {
  local f name desc mark
  for f in "$REPO"/instructions/*.md; do
    name="instructions/$(basename "$f")"
    desc=$(sed -n '1s/.*when: *\(.*[^ ]\) *-->/\1/p' "$f")
    printf '%s\t%s\n' "$name" "$desc"
  done
  for f in "$REPO"/skills/*/; do
    name="skills/$(basename "$f")"
    desc=$(sed -n 's/^description: *//p' "$f/SKILL.md" | head -1 | cut -c1-90)
    printf '%s\t%s\n' "$name" "$desc"
  done
  for f in $(cd "$REPO" && find templates -name '*.md' ! -name 'agents-md.md' | sort); do
    printf '%s\t%s\n' "$f" "template"
  done
}

pick_items() {
  local installed=""
  [ -f "$MANIFEST" ] && installed=$(tr '\n' '|' < "$MANIFEST")
  list_installable | while IFS=$'\t' read -r name desc; do
    case "|$installed" in *"|$name|"*) mark="installed" ;; *) mark="" ;; esac
    printf '%-34s %-10s %s\n' "$name" "$mark" "$desc"
  done | fzf --multi --height 80% --reverse \
             --header 'tab to select, enter to confirm, ctrl-c to abort' \
      | awk '{print $1}'
}

if [ -n "$PRESET" ]; then
  [ -f "$REPO/presets/$PRESET.txt" ] || {
    echo "no such preset: $PRESET (have: $(presets))" >&2; exit 1; }
  read_list "$REPO/presets/$PRESET.txt"
elif [ "$UPDATE" -eq 1 ]; then
  [ -f "$MANIFEST" ] || { echo "no manifest at $MANIFEST, nothing to update" >&2; exit 1; }
  read_list "$MANIFEST"
elif [ ${#items[@]} -eq 0 ]; then
  # Check here, not inside pick_items: that runs in a process-substitution
  # subshell, where exit would only leave the subshell.
  command -v fzf >/dev/null 2>&1 || { no_picker_help; exit 1; }
  while IFS= read -r l; do [ -n "$l" ] && items+=("$l"); done < <(pick_items)
  [ ${#items[@]} -gt 0 ] || { echo "nothing selected" >&2; exit 0; }
fi

mkdir -p "$TARGET/.agents/instructions" "$TARGET/.agents/skills"

# macOS ships BSD tools, so no sha256sum and no `realpath --relative-to`.
if command -v sha256sum >/dev/null 2>&1; then
  sha256() { sha256sum "$@"; }
elif command -v shasum >/dev/null 2>&1; then
  sha256() { shasum -a 256 "$@"; }
else
  echo "need sha256sum or shasum on PATH" >&2; exit 1
fi

# Portable `realpath --relative-to=$1 $2`. Both arguments are absolute and
# share a prefix here, which keeps this simple.
relpath() { # from-dir to-path
  local from=${1%/} to=${2%/} up=
  while [ -n "$from" ] && [ "$to" != "$from" ] && [ "${to#"$from"/}" = "$to" ]; do
    from=${from%/*}
    up="../$up"
  done
  printf '%s%s\n' "$up" "${to#"$from"/}"
}

# Insert the provenance comment after YAML frontmatter if present, else at top.
# The hash is of the upstream file at install time. sync.sh uses it to tell
# "upstream moved" apart from "I edited this copy".
stamp_file() { # src dst relpath
  local h
  h="$(sha256 "$1" | cut -c1-12)"
  awk -v line="<!-- from: agentic-development/$3 @ $STAMP sha:$h -->" '
    NR == 1 && $0 == "---" { print; fm = 1; next }
    fm && $0 == "---"      { print; print ""; print line; fm = 0; done = 1; next }
    !done && !fm           { print line; print ""; done = 1 }
                           { print }
  ' "$1" > "$2"
}

place() { # canonical-dir name
  local src=$1 name=$2 dest
  for dest in "$TARGET/.claude/skills" "$TARGET/.opencode/skill"; do
    mkdir -p "$dest"
    rm -rf "${dest:?}/$name"
    if [ "$MODE" = link ]; then
      ln -s "$(relpath "$dest" "$src")" "$dest/$name"
      [ -e "$dest/$name" ] || { echo "broken symlink at $dest/$name, re-run with --copy" >&2; exit 1; }
    else
      cp -r "$src" "$dest/$name"
    fi
  done
}

installed_instructions=()

for item in "${items[@]}"; do
  src="$REPO/${item%/}"
  [ -e "$src" ] || { echo "not found in repo: $item" >&2; exit 1; }

  if [ -d "$src" ]; then
    name="$(basename "$src")"
    canon="$TARGET/.agents/skills/$name"
    mkdir -p "$canon"
    for f in "$src"/*; do
      if [ -f "$f" ]; then
        case "$f" in
          *.md) stamp_file "$f" "$canon/$(basename "$f")" "$item/$(basename "$f")" ;;
          *)    cp "$f" "$canon/" ;;
        esac
      else
        cp -r "$f" "$canon/"
      fi
    done
    place "$canon" "$name"
    echo "skill       $name"
  else
    base="$(basename "$src")"
    case "$item" in
      templates/*) dst="$TARGET/.agents/templates/${item#templates/}"
                   mkdir -p "$(dirname "$dst")" ;;
      *)           dst="$TARGET/.agents/instructions/$base"
                   # "<!-- load: eager|routed | when: ... -->" on the first line
                   d=$(sed -n '1s/^<!-- load: *\([a-z]*\) *| *when: *\(.*[^ ]\) *-->$/\1\t\2/p' "$src")
                   load=${d%%$'\t'*}; when=${d#*$'\t'}
                   [ -n "$d" ] || { load=routed; when="(set a load directive in $item)"; }
                   installed_instructions+=("$load"$'\t'".agents/instructions/$base"$'\t'"$when") ;;
    esac
    stamp_file "$src" "$dst" "$item"
    printf 'file        %s%s\n' "${dst#"$TARGET"/}" "${load:+ [$load]}"
    unset load when
  fi
done

# AGENTS.md. Eager fragments become @imports, which load every session.
# Routed fragments become rows the agent reads only when the task matches.
AG="$TARGET/AGENTS.md"
if [ ! -e "$AG" ]; then
  sed "s/{{PROJECT}}/$(basename "$TARGET")/" "$REPO/templates/agents-md.md" > "$AG"
  echo "created     AGENTS.md from templates/agents-md.md"
fi

insert_after() { # marker, line
  grep -qF "$2" "$AG" && return 0
  awk -v marker="$1" -v line="$2" '
    { print }
    index($0, marker) { print line }
  ' "$AG" > "$AG.tmp" && mv "$AG.tmp" "$AG"
}

missing_marker=0
eager_rels=()
for entry in ${installed_instructions[@]+"${installed_instructions[@]}"}; do
  IFS=$'\t' read -r load rel when <<< "$entry"
  if [ "$load" = eager ]; then
    marker="<!-- install:eager -->"; line="@$rel"
    eager_rels+=("$rel")
  else
    marker="<!-- install:routed -->"; line="| $when | \`$rel\` |"
  fi
  if grep -qF "$marker" "$AG"; then
    insert_after "$marker" "$line"
  else
    missing_marker=1
    printf 'warning     no %s in AGENTS.md, add by hand:\n            %s\n' "$marker" "$line" >&2
  fi
done
[ "$missing_marker" -eq 1 ] && echo "            (markers come from templates/agents-md.md)" >&2

# Opencode does not expand the @import lines Claude Code uses, so eager fragments
# would silently never load. Its equivalent is the instructions array in
# opencode.json. Routed fragments stay out of it, or the split means nothing.
# AGENTS.md itself is read automatically, so it is not listed here.
wire_opencode() {
  [ ${#eager_rels[@]} -gt 0 ] || return 0
  local f="$TARGET/opencode.json" i first=1

  if [ -f "$TARGET/opencode.jsonc" ]; then
    echo "warning     opencode.jsonc present, not editing it (comments). Add to its" >&2
    echo "            instructions array:" >&2
    printf '              "%s"\n' "${eager_rels[@]}" >&2
    return 0
  fi

  if [ ! -f "$f" ]; then
    {
      printf '{\n  "$schema": "https://opencode.ai/config.json",\n  "instructions": [\n'
      for i in "${eager_rels[@]}"; do
        [ $first -eq 1 ] && first=0 || printf ',\n'
        printf '    "%s"' "$i"
      done
      printf '\n  ]\n}\n'
    } > "$f"
    echo "created     opencode.json, ${#eager_rels[@]} eager instructions"
    opencode_reload_hint
    return 0
  fi

  command -v python3 >/dev/null 2>&1 || {
    echo "warning     opencode.json exists and python3 is missing, cannot merge." >&2
    echo "            Add to its instructions array:" >&2
    printf '              "%s"\n' "${eager_rels[@]}" >&2
    return 0
  }
  # exit 3 from the helper means nothing changed, so no reload is needed.
  python3 - "$f" "${eager_rels[@]}" <<'PYEOF'
import json, sys, pathlib
path = pathlib.Path(sys.argv[1])
doc = json.loads(path.read_text())
cur = doc.get("instructions", [])
added = [x for x in sys.argv[2:] if x not in cur]
doc["instructions"] = cur + added
path.write_text(json.dumps(doc, indent=2) + "\n")
print(f"opencode    merged {len(added)} new into opencode.json instructions")
sys.exit(0 if added else 3)
PYEOF
  [ $? -eq 3 ] || opencode_reload_hint
}

# Opencode caches project config, so an already-open session will not see a new
# or changed instructions array until it is told to re-read.
opencode_reload_hint() {
  echo "            run /reload in any open Opencode session on this project"
}

wire_opencode

# CLAUDE.md -> AGENTS.md
if [ ! -e "$TARGET/CLAUDE.md" ]; then
  ln -s AGENTS.md "$TARGET/CLAUDE.md"
  echo "linked      CLAUDE.md -> AGENTS.md"
elif [ ! -L "$TARGET/CLAUDE.md" ]; then
  echo "warning     CLAUDE.md exists and is a real file, not linked to AGENTS.md" >&2
fi

# Record what this project has, so later runs need no arguments and sync can
# tell an item that was never installed from one that was deleted.
{ [ -f "$MANIFEST" ] && cat "$MANIFEST"; printf '%s\n' "${items[@]}"; } \
  | sed '/^[[:space:]]*$/d' | sort -u > "$MANIFEST.tmp"
mv "$MANIFEST.tmp" "$MANIFEST"
echo "manifest    $(grep -c . "$MANIFEST") items in .agents/manifest"

# Installed files reference each other by their post-install path. Flag any
# reference that points at something not installed here, rather than leaving a
# dead path in a live file.
dangling=$(grep -rhoE '\.agents/[a-zA-Z0-9_./-]+\.md' "$TARGET/.agents" 2>/dev/null \
  | sort -u | while read -r ref; do [ -e "$TARGET/$ref" ] || echo "$ref"; done)
if [ -n "$dangling" ]; then
  echo
  echo "warning     installed files reference these, which are not installed:" >&2
  printf '            %s\n' $dangling >&2
  echo "            install them too, or edit the references out of the copies." >&2
fi

echo
echo "Installed at $STAMP. Now read each copy and adapt it to this project."
