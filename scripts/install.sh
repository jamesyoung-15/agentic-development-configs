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
#   AGENTS.md                     index, created if missing
#   CLAUDE.md                     symlink to AGENTS.md
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
      templates/*) dst="$TARGET/.agents/templates/$base"; mkdir -p "$(dirname "$dst")" ;;
      *)           dst="$TARGET/.agents/instructions/$base"
                   installed_instructions+=(".agents/instructions/$base") ;;
    esac
    stamp_file "$src" "$dst" "$item"
    echo "file        ${dst#"$TARGET"/}"
  fi
done

# AGENTS.md index
AG="$TARGET/AGENTS.md"
if [ ! -e "$AG" ]; then
  printf '# Agent Instructions\n\n<!-- Project-specific rules go here. -->\n\n## Standards\n\n' > "$AG"
  echo "created     AGENTS.md"
fi
for rel in ${installed_instructions[@]+"${installed_instructions[@]}"}; do
  grep -qF "$rel" "$AG" || printf -- '- @%s\n' "$rel" >> "$AG"
done

# CLAUDE.md -> AGENTS.md
if [ ! -e "$TARGET/CLAUDE.md" ]; then
  ln -s AGENTS.md "$TARGET/CLAUDE.md"
  echo "linked      CLAUDE.md -> AGENTS.md"
elif [ ! -L "$TARGET/CLAUDE.md" ]; then
  echo "warning     CLAUDE.md exists and is a real file, not linked to AGENTS.md" >&2
fi

echo
echo "Installed at $STAMP. Now read each copy and adapt it to this project."
