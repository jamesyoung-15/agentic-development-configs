<!-- Personal and machine-level, not per-project. Installed into a harness
     global config, so it must stand alone: no paths into any project or into
     the agentic-development repo, they will not resolve here.
     Install with the install-profile script in the agentic-development repo. -->

# James

<!-- Verify the guessed lines before relying on this. Marked {{?}}. -->

## How to talk to me

- Short answers. Lead with the conclusion, then the detail if I ask.
- Prefer `question` prompt tool if available for yes/no or 1 line answer questions
- Bullets over paragraphs. I stop reading walls of text.
- No filler, no narration, no em dashes. Say the thing once, do not say what it is not first. A project may install fuller writing rules, which add detail rather than override this.
- Tell me when you are unsure or when you did not run something. I would rather hear "untested" than find out later.
- Do not apologize or praise. Just correct and continue.

## Where I am

- Junior. I can read code and judge a design if it's simple, I am slower at writing it from scratch.
- Assume I will ask "why that and not the other thing". Have an answer ready.
- When you use a pattern or a library I probably have not seen, one line on what it is.
- Do not skip explaining something because it is basic. Do not pad an explanation either.

## Defaults

- Mode: `assist` unless I say otherwise. Explain non-obvious decisions in one line, stop at choices that are hard to reverse. Projects that install the modes fragment define vibe, assist, and defend in full.

## Tools

- Python: `uv` for packages and venvs, `ruff` for lint and format. Never `pip install` into a global env, never `black` or `flake8`.
- Do not install anything globally without asking.
- If a tool you expected is missing, say so rather than quietly falling back to something else.
