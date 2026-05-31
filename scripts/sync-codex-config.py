#!/usr/bin/env python3
from __future__ import annotations

import argparse
import copy
import json
import os
import re
import shutil
import sys
import tempfile
from datetime import date, datetime, time
from pathlib import Path
from typing import Any

try:
    import tomllib
except ModuleNotFoundError:
    print("Python 3.11 以上が必要です。", file=sys.stderr)
    sys.exit(1)


BARE_KEY_RE = re.compile(r"^[A-Za-z0-9_-]+$")


def parse_args() -> argparse.Namespace:
    repo_dir = Path(__file__).resolve().parents[1]
    xdg_config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    default_source = xdg_config_home / "codex" / "config.toml"
    if not default_source.exists():
        default_source = repo_dir / "config" / "codex" / "config.toml"

    parser = argparse.ArgumentParser(
        description=(
            "dotfiles の Codex config を正として、既存の ~/.codex/config.toml に "
            "deep merge します。"
        )
    )
    parser.add_argument("--source", type=Path, default=default_source)
    parser.add_argument("--dest", type=Path, default=Path.home() / ".codex" / "config.toml")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--no-backup", action="store_true")
    return parser.parse_args()


def load_toml(path: Path) -> dict[str, Any]:
    try:
        return tomllib.loads(path.read_text())
    except tomllib.TOMLDecodeError as error:
        raise SystemExit(f"TOML の読み込みに失敗しました: {path}: {error}") from error
    except OSError as error:
        raise SystemExit(f"ファイルの読み込みに失敗しました: {path}: {error}") from error


def deep_merge(base: dict[str, Any], override: dict[str, Any]) -> dict[str, Any]:
    merged: dict[str, Any] = {}

    # dotfiles 側の順序を優先し、同じキーは dotfiles 側の値で上書きする。
    for key, override_value in override.items():
        base_value = base.get(key)
        if isinstance(base_value, dict) and isinstance(override_value, dict):
            merged[key] = deep_merge(base_value, override_value)
        else:
            merged[key] = copy.deepcopy(override_value)

    for key, base_value in base.items():
        if key not in override:
            merged[key] = copy.deepcopy(base_value)

    return merged


def quote_key(key: str) -> str:
    if BARE_KEY_RE.match(key):
        return key
    return json.dumps(key, ensure_ascii=False)


def table_name(path: tuple[str, ...]) -> str:
    return ".".join(quote_key(part) for part in path)


def is_array_of_tables(value: Any) -> bool:
    return isinstance(value, list) and bool(value) and all(isinstance(item, dict) for item in value)


def format_value(value: Any, indent: str = "") -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, int) and not isinstance(value, bool):
        return str(value)
    if isinstance(value, float):
        return repr(value)
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, date):
        return value.isoformat()
    if isinstance(value, time):
        return value.isoformat()
    if isinstance(value, list):
        if not value:
            return "[]"
        if all(not isinstance(item, (dict, list)) for item in value) and len(value) <= 3:
            return "[" + ", ".join(format_value(item, indent) for item in value) + "]"
        child_indent = indent + "  "
        lines = ["["]
        for item in value:
            lines.append(f"{child_indent}{format_value(item, child_indent)},")
        lines.append(f"{indent}]")
        return "\n".join(lines)

    raise TypeError(f"未対応の値です: {value!r}")


def split_table_items(data: dict[str, Any]) -> tuple[list[tuple[str, Any]], list[tuple[str, Any]]]:
    values: list[tuple[str, Any]] = []
    children: list[tuple[str, Any]] = []

    for key, value in data.items():
        if isinstance(value, dict) or is_array_of_tables(value):
            children.append((key, value))
        else:
            values.append((key, value))

    return values, children


def emit_table(lines: list[str], data: dict[str, Any], path: tuple[str, ...]) -> None:
    values, children = split_table_items(data)

    if path and (values or not children):
        if lines:
            lines.append("")
        lines.append(f"[{table_name(path)}]")

    for key, value in values:
        formatted = format_value(value)
        if "\n" in formatted:
            lines.append(f"{quote_key(key)} = {format_value(value)}")
        else:
            lines.append(f"{quote_key(key)} = {formatted}")

    for key, value in children:
        child_path = path + (key,)
        if isinstance(value, dict):
            emit_table(lines, value, child_path)
        elif is_array_of_tables(value):
            emit_array_of_tables(lines, value, child_path)
        else:
            raise TypeError(f"未対応のテーブル値です: {value!r}")


def emit_array_of_tables(lines: list[str], values: list[dict[str, Any]], path: tuple[str, ...]) -> None:
    for item in values:
        item_values, item_children = split_table_items(item)

        if lines:
            lines.append("")
        lines.append(f"[[{table_name(path)}]]")

        for key, value in item_values:
            formatted = format_value(value)
            lines.append(f"{quote_key(key)} = {formatted}")

        for key, value in item_children:
            child_path = path + (key,)
            if isinstance(value, dict):
                emit_table(lines, value, child_path)
            elif is_array_of_tables(value):
                emit_array_of_tables(lines, value, child_path)
            else:
                raise TypeError(f"未対応のテーブル値です: {value!r}")


def dump_toml(data: dict[str, Any]) -> str:
    lines: list[str] = []
    emit_table(lines, data, ())
    return "\n".join(lines).rstrip() + "\n"


def write_atomic(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = path.stat().st_mode & 0o777 if path.exists() else None
    with tempfile.NamedTemporaryFile("w", dir=path.parent, delete=False) as tmp:
        tmp.write(content)
        tmp_path = Path(tmp.name)
    if mode is not None:
        tmp_path.chmod(mode)
    tmp_path.replace(path)


def backup_path(path: Path) -> Path:
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    return path.with_name(f"{path.name}.bak.{timestamp}")


def main() -> int:
    args = parse_args()
    source = args.source.expanduser()
    dest = args.dest.expanduser()

    if not source.exists():
        print(f"source がありません: {source}", file=sys.stderr)
        return 1

    source_data = load_toml(source)
    dest_data = load_toml(dest) if dest.exists() else {}
    merged_data = deep_merge(dest_data, source_data)
    merged_text = dump_toml(merged_data)

    # 書き込み前に、生成した TOML を必ず検証する。
    tomllib.loads(merged_text)

    current_text = dest.read_text() if dest.exists() else None
    if current_text == merged_text:
        print(f"{dest} は既に同期済みです。")
        return 0

    if args.dry_run:
        print(merged_text, end="")
        return 0

    if dest.exists() and not args.no_backup:
        backup = backup_path(dest)
        shutil.copy2(dest, backup)
        print(f"backup: {backup}")

    write_atomic(dest, merged_text)
    print(f"synced: {source} -> {dest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
