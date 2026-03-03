---
allowed-tools: Bash(ou add:*), Bash(ou list:*), Bash(cd:*), mcp__claude_ai_Atlassian__getJiraIssue, AskUserQuestion, EnterPlanMode
description: Jiraチケットからworktreeを作成し、実装計画を立てる
arguments:
  - name: ticket_id
    description: JiraチケットID（例: BACK-302, FRONT-116）
    required: true
---

## Context

- 現在のディレクトリ: !`pwd`
- 現在のブランチ: !`git branch --show-current 2>/dev/null || echo "(git リポジトリではありません)"`
- ou の設定: !`cat .ou/settings.toml 2>/dev/null || echo "(ou 未初期化)"`

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
ou add {確定したブランチ名}
```

作成後、`ou list` でworktreeのパスを確認し、そのディレクトリに移動してください。

### 4. 実装計画の作成

EnterPlanMode で plan mode に入り、Jiraチケットの要件に基づいて:
- コードベースを探索して影響範囲を特定
- 具体的な実装ステップを設計
- 計画をユーザーに提示して確認を取る
