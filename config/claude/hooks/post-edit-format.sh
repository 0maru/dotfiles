#!/usr/bin/env bash
# PostToolUse hook: Edit/Write 後にファイル拡張子に応じたフォーマッターを実行する
# フォーマッターが未インストールの場合はスキップ

FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"

format_with() {
  if command -v "$1" &>/dev/null; then
    "$@" 2>/dev/null
    exit 0
  fi
}

case "$EXT" in
  ts|tsx|js|jsx|mjs|cjs)
    format_with biome format --write "$FILE_PATH"
    format_with prettier --write "$FILE_PATH"
    ;;
  json|css|scss|less|html|md|yaml|yml)
    format_with prettier --write "$FILE_PATH"
    ;;
  py)
    format_with ruff format "$FILE_PATH"
    format_with black --quiet "$FILE_PATH"
    ;;
  go)
    format_with gofmt -w "$FILE_PATH"
    ;;
  rs)
    format_with rustfmt "$FILE_PATH"
    ;;
  dart)
    format_with dart format "$FILE_PATH"
    ;;
  swift)
    format_with swift-format format -i "$FILE_PATH"
    ;;
esac

exit 0
