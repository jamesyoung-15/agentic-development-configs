# Harness Wiring

Content lives in `instructions/`, `skills/`, and `templates/`, as plain markdown with no harness assumptions. This directory holds the per-harness glue only.

## Eager vs lazy loading

The thing that decides whether a project's agent config works or wastes context.

| Mechanism | Loads | Use for |
|---|---|---|
| Body text in `AGENTS.md` | Always | Applies to every task |
| `@path` import (Claude Code) | Always, inlined at session start | Applies to most tasks here, and short |
| `instructions` array (Opencode) | Always | Same as above |
| Skill | On demand, matched against its `description` | A specific kind of task |
| Path in a routing table | On demand, the agent opens it | Reference material, wiki pages |

Imports are eager in both harnesses. Importing six fragments puts all six in context permanently, which is the 400-line `AGENTS.md` problem with extra steps.

Each instruction in this repo declares its default on line one, and `scripts/install.sh` wires it accordingly:

```
<!-- load: eager  | when: Writing or editing Python -->
<!-- load: routed | when: Writing a README, docs, or a wiki page -->
```

Routing-table rows are phrased as what the agent is **doing**, not what the file is about. Agents match on task, not topic.

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
