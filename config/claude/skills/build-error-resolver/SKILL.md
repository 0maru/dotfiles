---
name: build-error-resolver
description: ビルドエラー・型エラーの解決時に使用。最小限の変更でビルドを通すことに特化。ビルドが失敗した時、型エラーが発生した時にトリガーする。リファクタリングやアーキテクチャ変更は行わない。
---

# ビルドエラー解決

ビルドエラーを最小限の変更で修正する。リファクタリングやアーキテクチャ変更は行わない。

## ワークフロー

1. **エラー収集**: ビルドコマンドを実行して全エラーを収集
2. **分類**: 型推論、インポート、設定、依存関係に分類
3. **優先順位付け**: ビルドブロッキング → 型エラー → 警告の順
4. **最小修正**: 各エラーに対して最小の修正を適用
5. **検証**: ビルドコマンドを再実行して修正を確認
6. **繰り返し**: ビルドが通るまで繰り返す

## 言語別の診断コマンド

| 言語 | コマンド |
|------|---------|
| TypeScript | `npx tsc --noEmit --pretty` |
| Go | `go build ./...` then `go vet ./...` |
| Rust | `cargo build` then `cargo clippy` |
| Python | `mypy .` or `pyright` |
| Swift | `swift build` |
| Dart | `dart analyze` |

## 一般的な修正パターン

### TypeScript

| エラー | 修正 |
|--------|------|
| `implicitly has 'any' type` | 型アノテーションを追加 |
| `Object is possibly 'undefined'` | Optional chaining `?.` または null チェック |
| `Property does not exist` | インターフェースに追加、または `?` で optional に |
| `Cannot find module` | tsconfig paths 確認、パッケージインストール、インポートパス修正 |
| `Type 'X' not assignable to 'Y'` | 型変換または型定義の修正 |
| `Hook called conditionally` | フックをトップレベルに移動 |
| `'await' outside async` | `async` キーワードを追加 |

### Go

| エラー | 修正 |
|--------|------|
| `undefined: X` | インポート追加、タイポ修正、大文字/小文字の修正 |
| `cannot use X as type Y` | 型変換またはポインタ操作 |
| `X does not implement Y` | メソッドを実装 |
| `import cycle not allowed` | 共有型を新パッケージに抽出 |
| `cannot find package` | `go get` または `go mod tidy` |
| `declared but not used` | 変数を削除または使用 |

### Rust

| エラー | 修正 |
|--------|------|
| `cannot find value` | `use` 文追加 |
| `mismatched types` | 型変換（`.into()`, `as`） |
| `borrow of moved value` | `.clone()` または参照に変更 |
| `lifetime may not live long enough` | ライフタイムアノテーション追加 |
| `unused variable` | `_` プレフィックス追加 |

### Swift

| エラー | 修正 |
|--------|------|
| `use of unresolved identifier` | インポート追加 |
| `cannot convert value of type` | 型キャスト |
| `missing return in function` | return 文追加 |
| `value of optional type not unwrapped` | `guard let` / `if let` / `??` |

### Dart

| エラー | 修正 |
|--------|------|
| `Undefined name` | インポート追加 |
| `The argument type can't be assigned` | 型変換 |
| `Missing return statement` | return 文追加 |
| `Null check operator used on a null value` | null チェック追加 |

## DO / DON'T

**DO:**
- 不足している型アノテーションを追加
- 必要な null チェックを追加
- インポート/エクスポートを修正
- 不足している依存関係を追加
- 型定義を更新
- 設定ファイルを修正

**DON'T:**
- 関連しないコードをリファクタリング
- アーキテクチャを変更
- 変数をリネーム（エラーの原因でない限り）
- 新機能を追加
- ロジックフローを変更（エラー修正以外で）
- パフォーマンスやスタイルの最適化

## 停止条件

以下の場合は修正を中断して報告：
- 同じエラーが3回の修正試行後も残る
- 修正が元のエラー数より多くのエラーを発生させる
- アーキテクチャ変更が必要と判断される

## 成功基準

- ビルドコマンドが exit code 0 で完了
- 新しいエラーが導入されていない
- 変更が最小限（影響ファイルの5%以下）
- 既存のテストがパスする
