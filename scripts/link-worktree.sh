#!/usr/bin/env bash
# Link this project's agent config into a git worktree.
#
# git worktree add carries tracked files only. Anything gitignored, often
# .agents/ or .claude/, is simply absent in a new worktree, so the agent starts
# there with no instructions and no skills and says nothing about it.
#
# Usage:
#   scripts/link-worktree.sh <worktree-dir>
#
# Run from anywhere inside the repo. Works per item, so a project that tracks
# some of its config and ignores the rest gets only the missing parts linked.
# Anything already present is left alone, so re-running is safe.
#
# Links are relative, so moving the directory that contains both checkouts
# keeps them working.

set -uo pipefail

# Finer-grained than the top-level dirs on purpose: a project can track
# .claude/settings.json while ignoring .claude/skills, and the skills are the
# part that breaks silently.
# STATE.md and JOURNAL.md are deliberately absent: they are per-working-tree.
# Sharing state across two threads of work loses one of them on every rewrite.
ITEMS=(.agents AGENTS.md CLAUDE.md opencode.json
       .claude/skills .claude/settings.json .opencode/skill)

[ $# -eq 1 ] || { sed -n '2,16p' "$0" | sed 's/^# \?//'; exit 1; }

git rev-parse --git-dir >/dev/null 2>&1 || { echo "not inside a git repo" >&2; exit 1; }

SRC=$(git worktree list --porcelain | sed -n '1s/^worktree //p')
DST=$(cd "$1" 2>/dev/null && pwd) || { echo "no such directory: $1" >&2; exit 1; }
[ -n "$SRC" ] || { echo "could not find the main worktree" >&2; exit 1; }
[ "$SRC" != "$DST" ] || { echo "that is the main worktree, nothing to link" >&2; exit 1; }

# Same as install.sh. BSD realpath has no --relative-to.
relpath() { # from-dir to-path
  local from=${1%/} to=${2%/} up=
  while [ -n "$from" ] && [ "$to" != "$from" ] && [ "${to#"$from"/}" = "$to" ]; do
    from=${from%/*}
    up="../$up"
  done
  printf '%s%s\n' "$up" "${to#"$from"/}"
}

linked=0 present=0
for item in "${ITEMS[@]}"; do
  [ -e "$SRC/$item" ] || continue
  if [ -e "$DST/$item" ] || [ -L "$DST/$item" ]; then
    printf 'present     %s\n' "$item"
    present=$((present + 1))
    continue
  fi
  mkdir -p "$(dirname "$DST/$item")"
  ln -s "$(relpath "$(dirname "$DST/$item")" "$SRC/$item")" "$DST/$item"
  [ -e "$DST/$item" ] || { echo "broken symlink at $DST/$item" >&2; exit 1; }
  printf 'linked      %s\n' "$item"
  linked=$((linked + 1))
done

echo
echo "$linked linked, $present already there."
[ "$linked" -eq 0 ] && echo "Nothing to link."
exit 0
