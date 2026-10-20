---
name: create-pr
description: Open a pull request or merge request from the current branch. Use when the user asks to create a PR, MR, open a pull request, or "ship this". Works with GitHub (gh) and GitLab (glab). Writes the description from the actual diff, not from the conversation.
---

# Create PR / MR

## Rules

- Describe the diff, not the conversation. Re-read the changes before writing anything. What you remember doing and what is actually staged often differ.
- Follow `writing-style.md`. No em dashes, no emoji, no filler.
- Do not credit the agent anywhere in the branch, commits, title, or body.
- Never force-push, rebase, or amend without being asked.
- Stop and ask before pushing if the branch is `main`, `master`, `develop`, or the repo default.

## Steps

### 1. Figure out the forge

```bash
git remote get-url origin
```

- Contains `github` → use `gh`
- Contains `gitlab` → use `glab`
- Neither, or the CLI is missing → write the description to a file, print it, and tell the user to paste it. Do not guess at an API.

### 2. Read the actual change

```bash
git status --short
git log --oneline <base>..HEAD
git diff <base>...HEAD --stat
git diff <base>...HEAD
```

Find `<base>` from the repo default branch, not from assumption:

```bash
git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null | sed 's|origin/||'
```

If the diff is large, read the stat first, then the files that carry the behavior change. Skip lockfiles and generated output.

### 3. Check it is ready

- Uncommitted changes that belong in this PR? Ask before committing them.
- Debug prints, commented-out code, `TODO(me)`, stray test files in the diff? Flag them.
- Secrets, tokens, `.env` contents, internal hostnames? Stop and tell the user.
- Tests and linter: run them if the project has them. Report real results. If you did not run them, say so in the PR body.

### 4. Write the description

Use `templates/pr-body.md`. Fill `What` and `Why` always. Drop `Approach` and `Testing` if there is nothing real to put there, do not pad them.

- `What`: one bullet per user-visible or API-visible change. Not one bullet per file.
- `Why`: the problem being solved. If there is a ticket, the ticket is context, not the reason.
- `Approach`: only the decisions a reviewer would stop on. Pull these from ADRs if the project has them.
- `Testing`: the commands you actually ran and what they printed.
- `Notes`: ticket link, known gaps, follow-ups.

Title: same rules as a commit subject in the project's git standards. Conventional (`feat: ...`) or plain (`Add ...`), match what the repo's existing history uses.

### 5. Push and open

```bash
git push -u origin <branch>
```

GitHub:

```bash
gh pr create --base <base> --title "<title>" --body-file <file> --draft
```

GitLab:

```bash
glab mr create --target-branch <base> --title "<title>" --description "$(cat <file>)" --draft
```

- Open as draft by default. Say so, and tell the user the command to mark it ready.
- If the repo has a PR template at `.github/pull_request_template.md` or `.gitlab/merge_request_templates/`, use that structure instead of ours.

### 6. Report

Print the URL and a 3-line summary. Nothing else.

## Project overrides

<!-- Per-project edits go here. Examples: required reviewers, label conventions,
     ticket ID format, "never open as draft", a different base branch. -->
