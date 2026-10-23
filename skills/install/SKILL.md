---
name: install
description: Install instruction fragments and skills from this repo into a target project, and adapt them to that project. Use when the user says "install the python instructions here", "set up agent config for this project", or "bring in the PR skill". Runs from inside the agentic-development repo or against it.
---

# Install

Copies fragments into a project, stamps provenance, wires them into whatever harnesses that project uses, and tailors the copy to the project.

Paths in this file are relative to the `agentic-development` checkout, not to the target project. Everywhere else, a path names where a file lands after install, under `.agents/`.

## Steps

### 1. Read the catalog

`catalog.md` lists every fragment and when to use it. If the user named what they want, skip to step 3.

### 2. Recommend a set

Look at the target project first: language, package manager, test runner, forge, existing commit history style, existing `AGENTS.md` or `CLAUDE.md`.

Then propose a short list. Do not install everything. Each item needs a reason tied to something you saw in the project.

- Commit history uses `feat:` prefixes → `git-conventional.md`, otherwise `git-plain.md`.
- `pyproject.toml` present → `python.md`.
- The project has a README anyone else reads → `writing-style.md` and `documentation.md`.
- Long-running work, or a project that will outlive one session → `context.md`, `skills/checkpoint`, `templates/state.md`, `templates/journal.md`.

Ask before installing.

### 2b. Decide eager or routed

Each instruction declares a default on its first line. Check it against this project rather than accepting it.

- `eager` becomes an `@import` and sits in context on every turn of every session. Correct when the fragment applies to more than about half the tasks here, and runs short.
- `routed` becomes a row in the `Where to look` table and is read only when the task matches.

A Python-only repo should have `python.md` eager. A repo where you touch Python once a month should not. When unsure, choose routed. The cost of a missed read is one extra file open, the cost of a wrong eager import is paid on every turn forever.

Change the directive in the installed copy, not upstream, then re-run the install so `AGENTS.md` matches.

### 3. Copy

```bash
scripts/install.sh <target-project> instructions/python.md skills/create-pr
```

The script handles provenance stamping and harness symlinks. Do not copy files by hand, the provenance header is what makes updates possible later.

### 4. Adapt

This is the part that is not scriptable, and the reason this is a skill.

Read each installed file and edit the copy for this project:

- Replace `{{PLACEHOLDER}}` values with real ones.
- Fill the `## Project overrides` section at the bottom of each skill with things true of this project: base branch, reviewer conventions, ticket format, domain rules.
- Delete lines that are wrong here. If the project uses `poetry`, the `uv` lines in `python.md` are wrong, fix them rather than leaving a contradiction.
- Do not edit the upstream repo. Edits go in the copy.

An instruction that contradicts the project is worse than no instruction, because the agent will follow one of them at random.

### 5. Wire it up

`scripts/install.sh` creates `AGENTS.md` if missing and symlinks `CLAUDE.md` to it. Verify:

- `AGENTS.md` exists and references each installed instruction.
- `CLAUDE.md` is a symlink to `AGENTS.md`, not a second copy.
- For Opencode, `opencode.json` lists the instruction files.
- Installed skills appear under `.claude/skills/` and `.opencode/skill/`.

### 6. Report

List what was installed, what you changed in each copy and why, and anything in the project that contradicts an installed instruction.

## Updating later

```bash
scripts/sync.sh <target-project>
```

Reports which installed files are behind the upstream version. It does not overwrite. Read the diff, decide per file whether the local edits should survive the update.
