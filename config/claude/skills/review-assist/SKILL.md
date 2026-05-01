---
name: review-assist
description: |
  PR、git diff、ブランチ差分を人間がレビューするときに使用する。変更ファイルを優先度別に整理して
  ナビゲーションを提示し、ファイルごとの変更要約と所感記録テンプレートを生成する。agent-review
  の集約レポート（あれば）を読み込み、人間が見るべきファイルを絞り込んだうえで所感メモを残す
  用途で使う。「レビューを始める」「レビューメモを作って」「変更ファイルを整理して」「人間
  レビューの準備」「レビューの所感を残したい」「レビュー補助」と言われた時に必ず起動する。
  approve/request-changes は行わず、人間が判断するための材料を整える役割に徹する。
---

# Review Assist

人間が PR / branch 差分をレビューするときに、変更ファイルのナビゲーションと所感メモの記録を補佐する。AI レビュー（agent-review）の後段で人間が要点を掴みやすくすることが目的。

## 立ち位置

- **agent-review**: 多角的 reviewer サブエージェントを並列起動して機械的なふるいをかける（事前）。
- **review-assist**: agent-review の結果と diff を読み、人間が読むべき順序・観点・記録フォーマットを提供する（事後）。

review-assist は判定を下さない。必ず人間が最終判断する前提で、判断材料を構造化する。

## 最重要ルール

- コードを変更しない。PR コメントを投稿しない。approve / request changes をしない。
- 変更行と変更の直接影響に限定する。範囲外の既存問題は出さない。
- 大量の diff を全文転記しない。優先度・要約・所感欄を提供する。
- agent-review レポートが渡された場合、その findings を「重点確認」セクションに引用する。
- 所感欄は空のまま渡す（ユーザーが書く欄）。AI が先回りして埋めない。

## 入力

呼び出し側は次のいずれかを用意する。揃っていない場合は取れる範囲で動く。

- 対象: PR 番号 / URL、または `base...HEAD`、または `git diff` 範囲
- 変更ファイル一覧と additions/deletions
- diff 本文
- agent-review の集約レポート（存在する場合）
- ユーザーからの補足（特に見たい観点、レビュー時間制約 など）

## ワークフロー

### 1. 対象確定
- PR 番号/URL があれば `gh pr view` と `gh pr diff` で取得する。
- ローカル branch なら `git diff --stat <base>...HEAD` と `git diff <base>...HEAD` を使う。
- uncommitted 差分なら `git status` と `git diff HEAD` を使う。
- 対象が空なら「レビュー対象がありません」と返して終了する。

### 2. agent-review レポート参照
- 直前のメッセージ／カレントセッションに agent-review の集約レポートがあれば読み取る。
- 無くても続行できるが、無い場合は「agent-review 未実施」と明記する。
- レポートがある場合は findings を file/line ごとにインデックス化する。

### 3. ファイル分類
[file-classification.md](references/file-classification.md) のルールで各ファイルを 3 段階に振り分ける。

- **🔴 重点確認**: agent-review の blocker/major findings 該当、認証・権限・migration・課金・公開 API 等
- **🟡 通常確認**: 通常の実装・リファクタ
- **🟢 軽微確認**: テスト追加のみ・lockfile・docs・format-only

### 4. ファイル別サマリー作成
各ファイルに対して 1〜3 行で「何が変わったか」「なぜ重要か」を記述する。
- 変更が大きい場合は主要な hunk のみ要約する。
- 何を見るべきかの観点ヒント（例: 「副作用の発生箇所」「null 許容性の変更」）を 1 行付ける。
- 推測で「正しい/間違い」を断定しない。

### 5. レビューメモ生成
[templates.md](references/templates.md) の出力テンプレートで構造化する。
- デフォルトは「標準テンプレート」。レビュー時間が短い指示があれば「クイックテンプレート」を選ぶ。
- 所感欄、判定欄、質問欄は空欄のまま提示する。

