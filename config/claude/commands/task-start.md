---
allowed-tools: Bash(git branch:*), Bash(git worktree add:*), Bash(git worktree list:*), Bash(cd:*), mcp__claude_ai_Atlassian__getJiraIssue, AskUserQuestion, Skill
description: Jiraチケットからworktreeを作成し、実装計画を立てる
arguments:
  - name: ticket_id
    description: JiraチケットID（例: BACK-302, FRONT-116）
    required: true
---

## Context

- 現在のディレクトリ: !`pwd`
- 現在のブランチ: !`git branch --show-current 2>/dev/null || echo "(git リポジトリではありません)"`
- worktree 一覧: !`git worktree list 2>/dev/null || echo "(worktree を取得できません)"`

## あなたのタスク

以下の手順を順番に実行してください。

### 1. Jiraチケットの取得

mcp__claude_ai_Atlassian__getJiraIssue を使って `$ARGUMENTS.ticket_id` の詳細を取得してください。
- cloudId: `1857518a-2dc8-4755-b8e0-50ed87144603`

取得したら以下を表示:
- チケットID・タイトル
- 説明（あれば）
- ステータス
- プロジェクト

### 2. ブランチ名の決定

チケットIDとタイトルから、ブランチ名を提案してください:
- フォーマット: `{チケットID}-{英語の簡潔な説明（kebab-case）}`
- 例: `BACK-302-multiple-product-images`

AskUserQuestion でユーザーに確認を取ってください。

### 3. worktreeの作成

```bash
git worktree add -b {確定したブランチ名} {worktreeパス}
```

パスは既存の git worktree 対応ツールの配置規約を優先してください。
作成後、`git worktree list` でworktreeのパスを確認し、そのディレクトリに移動してください。

### 4. 設計・実装計画の作成

superpowers:brainstorming スキルを使用して、Jiraチケットの要件に基づいて設計・計画を作成する。
brainstorming スキルが完了したら、自動的に writing-plans → 実装フローへ移行する。
