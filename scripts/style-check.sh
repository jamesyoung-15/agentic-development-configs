#!/usr/bin/env bash
# Flag banned style patterns in markdown prose.
# Usage: scripts/style-check.sh FILE [FILE...]
#        scripts/style-check.sh                 (all tracked *.md)
#
# Skips fenced code blocks. A file containing "<!-- style-check: skip-file -->"
# is skipped entirely (use for files that quote banned patterns on purpose).
# Exit 0 clean, 1 violations found.

set -uo pipefail

BANNED_WORDS='load-bearing|load bearing|seams?\b|genuinely|crucial|delve|robust|seamless(ly)?|elegant|leverages?\b|leveraging'
BANNED_PHRASES="it's not just|it is not just|that said,|at the end of the day|it's worth noting|it is worth noting|in today's world|let's dive in|dive into|game.?changer"
EMDASH=$'—'
ENDASH=$'–'

# No mapfile or readarray here: macOS ships bash 3.2.
files=()
if [ $# -gt 0 ]; then
  files=("$@")
else
  if git rev-parse --git-dir >/dev/null 2>&1; then
    list=$(git ls-files '*.md')
  else
    list=$(find . -name '*.md' -not -path './.git/*')
  fi
  while IFS= read -r line; do
    [ -n "$line" ] && files[${#files[@]}]="$line"
  done <<< "$list"
fi
[ ${#files[@]} -gt 0 ] || exit 0

has_pcre=0
echo | grep -qP '' 2>/dev/null && has_pcre=1
# Arrows (U+2190-U+21FF, U+2192) are allowed, they are useful in tables.
EMOJI='[\x{1F000}-\x{1FAFF}\x{2600}-\x{27BF}\x{2B00}-\x{2BFF}\x{FE0F}]'

violations=0

# Strip fenced code blocks, keep original line numbers as "N:text".
prose() {
  awk '/^[[:space:]]*(```|~~~)/ {fence = !fence; next} {if (!fence) print NR ":" $0}' "$1"
}

check() { # file, pattern, grep-flags, message
  local f=$1 pattern=$2 flags=$3 msg=$4 hit n
  while IFS= read -r hit; do
    n=${hit%%:*}
    printf '%s:%s: %s\n' "$f" "$n" "$msg"
    violations=$((violations + 1))
  done < <(prose "$f" | grep $flags -e "$pattern" 2>/dev/null)
}

for f in ${files[@]+"${files[@]}"}; do
  [ -f "$f" ] || continue
  grep -q 'style-check: skip-file' "$f" 2>/dev/null && continue

  check "$f" "$EMDASH" "-F"  "em dash. Use a comma, colon, parentheses, or two sentences."
  check "$f" "$ENDASH" "-F"  "en dash. Use a hyphen or rewrite the range."
  check "$f" "$BANNED_WORDS"   "-iE" "banned word. See instructions/writing-style.md"
  check "$f" "$BANNED_PHRASES" "-iE" "banned phrase. See instructions/writing-style.md"
  [ "$has_pcre" -eq 1 ] && check "$f" "$EMOJI" "-P" "emoji. Remove it."
done

if [ "$violations" -gt 0 ]; then
  printf '\n%s style violation(s).\n' "$violations"
  exit 1
fi
exit 0
