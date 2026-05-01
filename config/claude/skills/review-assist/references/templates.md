# 出力テンプレート集

レビューメモの出力テンプレート。状況に応じて選ぶ。

## 目次

1. [標準テンプレート](#標準テンプレート)
2. [クイックテンプレート](#クイックテンプレート)
3. [PR コメント用テンプレート](#pr-コメント用テンプレート)
4. [使い分けの目安](#使い分けの目安)

## 標準テンプレート

通常のレビュー時のデフォルト。1〜10 ファイル程度の差分に向く。

```markdown
# Review Notes: {branch-or-pr} ({YYYY-MM-DD})

## 対象
- Target: {PR URL | base...HEAD}
- Files: {N} (+{additions}/-{deletions})
- Branch: {branch-name}
- Reviewer: {人間の名前 / 空欄}

## Agent Review サマリー
- Status: {PASS | PASS_WITH_NOTES | REVISE | BLOCK | 未実施}
- Blockers / Major / Minor / Nit: {0/2/3/1}
- 主要指摘:
  - {1 行サマリー}
  - {1 行サマリー}

## 人間レビューで特に見たい点
- {agent-review の「人間レビューで見るとよい点」を転記。なければ「特になし」}

## 🔴 重点確認

### `path/to/critical-file.ts` (+30/-5)
- 変更内容: {1-3 行で何が変わったか}
- 観点: {副作用 / null 許容 / public API 互換 / 例外パス など}
- Agent Findings:
  - [major] {issue 要約} (reviewer: security, confidence: high)
  - [minor] {issue 要約} (reviewer: typescript-type-safety)
- 所感:
- 質問:
- 判定: [ ] OK / [ ] 質問あり / [ ] 修正要

## 🟡 通常確認

### `path/to/normal-file.ts` (+12/-3)
- 変更内容: {1-2 行}
- 観点: {観点}
- Agent Findings: なし
- 所感:
- 判定: [ ] OK / [ ] 質問あり / [ ] 修正要

## 🟢 軽微確認

| ファイル | 変更 | 所感 |
|---|---|---|
| `path/to/test-file.test.ts` | +50/-0 テスト追加 |  |
| `package-lock.json` | lockfile 更新 |  |
| `README.md` | 文言修正 |  |

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

## メモ
- レビュー所要時間: {分}
- フォローアップ: {次に確認したい点 / Issue 化したい点}
```

## クイックテンプレート

差分が小さい / レビュー時間が短い場合。3 ファイル以下、または「ざっと見る」指示があるとき。

```markdown
# Quick Review: {branch-or-pr} ({YYYY-MM-DD})

## 対象
- Target: {PR URL | base...HEAD}
- Files: {N} (+{additions}/-{deletions})

## Agent Review
- Status: {... | 未実施}
- 要点: {1-2 行}

## 重点確認
- `path/file.ts` (+30/-5) — {1 行要約}
  - 所感:
- `path/other.ts` (+12/-3) — {1 行要約}
  - 所感:

## その他
- {その他のファイルを 1 行で}

## 判定
- [ ] Approve / [ ] Comment / [ ] Request Changes
- 全体所感:
```

## PR コメント用テンプレート

レビューメモを PR コメントに転載する場合。所感は人間が記入済みの想定。判定欄は外す（PR 機能側で行うため）。

```markdown
## レビューコメント

### 全体所感
{記入}

### ファイル別

**`path/to/file.ts`**
{所感 / 質問}

**`path/to/other.ts`**
{所感 / 質問}

### 質問
- {質問 1}
- {質問 2}
```

PR コメント転載時の注意:
- agent-review の findings をそのまま投稿しない（人間が選別したものだけ載せる）。
- 機械的な「未確認」「判定: OK」の欄は削除する。
- レビュー所要時間や reviewer 名などのメタ情報は除外する。

## 使い分けの目安

| 状況 | テンプレート |
|---|---|
| 通常の PR レビュー | 標準 |
| 1〜3 ファイルの小さな PR | クイック |
| 「時間がない」「ざっと見たい」指示 | クイック |
| レビュー結果を PR コメントにする | 標準で書き、PR コメント用に変換 |
| agent-review が未実施 | 標準（findings 部分は省略） |

## 共通ルール

- 所感欄・判定欄・質問欄は空のまま渡す。AI は埋めない。
- agent-review の引用は severity と reviewer-id を必ず併記する（出典の追跡可能性）。
- ファイルパスは backtick で囲む（クリッカブルにするため）。
- 行数表記は `(+N/-M)` 形式で統一する。
