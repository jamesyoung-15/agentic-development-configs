# Skill Tests

A skill is a prompt. You cannot know it still works without running it. Re-run these after a model change, a harness change, or an edit to the skill.

Manual. Each scenario: the setup, what to type, and what a pass looks like. Record failures in the table at the bottom so you can see which skills are drifting.

## alignment

- Setup: any repo. Give a deliberately vague request, for example "the auth thing is slow, fix it".
- Run: invoke the skill.
- Pass: restates the problem in its own words, tags assumptions, asks at most 3 questions, writes no code, and stops. Any file edit is a fail.
- Common failure: restates the problem and then starts implementing in the same turn.

## whiteboard-defense

- Setup: a branch with changes you did not write.
- Run: invoke with tier `customer-facing`.
- Pass: asks one question at a time, gives away nothing in the question, grades each answer against the real source, ends with a gap list pointing at files.
- Common failure: the question contains the answer. Watch for "as you know" and for multiple choice where one option is obviously right.
- Also check: answer one question with something plausible but wrong for this code. It should catch it, not accept it.

## teach

- Setup: a file in your repo using something you do not know well.
- Run: "teach me how this works", depth `proper`.
- Pass: asks what you already think before explaining, stays under roughly 150 words per turn, points at real line numbers, checks with a prediction question rather than "does that make sense", ends with something for you to do.
- Common failure: the 800-word first turn. If the first reply is a wall of text, the skill failed, regardless of how good the content is.
- Also check: answer a prediction question wrong on purpose. It should say you are wrong and go back to the step that failed, not restart from the beginning.

## checkpoint

- Setup: a session where something failed and you fixed it, and where you chose between two approaches.
- Run: invoke the skill.
- Pass: `JOURNAL.md` gains a `fail` line for the dead end and a `why` line for the choice, `STATE.md` is rewritten in full with a `Next` item specific enough to act on, undocumented decisions are listed.
- Common failure: `STATE.md` reads as a summary of the conversation rather than a description of where things stand. If it says "we discussed" or "I then", it failed.
- Also check: exact error strings and job IDs should be copied, not paraphrased.
- The real test: start a fresh session, read only `STATE.md` and the journal tail, and see whether you can continue without asking a question.

## install (eager vs routed)

```bash
./scripts/install.sh /tmp/p instructions/python.md instructions/documentation.md
grep -A3 'install:eager' /tmp/p/AGENTS.md      # expect @.agents/instructions/python.md
grep -A3 'install:routed' /tmp/p/AGENTS.md     # expect a documentation.md table row
```

A fragment with no `load:` directive must land as routed, never eager.

## create-pr

- Setup: a branch with 2 or 3 commits, one of them touching a lockfile.
- Run: invoke the skill.
- Pass: reads the real diff, describes behavior changes rather than files, ignores the lockfile, opens as draft, does not credit itself anywhere.
- Common failure: describes what it remembers doing in the conversation instead of what is in the diff.

## review-pr

- Setup: a diff with one real bug and some cosmetic noise.
- Run: invoke the skill.
- Pass: the real bug is in Blocking with a concrete failure case, cosmetic items are below it, no praise padding, no edits made.
- Common failure: finding count inflation. Five vague findings instead of one real one.

## install

- Setup: an empty directory.
- Run: ask it to set up agent config for a Python project.
- Pass: inspects the project first, proposes a short list with reasons, asks before installing, then adapts the copies rather than leaving them generic.

## style-check

Manual tool, not wired to anything. Run it after editing the pattern list.

```bash
printf 'This is genuinely load-bearing.\n\nAnd the fix? More of it.\n\nIt is not a bug, it is a feature.\n' > /tmp/t.md
./scripts/style-check.sh /tmp/t.md   # expect 3 violations, exit 1
```

The pattern list is the part that rots. After changing it, check both directions:
a file containing each banned shape must flag every one, and a file of similar
but legitimate sentences (`Report findings, do not fix them`) must stay silent.
False positives cost more than misses here, since the fix is to rewrite prose
that was fine.

## Results

| Date | Model | Failures |
|---|---|---|
| | | |
