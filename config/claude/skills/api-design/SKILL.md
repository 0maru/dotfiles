---
name: api-design
description: REST API の設計・実装時に使用。リソース設計、ステータスコード、ページネーション、バージョニング、レート制限のベストプラクティスを含む。API エンドポイントの作成・修正時にトリガーする。
---

# API 設計パターン

## リソース設計
- URL は「名詞・複数形・小文字・kebab-case」— パスに動詞を使わない
- サブリソースで関係性を表現

```
GET    /api/v1/users              # 一覧取得
POST   /api/v1/users              # 作成
GET    /api/v1/users/:id          # 個別取得
PUT    /api/v1/users/:id          # 全体更新
PATCH  /api/v1/users/:id          # 部分更新
DELETE /api/v1/users/:id          # 削除
GET    /api/v1/users/:id/orders   # サブリソース
POST   /api/v1/orders/:id/cancel  # アクション（動詞はサブリソースとして）
```

## HTTP ステータスコード

| コード | 用途 |
|--------|------|
| 200 OK | 成功（GET, PUT, PATCH） |
| 201 Created | リソース作成成功（POST）— `Location` ヘッダー付き |
| 204 No Content | 削除成功（DELETE） |
| 400 Bad Request | リクエスト形式不正 |
| 401 Unauthorized | 認証なし |
| 403 Forbidden | 認可なし |
| 404 Not Found | リソースが存在しない |
| 409 Conflict | リソース競合 |
| 422 Unprocessable Entity | 形式は正しいがデータが不正 |
| 429 Too Many Requests | レート制限超過 |
| 500 Internal Server Error | サーバーエラー |

**原則**: エラー時に 200 を返さない。バリデーション失敗で 500 を返さない。

## レスポンス構造

### 成功レスポンス
```json
{
  "data": { "id": "123", "name": "Alice" },
  "meta": { "request_id": "req_abc123" }
}
```

### コレクションレスポンス
```json
{
  "data": [{ "id": "1" }, { "id": "2" }],
  "meta": {
    "total": 100,
    "page": 1,
    "per_page": 20
  },
  "links": {
    "self": "/api/v1/users?page=1",
    "next": "/api/v1/users?page=2",
    "last": "/api/v1/users?page=5"
  }
}
```

### エラーレスポンス
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Input validation failed",
    "details": [
      { "field": "email", "message": "must be a valid email address" }
    ]
  }
}
```

## ページネーション

| データセットサイズ | 方式 | 理由 |
|-------------------|------|------|
| < 10K / 管理画面 | オフセット（`page`, `per_page`） | シンプル、ランダムアクセス可能 |
| 大規模 / フィード | カーソル（opaque token） | 安定したパフォーマンス、一貫性 |

```
# オフセット
GET /api/v1/users?page=2&per_page=20

# カーソル
GET /api/v1/users?cursor=eyJpZCI6MTAwfQ&limit=20
```

## フィルタリング & ソート

```
# 比較: ブラケット記法
GET /api/v1/products?price[gte]=10&price[lte]=100

# ソート: `-` プレフィックスで降順
GET /api/v1/users?sort=-created_at,name

# Sparse fieldsets
GET /api/v1/users?fields=id,name,email
```

## バージョニング

- URL パスバージョニング（`/api/v1/`）を推奨 — 明示的、ルーティングが容易、キャッシュ可能
- 同時に最大2バージョンを維持
- 非推奨化は `Sunset` ヘッダーで6ヶ月前に告知

## レート制限

- `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` ヘッダーを返す
- 制限超過時は `429 Too Many Requests` + `Retry-After` ヘッダー

## プリシップチェックリスト

- [ ] リソースURL が名詞・複数形・kebab-case か
- [ ] HTTP ステータスコードが意味的に正しいか
- [ ] レスポンスが `data` エンベロープでラップされているか
- [ ] エラーレスポンスに `code`, `message`, `details` があるか
- [ ] ページネーションが実装されているか
- [ ] レート制限ヘッダーが返されているか
- [ ] バージョンプレフィックスがあるか
- [ ] 入力バリデーションがあるか
- [ ] 認証・認可チェックがあるか
