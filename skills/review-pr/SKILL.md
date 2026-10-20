---
name: review-pr
description: Review a pull request or merge request, or the current branch diff, and report findings ranked by severity. Use when the user asks to review a PR/MR, check a diff before merging, or look over someone else's changes. Reports findings, does not fix them unless asked.
---

# Review PR / MR

## Rules

- Report findings. Do not edit files unless the user asks for fixes.
- Every finding needs a concrete failure: inputs or state, then the wrong result. "This could be fragile" is not a finding.
- Rank by severity. A correctness bug outranks ten style notes.
- Say when you are unsure. Mark a finding `likely` instead of asserting it.
- Do not restate what the diff does. The author knows. Only say what is wrong or missing.
- No praise padding. If the change is clean, say "no blocking findings" and list the minor notes.

## Steps

### 1. Get the diff

Current branch:

```bash
git diff $(git merge-base HEAD origin/<base>)...HEAD
```

A specific PR:

```bash
gh pr diff <number>          # GitHub
glab mr diff <number>        # GitLab
```

Also read the PR description and the linked ticket if there is one. The stated intent is what you check the diff against.

### 2. Build context before judging

Do not review a diff in isolation. For each changed file, read enough of the surrounding code to know:

- What calls this, and what it calls.
- Whether the pattern used here matches the rest of the codebase.
- Whether an existing helper already does this.

Most bad reviews come from not opening the files around the diff.

### 3. Passes

Run these as separate passes. Mixing them means you find three style nits and miss the race condition.

**Correctness**

- Off-by-one, boundary conditions, empty and single-element cases.
- Null, None, and missing-key paths.
- Error handling: swallowed exceptions, errors that lose context, retries without backoff or bound.
- Concurrency: shared mutable state, check-then-act, ordering assumptions.
- Resource handling: unclosed files, connections, locks on the error path.

**Intent**

- Does the diff do what the description says?
- Does it do more than the description says? Unannounced scope is a finding.
- Does it leave the stated problem partly unsolved?

**Security** (anything touching input, auth, or data)

- Unvalidated input reaching a query, a shell, a path, or a template.
- Authorization checked at the wrong layer, or not at all.
- Secrets in code, logs, or error messages.
- New dependencies: what are they, who maintains them, why not stdlib.

**Tests**

- Is the new behavior tested? Is the fixed bug tested?
- Do the tests assert on behavior, or just on mocks they set up themselves?
- Would these tests fail if the change were reverted? If not, say so.

**Quality**

- Duplication of something that already exists in the repo.
- A simpler approach that is clearly available.
- Dead code, debug output, commented-out blocks.

### 4. Verify before reporting

For each candidate finding, try to disprove it. Re-read the code and ask what would have to be true for the code to be correct as written. Drop anything you cannot defend with a concrete failure. False findings cost the author more time than missed ones.

### 5. Report

```
## Blocking
1. `path/file.py:42`: <one-line claim>
   Fails when: <inputs or state> → <wrong result>

## Non-blocking
...

## Notes
- Questions for the author, not defects.
```

If posting inline comments is requested, use `gh pr review --comment` or `glab mr note`. Ask first.

## Project overrides

<!-- Per-project edits go here. Examples: domain invariants that are easy to break,
     files that need extra scrutiny, conventions this repo enforces. -->