### 6. 保存先の確認
出力をファイルに保存するかどうかをユーザーに確認する。
- 保存する場合のデフォルトパス: `tmp/review-{branch-or-pr}-{YYYY-MM-DD}.md`
- ユーザーが別のパスを指定したらそれを優先する。
- 既存ファイルを上書きする前に必ず確認する。

## 分類の閾値（簡易版）

詳細は [file-classification.md](references/file-classification.md)。最初のスクリーニングで使う簡易ルール:

| 分類 | 判定条件（いずれか該当） |
|---|---|
| 🔴 重点 | agent-review が blocker/major、認証/認可/secret 変更、migration、public API スキーマ変更、課金/料金計算ロジック |
| 🟡 通常 | 上記以外の `.ts/.tsx/.go/.py/.rb/.swift/.java` などの実装変更、設定の意味的変更 |
| 🟢 軽微 | `*.test.*` / `*_test.go` のテスト追加のみ、lockfile、`*.md` のみ、CI yaml の値だけの変更、自動 format/lint 起因 |

迷ったら 1 段階上に倒す。

## Codex / agent-review との連携

- agent-review レポートの `Findings` は `🔴 重点確認` セクションの該当ファイル直下に引用する（severity と reviewer-id を残す）。
- 複数 reviewer が同じ箇所を指摘していれば「corroborated」を明記する（信頼度ブースト）。
- agent-review の `確認ポイント` は出力の末尾に「AI が低信頼度で出した観点」として列挙する。
- agent-review の `人間レビューで見るとよい点` は冒頭に強調表示する。

## 出力テンプレート（標準）

[templates.md](references/templates.md) に詳細とクイック版を置く。標準は次の構造:

```markdown
# Review Notes: {branch-or-pr} ({YYYY-MM-DD})

## 対象
- Target: {PR URL | base...HEAD}
- Files: {N} (+{additions}/-{deletions})
- Branch: {branch-name}

## Agent Review サマリー
- Status: {PASS | PASS_WITH_NOTES | REVISE | BLOCK | 未実施}
- Blockers / Major / Minor / Nit: {0/2/3/1}
- 主要指摘: {1-3 行}

## 人間レビューで特に見たい点
- {agent-review の「人間レビューで見るとよい点」を転記。なければ「特になし」}

## 🔴 重点確認

### `path/to/critical-file.ts` (+30/-5)
- 変更内容: {1-3 行}
- 観点: {副作用 / null 許容 / public API 互換 など}
- Agent Findings:
  - [major] {issue} (reviewer: security)
- 所感:
- 判定: [ ] OK / [ ] 質問あり / [ ] 修正要

## 🟡 通常確認

### `path/to/normal-file.ts` (+12/-3)
- 変更内容: {1-2 行}
- 観点: {観点}
- 所感:
- 判定: [ ] OK / [ ] 質問あり / [ ] 修正要

## 🟢 軽微確認
- `path/to/test-file.test.ts` (+50/-0): テスト追加のみ
- `package-lock.json`: lockfile 更新
- 所感:

## 全体所感
-

## 質問・コメント
-

## 確認ポイント（AI 低信頼度）
- {agent-review の「確認ポイント」を転記。なければ省略}

## 判定（人間）
- [ ] Approve
- [ ] Comment（質問あり）
- [ ] Request Changes
```

## 失敗モードと回避

- **diff が巨大**: 全 diff を貼らず、ファイル一覧と stat、🔴/🟡 のみ詳細表示。🟢 は行数のみ。
- **agent-review が無い**: 「未実施」と明示し、findings 引用部分を省略する。代わりに [file-classification.md](references/file-classification.md) の機械的な分類だけで進める。
- **対象判別不能**: PR 番号と branch 名のどちらを期待するかユーザーに 1 度だけ確認する。
- **保存先衝突**: 既存ファイルがあれば上書き確認。`-2`, `-3` のサフィックスは付けない（人間が決める）。

## 参照ファイル

- ファイル分類の詳細ルール: [file-classification.md](references/file-classification.md)
- 出力テンプレート（標準・クイック・PR コメント用）: [templates.md](references/templates.md)
