# Testing Log

Two weeks of real use at work, starting 2026-10-20, against v0.2.0. Nothing in this repo has been run on a real project yet.

Record observations here as they happen, one line each. Detail goes in `llm-issues.md` once a pattern is clear. The point is to find out which of these are wrong, so a line saying "this did not work" is the most valuable kind.

## Read this first

Work is mostly Opencode, so these are untested there specifically:

- **Nothing enforces the writing style.** The hook was removed on 2026-10-21. Enforcement would have been Claude Code only, since Opencode needs a TypeScript plugin for any event, so it would have existed at home and not at work. `scripts/style-check.sh` still exists and runs by hand.

  This makes the two weeks a clean test of the instruction on its own. If prose stays acceptable, the instruction is enough and the linter stays manual. If it drifts after twenty turns, that is the argument for wiring both harnesses up at once: a Claude Code hook plus a plugin in `~/.config/opencode/plugins/`, which is global and covers every project.
- **Skill discovery through symlinks is unverified.** `install.sh` links `.opencode/skill/<name>` to `.agents/skills/<name>`. If Opencode does not pick skills up, re-run with `--copy` and record that here.
- **`@import` syntax is Claude Code only.** Eager fragments in `AGENTS.md` need the `instructions` array in `opencode.json` instead. `harness/opencode/opencode.json` covers `.agents/instructions/*.md` with a glob, so eager and routed are not actually distinguished under Opencode yet. This is a real gap, not a detail.

That last one matters most. The eager and routed split is the main design claim of v0.2.0 and it currently only works in one of the two harnesses.

## What to watch, per item

| Item | The question | Failure looks like |
|---|---|---|
| `checkpoint` | Can a fresh session continue from `STATE.md` alone? | Having to re-explain for 10 minutes, or `STATE.md` reading as a transcript summary |
| `JOURNAL.md` | Does the agent actually append without being told? | An empty journal after a session that clearly had failures in it |
| Sub-agent triggers | Does naming AAP job output explicitly change behavior? | Raw job output in the main context anyway |
| `teach` | Does it stay under roughly 150 words per turn? | The 800-word first reply |
| `whiteboard-defense` | Does it leak answers into its own questions? | "As you know", or multiple choice with one obvious option |
| `writing-style` | Does the banned list hold up without the hook? | Em dashes and the banned vocabulary returning after about 20 turns |
| `AGENTS.md` size | Does it stay under 100 lines once a real project fills it in? | Project notes growing into a second standards document |

## Observations

Format: `YYYY-MM-DD  item  what happened`

```
2026-10-20  --       starting point, nothing run yet
2026-10-20  install  macOS: symlinks landed broken. realpath --relative-to is GNU only
                     and BSD realpath has no equivalent. Fixed with a shell relpath.
                     Same pass found sha256sum (BSD uses shasum -a 256) and mapfile
                     (bash 3.2 on macOS). All three now portable.
2026-10-23  install  macOS: fzf picker and skill symlinks work, --copy not needed.
2026-10-23  opencode Eager fragments never loaded: Opencode does not expand @import.
                     install.sh now writes them to opencode.json instructions. See
                     CHANGELOG 0.3.1.
2026-10-23  opencode Confirmed loading on the Mac. An already-open session needs
                     /reload first, since Opencode caches project config. Fresh
                     sessions pick it up on their own.
```

Lesson: everything here was written and tested on Linux, and the work machine
is an M4 Mac. Assume any script is Linux-only until it has been run there.
Constraints are now listed under Platforms in the README.


## After two weeks

Three questions to answer before building anything else:

1. Which of these did you actually invoke more than twice? Delete or fix the rest.
2. Which failure above happened? That is the next build item, in `llm-issues.md`.
3. Did the context problem get better in a way you can point at, such as fewer compactions or a cheaper restart?

Then tag v0.3.0, and only then. See the release rule in `philosophy.md`.
