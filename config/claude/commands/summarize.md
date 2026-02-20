---
allowed-tools: Bash, Read, Glob, Grep, WebFetch, WebSearch
description: Summarize URLs, files, or search results
---

# Summarize

Extract and summarize content from URLs, local files, or web search results.

## Arguments

Parse the text after `/summarize`:
- **GitHub Repository URL** (`https://github.com/{owner}/{repo}`) → `ghq get` してコードを直接調査
- **URL** (GitHub リポジトリ以外) → fetch and summarize the web page
- **File path** → read and summarize the local file
- **Search query** (prefixed with `?`) → search the web first, then summarize top results
- **No argument** → ask the user what to summarize

## Output Options

The user may append flags after the target:
- `--short` — 2-3 sentence summary
- `--detailed` — comprehensive summary with sections
- `--bullets` — bullet point format
- `--jp` — output in Japanese (default: match input language)
- `--code` — focus on code examples and technical details

Default: medium-length summary in the same language as the source.

## Process

### For GitHub Repositories

GitHub リポジトリ URL（`https://github.com/{owner}/{repo}`）の場合、WebFetch ではなく実際のコードを調査する。

1. `ghq get {url}` でリポジトリを取得（既に取得済みならスキップされる）
2. `ghq list -p -e {owner}/{repo}` でローカルの絶対パスを取得
3. README.md を読んでプロジェクト概要を把握
4. Glob でディレクトリ構造を確認
5. 依存関係ファイル（package.json, Cargo.toml, go.mod, pubspec.yaml 等）を確認し技術スタックを把握
6. Glob/Grep/Read で主要なソースコードを調査
7. 結果をまとめて出力

### For URLs (GitHub リポジトリ以外)

1. Fetch the URL content using WebFetch
2. Extract the main content (skip navigation, ads, footers)
3. Summarize with the requested format

### For Local Files

1. Read the file content
2. For code files: summarize purpose, key functions, dependencies
3. For documents: summarize main points and conclusions
4. For large files: focus on structure and key sections

### For Search Queries (prefixed with `?`)

1. Use WebSearch to find relevant results
2. Fetch the top 2-3 most relevant pages
3. Synthesize a combined summary with source links

## Output Format

```markdown
## Summary: {title or filename}

{summary content}

---
Source: {URL or file path}
```

For search-based summaries, include a Sources section with links.

## Your Task

Parse the user's input and produce a clear, well-structured summary. If the target is ambiguous, ask for clarification. Always cite sources for web content.
