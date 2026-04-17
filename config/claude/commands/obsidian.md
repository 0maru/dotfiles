---
allowed-tools: Bash(obsidian-cli:*), Bash(cat:*/Library/Application Support/obsidian/obsidian.json)
description: Search, create, and manage Obsidian vault notes
---

# Obsidian

Work with Obsidian vaults (plain Markdown notes).

## Context

- Default vault: !`obsidian-cli print-default --path-only 2>/dev/null || echo "(not configured — run: obsidian-cli set-default <vault-name>)"`
- Registered vaults: !`cat ~/Library/Application\ Support/obsidian/obsidian.json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); [print(f'  {v.get(\"path\",\"?\")}') for v in d.get('vaults',{}).values()]" 2>/dev/null || echo "(obsidian not found)"`

## Vault Structure

- Notes: `*.md` (plain Markdown)
- Config: `.obsidian/` (plugin settings — don't modify from CLI)
- Canvases: `*.canvas` (JSON)
- Attachments: configured per vault (images, PDFs, etc.)

## Common Operations

### Search

```bash
# Search by note name
obsidian-cli search "query"

# Search inside note content (full-text)
obsidian-cli search-content "query"
```

### Create

```bash
# Create a new note (opens in Obsidian)
obsidian-cli create "Folder/Note Title" --content "..." --open
```

### Move / Rename

```bash
# Safe rename — updates [[wikilinks]] across the vault
obsidian-cli move "old/path/note" "new/path/note"
```

### Delete

```bash
obsidian-cli delete "path/note"
```

### Direct File Edit

Obsidian vaults are plain files. For bulk edits or content changes, directly read/write `.md` files:

```bash
# Read a note
cat "/path/to/vault/folder/note.md"

# Edit via your editor or programmatically
```

Obsidian auto-detects file changes and updates the UI.

## Tips

- `obsidian-cli move` を使うと `[[wikilink]]` が自動で更新される（`mv` では更新されない）
- 複数のボルトがある場合はまず `set-default` で設定
- `.obsidian/` ディレクトリはスクリプトから触らないこと
- ドット(`.`)で始まるフォルダには URI 経由でノートを作成できない

## Your Task

Parse the user's request and perform the appropriate Obsidian vault operation. If no default vault is configured, help the user set one up first.
