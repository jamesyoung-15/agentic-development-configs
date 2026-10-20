# Philosophy

Why this repo is shaped the way it is. Read before adding anything.

## Goals

- Bring a standard into any project in under a minute, personal or work.
- Change it for that project without forking the idea.
- Survive a model change, a harness change, and a job change.

## Rules

### Model agnostic

No instruction names a model or depends on one model's habits. A rule that only works because of how one model is tuned this quarter is not a rule, it is a workaround. Write the rule, then enforce it mechanically where possible.

### Harness agnostic

Content is plain markdown. Harness paths, frontmatter quirks, config schemas, and hook formats live in `harness/` and nowhere else. Adding a fourth harness should mean one table row and one script case, not a rewrite.

Claude Code, Opencode, and Pi are the three that matter. If something only works in one of them, it belongs in `harness/`.

### Copies, not dependencies

A project gets a copy, stamped with where it came from. It does not get a submodule, a package, or a live link. The copy is meant to be edited, because a generic instruction that contradicts the project is worse than no instruction at all. The agent will follow one of the two at random.

`sync.sh` reports drift and never resolves it. Resolving drift is a judgment call about that project.

### Enforce what you can, instruct what you cannot

Instructions decay over a long context. The model follows them for twenty turns and then does not. This is not fixable by asking harder.

Order of preference:

1. A script that fails. `style-check.sh`.
2. A hook that feeds the failure back. The agent fixes its own output before you ever see it.
3. A checkpoint skill that reviews at the end. `review-pr`.
4. An instruction in `AGENTS.md`. Weakest. Use for things that cannot be checked.

Anything important enough to care about should climb as high up that list as it can go.

### Behavior rules need examples, not adjectives

"Be concise" does not work. "1 to 3 lines" barely works, because the model cannot feel a line count. A bad example next to a good one works, because imitation is what the model is actually good at. Every style rule in this repo is written as a rewrite pair where it can be.

### Stopping is a feature

The two skills that matter most, `alignment` and `whiteboard-defense`, both work by refusing to continue. An agent that restates the problem and then immediately implements has not aligned, it has narrated. The pause is the product.

### Small catalog

Three skills used weekly beats twelve that rot. `catalog.md` has a "Not built" table with reasons, and things only leave it when a real task makes the gap obvious. Untested prompts decay silently, and every model release changes what is needed.

### Test the prompts

A skill is a prompt, and a prompt cannot be known to work without running it. `tests/` has one scenario per skill, with the failure mode to watch for. Run them after a model change. The expected result is that some of them will have started failing.

## The mode problem

The thing this repo exists to manage, more than any individual instruction.

Two settings are both correct, for different work:

- Generate all of it, understand none of it. PoCs, spikes, internal tools. Speed wins.
- Understand and justify every decision. Customer-facing work.

The failure is not picking the wrong one. It is drifting from the first into the second without noticing, and shipping something you cannot explain. `instructions/modes.md` makes the choice explicit so it has to be made on purpose.

The benchmark for the second setting, from Mitchell Hashimoto:

> I should be able to pull you aside at any moment and ask you to explain any customer-facing system you've shipped. You should be able to clearly explain how it works and defend the decisions you made. I don't expect line-level familiarity with the code. But if I ask "why did you do X instead of Y?", "what happens if this actor behaves maliciously?", "what data structure did you use here and why?", or "where does this fail?" you should be able to answer confidently.

Two things support it, and the order matters:

- ADRs written at decision time, while the reasoning is still in context. Five minutes then, or an hour of archaeology in three months. This is the real fix.
- `whiteboard-defense` as the check, not the cure. If the drill is the first time a decision gets written down, the ADR was skipped.

`teach` is the third piece. The drill finds the gaps, teaching closes them.
