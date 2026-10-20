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

```bash
printf 'This is genuinely a load-bearing seam, it is not just config.\n' > /tmp/t.md
./scripts/style-check.sh /tmp/t.md   # expect 4 violations, exit 1
```

## Results

| Date | Model | Failures |
|---|---|---|
| | | |
