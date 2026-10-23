# Catalog

Everything installable, and when to reach for it.

## Instructions

Drop-in markdown fragments. Installed to `.agents/instructions/` and wired into `AGENTS.md`.

`Load` is the default on the fragment's first line. `eager` means an `@import` that sits in context every turn, `routed` means a row in the `Where to look` table read on demand. Override per project, see `harness/README.md`.

| Fragment | Load | Install when |
|---|---|---|
| `python.md` | eager | The project is Python |
| `git-conventional.md` | eager | Repo history uses `feat:` / `fix:` prefixes |
| `git-plain.md` | eager | Repo history uses plain subject lines. Pick one of the two, never both |
| `writing-style.md` | eager | Anyone other than you reads the output |
| `documentation.md` | routed | The project has a README or docs that are maintained |
| `modes.md` | eager | You want vibe / assist / defend to be explicit |
| `context.md` | eager | Any project that outlives one session. Sub-agent and journal rules |

## Presets

Named sets, one file per preset in `presets/`. One repo-relative path per line, `#` for comments. Add your own by dropping a file in.

| Preset | Contains |
|---|---|
| `python` | Python standards, plain git, writing style, context, create-pr, review-pr, checkpoint, and the ADR, PR, state and journal templates |
| `long-running` | Context rules, checkpoint, and the ADR, state and journal templates. Layer on top of a language preset |

Each preset is self-contained: everything a skill in it references is also in it, so installing one never leaves a dangling reference.

## Skills

Installed to `.agents/skills/<name>/`, linked into `.claude/skills/` and `.opencode/skill/`.

| Skill | Use when |
|---|---|
| `create-pr` | Opening a PR or MR. GitHub and GitLab |
| `review-pr` | Reviewing a PR, an MR, or a branch diff before merge |
| `alignment` | The request is vague, or the work would be expensive to redo. Runs before the work |
| `checkpoint` | Context is filling, a session is ending, or a second compaction just happened |
| `teach` | You want to be taught rather than handed a result, or you are lost in a file |
| `whiteboard-defense` | Before shipping customer-facing code, or when you have lost the mental model. Runs after the work |
| `install` | Bringing any of this into a project and adapting it |

`alignment` runs before the work, `teach` during, `whiteboard-defense` after. The drill produces a gap list, `teach` closes the gaps. `checkpoint` runs across all of them, whenever the session is about to lose state.

## Templates

| Template | Use when |
|---|---|
| `pr-body.md` | PR and MR descriptions. Used by `create-pr` |
| `adr.md` | Any decision that was not forced. Write it at decision time |
| `agents-md.md` | Starting a project's `AGENTS.md`. Used by `install.sh` when none exists |
| `state.md` | Current state, rewritten each checkpoint. The first thing a fresh session reads |
| `journal.md` | Append-only event log. Where negative results accumulate |
| `wiki/index.md` | The wiki catalog. The only wiki file read unconditionally |
| `wiki/page.md` | One page per entity, with a last-verified date |
| `wiki/log.md` | Append-only record of what the wiki was built from |

## Profiles

Personal, machine-level, not per-project. `scripts/install-profile.sh <harness>`, paths in `harness/README.md`.

| Profile | What |
|---|---|
| `james.md` | How to talk to me, where I am, defaults, tools |

## Not built

Listed so I remember why, not as a backlog I owe anyone.

| Idea | Status |
|---|---|
| `debug` skill | Hypothesis, evidence, minimal fix. Build next if shotgun patching keeps happening |
| `wiki-maintain` skill | Ingest a source into the wiki, update the index and log. Hand-write pages first and see what the routine actually is |
| `testing-python.md` | What to test and what not to. `python.md` covers tooling only |
| `pre-commit` skill | Self-review of the staged diff. Partly covered by `review-pr` |
| `explain-this` skill | Dropped. Folded into `teach` as the code-walkthrough path |
| `research-plan` skill | Both harnesses have plan modes. Write this only after naming what they get wrong |

Rule for this table: nothing moves out of it until a real task makes the gap obvious. Three skills used weekly beats twelve that rot. See `notes/llm-issues.md` for which gaps are actually hurting.
