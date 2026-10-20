#!/usr/bin/env bash
# Claude Code PostToolUse hook. Runs the markdown style linter on a file the
# agent just wrote, and feeds violations back so it fixes them in the same turn.
#
# Install: copy harness/claude-code/settings.json into the project's
# .claude/settings.json (or merge the hooks block) and point STYLE_CHECK at
# your checkout of this repo.
#
# Exit 2 returns stderr to the model as a blocking error.

set -uo pipefail

STYLE_CHECK="${STYLE_CHECK:-$HOME/dev/agentic-development/scripts/style-check.sh}"
[ -x "$STYLE_CHECK" ] || exit 0

# Neither macOS nor NixOS guarantees python3 or jq on PATH, and a hook that
# silently does nothing is worse than one that is absent. Fall back to sed.
payload=$(cat)
extract() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null && return
  fi
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$payload" | python3 -c \
      'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' \
      2>/dev/null && return
  fi
  printf '%s' "$payload" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
}
file=$(extract)

case "$file" in
  *.md|*.markdown) ;;
  *) exit 0 ;;
esac
[ -f "$file" ] || exit 0

if ! out=$("$STYLE_CHECK" "$file" 2>&1); then
  {
    echo "Style violations in $file. Fix them now, do not ask."
    echo "$out"
  } >&2
  exit 2
fi
exit 0
