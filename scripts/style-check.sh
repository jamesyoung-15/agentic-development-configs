#!/usr/bin/env bash
# Flag banned style patterns in markdown prose: em dashes, banned words and
# phrases, and the sentence shapes in SENTENCE_PATTERNS. Everything else in
# writing-style.md is a rule, not a check.
# Usage: scripts/style-check.sh FILE [FILE...]
#        scripts/style-check.sh                 (all tracked *.md)
#
# Skips fenced code blocks. A file containing "<!-- style-check: skip-file -->"
# is skipped entirely (use for files that quote banned patterns on purpose).
# Exit 0 clean, 1 violations found.

set -uo pipefail

BANNED_WORDS='load-bearing|load bearing|seams?\b|genuinely|delve|powerful|seamless(ly)?|elegant|kicker|fluff'
BANNED_PHRASES="it's not just|it is not just|at the end of the day|in today's world|game.?changer"
EMDASH=$'—'
ENDASH=$'–'

# Sentence shapes. Matched per line, so a shape split across a wrapped line is
# missed. That is deliberate: joining paragraphs merged unrelated list items and
# reported the wrong line. Prefer a miss to a false positive, since a false hit
# makes the agent rewrite prose that was fine.
# Format: label|extended-regex, matched case-insensitively.
SENTENCE_PATTERNS='
contrast|(it'\''?s|that'\''?s|this is|that is|it is|these are|they'\''?re|we'\''?re|you'\''?re) not [^,.;:!?]{2,50}, ?(it'\''?s|that'\''?s|this is|that is|it is|these are|they'\''?re|we'\''?re|you'\''?re|just|but)
contrast|(isn'\''?t|aren'\''?t|wasn'\''?t|weren'\''?t) [^,.;:!?]{2,50}, ?(it'\''?s|that'\''?s|this is|that is|it is|just|but)
contrast|: [a-z][a-z ]{2,30}, ?not [a-z]{3,}[.!?]
triad|\bno [^,.;:!?]{2,35}[,.] ?no [^,.;:!?]{2,35}[,.] ?(just|only|simply)
rhetorical|(^|[.!?] ?)(and|but|so) (the|that|what|why|who|where|how) [^.?!]{0,45}\?
rhetorical|(^|[.!?] ?)(and|but|so) (honestly|genuinely|really|truly|seriously|frankly)[,?]
notbut|\bnot because [^.!?]{2,60}[.!?] ?but because\b
notbut|(^|[.!?] ?)not [^.!?]{2,60}[.!?] ?but [^.!?]{2,60}[.!?]
staccato|(^|[.!?] )[A-Za-z]+ [A-Za-z]+\. [A-Za-z]+ [A-Za-z]+\. [A-Za-z]+ [A-Za-z]+[.!?]
'

describe() { # label -> what to do about it
  case $1 in
    contrast)   echo "contrastive parallelism (\"not X, it's Y\"). Say the thing once." ;;
    triad)      echo "\"no X, no Y, just Z\". Drop the build-up, state what it is." ;;
    rhetorical) echo "rhetorical question you then answer. Delete the question." ;;
    notbut)     echo "\"Not X. But Y.\" Keep Y, drop the setup." ;;
    staccato)   echo "three two-word sentences in a row. Write one normal sentence." ;;
  esac
}

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

  # Grep the text with no line-number prefix, so patterns can anchor on ^,
  # then map the match back to its real line.
  joined=$(prose "$f")
  [ -n "$joined" ] || continue
  nums=$(printf '%s\n' "$joined" | cut -d: -f1)
  texts=$(printf '%s\n' "$joined" | cut -d: -f2-)

  # Several patterns share a label, so report each shape once per line.
  seen=""
  while IFS='|' read -r label pattern; do
    [ -n "$label" ] || continue
    while IFS= read -r k; do
      case "$seen" in *"[$k/$label]"*) continue ;; esac
      seen="$seen[$k/$label]"
      printf '%s:%s: %s\n' "$f" "$(printf '%s\n' "$nums" | sed -n "${k}p")" "$(describe "$label")"
      violations=$((violations + 1))
    done < <(printf '%s\n' "$texts" | grep -niE -e "$pattern" 2>/dev/null | cut -d: -f1)
  done <<< "$SENTENCE_PATTERNS"
done

if [ "$violations" -gt 0 ]; then
  printf '\n%s style violation(s).\n' "$violations"
  exit 1
fi
exit 0
