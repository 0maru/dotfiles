# テストコード作成ガイドライン

## 作成フロー

1. テスト項目をコメントでフラットに一覧化する
2. コメントを元にテストメソッドに変換する（docstring + AAA コメント）
3. テストコードを実装する

各ステップでユーザーの確認を取ってから次に進む。

## 命名規則

### テストメソッド

- 同じ分類のテストは共通の prefix を持つ（例: `test_list_`, `test_create_`）
- docstring は「分類 / 具体的な対象」形式にする

```python
def test_list_returns_all_items(self):
    """一覧取得の検証 / 正常時に全件が返る (200)"""
```

### ヘルパーメソッド

- 動詞 + 名詞のペアで命名する（動詞だけは不可）
- private (`_` prefix) は積極的に利用を禁止したいケースのみ付ける
- AAA に類する prefix を持つことが望ましい（`assert_`, `create_` など）

```python
def create_data(self, ...):
def assert_error_no_detail(self, ...):
```

## AAA (Arrange-Act-Assert) パターン

- 各セクションに `# Arrange:`, `# Act:`, `# Assert:` コメントを書く
- コメントには最低限動詞を含める（名詞だけは不可）
- 各セクション間は空行で区切る
- Arrange の前（docstring 直後）に空行は不要
- Act と Assert を同一セクションにする場合は `# Act, Assert:` と書く

```python
def test_example(self):
    """分類 / 具体的な対象"""
    # Arrange: テストデータを用意する
    obj = self.create_data()

    # Act: API を呼び出す
    res = call_api()

    # Assert: status = 200 か検証
    self.assertEqual(res.status_code, 200)
```

### Assert のルール

- 末尾は「〜かを検証」「〜か検証」で統一する
- status は `status = XXX` と書く
- 複数の検証観点がある場合は別 Assert セクションに分ける（空行で区切る）
- レスポンスの検証と DB の検証は別セクション

```python
    # Assert: status = 201 か検証
    self.assertEqual(res.status_code, 201)

    # Assert: DB にデータが保存されたか検証
    self.assertTrue(Model.objects.filter(...).exists())
```

### DB の before/after 検証

データ更新系（create, update, delete）は Act を挟んで before/after の Assert を書く。
Act による影響であることを明文化するため。

```python
    # Assert: DB にレコードが存在しないか検証 (before)
    self.assertFalse(Model.objects.filter(...).exists())

    # Act: POST 作成を送信する
    res = call_api()

    # Assert: status = 201 か検証
    self.assertEqual(res.status_code, 201)

    # Assert: DB にデータが保存されたか検証 (after)
    self.assertTrue(Model.objects.filter(...).exists())
```

### レスポンスボディ

- レスポンスボディは必ず検証する
- ボディがない場合はないことを検証する（例: `self.assertIsNone(res.data)`）

## セクション行数

1 セクションが 20 行以上にまたがる場合は過大なので、サブセクションを示すコメント行を追加する。

## コードスタイル

### 変数名

- black による複数行化を避けるため、変数名は短く保つ（例: `response` → `res`）

### import

- メソッド内に import を書かない（必須の場合を除く）
- グローバル領域で初期化しない（import 時に評価されるコードを避ける）

```python
# NG
User = get_user_model()
factory = APIRequestFactory()

# OK: 使用箇所で都度呼び出す
get_user_model().objects.create_user(...)
factory = APIRequestFactory()  # メソッド内で生成
```

### setUpTestData

各フィールドに用途をコメントで記載する。

```python
@classmethod
def setUpTestData(cls):
    # get_queryset のフィルタ対象
    cls.site = Site.objects.get_current()
    # site 分離テスト用
    cls.other_site = Site.objects.create(...)
```

### 繰り返しパターンの切り出し

- 類似の検証が 3 回以上繰り返される場合はヘルパーメソッドに切り出す
- 引数はキーワード専用にする（`*` を使う）
- 引数に型アノテーションを書く
- パラメータには `expected_`, `actual_` の prefix を付ける
- 引数の順番は expected, actual の順
- 呼び出し側は必ずキーワード引数で渡す

```python
def assert_error_no_detail(self, *, expected_status: int, actual_res: Response):
    """error を含み detail = null のエラーレスポンスか検証"""
    self.assertEqual(actual_res.status_code, expected_status)
    self.assertIn('error', actual_res.data)
    self.assertIsNone(actual_res.data['detail'])

# 呼び出し
self.assert_error_no_detail(
    expected_status=status.HTTP_404_NOT_FOUND,
    actual_res=res,
)
```

## 日本語表記

- 英数と日本語の間にはスペースを入れる
- 「〜の〜の〜」のような連鎖は避ける
- グループ区切りコメント (`# --- xxx ---`) やセクション区切り (`# -----`) は不要
