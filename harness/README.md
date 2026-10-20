# Harness Wiring

Content lives in `instructions/`, `skills/`, and `templates/`, as plain markdown with no harness assumptions. This directory holds the per-harness glue only.

## Claude Code

| What | Where |
|---|---|
| Project instructions | `CLAUDE.md`, symlinked to `AGENTS.md` |
| Fragment includes | `@.agents/instructions/foo.md` lines inside `AGENTS.md` |
| Skills | `.claude/skills/<name>/SKILL.md` |
| Settings and hooks | `.claude/settings.json`, see `claude-code/settings.json` |

## Opencode

| What | Where |
|---|---|
| Project instructions | `AGENTS.md` |
| Fragment includes | `instructions` array in `opencode.json` |
| Skills | `.opencode/skill/<name>/SKILL.md` |

## Personal globals

Machine-level, applies to every project. `scripts/install-profile.sh <harness>` does this, and never overwrites an existing file.

| Harness | Global instructions | Global skills | Include syntax |
|---|---|---|---|
| Claude Code | `$CLAUDE_CONFIG_DIR/CLAUDE.md`, default `~/.claude/CLAUDE.md` | `~/.claude/skills/` | `@/abs/path.md` |
| Opencode | `~/.config/opencode/AGENTS.md` | `~/.config/opencode/skill/` | none, use `instructions` in `opencode.json` |

Verify these against your installed version. Harness config paths move between releases, and nothing in `profiles/` should name one.

## A third harness

Three things to check:

1. Does it read `AGENTS.md`? Most do. If not, add another symlink.
2. Does it read `SKILL.md` folders? If not, the skill body is still plain markdown. Point the harness at the file, or paste it into whatever format it does read.
3. Where do personal globals live? Add a row above and a case in `scripts/install-profile.sh`.

Nothing in `instructions/`, `skills/`, or `profiles/` should ever contain a harness-specific path. If you find one, move it here.
