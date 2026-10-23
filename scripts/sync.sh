#!/usr/bin/env bash
# Report which installed fragments in a project are behind this repo.
# Never overwrites. You decide per file whether local edits should survive.
#
# Usage: scripts/sync.sh <target-dir> [--diff]
#
# Statuses:
#   CURRENT   identical to upstream
#   BEHIND    upstream changed, this copy was never edited. Safe to overwrite
#   LOCAL     this copy was edited, upstream unchanged. Nothing to do
#   DIVERGED  both changed. Read the diff and merge by hand
#   GONE      upstream file no longer exists
#   DELETED   the manifest lists it but it is not in the project any more

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# macOS ships BSD tools, so no sha256sum.
if command -v sha256sum >/dev/null 2>&1; then
  sha256() { sha256sum "$@"; }
elif command -v shasum >/dev/null 2>&1; then
  sha256() { shasum -a 256 "$@"; }
else
  echo "need sha256sum or shasum on PATH" >&2; exit 1
fi

[ $# -ge 1 ] || { echo "usage: scripts/sync.sh <target-dir> [--diff]" >&2; exit 1; }
TARGET="$(cd "$1" && pwd)" || exit 1
SHOW_DIFF=${2:-}

# Strip the provenance line and the blank line install.sh adds after it,
# recovering the original upstream bytes.
original() {
  awk '/<!-- from: agentic-development\// { skip = 1; next }
       skip && $0 == "" { skip = 0; next }
       { skip = 0; print }' "$1"
}

n_current=0; n_behind=0; n_local=0; n_diverged=0

while IFS= read -r f; do
  header=$(grep -m1 -o 'from: agentic-development/[^ ]* @ [^ ]* sha:[0-9a-f]*' "$f") || continue
  rel=${header#from: agentic-development/}; rel=${rel%% @ *}
  ver=${header#* @ }; ver=${ver%% *}
  installed_sha=${header##*sha:}
  upstream="$REPO/$rel"
  short="${f#"$TARGET"/}"

  if [ ! -e "$upstream" ]; then
    printf 'GONE      %s (upstream %s was removed)\n' "$short" "$rel"
    continue
  fi

  local_sha=$(original "$f" | sha256 | cut -c1-12)
  upstream_sha=$(sha256 "$upstream" | cut -c1-12)

  edited_here=0; moved_upstream=0
  [ "$local_sha" != "$installed_sha" ] && edited_here=1
  [ "$upstream_sha" != "$installed_sha" ] && moved_upstream=1

  if [ "$local_sha" = "$upstream_sha" ]; then
    n_current=$((n_current+1))
    [ "$SHOW_DIFF" = "--diff" ] && printf 'CURRENT   %s\n' "$short"
    continue
  fi

  if [ "$edited_here" -eq 1 ] && [ "$moved_upstream" -eq 1 ]; then
    printf 'DIVERGED  %s (installed at %s, both sides changed)\n' "$short" "$ver"
    n_diverged=$((n_diverged+1))
  elif [ "$moved_upstream" -eq 1 ]; then
    printf 'BEHIND    %s (installed at %s, never edited here)\n' "$short" "$ver"
    n_behind=$((n_behind+1))
  else
    printf 'LOCAL     %s (edited for this project)\n' "$short"
    n_local=$((n_local+1))
  fi

  if [ "$SHOW_DIFF" = "--diff" ]; then
    diff -u --label "installed: $short" --label "upstream: $rel" \
      <(original "$f") "$upstream" | sed 's/^/    /'
  fi
done < <(grep -rl 'from: agentic-development/' "$TARGET/.agents" 2>/dev/null | sort)

# The scan above only sees files that exist. The manifest also records what was
# installed, so it can catch an item that was deleted from the project.
n_gone=0
MANIFEST="$TARGET/.agents/manifest"
if [ -f "$MANIFEST" ]; then
  while IFS= read -r item; do
    case "$item" in ''|'#'*) continue ;; esac
    case "$item" in
      skills/*)       expect=".agents/skills/${item#skills/}/SKILL.md" ;;
      templates/*)    expect=".agents/templates/${item#templates/}" ;;
      instructions/*) expect=".agents/instructions/${item#instructions/}" ;;
      *)              expect=".agents/$item" ;;
    esac
    [ -e "$TARGET/$expect" ] || {
      printf 'DELETED   %s (in manifest, not on disk)\n' "$item"
      n_gone=$((n_gone+1))
    }
  done < "$MANIFEST"
fi

printf '\n%d current, %d behind, %d local, %d diverged' \
  "$n_current" "$n_behind" "$n_local" "$n_diverged"
[ "$n_gone" -gt 0 ] && printf ', %d deleted' "$n_gone"
printf '.\n'
[ "$n_behind" -gt 0 ] && echo "BEHIND files can be reinstalled with scripts/install.sh."
[ "$n_diverged" -gt 0 ] && echo "DIVERGED files need a hand merge. Run with --diff."
exit 0
