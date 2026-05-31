---
allowed-tools: Bash(gh:*), Bash(git remote:*), Bash(git branch:*)
description: "GitHub operations via gh CLI: issues, PRs, CI, code review"
---

# GitHub

Use the `gh` CLI to interact with GitHub repositories, issues, PRs, and CI.

## Context

- Current repo: !`git remote get-url origin 2>/dev/null || echo "(not in a git repo)"`
- Current branch: !`git branch --show-current 2>/dev/null || echo "(detached)"`
- gh auth: !`gh auth status 2>&1 | head -3`

## When to Use

- Checking PR status, reviews, or merge readiness
- Viewing CI/workflow run status and logs
- Creating, closing, or commenting on issues
- Querying GitHub API for repository data

## When NOT to Use

- Local git operations (commit, push, pull) → use `git` directly
- Cloning repositories → use `git clone`
- Non-GitHub repos (GitLab, Bitbucket) → different CLIs

## Common Patterns

### Pull Requests

```bash
# List PRs
gh pr list

# View PR details + CI status
gh pr view <number>
gh pr checks <number>

# View failed CI logs only
gh run view <run-id> --log-failed

# Create PR
gh pr create --title "feat: add feature" --body "Description"

# Merge PR
gh pr merge <number> --squash
```

### Issues

```bash
# List open issues
gh issue list --state open

# Create issue
gh issue create --title "Bug: something broken" --body "Details..."

# Close with comment
gh issue close <number> --comment "Fixed in #<pr>"
```

### CI/Workflow

```bash
# List recent runs
gh run list --limit 10

# Re-run failed jobs
gh run rerun <run-id> --failed
```

### API Queries (advanced)

```bash
# Get specific fields via jq
gh api repos/{owner}/{repo}/pulls/<number> --jq '.title, .state, .user.login'

# List labels
gh api repos/{owner}/{repo}/labels --jq '.[].name'
```

## Tips

- `--json` + `--jq` で構造化出力をフィルタリング可能
- URL を直接渡せる: `gh pr view https://github.com/owner/repo/pull/55`
- `--repo owner/repo` を指定すれば別リポジトリも操作可能
- 頻繁なAPIクエリは `gh api --cache 1h` でキャッシュ

## Your Task

Parse the user's request and execute the appropriate `gh` commands. If no specific request is given, show a summary of the current repo's open PRs and issues.
