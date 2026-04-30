---
name: agent-review
description: |
  PR、git diff、ブランチ差分を AI でレビューするときに使用する。マルチエージェントレビュー、
  多角的レビュー、並列コードレビュー、複数観点レビューといった依頼でも必ず起動する。
  差分内容から必要な専門 Agent（セキュリティ、アーキテクチャ、TypeScript 型安全性、
  データベース設計、Frontend UX など）を 3〜5 個選び、並列実行した結果を Aggregator が
  低ノイズに集約する。/agent-review コマンドから参照される。
---

# Agent Review

PR/差分を人間レビュー前にふるいにかけるためのレビューオーケストレーション。目的は approve 代行ではなく、実害のあるミス・見落とし・テスト不足を高信頼度で拾うこと。

## 設計の前提

- **多様な観点が単一観点の繰り返しに勝る**: 同じレビューを複数回繰り返すより、異なる専門観点（security / architecture / type-safety / database / frontend など）の Agent を独立に走らせるほうが網羅性も精度も高い（Mixture-of-Agents 的 Proposer + Aggregator 構成）。
- **複数 Agent の合意は強いシグナル**: 異なる Agent が独立に同じ箇所を指摘した場合、それは高信頼度の問題として扱う（Multi-Agg 集約戦略）。
- **散発的な単独指摘は慎重に**: 1 Agent だけの主観的・低根拠な指摘は Precision を下げるため、findings から外して確認ポイントに回す。

## 最重要ルール

- レビューのみ行い、コード修正・PR コメント投稿・approve/request changes はしない。
- 変更行、または変更の直接影響に限定して指摘する。
- 好み、抽象的な設計論、変更範囲外の既存問題は出さない。
- 自動チェックで決定的に分かる問題は、Agent の推測ではなくチェック結果として扱う。
- 専門 Agent は必要なものだけ起動する。毎回すべての Agent を起動しない。
- 起動する Agent は通常 3〜5 個。少なすぎると観点が偏り、多すぎるとノイズが増える。

## 入力

呼び出し側は次を用意する:

- PR 情報: title, body, base/head, additions/deletions（PR の場合）
- 変更ファイル一覧
- diff 本文
- 自動チェック結果: lint, typecheck, test, build, CI checks（実行・取得できた範囲）
- 対象の補足説明（ユーザー指定がある場合）

## ワークフロー

1. **対象確認**: diff が空なら終了。大きすぎる場合は変更ファイル一覧、重要 hunk、関連する既存実装を優先する。
2. **自動チェック整理**: 失敗コマンド、失敗概要、該当ファイルを `自動チェック結果` に分離する。
3. **Router 実行**: [routing.md](references/routing.md) を読み、変更内容から起動する Agent を選ぶ。
4. **Agent プロンプト作成**: [reviewers.md](references/reviewers.md) を読み、選択した Agent ごとの「見るもの/見ないもの」を渡す。
5. **並列レビュー**: 必ず 1 メッセージ内で複数の Agent ツール呼び出しを並べて並列起動する（順次起動するとレイテンシが線形に増えるだけで Aggregation の効果が薄れる）。各 Agent は自分の観点だけをレビューする。
6. **集約**: [severity.md](references/severity.md) を読み、cross-agent の合意を信頼度ブーストに使い、重複・低信頼度・好みの指摘を落として最終レポートにする。

## Router 出力

Router は Agent 起動前に次の形式で判断を明示する:

```markdown
## Router Decision

### Selected
- hygiene: 常時レビュー
- correctness: 常時レビュー
- typescript-type-safety: `.ts` と API 型定義が変更されているため

### Skipped
- database-design: migration/query/model の変更がないため
- security: 認証・権限・入力境界・secret 変更がないため
```

## Agent 共通契約

各 Agent に必ず伝える:

- コードを変更しない。
- 自分の専門観点だけを見る。
- `confidence: low` の指摘は findings に入れず、確認ポイントに回す。
- 根拠が diff から追えない指摘は断定しない。
- 出力は下記形式に固定する。

```markdown
## Reviewer: {reviewer-id}

### Findings
- severity: blocker | major | minor | nit
  file: path/to/file.ext
  line: 123
  confidence: high | medium | low
  issue: 何が問題か
  why: なぜ実害があるか
  suggested_fix: 具体的な直し方

### Checks
- 見たもの
- 見なかったもの

### Summary
- PASS | REVISE | BLOCK
```

## 集約レポート

最終出力はこの形式にする:

```markdown
# Agent Review Report

## 対象
- Target: {PR URL | base...HEAD | git diff HEAD}
- Files: {N}
- Additions/Deletions: +{N}/-{N}（分かる場合）

## Router Decision
- Selected: ...
- Skipped: ...

## 自動チェック結果
| Command | Status | Notes |
|---|---|---|
| ... | PASS/FAIL/SKIPPED | ... |

## 総合判定
{PASS | PASS_WITH_NOTES | REVISE | BLOCK}

## Findings

### {severity}: {短いタイトル}
- file:line: `path/to/file.ext:123`
- reviewer: {reviewer-id}（複数 Agent の合意がある場合は `corroborated_by: [a, b]` を併記）
- confidence: {high|medium}
- issue: ...
- why: ...
- suggested_fix: ...

## 確認ポイント
- 低信頼度だが人間が見る価値のある点。なければ「なし」。

## 人間レビューで見るとよい点
- AI が判断しづらい仕様、UX、設計トレードオフだけを列挙する。
```

## 参照ファイル

- Agent 選択時: [routing.md](references/routing.md)
- Agent 定義作成時: [reviewers.md](references/reviewers.md)
- 集約・判定時: [severity.md](references/severity.md)
