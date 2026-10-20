<!-- style-check: skip-file (quotes the banned patterns on purpose) -->

# Agent Issues

Problems I hit, what in this repo addresses each one, and what is still open. This drives the roadmap. An issue with no mitigation is the argument for the next thing to build.

Status values: `mitigated` (something enforces it), `partial` (helps, still leaks), `open` (no mitigation yet), `accepted` (decided not to fix).

## Writing

### Volume and narration

`partial`

Agents produce walls of text with little in them. Long preambles, restatements of the heading, explanation nobody asked for.

What I want instead: skim the page in ten seconds, decide whether to read it. Bullets. Commands I can copy. Detail behind a link or a collapsed section if I choose to dig. Docs that do this well: Stripe API, FastAPI, Django, MDN.

- Mitigated by: `instructions/writing-style.md` (structural limits, rewrite pairs), `instructions/documentation.md` (README ordering).
- Still leaks: length is not mechanically checked. Could add a words-per-section check to `style-check.sh`.

### Vocabulary and phrasing

`mitigated`

Specific patterns that make text harder to read:

- Words: load-bearing, seam, genuinely, crucial, delve, robust, seamless, elegant, leverage.
- "That's genuinely x".
- Contrastive parallelism: "it's not x, it's y", "the real bottleneck: connections, not CPU". Say the thing once.
- Em dashes and emoji everywhere.

- Mitigated by: `scripts/style-check.sh` plus the PostToolUse hook. The agent gets its own violations back and fixes them in the same turn, before I see the file.
- Maintenance: add a pattern to the script and to `instructions/writing-style.md` together, or the agent learns nothing from being blocked.

## Code

### Code quality

`accepted`

Not a real problem. Given a linter, tests, and basic standards, agents write better code than I do right now.

### Comment verbosity

`accepted`

Agents leave five lines of comments where the code is self-documenting. `AGENTS.md` saying "1 to 3 lines" gets ignored until I repeat it in the prompt.

Decided not to chase this. Over-commenting forces me to read the code and edit by hand, which I want to be doing anyway. For agent-driven projects more comments do not hurt.

The part that does matter is accuracy. A stale comment that contradicts the code is worse than no comment. `instructions/python.md` says to delete rather than let one drift.

### Alignment

`partial`

Sometimes a prompt problem, sometimes the agent misreading the problem. Either way it implements the wrong thing, confidently. Switching between plan and write mode covers most of it, not all.

- Mitigated by: `skills/alignment`. Restate in its own words, tag every assumption, at most three questions, then stop and wait. The stop is the whole mechanism.
- Still leaks: the skill has to be invoked. Nothing detects that alignment was needed and skipped.

## Me

### Mode switching

`partial`

Not the agent's fault. I switch between wanting the agent to own something completely and wanting to understand every decision, and I do not always notice which one I am in. Drifting from the first into the second is how you ship something you cannot explain.

- Mitigated by: `instructions/modes.md` makes the choice explicit. `templates/adr.md` captures reasoning at decision time.
- Still leaks: declaring the mode is manual.

### Whiteboard defense

`partial`

Mitchell Hashimoto's benchmark, quoted in full in `philosophy.md`. For customer-facing work I need to be able to explain and defend anything I shipped, without line-level familiarity. For PoCs and experiments I do not care at all.

- Mitigated by: `skills/whiteboard-defense` drills me and produces a gap list. `skills/teach` closes the gaps.
- Still leaks: needs testing against a real change to see whether it leaks answers into its own questions.

### Learning

`open`

I am junior. There are times I want to be taught rather than handed a result, and the default agent behavior is to hand me the result.

- Mitigated by: `skills/teach`, new and untested.
- Watch for: the 800-word answer. The 150-word turn limit is the guard, and it is the rule most likely to be ignored.

## Roadmap

Ordered by what the table above says is weakest.

1. Run `whiteboard-defense` and `teach` against real work. Both untested. Record failures in `tests/README.md`.
2. Length check in `style-check.sh`, if writing volume keeps leaking past the word and phrase rules.
3. `debug` skill, if shotgun patching keeps happening.
4. Nothing else until an issue above goes from `partial` to needing it.
