---
allowed-tools: Bash(plamo-translate *), Bash(pgrep *), Bash(nohup *)
description: PLaMo Translate でテキストを翻訳する（英→日がデフォルト）
---

# /translate

## コンテキスト

- PLaMo サーバー状態: !`pgrep -lf "plamo-translate server" > /dev/null 2>&1 && echo "起動中" || echo "停止中"`

## 手順

### 1. サーバー起動の確認

上のコンテキストで「停止中」と表示された場合、以下で起動する:

```bash
nohup plamo-translate server > /dev/null 2>&1 &
```

起動後 5 秒待ってから翻訳を実行する。

### 2. 翻訳の実行

`$ARGUMENTS` を翻訳する。

言語の判定:
- テキストが英語 → `--from English --to Japanese`（デフォルト）
- テキストが日本語 → `--from Japanese --to English`
- 明示的な指定があればそれに従う（例: `--to Korean`）

実行コマンド:

```bash
plamo-translate --from {source} --to {target} --input "翻訳対象テキスト"
```

長いテキスト（改行含む）の場合はパイプで渡す:

```bash
echo '翻訳対象テキスト' | plamo-translate --from {source} --to {target}
```

### 3. 結果の出力

翻訳結果をそのまま表示する。余計な説明は不要。
