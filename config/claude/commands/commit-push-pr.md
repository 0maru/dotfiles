---
allowed-tools: Bash(git checkout --branch:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(gh pr create:*), Bash(git log:*), Bash(git diff:*), Bash(git branch:*)
description: Commit, push, and open a PR
---

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status`
- Staged and unstaged changes: !`git diff HEAD`
- Recent commits (style reference): !`git log --oneline -5`
- Commits on this branch since origin/main: !`git log origin/main..HEAD --oneline 2>/dev/null || echo "(no commits yet)"`

## Rules

- Commit message is in Japanese
- Do NOT commit files that contain secrets (.env, credentials, etc.)
- Do NOT commit unrelated changes (e.g. submodule pointer changes) unless they are intentional
- Split commits by logical unit of change (avoid over-splitting)
- If there are no changes to commit, skip to push and PR creation

## Your task

Based on the above context, execute the following steps:

1. **Branch**: If on main, create a new branch with a descriptive name
2. **Commit**: Split changes into logical units and create separate commits for each
   - Group changed files by purpose, tool, or feature
     - e.g. aerospace config changes, Claude config changes, zsh config changes should be separate commits
     - Related changes for the same purpose (e.g. multiple files for one tool) can be in a single commit
   - For each commit:
     - Write a concise Japanese commit message following the existing style
     - Use a short title line, and add detail in the body if needed
     - End with: `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
   - If all changes belong to a single logical unit, a single commit is fine
3. **Push**: Push the branch to origin with `-u` flag
4. **PR**: Create a pull request with `gh pr create`. The PR should:
   - Have a short Japanese title (under 70 characters) summarizing ALL changes on the branch
   - Use this body format:

```
## Summary
- <ALL commits on this branch をまとめた1-3行の箇条書き>

## Test plan
- [ ] <テスト項目>
```

5. Return the PR URL when done
6. You MUST do all of the above in a single message. Use parallel tool calls where possible.
