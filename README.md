# Agentic Development

Agent instructions, skills, and templates I install into projects. Plain markdown, no harness-specific content outside `harness/`.

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

Then read each installed copy and edit it for that project. The copies are yours. See `catalog.md` for what to install and when.

## Check for upstream changes

```bash
./scripts/sync.sh ~/code/my-project          # what is behind
./scripts/sync.sh ~/code/my-project --diff   # and what changed
```

It never overwrites. Local edits are the point, so you decide per file.

## Personal globals

Machine-level, every project. Once per harness.

```bash
./scripts/install-profile.sh all     # or claude-code, or opencode
```

Never overwrites. If the global config already exists it prints the line to add. Paths per harness are in `harness/README.md`.

## Style linter

```bash
./scripts/style-check.sh                    # all tracked markdown
./scripts/style-check.sh path/to/file.md
```

Wire it as a Claude Code hook so the agent fixes its own prose instead of you catching it at review:

```bash
mkdir -p ~/code/my-project/.claude
cp harness/claude-code/settings.json ~/code/my-project/.claude/settings.json
```

Rules live in `instructions/writing-style.md`. Add a banned pattern there and in `scripts/style-check.sh` together.

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

`notes/` is never installed into a project. It is the input to deciding what to build next.

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

- A fragment must work unmodified in a project that knows nothing about this repo.
- No harness paths outside `harness/`.
- Every skill ends with a `## Project overrides` section for the installed copy to fill.
- Nothing leaves `catalog.md`'s "Not built" table until a real task needs it.
- Changing anything installable means bumping `VERSION` and adding a `CHANGELOG.md` entry. Installed copies carry the version they came from.
