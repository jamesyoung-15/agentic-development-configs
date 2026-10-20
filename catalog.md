# Catalog

Everything installable, and when to reach for it.

## Instructions

Drop-in markdown fragments. Installed to `.agents/instructions/` and referenced from `AGENTS.md`.

| Fragment | Install when |
|---|---|
| `python.md` | The project is Python |
| `git-conventional.md` | Repo history uses `feat:` / `fix:` prefixes |
| `git-plain.md` | Repo history uses plain subject lines. Pick one of the two, never both |
| `writing-style.md` | Anyone other than you reads the output. Pair with the style-check hook |
| `documentation.md` | The project has a README or docs that are maintained |
| `modes.md` | You want vibe / assist / defend to be explicit |

## Skills

Installed to `.agents/skills/<name>/`, linked into `.claude/skills/` and `.opencode/skill/`.

| Skill | Use when |
|---|---|
| `create-pr` | Opening a PR or MR. GitHub and GitLab |
| `review-pr` | Reviewing a PR, an MR, or a branch diff before merge |
| `alignment` | The request is vague, or the work would be expensive to redo. Runs before the work |
| `teach` | You want to be taught rather than handed a result, or you are lost in a file |
| `whiteboard-defense` | Before shipping customer-facing code, or when you have lost the mental model. Runs after the work |
| `install` | Bringing any of this into a project and adapting it |

`alignment` runs before the work, `teach` during, `whiteboard-defense` after. The drill produces a gap list, `teach` closes the gaps.

## Templates

| Template | Use when |
|---|---|
| `pr-body.md` | PR and MR descriptions. Used by `create-pr` |
| `adr.md` | Any decision that was not forced. Write it at decision time |

## Profiles

Personal, machine-level, not per-project. `scripts/install-profile.sh <harness>`, paths in `harness/README.md`.

| Profile | What |
|---|---|
| `james.md` | How to talk to me, where I am, defaults |
| `toolset.md` | What is installed, what to use instead of what |

## Not built

Listed so I remember why, not as a backlog I owe anyone.

| Idea | Status |
|---|---|
| `debug` skill | Hypothesis, evidence, minimal fix. Build next if shotgun patching keeps happening |
| `testing-python.md` | What to test and what not to. `python.md` covers tooling only |
| `pre-commit` skill | Self-review of the staged diff. Partly covered by `review-pr` |
| `explain-this` skill | Dropped. Folded into `teach` as the code-walkthrough path |
| `handoff` skill | Dump session state for the next session |
| `research-plan` skill | Both harnesses have plan modes. Write this only after naming what they get wrong |

Rule for this table: nothing moves out of it until a real task makes the gap obvious. Three skills used weekly beats twelve that rot. See `notes/llm-issues.md` for which gaps are actually hurting.
