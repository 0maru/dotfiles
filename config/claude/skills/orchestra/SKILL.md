---
name: orchestra
description: |
  マルチエージェントオーケストレーションのコア定義。ワークフロー種別、フェーズ構成、ルーティングロジックを定義する。
  /orchestrate コマンドから参照される内部スキル。直接トリガーはしない。
---

# Orchestra: マルチエージェントオーケストレーション

既存スキル・コマンドを連鎖実行して、タスクを自律的に完遂するためのオーケストレーションフレームワーク。

## 設計原則

1. **既存資産の再利用**: スキル・コマンドの中身を複製しない。参照して連鎖させる
2. **Generator-Evaluator 分離**: コード生成と品質評価を別エージェントが担当する（GANパターン）
3. **人間ゲート**: 実装計画の承認は必ず人間が行う
4. **決定論的品質強制**: 停止条件とハンドオフプロトコルで品質を担保する

## ワークフロー種別

### review（Phase 1 で実装済み）

コード変更を複数観点から並列評価し、統合レポートを出力する。

```
Phase 1: Diff 取得
  入力: PR URL or git diff
  出力: 変更ファイルリスト + diff 内容
    ↓
Phase 2: 並列レビュー（3エージェント同時実行）
  Agent A: コード品質（coding-standards + {language}-patterns）
  Agent B: セキュリティ（security-review）
  Agent C: テストカバレッジ（aaa-test-pattern）
    ↓
Phase 3: 統合レポート
  3エージェントの結果を統合し、Severity 順にソートして出力
  ハンドオフドキュメントを plans/ に保存
```

### feature（Phase 2 で実装予定）

```
Phase 1: Plan（planner）→ ユーザー承認
Phase 2: Implement → /quality-gate パス
Phase 3: Review Loop（最大5回）
Phase 4: Finalize（/commit-push-pr）
```

### bugfix（Phase 3 で実装予定）

```
Phase 1: Diagnose（planner）→ 根本原因分析
Phase 2: Fix → 最小修正 + 回帰テスト
Phase 3: Validate Loop（最大5回）
Phase 4: Finalize（/commit-push-pr）
```

### refactor（Phase 3 で実装予定）

```
Phase 1: Analyze（planner + refactor-cleaner）
Phase 2: Refactor（バッチ単位）
Phase 3: Review Loop（最大5回）
Phase 4: Finalize（/commit-push-pr）
```

## ワークフロー自動検出

引数からワークフロー種別を推定するルール:

| 入力パターン | 推定ワークフロー |
|---|---|
| PR URL（`github.com/*/pull/*`） | review |
| Jira チケット ID（`[A-Z]+-\d+`） | feature（ユーザーに確認） |
| "refactor" / "リファクタ" を含む | refactor |
| "bug" / "fix" / "バグ" / "修正" を含む | bugfix |
| 上記のいずれにも該当しない | AskUserQuestion で確認 |

## エージェント構成

| エージェント | 役割 | スキル |
|---|---|---|
| orchestra-planner | タスク分析・計画作成 | investigate-repo パターン |
| orchestra-evaluator | 独立品質評価（コード変更しない） | coding-standards, security-review, {lang}-patterns |
| orchestra-loop-operator | レビュー→修正ループの管理 | build-error-resolver の停止条件 |

## 言語検出テーブル

対象プロジェクトの設定ファイルから使用言語を検出し、適用スキルを決定する:

| 設定ファイル | 言語 | 適用スキル |
|---|---|---|
| `tsconfig.json` / `package.json` | TypeScript/JS | typescript-patterns |
| `go.mod` | Go | golang-patterns |
| `Cargo.toml` | Rust | （汎用: coding-standards） |
| `pyproject.toml` / `setup.py` | Python | python-patterns |
| `Package.swift` | Swift | swift-patterns |
| `pubspec.yaml` | Dart/Flutter | （汎用: coding-standards） |

## ループ制御パラメータ

| パラメータ | デフォルト値 | 説明 |
|---|---|---|
| max_iterations | 5 | レビュー→修正ループの最大回数 |
| same_error_limit | 3 | 同一エラーが残り続けた場合の停止しきい値 |
| oscillation_threshold | 2 | 揺動パターン検出時に BLOCK に昇格する回数 |

## ハンドオフプロトコル

エージェント間の引き継ぎは構造化 Markdown で行う。
詳細な仕様は `references/handoff-format.md` を参照。

保存先: プロジェクトの `plans/` ディレクトリ
ファイル名: `orchestra-handoff-{workflow}-{timestamp}.md`
