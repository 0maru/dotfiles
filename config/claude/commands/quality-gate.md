---
description: 言語自動検出でフォーマッタ + リント + 型チェックを一括実行
---

# /quality-gate

$ARGUMENTS のパスに対して品質チェックパイプラインを実行する。引数がない場合はカレントディレクトリを対象とする。

## 手順

### 1. 言語・ツールの検出

対象ディレクトリの設定ファイルから使用言語とツールを自動検出する：

| ファイル | 言語/ツール |
|---------|------------|
| `tsconfig.json` | TypeScript |
| `package.json` | Node.js / JavaScript |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pyproject.toml` / `setup.py` | Python |
| `Package.swift` | Swift |
| `pubspec.yaml` | Dart / Flutter |
| `build.gradle.kts` | Kotlin |

### 2. フォーマットチェック

検出された言語に応じてフォーマッタを実行：

| 言語 | コマンド |
|------|---------|
| TypeScript/JS | `npx biome check .` or `npx prettier --check .` |
| Go | `gofmt -l .` |
| Rust | `cargo fmt --check` |
| Python | `ruff format --check .` |
| Swift | `swift-format lint -r .` |
| Dart | `dart format --set-exit-if-changed .` |

### 3. リント/型チェック

| 言語 | コマンド |
|------|---------|
| TypeScript | `npx tsc --noEmit && npx eslint .` |
| Go | `go vet ./... && staticcheck ./...` |
| Rust | `cargo clippy -- -D warnings` |
| Python | `ruff check . && mypy .` |
| Swift | `swiftlint lint` |
| Dart | `dart analyze` |

### 4. テスト（利用可能な場合）

| 言語 | コマンド |
|------|---------|
| TypeScript/JS | `npm test` or `npx vitest run` |
| Go | `go test ./...` |
| Rust | `cargo test` |
| Python | `pytest` |
| Swift | `swift test` |
| Dart | `dart test` or `flutter test` |

## 出力フォーマット

各ステップの結果を以下の形式で報告：

```
## Quality Gate Results

### Format Check
- Status: PASS / FAIL
- Details: [問題のあるファイル一覧]

### Lint / Type Check
- Status: PASS / FAIL
- Errors: N
- Warnings: N
- Details: [問題一覧]

### Tests
- Status: PASS / FAIL / SKIPPED
- Passed: N
- Failed: N

### Overall: PASS / FAIL
```

## 注意事項

- ツールがインストールされていない場合はスキップして報告する
- 全ステップが PASS の場合のみ Overall を PASS とする
- FAIL の場合は修正が必要な項目を簡潔に提示
