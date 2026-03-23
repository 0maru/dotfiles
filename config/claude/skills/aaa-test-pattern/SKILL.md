---
name: aaa-test-pattern
description: テストコードを書く際に使用するスキル。AAA パターン（Arrange-Act-Assert）で統一されたテストを生成する。「テストを書いて」「テスト追加」「ユニットテスト」「test を書いて」と言われた時に使用する。テストコードの新規作成・修正時にも使用する。
---

# AAA テストパターン

すべてのテストコードは AAA（Arrange-Act-Assert）パターンに従って記述すること。

## 基本原則

- すべてのテストメソッドは **Arrange → Act → Assert** の3フェーズで構成する
- 各フェーズは `# Arrange: 説明`, `# Act: 説明`, `# Assert: 説明` のコメントで区切る
- `: ` の後にそのフェーズで **何をしているか** を簡潔に書く
- **1テストメソッド = 1つの Act**（複数の振る舞いをテストしない）
- Arrange が setUp で完結する場合はコメントを省略可
- 事前条件の検証が必要な場合は Act の前に `# Assert: ... (before)` を置いてよい

```python
# 例
def test_create_user_with_valid_data_returns_201(self):
    # Arrange: 必須パラメータのみのリクエストデータを用意する
    user_data = UserFactory.build_dict(email="new@example.com")

    # Assert: DB に対象レコードが存在しないか検証 (before)
    self.assertFalse(User.objects.filter(email="new@example.com").exists())

    # Act: POST ユーザー作成を送信する
    response = self.client.post("/api/users/", user_data)

    # Assert: status = 201, レスポンスに作成データを含むか検証
    self.assertEqual(response.status_code, status.HTTP_201_CREATED)
    self.assertEqual(response.data["email"], "new@example.com")
```

## 命名規則

### テストクラス名
`Test[対象クラス/機能名]`

例: `TestUserRegistration`, `TestOrderCreation`, `TestArticleSerializer`

### テストメソッド名
`test_[action]_[condition]_[expected]`

| 要素 | 説明 | 例 |
|------|------|-----|
| action | テスト対象の操作 | `register_user`, `create_order` |
| condition | 条件（省略可） | `with_valid_email`, `with_duplicate_email` |
| expected | 期待結果 | `creates_active_user`, `returns_400` |

例:
- `test_register_user_with_valid_email_creates_active_user`
- `test_register_user_with_duplicate_email_returns_400`
- `test_list_users_returns_paginated_response`（condition 省略）

## データ生成ルール

- テストデータは **FactoryBoy** を使用して生成する
- `factories.py` を各テストディレクトリまたはアプリ内に配置
- Factory クラス命名: `[Model名]Factory`（例: `UserFactory`, `OrderFactory`）
- テスト固有の値のみ明示的に指定し、その他は Factory のデフォルトに任せる
- API テスト用のリクエストデータには `Factory.build_dict()` パターンを使用する

## テスト種類ガイド

### Django プロジェクト

| テスト種類 | テスト対象 | ファイル名 |
|-----------|-----------|-----------|
| Model テスト | ビジネスロジック・カスタムメソッド・バリデーション | `test_models.py` |
| API (View) テスト | エンドポイントのリクエスト/レスポンス・認証・ステータスコード | `test_views.py` |
| Serializer テスト | バリデーション・シリアライズ/デシリアライズの変換 | `test_serializers.py` |

各テスト種類の具体的なコード例は `references/django-examples.md` を参照すること。

## アンチパターン

### 一般
- 1テストメソッド内で複数の Act を実行する
- テスト名が曖昧（`test_user`, `test_api`, `test_success` など）
- テスト内に過剰な条件分岐ロジック（if/for）
- マジックナンバーの使用（意味のある変数名や定数を使う）

### AI が陥りやすいアンチパターン
- **過剰な mock**: 実際の DB / モデルを使えるところまで mock しない。Django の TestCase は DB をサポートしている
- **冗長なコメント**: AAA コメント（`# Arrange: ...` / `# Act: ...` / `# Assert: ...`）以外の説明コメントを過剰に追加しない
- **汎用的すぎるメソッド名**: `test_success`, `test_failure`, `test_create` のような情報量の少ない名前を使わない
- **浅いアサーション**: `assertIsNotNone` だけで終わらせず、値の中身まで検証する
- **setUp の肥大化**: 全テストデータを setUp で作らない。各テストの Arrange で必要なものだけ作る
- **不要な setUp/tearDown**: FactoryBoy で Arrange に書けるものを setUp に分離しない
