---
allowed-tools: Bash(git *), Bash(gh *), Agent, AskUserQuestion
description: コード変更を品質・セキュリティ・テストの3観点から並列レビュー
arguments:
  - name: target
    description: PR URL またはレビュー対象の説明（省略時は git diff HEAD）
    required: false
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current 2>/dev/null || echo "(git リポジトリではありません)"`
- 変更ファイル: !`git diff --name-only HEAD 2>/dev/null`
- ブランチの全コミット: !`git log origin/main..HEAD --oneline 2>/dev/null || echo "(コミットなし)"`

## あなたのタスク

コード変更を3つの独立したエージェントで並列レビューし、統合レポートを出力する。

### Step 1: レビュー対象の取得

**PR URL が指定されている場合:**

PR 番号とリポジトリを URL から抽出し、以下を実行:
```bash
gh pr diff {PR番号}
gh pr view {PR番号} --json title,body,changedFiles,additions,deletions
```

**PR URL が指定されていない場合:**

ローカルの変更を取得:
```bash
git diff HEAD
git diff --name-only HEAD
```

変更がない場合は `origin/main..HEAD` の diff を取得:
```bash
git diff origin/main..HEAD
git diff --name-only origin/main..HEAD
```

### Step 2: 言語検出

変更ファイルの拡張子から言語を検出する:

- `.ts` / `.tsx` → TypeScript（`typescript-patterns` スキル適用）
- `.go` → Go（`golang-patterns` スキル適用）
- `.py` → Python（`python-patterns` スキル適用）
- `.swift` → Swift（`swift-patterns` スキル適用）
- その他 → `coding-standards` スキルのみ適用

### Step 3: 3並列レビュー

**以下の3つの Agent 呼び出しを、必ず1つのメッセージ内で同時に実行すること。**

各エージェントには以下を渡す:
- 変更ファイルのリスト（パスと拡張子）
- diff の全内容
- 検出された言語
- PR のタイトル・説明（あれば）

#### Agent A: コード品質レビュー

Agent ツールで起動。プロンプトに以下を含める:
- 役割: コード品質の評価
- 基準: 関数サイズ（50行以下）、ファイルサイズ（800行以下）、ネスト深度（4段以下）、エラーハンドリング、不変性パターン、命名一貫性、言語固有イディオム、デバッグコード残留
- diff 内容を全文含める
- 出力フォーマット: `## 評価結果: コード品質` → CRITICAL/HIGH/MEDIUM/LOW の発見事項 → サマリー → 判定

#### Agent B: セキュリティレビュー

Agent ツールで起動。プロンプトに以下を含める:
- 役割: セキュリティの評価
- 基準: OWASP Top 10、シークレット管理、入力バリデーション、依存関係の脆弱性、セキュリティ設定
- diff 内容を全文含める
- 出力フォーマット: `## 評価結果: セキュリティ` → CRITICAL/HIGH/MEDIUM/LOW の発見事項 → サマリー → 判定

#### Agent C: テストカバレッジレビュー

Agent ツールで起動。プロンプトに以下を含める:
- 役割: テストカバレッジの評価
- 基準: テスト有無、AAA パターン、エッジケース、テスト品質
- diff 内容を全文含める
- 出力フォーマット: `## 評価結果: テストカバレッジ` → CRITICAL/HIGH/MEDIUM/LOW の発見事項 → サマリー → 判定

### Step 4: 統合レポート

3エージェントの結果を受け取ったら、以下の形式で統合する:

```
# Orchestra Review Report

## 対象
- {PR URL or ブランチ名}
- 変更ファイル数: {N}

## 総合判定: {PASS | REVISE | BLOCK}
（3エージェントのうち最も厳しい判定。BLOCK > REVISE > PASS）

---

## コード品質（Agent A）
判定: {PASS/REVISE/BLOCK} — CRITICAL: {N}, HIGH: {N}, MEDIUM: {N}, LOW: {N}

## セキュリティ（Agent B）
判定: {PASS/REVISE/BLOCK} — CRITICAL: {N}, HIGH: {N}, MEDIUM: {N}, LOW: {N}

## テストカバレッジ（Agent C）
判定: {PASS/REVISE/BLOCK} — CRITICAL: {N}, HIGH: {N}, MEDIUM: {N}, LOW: {N}

---

## 発見事項（Severity 順）

### CRITICAL
（全エージェントの CRITICAL を統合、ファイル:行 付き）

### HIGH
（全エージェントの HIGH を統合）

### MEDIUM
（全エージェントの MEDIUM を統合）

### LOW
（全エージェントの LOW を統合）

---

## 推奨アクション
（CRITICAL/HIGH の修正方法を優先順に列挙）
```

### Step 5: ハンドオフ保存

統合レポートをハンドオフドキュメントとして保存する:
- ファイル名: `plans/orchestra-handoff-review-{YYYYMMDD-HHMMSS}.md`
- ハンドオフフォーマットの `メタデータ` セクションを先頭に追加
- ワークフロー: review、ステータス: 総合判定の値

保存完了後、統合レポートをユーザーに表示する。

## 注意事項

- 変更されていないコード（既存コード）への指摘は除外する
- 信頼度 80% 以上の問題のみ報告する
- 同種の問題は統合して報告する
- 発見事項が 0 件の場合は「問題なし」と明記する
