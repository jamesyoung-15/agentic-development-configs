# Changelog

Follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versions are the `VERSION` file, stamped into every installed copy.

Bump `VERSION` when something installable changes. Changes to `notes/`, `tests/`, or this file do not need a bump.

## Unreleased

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
