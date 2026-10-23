# Changelog

Follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versions are the `VERSION` file, stamped into every installed copy.

Bump `VERSION` when something installable changes. Changes to `notes/`, `tests/`, or this file do not need a bump.

## Unreleased

## 0.3.0 - 2026-10-23

### Added

- Presets. `install.sh <target> --preset python` installs a named set from `presets/`, one repo-relative path per line. Two to start, `python` and `long-running`, each self-contained so installing one leaves no dangling references.
- A picker. `install.sh <target>` with no items lists everything installable with its `when:` text, multi-select, already-installed items marked. Needs `fzf`; presets and explicit lists do not, so a machine that cannot install tools is unaffected. Without `fzf` it prints the preset list rather than erroring.
- `.agents/manifest` in the target records what is installed. `install.sh <target> --update` reinstalls the lot with no arguments, instead of retyping the original list.
- `sync.sh` reports `DELETED` for a manifest entry that is no longer on disk, which the provenance scan cannot see.

### Changed

- The prose style hook is gone. Enforcement would have been Claude Code only, since Opencode needs a TypeScript plugin for any event. `scripts/style-check.sh` stays as a manual tool and nothing references it.
- `style-check.sh` matches sentence shapes, not just words: contrastive parallelism, the build-up triad, a rhetorical question you then answer, "Not X. But Y.", and staccato triples. `instructions/writing-style.md` carries a bad and good pair for each.
- Cross-references inside installable content name their post-install path, so `.agents/templates/adr.md` rather than `templates/adr.md`. Install warns when a reference points at something not installed.
- Commit messages: lowercase subjects, body capped at 3 lines.

### Removed

- `profiles/toolset.md`, folded into `profiles/james.md`. Most of it duplicated what `create-pr` and the project config already encode.

## 0.2.0 - 2026-10-20

Context management, and a fix to how instructions get wired into `AGENTS.md`.

### Changed

- `install.sh` no longer makes every instruction an eager `@import`. Each instruction declares `<!-- load: eager|routed | when: ... -->` on its first line. Eager becomes an `@import`, routed becomes a row in a `Where to look` table that the agent reads on demand. A fragment with no directive defaults to routed.

  Imports load at session start in both harnesses, so importing everything reproduced the 400-line `AGENTS.md` problem. Listed as a known gap at v0.1.0.

- `install.sh` creates `AGENTS.md` from `templates/agents-md.md` instead of a bare stub, and maintains the two marked sections in it.
- Template installs keep their subdirectory, so `templates/wiki/page.md` lands at `.agents/templates/wiki/page.md`.

### Added

- `instructions/context.md`, eager. Sub-agent delegation triggers, journal triggers, the rule that planning ends on disk, and when to checkpoint instead of compacting again.
- `skills/checkpoint`. Writes `STATE.md`, appends to `JOURNAL.md`, flags decisions missing an ADR. Refuses to write a conversation summary, which is what made an earlier MEMORY.md approach useless.
- `templates/agents-md.md`, a skeleton under 100 lines with a routing table and the install markers.
- `templates/state.md`, rewritten each checkpoint. `templates/journal.md`, append-only, where negative results accumulate.
- `templates/wiki/`, with `index.md`, `page.md`, and `log.md`. Adapted from Karpathy's LLM wiki layout. Pages carry a last-verified date, and the test for inclusion is whether an agent could learn it from the code in a minute.
- `harness/README.md` gains an eager vs lazy loading table.

### Removed

- `handoff` from the "Not built" table, delivered as `checkpoint`.

## 0.1.0 - 2026-10-19

First version. Replaces the loose files in `drafts/`.

### Added

Instructions, installed per project:

- `python.md`, tooling and code standards. Ported from drafts and expanded with layout and exception rules.
- `git-conventional.md` and `git-plain.md`, one or the other, never both. Ported from drafts and expanded with staging and history rules.
- `writing-style.md`, banned words and phrases with rewrite pairs.
- `documentation.md`, README ordering and structure rules.
- `modes.md`, the vibe / assist / defend switch.

Skills:

- `create-pr`, GitHub and GitLab, writes the description from the diff rather than the conversation.
- `review-pr`, separate correctness, intent, security, test, and quality passes, with a verify step before reporting.
- `alignment`, restate and stop before implementing.
- `teach`, mentoring with a 150 word per turn limit, including a code walkthrough path.
- `whiteboard-defense`, tiered drill that does not reveal answers, ends with a gap list.
- `install`, brings fragments into a project and adapts them.

Templates:

- `pr-body.md`, ported from drafts.
- `adr.md`, written at decision time.

Profiles, personal and machine-level:

- `james.md`, how to talk to me and where I am.
- `toolset.md`, what is installed and what to use instead of what.

Scripts:

- `install.sh`, copies into `.agents/`, stamps provenance with a content hash, links into harness skill directories, creates `AGENTS.md` and links `CLAUDE.md` to it.
- `install-profile.sh`, wires profiles into a harness global config without overwriting.
- `sync.sh`, reports CURRENT, BEHIND, LOCAL, DIVERGED, and GONE. Never overwrites.
- `style-check.sh`, markdown linter for the rules in `writing-style.md`. Skips fenced code blocks.

Harness wiring, the only place harness-specific paths are allowed:

- `claude-code/settings.json`, permission allowlist and a PostToolUse hook.
- `claude-code/hooks/style-check-hook.sh`, returns style violations to the agent so it fixes its own prose.
- `opencode/opencode.json`, instruction file list.
- `harness/README.md`, per-harness paths and what to check when adding a fourth.

Notes, never installed:

- `philosophy.md`, design rules for this repo.
- `llm-issues.md`, problems with status, mitigation, and what still leaks. Drives the roadmap.

Also `catalog.md` (what to install and when, plus a "Not built" table with reasons) and `tests/README.md` (one manual scenario per skill, with the failure mode to watch for).

### Notes

- `teach` and `whiteboard-defense` have not been run against real work yet.
- The Opencode global config path in `harness/README.md` is unverified.
