#!/usr/bin/env bash
# Wire personal profiles into a harness's global config. Machine-level, not
# per-project. Run once per machine, per harness.
#
# Usage:
#   scripts/install-profile.sh claude-code
#   scripts/install-profile.sh opencode
#   scripts/install-profile.sh all
#
# Never overwrites. If the target already exists, it prints the line to add
# and leaves the file alone.

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILES=("$REPO/profiles/james.md")

[ $# -ge 1 ] || { sed -n '2,13p' "$0" | sed 's/^# \?//'; exit 1; }

note()  { printf '  %s\n' "$1"; }
exists(){ printf '  exists, leave it. Add this yourself:\n    %s\n' "$1"; }

install_claude_code() {
  local dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  local f="$dir/CLAUDE.md"
  echo "claude-code -> $f"
  mkdir -p "$dir"
  if [ -e "$f" ]; then
    for p in "${PROFILES[@]}"; do
      grep -qF "$p" "$f" || exists "@$p"
    done
  else
    { echo "# Personal"; echo; for p in "${PROFILES[@]}"; do echo "@$p"; done; } > "$f"
    note "created"
  fi
}

install_opencode() {
  local dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
  local f="$dir/AGENTS.md"
  echo "opencode -> $f"
  mkdir -p "$dir"
  if [ -e "$f" ]; then
    note "exists, leave it. Opencode has no include syntax, so either paste the"
    note "profile contents in, or list the files in opencode.json:"
    list=""
    for p in "${PROFILES[@]}"; do list="$list${list:+, }\"$p\""; done
    note "  \"instructions\": [$list]"
  else
    { for p in "${PROFILES[@]}"; do cat "$p"; echo; done; } > "$f"
    note "created as a copy (no include syntax). Re-run after editing a profile."
  fi
}

case "$1" in
  claude-code) install_claude_code ;;
  opencode)    install_opencode ;;
  all)         install_claude_code; install_opencode ;;
  *) echo "unknown harness: $1. Expected claude-code, opencode, or all." >&2; exit 1 ;;
esac

echo
echo "Verify the paths against your harness version before relying on this."
