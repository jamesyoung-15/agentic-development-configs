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
- Still leaks: nothing is mechanically checked. Whether the instruction holds on its own is the open question.

### Vocabulary and phrasing

`partial`

Specific patterns that make text harder to read:

- Words: load-bearing, seam, genuinely, delve, powerful, seamless, elegant. Ordinary words like leverage, robust, and crucial are fine, I say them too.
- "That's genuinely x".
- Contrastive parallelism: "it's not x, it's y", "the real bottleneck: connections, not CPU". Say the thing once.
- Em dashes everywhere.
- Emoji everywhere, though this was mostly a 2024 problem and current models rarely do it unprompted.

- Mitigated by: `instructions/writing-style.md`, as bad and good pairs for each sentence shape. Nothing enforces it. `scripts/style-check.sh` exists and is run by hand, not wired to any hook. See the enforcement note in `philosophy.md`.
- The sentence shapes matter more than the vocabulary. Those are the structures that read as machine-written: contrastive parallelism, the build-up triad, a rhetorical question you then answer, "Not X. But Y.", staccato triples.
- Maintenance: if a pattern is added to the script, add it to `instructions/writing-style.md` as a bad and good pair too. The instruction is what the agent reads.

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

## Context

### Compaction loses decisions and dead ends

`partial`

On a long project with a large context window I still hit the limit repeatedly, and every compaction dropped things that mattered. Worst losses, in order: approaches already ruled out, rejected alternatives and why, exact strings like job IDs and error text.

A MEMORY.md the agent updated periodically did not work. It was written reactively, at or near compaction time, so the agent was summarizing a summary and producing compaction notes under a different filename.

- Mitigated by: `instructions/context.md` (write at the moment, not at the limit), `skills/checkpoint`, `templates/state.md` rewritten each time, `templates/journal.md` append-only. The split between rewritten state and appended events is what MEMORY.md was missing.
- Also: stop defending against compaction and make a fresh session cheap instead. One compaction is fine, checkpoint at the second.
- Still leaks: nothing enforces the journal triggers. If the agent stops appending, the loss is silent until you need the line that is not there.

### Context spent on things a sub-agent should have read

`partial`

Large tool output, especially automation job output, read straight into the main context when the answer needed was two lines.

- Mitigated by: `instructions/context.md` names the triggers and the exact return format, rather than saying to use sub-agents when appropriate.
- Still leaks: untested whether a named trigger list actually changes the behavior. Watch for it.

### Planning that never reached disk

`mitigated`

Staying in plan mode for a long stretch, then losing the reasoning at the first compaction.

- Mitigated by: `instructions/context.md`, planning ends by writing the plan file plus an ADR per decision.

## Knowledge

### AGENTS.md carries everything

`mitigated`

A single 100 to 400 line file with coding, git, and response standards, all in context on every turn, most of it irrelevant to the task at hand.

- Mitigated by: the eager and routed split, `templates/agents-md.md`, the routing table keyed on what the agent is doing.

### No wiki

`open`

Things true about work systems and derivable from no repo live only in my head and in whatever conversation happened to cover them.

- Mitigated by: `templates/wiki/`, unused so far.
- Watch for: pages that restate code, and pages nobody re-verifies. The date header is the guard, and it only works if something checks it.

## Roadmap

Ordered by what the table above says is weakest.

1. Run `checkpoint` on a real long-running work project. The test is whether a fresh session can continue from `STATE.md` alone.
2. Start the work wiki. Three pages, hand-written, before automating anything.
3. Run `whiteboard-defense` and `teach` against real work. Both untested. Record failures in `tests/README.md`.
4. Wire up the prose linter, only if the instruction alone turns out not to hold. Claude Code hook plus an Opencode plugin in `~/.config/opencode/plugins/`, or it exists on one machine and not the other.
5. `debug` skill, if shotgun patching keeps happening.
6. Nothing else until an issue above goes from `partial` to needing it.
