---
name: codex-plan-review
description: |
  ExitPlanMode の前に自動実行される Codex CLI プランレビュースキル。
  プランモード内で Claude が自動的に使用する。直接トリガーはしない。
---

# Codex Plan Review

プランモードで ExitPlanMode を呼ぶ前に、Codex CLI（OpenAI）にプランをレビューさせる。

## 最重要ルール

**プランファイル以外のファイルを変更してはならない。**

## 前提条件の確認

以下を確認し、満たさない場合はスキップして ExitPlanMode へ進む:

1. `which codex` で Codex CLI がインストールされていること
2. プランファイルが存在すること（プランモードのシステムメッセージに記載されたパス）

エラー時は「Codex レビューをスキップします: {理由}」と表示して続行する。

## 実行手順

### Step 1: プラン読み取り

プランモードで書き出したプランファイルを Read ツールで読み取る。

### Step 2: Codex exec でレビュー実行

以下のコマンドを Bash で実行する。`{プランの全文}` 部分にはStep 1で読み取ったプランの内容を埋め込む:

```bash
codex exec --color never --full-auto \
  - <<'REVIEW_PROMPT'
あなたはシニアソフトウェアアーキテクトです。
以下の実装計画をレビューしてください。

評価基準:
1. 技術的実現可能性: 依存関係・前提条件は正しいか
2. 完全性: 手順の漏れ、エッジケース、ロールバック計画
3. リスク: 破壊的変更、セキュリティ、パフォーマンス、データ整合性
4. 代替案: よりシンプルまたは安全な方法があるか

出力フォーマット:
## Codex Plan Review

### 技術的実現可能性: {PASS|CONCERN|BLOCK}
{説明}

### 完全性: {PASS|CONCERN|BLOCK}
{説明}

### リスク: {LOW|MEDIUM|HIGH}
{上位リスク}

### 代替案
{提案があれば}

### 判定: {APPROVE|SUGGEST_CHANGES|REJECT}
{判定理由}

=== 計画内容 ===
{プランの全文}
REVIEW_PROMPT
```

### Step 3: 結果に応じた対応

| Codex の判定 | 対応 |
|-------------|------|
| **APPROVE** | レビュー結果を表示し、ExitPlanMode へ進む |
| **SUGGEST_CHANGES** | 指摘内容を表示し、妥当な指摘があればプランファイルを修正。修正箇所をユーザーに報告してから ExitPlanMode へ |
| **REJECT** | 指摘内容を表示し、AskUserQuestion でユーザーに続行を確認。続行する場合は ExitPlanMode へ |

## 注意事項

- Codex の指摘を盲目的に受け入れない。Claude 自身の判断で妥当性を評価する
- タイムアウト（2分以上）した場合はスキップする
