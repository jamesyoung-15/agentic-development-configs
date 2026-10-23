# Agentic Development Configs

Agent instructions, skills, and templates I install into projects. Mainly targets work and personal projects/tasks, where my work dev machine uses MacOS (Apple Silicon) and my personal dev machines are Linux-based (typically NixOS or Debian-based).

Note: Very high LLM usage (at least for v0.1.0), most of the files are generated and written by LLM, although down the line I may fine-tune these by hand.

## Install into a project

```bash
git clone <this-repo> ~/dev/agentic-development
cd ~/dev/agentic-development
chmod +x scripts/*.sh harness/claude-code/hooks/*.sh

./scripts/install.sh ~/code/my-project \
  instructions/python.md \
  instructions/git-conventional.md \
  instructions/writing-style.md \
  skills/create-pr \
  templates/adr.md
```

Then read each installed copy and edit it for that project. See `catalog.md` for what to install and when.

## Check for upstream changes

```bash
./scripts/sync.sh ~/code/my-project          # what is behind
./scripts/sync.sh ~/code/my-project --diff   # and what changed
```

Doesn't overwrite and keeps local edits.

## Personal globals

Machine-level, every project. Once per harness.

```bash
./scripts/install-profile.sh all     # or claude-code, or opencode
```

Doesn't overwrite, if the global config already exists it prints the line to add. Paths per harness are in `harness/README.md`.

## Style linter

Run by hand. Nothing is wired to it, and no instruction references it, so it is not something a project needs to carry.

```bash
./scripts/style-check.sh                    # all tracked markdown
./scripts/style-check.sh path/to/file.md
```

Checks em dashes, a short word list, and the sentence shapes in `instructions/writing-style.md`. The rules themselves live in that file and stand on their own.

Currently not used, may experiment with this in future.

## Layout

```
instructions/   drop-in markdown fragments
skills/         SKILL.md folders
templates/      PR body, ADR
profiles/       personal, machine-level
harness/        Claude Code and Opencode wiring, nothing else
scripts/        install, install-profile, sync, style-check
tests/          one scenario per skill, run manually
notes/          philosophy and open issues, for developing this repo
catalog.md      what everything is and when to use it
CHANGELOG.md    what changed, per VERSION
```

## How a project ends up wired

```
AGENTS.md            under 100 lines: what this is, commands, always-rules, routing table
  @ imports          eager fragments, in context every turn
  Where to look      routed fragments and wiki pages, read on demand
STATE.md             current state, rewritten each checkpoint
JOURNAL.md           append-only events, where negative results live
docs/adr/            decisions, written at decision time
wiki/                things not derivable from any repo, each page dated
```

Eager costs context on every turn, routed costs one file open when it matters. Default to routed. See `harness/README.md`.

## What lands where in a project

```
AGENTS.md                  index, @-references the fragments
CLAUDE.md                  symlink to AGENTS.md
.agents/instructions/      canonical copies, stamped with provenance
.agents/skills/<name>/     canonical copies
.claude/skills/<name>      link to .agents/skills/<name>
.opencode/skill/<name>     link to .agents/skills/<name>
```

Pass `--copy` to `install.sh` if a harness does not follow symlinked skill directories.

## Rules for this repo

- Where a fragment needs changing for a project, make that obvious. Skills end with `## Project overrides`, templates use `{{PLACEHOLDER}}`, guessed lines are marked `{{?}}`. A fragment that needs silent editing is a bug.
- No harness paths outside `harness/`.
- Inside installable content, write a path as it exists after install: `.agents/instructions/foo.md`, `.agents/templates/adr.md`. The `install` skill is the exception, it runs from this repo and uses repo-relative paths. Profiles install into a harness global config and must contain no paths at all.
- Every skill ends with a `## Project overrides` section for the installed copy to fill.
- Nothing leaves `catalog.md`'s "Not built" table until a real task needs it.
- Changing anything installable means bumping `VERSION` and adding a `CHANGELOG.md` entry. Installed copies carry the version they came from.
