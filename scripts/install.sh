#!/usr/bin/env bash
# Install instruction fragments and skills into a target project.
#
# Usage:
#   scripts/install.sh <target-dir> <item> [<item>...] [--copy]
#
#   <item>  path relative to this repo, e.g.
#             instructions/python.md
#             skills/create-pr
#             templates/adr.md
#
#   --copy  copy skills into harness dirs instead of symlinking
#           (use if a harness does not follow symlinked skill dirs)
#
# Layout created in the target:
#   .agents/instructions/*.md     canonical copies
#   .agents/skills/<name>/        canonical copies
#   .claude/skills/<name>         link or copy
#   .opencode/skill/<name>        link or copy
#   .agents/templates/...         canonical copies
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
args=()
for a in "$@"; do
  case "$a" in
    --copy) MODE=copy ;;
    *) args+=("$a") ;;
  esac
done

[ ${#args[@]} -ge 2 ] || { sed -n '2,25p' "$0" | sed 's/^# \?//'; exit 1; }

TARGET="$(cd "${args[0]}" 2>/dev/null && pwd)" || { echo "no such directory: ${args[0]}" >&2; exit 1; }
items=("${args[@]:1}")

mkdir -p "$TARGET/.agents/instructions" "$TARGET/.agents/skills"

# Insert the provenance comment after YAML frontmatter if present, else at top.
# The hash is of the upstream file at install time. sync.sh uses it to tell
# "upstream moved" apart from "I edited this copy".
stamp_file() { # src dst relpath
  local h
  h="$(sha256sum "$1" | cut -c1-12)"
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
      ln -s "$(realpath --relative-to="$dest" "$src")" "$dest/$name"
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
for entry in ${installed_instructions[@]+"${installed_instructions[@]}"}; do
  IFS=$'\t' read -r load rel when <<< "$entry"
  if [ "$load" = eager ]; then
    marker="<!-- install:eager -->"; line="@$rel"
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

# CLAUDE.md -> AGENTS.md
if [ ! -e "$TARGET/CLAUDE.md" ]; then
  ln -s AGENTS.md "$TARGET/CLAUDE.md"
  echo "linked      CLAUDE.md -> AGENTS.md"
elif [ ! -L "$TARGET/CLAUDE.md" ]; then
  echo "warning     CLAUDE.md exists and is a real file, not linked to AGENTS.md" >&2
fi

echo
echo "Installed at $STAMP. Now read each copy and adapt it to this project."
