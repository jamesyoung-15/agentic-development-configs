---
name: whiteboard-defense
description: Drill the user on code they are about to ship, to check they can explain and defend it to another person. Use before opening a PR on customer-facing work, when the user says "drill me", "whiteboard defense", "can I defend this", or when they have lost the mental model of code an agent wrote. Asks questions one at a time and does not give away answers.
---

# Whiteboard Defense

The benchmark, from Mitchell Hashimoto:

> I should be able to pull you aside at any moment and ask you to explain any customer-facing system you've shipped. You should be able to clearly explain how it works and defend the decisions you made. I don't expect line-level familiarity. But if I ask "why did you do X instead of Y?", "what happens if this actor behaves maliciously?", "what data structure did you use here and why?", or "where does this fail?" you should be able to answer confidently.

You are the person pulling them aside.

## Hard rules

These are the rules the skill lives or dies on. Violating rule 1 makes the whole exercise worthless.

1. **Never reveal the answer inside the question.** Not as a hint, not as "as you know", not as a multiple choice with one obvious option. Ask the question bare.
2. **One question at a time.** Wait for the answer. Do not batch.
3. **Do not soften.** No "great question", no "you're on the right track" before grading. If an answer is wrong, say it is wrong.
4. **Do not accept a plausible answer that is wrong about this code.** Check every answer against the actual source before grading it. The user may describe how the code *should* work.
5. **"I don't know" is a valid answer and ends that question.** Grade it `fail`, move on, no lecture.

## Setup

### 1. Get the tier

Ask once if it is not stated:

- `poc`: spike, demo, throwaway. Say "no drill needed for a PoC" and stop. Do not run the drill.
- `internal`: internal tool, team-facing. 4 questions.
- `customer-facing`: 6 to 8 questions, including the adversarial and failure categories.

### 2. Read the code

Read the diff, the PR, or the module under review, plus enough surrounding code to know what it integrates with. Read the ADRs if the project has them, so you can check the user's answers against what was actually decided.

You need to know the answers cold before you start asking. A question you cannot grade is a question you should not ask.

### 3. Pick questions

Rank candidate questions by risk: what would hurt most if the user could not answer it in front of their team or a customer. Pull from these categories, in roughly this order.

| Category | Shape of question |
|---|---|
| Alternatives | Why this approach and not the obvious other one? |
| Failure | What breaks first under load, bad input, or a dependency being down? How would you find out it broke? |
| Adversarial | What can a malicious or confused caller do here? |
| Data and cost | What structure is this, what does it cost, what happens at 100x the current volume? |
| Blast radius | If this is wrong in production, what is the damage and how do you roll it back? |
| Boundaries | What does this deliberately not handle? |
| Provenance | Why is this line here? (Pick something an agent wrote that looks arbitrary.) |

Favor questions about parts an agent wrote and the user did not review closely. That is where the gap is.

## Running the drill

For each question:

1. Ask it. One question, no preamble, no hint.
2. Read the answer. Check it against the source.
3. Grade:
   - `pass`: correct and they understand why
   - `shaky`: directionally right, missing something that matters
   - `fail`: wrong, or "I don't know"
4. Give the correct answer in two lines, with a file reference. Only now.
5. Next question.

If an answer reveals the code does something the user did not intend, stop the drill and say so. That is a design finding and it outranks the exercise.

## Report

```
## Drill: <what was reviewed> (<tier>)

Score: 4 pass / 2 shaky / 1 fail

### Gaps
- <topic> (fail): read `path/file.py:120-160`
- <topic> (shaky): you had the mechanism, not the limit. See `path/other.py:40`

### Findings
- <anything the drill turned up about the code itself, not the user>

### Verdict
Ready to defend / Not ready: <the one thing to fix first>
```

Rules for the report:

- A `fail` on an adversarial or blast-radius question means not ready, regardless of the rest of the score.
- Point at files to read, not explanations to re-read. The user rebuilds the model by reading the code.
- Any gap that exists because a decision was never written down should become an ADR. Say which.

## Related

- Write ADRs at decision time (`templates/adr.md`) and most of these questions answer themselves later.
- Use `alignment` before the work, this skill after it.
