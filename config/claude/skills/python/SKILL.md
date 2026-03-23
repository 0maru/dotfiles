---
name: python-patterns
description: Python コードの作成・レビュー時に使用。Pythonic パターン、セキュリティ、テスト規約、レビューチェックリストを含む。`.py` ファイルの編集・作成・レビュー時にトリガーする。
---

# Python パターン & ベストプラクティス

## コーディングスタイル

- **PEP 8** 準拠（ruff or black でフォーマット）
- **命名**: snake_case（変数・関数・モジュール）、PascalCase（クラス）、UPPER_SNAKE_CASE（定数）
- **型ヒント**: public 関数には必ず型アノテーション
- **docstring**: public 関数・クラスには docstring を記述
- **インポート**: 標準ライブラリ → サードパーティ → ローカルの順、`isort` で自動整理
- **関数サイズ**: 50行以下を目安

```python
# Good: type hints + docstring
def get_user(user_id: str) -> User | None:
    """Fetch a user by ID from the database."""
    if not user_id:
        raise ValueError("user_id must not be empty")
    return db.query(User).filter_by(id=user_id).first()
```

## パターン

### データクラス
- `dataclasses.dataclass` or `pydantic.BaseModel` でデータモデルを定義
- 不変データは `frozen=True` or `model_config = ConfigDict(frozen=True)`
- `__post_init__` でバリデーションロジック

```python
from dataclasses import dataclass, field

@dataclass(frozen=True)
class User:
    id: str
    name: str
    email: str
    roles: list[str] = field(default_factory=list)

    def __post_init__(self) -> None:
        if not self.id:
            raise ValueError("id must not be empty")
```

### コンテキストマネージャ
- リソース管理には `with` 文を必ず使用（ファイル、DB接続、ロック等）
- カスタムコンテキストマネージャは `contextlib.contextmanager` で作成

```python
# Good: context manager
with open("data.json") as f:
    data = json.load(f)
```

### 非同期処理
- `asyncio` + `async/await` で非同期 I/O
- `asyncio.gather()` で並行タスク
- `asyncio.TaskGroup` (Python 3.11+) で構造化された並行処理

```python
async def fetch_dashboard() -> DashboardData:
    async with asyncio.TaskGroup() as tg:
        users_task = tg.create_task(fetch_users())
        orders_task = tg.create_task(fetch_orders())
        stats_task = tg.create_task(fetch_stats())
    return DashboardData(
        users=users_task.result(),
        orders=orders_task.result(),
        stats=stats_task.result(),
    )
```

### Pythonic イディオム
- リスト内包表記を適切に使用（複雑なら通常ループ）
- `enumerate()` でインデックス付きループ
- `zip()` で並列イテレーション
- EAFP (Easier to Ask for Forgiveness than Permission) パターン
- ミュータブルデフォルト引数を避ける（`None` をデフォルトに）

```python
# Good: mutable default
def add_item(items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append("new")
    return items

# Bad: mutable default argument - shared across calls
def add_item(items: list[str] = []) -> list[str]:
    items.append("new")
    return items
```

## セキュリティ

### CRITICAL
- **SQLインジェクション**: パラメータ化クエリを必ず使用

```python
# Good: parameterized query
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

- **コマンドインジェクション**: `subprocess` に `shell=True` + ユーザー入力は禁止

```python
# Good: list form without shell
subprocess.run(["ls", "-la", safe_path], check=True)
```

- **安全でないデシリアライゼーション**: 信頼できないデータに対して安全でないシリアライゼーションライブラリを使わない。`yaml.safe_load()` を使用し、`yaml.load()` は避ける
- **動的コード実行の濫用**: ユーザー入力を動的に評価しない
- **ハードコードされたシークレット**: ソースコードにAPIキー・パスワードを含めない
- **パストラバーサル**: ユーザー入力のパスは `os.path.realpath()` + プレフィックスチェック

### HIGH
- **bare except**: `except:` や `except Exception:` で全例外をキャッチしない
- **弱い暗号化**: `hashlib.md5`, `hashlib.sha1` をパスワードに使わない（`bcrypt` or `argon2` を使用）
- **一時ファイル**: `tempfile` モジュールを使用（予測可能なファイル名を避ける）
- **ログ出力**: 機密情報（パスワード、トークン）をログに含めない

## テスト

- **pytest** を標準テストフレームワークとして使用
- テストファイルは `test_` プレフィックス or `_test.py` サフィックス
- **AAA パターン**: Arrange-Act-Assert で構造化
- **fixture** でテストデータとセットアップを管理
- **parametrize** でテーブル駆動テスト

```python
import pytest

class TestUserService:
    @pytest.fixture
    def service(self, mock_repo: MockUserRepository) -> UserService:
        return UserService(repository=mock_repo)

    @pytest.fixture
    def mock_repo(self) -> MockUserRepository:
        return MockUserRepository()

    @pytest.mark.parametrize(
        "user_id, expected_error",
        [
            ("", ValueError),
            ("invalid", UserNotFoundError),
        ],
    )
    def test_get_user_error_cases(
        self, service: UserService, user_id: str, expected_error: type
    ) -> None:
        with pytest.raises(expected_error):
            service.get_user(user_id)

    def test_get_user_success(
        self, service: UserService, mock_repo: MockUserRepository
    ) -> None:
        # Arrange
        expected = User(id="123", name="Alice")
        mock_repo.add(expected)

        # Act
        result = service.get_user("123")

        # Assert
        assert result == expected
```

### 診断コマンド
```bash
ruff check .
ruff format --check .
mypy .
pytest --cov -v
bandit -r src/
```

## レビューチェックリスト

### CRITICAL
- [ ] SQLインジェクション脆弱性がないか（パラメータ化クエリ使用）
- [ ] コマンドインジェクション脆弱性がないか（`shell=True` + ユーザー入力）
- [ ] ユーザー入力を動的に評価していないか
- [ ] 安全でないデシリアライゼーションがないか
- [ ] ハードコードされたシークレットがないか
- [ ] bare except で例外を握りつぶしていないか

### HIGH
- [ ] public 関数に型ヒントがあるか
- [ ] コンテキストマネージャ（`with`文）でリソース管理しているか
- [ ] ミュータブルデフォルト引数がないか
- [ ] `value == None` ではなく `value is None` を使っているか
- [ ] 例外にコンテキスト情報が含まれているか
- [ ] 50行を超える関数がないか

### MEDIUM
- [ ] PEP 8 準拠か（ruff/black でフォーマット済みか）
- [ ] インポート順序が正しいか（isort）
- [ ] pytest + AAA パターンでテストを書いているか
- [ ] `print()` ではなく `logging` を使っているか
- [ ] docstring が public API にあるか
