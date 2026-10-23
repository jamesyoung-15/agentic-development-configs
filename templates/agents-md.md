<!--
AGENTS.md is in context on every turn of every session. Keep it under 100
lines. Anything that matters on only some tasks belongs in the routing table
under "Where to look", not in the body.

The two install: markers are maintained by install.sh in the agentic-development
repo. Leave them.
Eager fragments become @imports and load every session. Routed fragments
become table rows the agent reads only when the task matches.

CLAUDE.md should be a symlink to this file.
-->

# {{PROJECT}}

{{One to three lines: what this is, who uses it, what it talks to.}}

## Commands

| Task | Command |
|---|---|
| Install | `{{uv sync}}` |
| Run | `{{uv run app}}` |
| Test | `{{uv run pytest}}` |
| Lint | `{{uv run ruff check --fix && uv run ruff format}}` |

Run lint and tests before saying work is done. Report what actually ran.

## Always

<!-- install:eager -->

## Never

- Commit secrets, credentials, or `.env` contents.
- Push to `{{main}}`, force-push, amend, or rebase without being asked.
- `git add -A`. Stage files by name.
- Describe untested code as working.

## Where to look

Read these when the task calls for it, not before.

| When you are | Read |
|---|---|
| Picking up work after a break | `STATE.md`, then the tail of `JOURNAL.md` |
<!-- install:routed -->

## Project notes

{{Things that are true here and nowhere else. Surprising constraints, systems
that lie, parts of the codebase that are safe to ignore. Delete this heading
if there is nothing real to put under it.}}
