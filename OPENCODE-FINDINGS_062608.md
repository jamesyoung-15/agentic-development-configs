# Opencode setup findings

Checked 2026-10-23 against opencode v2.1.4, using this project as installed by `agentic-development-configs/scripts/install.sh`.

## Summary

| Item | Status |
|---|---|
| Skill symlinks (`.opencode/skill/<name>`) | Working |
| Eager instruction fragments | **Not loading** |

The install script's symlinks are correct. The problem is that the eager `@import` lines in `AGENTS.md` are never expanded by Opencode.

## Skills: working

`install.sh` creates relative symlinks in both harness dirs:

```
.opencode/skill/alignment -> ../../.agents/skills/alignment
.claude/skills/alignment  -> ../../.agents/skills/alignment
(same for create-pr, review-pr)
```

- The links resolve and each contains `SKILL.md`.
- Opencode lists all three skills and loaded `alignment` correctly.
- A glob over `.opencode/**` returns nothing because the glob tool does not follow symlinks. That is a tool quirk, not a broken install.
- The skill's reported base directory is `.opencode/skill/alignment`, which confirms Opencode reads through the link.

`--copy` is not needed.

## Instructions: not loading

`install.sh` puts eager fragments into `AGENTS.md` as `@.agents/instructions/<file>.md` lines. Claude Code expands these. Opencode does not, so it sees the literal text and none of the file contents.

Not loaded in this session: `writing-style.md`, `modes.md`, `git-plain.md`.

The repo already documents this in `harness/README.md` and `notes/testing-log.md`. The fix it describes is the `instructions` array in `opencode.json`, but nothing applies it:

- `install.sh` never creates or edits `opencode.json`. A grep for `opencode.json` in the script finds nothing.
- This project has no `opencode.json` or `opencode.jsonc`.
- `~/.config/opencode/opencode.jsonc` has no `instructions` key.
- `harness/opencode/opencode.json` is a template that has to be merged by hand.

## Side effects of the template

`harness/opencode/opencode.json` lists `.agents/instructions/*.md`. If it were merged as-is, it would load every instruction, including the routed ones such as `documentation.md`. That defeats the eager/routed split, and `testing-log.md` already notes it.

## Options

1. **Hand-merge** the template into the project's `opencode.json`. Works now, but it is manual per project and loads routed files too.
2. **Have `install.sh` write the `instructions` array** from the eager entries only (it already collects `load`, `rel`, and `when` for each fragment). This fixes the gap, and the eager/routed split then works under both harnesses. It means a JSON edit in bash, so `jq` or a small fallback is needed.
3. **Convert eager entries to routed rows when the harness is Opencode.** No config file is needed, but the content stops being always-on.

Option 2 is the one that matches the repo's stated design.

## Not verified

- I did not read the contents of the three instruction files. I only confirmed they exist.
- I did not test whether an `instructions` array in a project-level `opencode.json` loads them under v2.1.4. The docs say it should.
