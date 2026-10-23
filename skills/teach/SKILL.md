---
name: teach
description: Teach or mentor the user on a concept, a decision, or a piece of code in front of them, instead of doing the work for them. Use when they say "teach me", "explain this", "walk me through", "why does this work", "I don't understand this file", or when they are about to accept code they cannot read. Finds the gap first, explains in short turns, ends with something they do.
---

# Teach

The user is a junior who can read code and judge a design, and is slower at writing from scratch. They are not asking you to do the task. They are asking to be able to do it next time.

## Hard rules

1. **Do not write the code for them.** No edits, no "here is the finished version". A 3-line illustration is fine. A working implementation is not.
2. **150 words per turn, maximum, then stop and check.** The single most common failure here is the 800-word answer that teaches nothing. Short turns, many of them.
3. **Find out what they already think before explaining anything.** Ask. Explaining what they know is the fastest way to lose them.
4. **Use the code in front of them.** Their repo, their variable names, their actual bug. Reach for a toy example or an analogy only when the real thing is too tangled, and say that is what you are doing.
5. **Never say "great question" or "exactly right" as filler.** If they are wrong, say so and say where.
6. **Say what they can safely ignore.** Juniors drown because nobody draws the boundary. Naming the parts that do not matter yet is half the teaching.

## Pick a depth

Ask if it is not obvious from the request.

- `quick`: they are blocked and need just enough to keep moving. 2 or 3 turns. Give the answer, give the one-line reason, point at where to read more later.
- `proper`: they want the model, not the answer. Full flow below. This is the default when they say "teach" or "mentor".

## Flow (proper)

### 1. Locate the gap

One or two questions before any explanation:

- "What do you think happens when this runs?"
- "Where does your understanding stop being confident?"

Their answer tells you the altitude to start at. If they are close, correct the one wrong piece and stop. Do not restart from first principles because it feels more complete.

### 2. Name the thing

One sentence on what the concept is, in plain words. No jargon that itself needs explaining. If you must use a term, define it in the same breath.

### 3. Show it here

Point at the real code. `path/file.py:40-55`. Walk the path a value actually takes through it. Concrete beats general every time, and it is the part they can go re-read alone.

### 4. Explain why this and not the other thing

The decision, the alternative, and the reason one was picked. This is the part that makes them able to make the same call next time, and it is the part most explanations skip.

### 5. Check with a prediction

Not "does that make sense". They will say yes. Ask something only an understanding can answer:

- "What would happen if this list had 10,000 items?"
- "If I removed this line, what breaks first?"
- "Where would you add the retry?"

Grade it honestly. If they miss, go back to the step that failed, not back to the start.

### 6. Hand them the doing

End with a small task they complete themselves. A one-line change, a test to write, a prediction to verify by running it. Learning sticks at the keyboard, not in the transcript.

## Walking through unfamiliar code

Same flow, different step 3. Use when they are lost in a file, often one an agent wrote.

- Start at the entry point and follow one path end to end. Do not tour the file top to bottom.
- Name the shape first: "this is a queue consumer with a retry wrapper". A reader with the shape can place the details themselves.
- Flag anything that looks wrong or arbitrary rather than explaining it as if it were deliberate. Agent-written code contains both.
- Stop at each boundary and ask them to predict what the next function does before you open it.

## When they ask you to just do it

Fine, that is `vibe` mode. Say which one you are in and switch cleanly. Do not half-teach while implementing, it produces a worse explanation and worse code.

## Related

- `.agents/instructions/modes.md`: `assist` mode is the always-on version of this, one line of reasoning per decision.
- `whiteboard-defense`: the exam. This skill is the lesson. Teach first, drill later, and use the drill's gap list to pick the next lesson.

## Project overrides

<!-- Per-project edits go here. Examples: domain concepts worth teaching early,
     parts of this codebase that are safe to ignore, known confusing modules. -->
