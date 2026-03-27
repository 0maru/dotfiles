---
allowed-tools: Bash(git *), Bash(gh *), Bash(ou *), Agent, Skill, AskUserQuestion
description: マルチエージェントオーケストレーター。既存スキルを連鎖実行してタスクを完遂する。
arguments:
  - name: workflow
    description: "ワークフロー種別: review, feature, bugfix, refactor（省略時は自動検出）"
    required: false
  - name: task
    description: タスクの説明（PR URL、チケットID、タスク内容など）
    required: false
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current 2>/dev/null || echo "(git リポジトリではありません)"`
- Git ステータス: !`git status --short 2>/dev/null`
- 最近のコミット: !`git log --oneline -5 2>/dev/null`

## あなたのタスク

マルチエージェントオーケストレーターとして、指定されたワークフローを実行する。

### Step 1: ワークフロー種別の決定

`$ARGUMENTS.workflow` が指定されている場合はそれを使用する。
未指定の場合は `$ARGUMENTS.task` の内容から自動検出する:

| 入力パターン | ワークフロー |
|---|---|
| PR URL（`github.com/*/pull/*`） | review |
| Jira チケット ID（`[A-Z]+-\d+`） | feature（ユーザーに確認） |
| "refactor" / "リファクタ" を含む | refactor |
| "bug" / "fix" / "バグ" / "修正" を含む | bugfix |
| 上記のいずれにも該当しない | AskUserQuestion で確認 |

両方とも未指定の場合は AskUserQuestion で確認する。

### Step 2: ワークフローの実行

決定したワークフローに応じて適切なコマンドに委譲する:

| ワークフロー | 実行方法 |
|---|---|
| review | `/orchestra-review` と同じ手順を実行 |
| feature | 「Phase 2 で実装予定」とユーザーに伝える |
| bugfix | 「Phase 3 で実装予定」とユーザーに伝える |
| refactor | 「Phase 3 で実装予定」とユーザーに伝える |

### Review ワークフロー（実装済み）

以下の手順で実行する:

#### Phase 1: Diff 取得

PR URL が指定されている場合:
```bash
gh pr diff {PR番号} --repo {owner/repo}
gh pr view {PR番号} --repo {owner/repo} --json title,body,files
```

PR URL がない場合:
```bash
git diff HEAD
git diff --name-only HEAD
```

#### Phase 2: 言語検出

変更ファイルの拡張子とプロジェクトの設定ファイルから言語を検出:

| 設定ファイル / 拡張子 | 言語 | 適用パターン |
|---|---|---|
| `.ts`, `.tsx`, `tsconfig.json` | TypeScript | typescript-patterns |
| `.go`, `go.mod` | Go | golang-patterns |
| `.py`, `pyproject.toml` | Python | python-patterns |
| `.swift`, `Package.swift` | Swift | swift-patterns |
| その他 | — | coding-standards のみ |

#### Phase 3: 3並列エージェントによるレビュー

**3つの Agent ツール呼び出しを1つのメッセージ内で同時に実行する。**

各エージェントに渡す情報:
- 評価観点（A: 品質、B: セキュリティ、C: テスト）
- 変更ファイルリスト
- diff 内容
- 検出された言語と適用スキル
- タスク概要（PR タイトル等）

**Agent A（コード品質）:**
```
あなたは orchestra-evaluator（観点 A: コード品質）です。

以下のコード変更をレビューしてください。

## 評価基準
- 構造: 関数サイズ（50行以下）、ファイルサイズ（800行以下）、ネスト深度（4段以下）
- 品質: エラーハンドリング、不変性パターン、命名の一貫性
- 言語イディオム: {検出言語}のベストプラクティス
- デバッグコード: console.log / print / TODO / FIXME の残留

## 変更ファイル
{ファイルリスト}

## Diff
{diff内容}

信頼度80%以上の問題のみ報告してください。
出力は以下のフォーマットで:
## 評価結果: コード品質
### 発見事項
#### CRITICAL / HIGH / MEDIUM / LOW
### サマリー
### 判定: PASS | REVISE | BLOCK
```

**Agent B（セキュリティ）:**
```
あなたは orchestra-evaluator（観点 B: セキュリティ）です。

以下のコード変更をセキュリティ観点でレビューしてください。

## 評価基準
- OWASP Top 10: インジェクション、認証不備、XSS、CSRF、SSRF
- シークレット管理: ハードコードされた認証情報・APIキー・トークン
- 入力バリデーション: ユーザー入力の検証
- 依存関係: 既知の脆弱性
- 設定: デバッグモード、セキュリティヘッダー

## 変更ファイル
{ファイルリスト}

## Diff
{diff内容}

信頼度80%以上の問題のみ報告してください。
出力は以下のフォーマットで:
## 評価結果: セキュリティ
### 発見事項
#### CRITICAL / HIGH / MEDIUM / LOW
### サマリー
### 判定: PASS | REVISE | BLOCK
```

**Agent C（テストカバレッジ）:**
```
あなたは orchestra-evaluator（観点 C: テストカバレッジ）です。

以下のコード変更のテストカバレッジを評価してください。

## 評価基準
- テスト有無: 変更されたロジックに対するテストが存在するか
- AAA パターン: Arrange-Act-Assert の構造
- エッジケース: 境界値、null/undefined、空配列、エラーケース
- テスト品質: テスト名の明確さ、アサーションの具体性

## 変更ファイル
{ファイルリスト}

## Diff
{diff内容}

信頼度80%以上の問題のみ報告してください。
出力は以下のフォーマットで:
## 評価結果: テストカバレッジ
### 発見事項
#### CRITICAL / HIGH / MEDIUM / LOW
### サマリー
### 判定: PASS | REVISE | BLOCK
```

#### Phase 4: 統合レポート

3エージェントの結果を以下の形式で統合する:

```markdown
# Orchestra Review Report

## 対象
- {PR URL or ブランチ名}
- 変更ファイル数: {N}

## 総合判定: {PASS | REVISE | BLOCK}

最も厳しい判定を総合判定とする（BLOCK > REVISE > PASS）。

## コード品質
{Agent A の結果サマリー}

## セキュリティ
{Agent B の結果サマリー}

## テストカバレッジ
{Agent C の結果サマリー}

## 発見事項一覧（Severity 順）

### CRITICAL
{3エージェントの CRITICAL を統合}

### HIGH
{3エージェントの HIGH を統合}

### MEDIUM
{3エージェントの MEDIUM を統合}

### LOW
{3エージェントの LOW を統合}

## 推奨アクション
{CRITICAL/HIGH の修正を優先すべき項目のリスト}
```

#### Phase 5: ハンドオフ保存

統合レポートをハンドオフドキュメントとして保存:
- 保存先: `plans/orchestra-handoff-review-{YYYYMMDD-HHMMSS}.md`
- ハンドオフフォーマットは `orchestra` スキルの `references/handoff-format.md` に準拠

保存後、レポートの内容をユーザーに表示する。
