---
name: golang-patterns
description: Go コードの作成・レビュー時に使用。idiomatic Go パターン、セキュリティ、テスト規約、レビューチェックリストを含む。`.go` ファイルの編集・作成・レビュー時にトリガーする。
---

# Go パターン & ベストプラクティス

## コーディングスタイル

- **パッケージ命名**: 小文字、単数形、アンダースコア不可（`userservice` ではなく `user`）
- **変数命名**: camelCase、短く（`userCount` → `n`、ループ変数は1文字可）
- **インターフェース命名**: `-er` サフィックス（`Reader`, `Writer`, `Stringer`）
- **エラー命名**: `Err` プレフィックス（`ErrNotFound`, `ErrInvalidInput`）
- **レシーバ命名**: 型名の1-2文字省略形（`func (u *User) Name()`, `func (db *DB) Query()`）
- **早期リターン**: `if/else` より guard clause を優先
- **関数サイズ**: 50行以下を目安

```go
// Good: early return
func (s *Service) GetUser(id string) (*User, error) {
    if id == "" {
        return nil, ErrInvalidInput
    }
    user, err := s.repo.Find(id)
    if err != nil {
        return nil, fmt.Errorf("find user %s: %w", id, err)
    }
    return user, nil
}

// Bad: nested if/else
func (s *Service) GetUser(id string) (*User, error) {
    if id != "" {
        user, err := s.repo.Find(id)
        if err == nil {
            return user, nil
        } else {
            return nil, err
        }
    } else {
        return nil, ErrInvalidInput
    }
}
```

## パターン

### エラーハンドリング
- エラーは必ず `fmt.Errorf("context: %w", err)` でラップする
- `_` でエラーを捨てない
- `errors.Is(err, target)` を使う（`err == target` は使わない）
- カスタムエラー型は `Error()` メソッドを実装
- パニックは回復不可能な状態のみ（プログラムの初期化失敗など）

```go
// Good: error wrapping with context
if err := db.Save(user); err != nil {
    return fmt.Errorf("save user %s: %w", user.ID, err)
}

// Good: sentinel errors
var ErrNotFound = errors.New("not found")

// Good: custom error type
type ValidationError struct {
    Field   string
    Message string
}
func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error on %s: %s", e.Field, e.Message)
}
```

### 並行処理
- `context.Context` を第1引数に渡す
- goroutine にはキャンセル機構を持たせる（`context.WithCancel` or channel）
- `sync.WaitGroup` で goroutine の完了を待つ
- `defer mu.Unlock()` でミューテックスを解放
- チャネルのバッファサイズを適切に設定

```go
// Good: context-aware goroutine with proper cleanup
func (s *Service) ProcessItems(ctx context.Context, items []Item) error {
    g, ctx := errgroup.WithContext(ctx)
    for _, item := range items {
        item := item // capture loop variable
        g.Go(func() error {
            return s.processItem(ctx, item)
        })
    }
    return g.Wait()
}
```

### 構造体とインターフェース
- インターフェースは使う側で定義する（producer ではなく consumer 側）
- 小さなインターフェース（1-3メソッド）を優先
- 構造体埋め込みは「is-a」関係のみ（「has-a」はフィールドで）

```go
// Good: consumer-side interface
type UserFinder interface {
    Find(ctx context.Context, id string) (*User, error)
}

// Bad: large producer-side interface
type UserRepository interface {
    Find(id string) (*User, error)
    FindAll() ([]*User, error)
    Create(user *User) error
    Update(user *User) error
    Delete(id string) error
    Count() (int, error)
    // ... too many methods
}
```

### パフォーマンス
- ループ内の文字列結合は `strings.Builder` を使用
- スライスは `make([]T, 0, cap)` で事前確保
- 小さな構造体は値レシーバ、大きな構造体はポインタレシーバ
- `sync.Pool` で頻繁なアロケーションを削減

## セキュリティ

### CRITICAL
- **SQLインジェクション**: `database/sql` でプレースホルダーを必ず使用。文字列結合でクエリを組み立てない

```go
// Good
db.QueryRow("SELECT * FROM users WHERE id = $1", userID)

// Bad - SQL injection
db.QueryRow("SELECT * FROM users WHERE id = " + userID)
```

- **コマンドインジェクション**: `os/exec` にユーザー入力を直接渡さない

```go
// Good
cmd := exec.Command("ls", "-la", sanitizedPath)

// Bad - command injection
cmd := exec.Command("sh", "-c", "ls -la " + userInput)
```

- **パストラバーサル**: ユーザー入力のパスは `filepath.Clean` + プレフィックスチェック

```go
// Good
cleanPath := filepath.Clean(userPath)
if !strings.HasPrefix(cleanPath, allowedDir) {
    return ErrForbidden
}
```

- **Race条件**: 共有状態には必ず同期機構を使用
- **ハードコードされたシークレット**: API キー、パスワードをソースコードに含めない
- **安全でないTLS**: `InsecureSkipVerify: true` は使用禁止

### HIGH
- **unsafe パッケージ**: 正当な理由なしに使用しない
- **エラーの無視**: `_` でエラーを捨てない
- **goroutine リーク**: キャンセル機構のない goroutine を起動しない

## テスト

- **テーブル駆動テスト**を標準パターンとして使用
- テストファイルは `_test.go` サフィックス
- テスト関数は `Test` プレフィックス
- サブテストは `t.Run()` で構造化
- `-race` フラグでレースコンディション検出

```go
func TestGetUser(t *testing.T) {
    tests := []struct {
        name    string
        id      string
        want    *User
        wantErr error
    }{
        {
            name:    "valid user",
            id:      "123",
            want:    &User{ID: "123", Name: "Alice"},
            wantErr: nil,
        },
        {
            name:    "empty id",
            id:      "",
            want:    nil,
            wantErr: ErrInvalidInput,
        },
        {
            name:    "not found",
            id:      "999",
            want:    nil,
            wantErr: ErrNotFound,
        },
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := svc.GetUser(tt.id)
            if !errors.Is(err, tt.wantErr) {
                t.Errorf("GetUser() error = %v, wantErr %v", err, tt.wantErr)
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("GetUser() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

### 診断コマンド
```bash
go build ./...
go vet ./...
go test -race ./...
staticcheck ./...
golangci-lint run
govulncheck ./...
```

## レビューチェックリスト

### CRITICAL
- [ ] ハードコードされたシークレットがないか
- [ ] SQLインジェクション脆弱性がないか
- [ ] コマンドインジェクション脆弱性がないか
- [ ] パストラバーサル脆弱性がないか
- [ ] Race条件がないか（共有状態に同期機構があるか）
- [ ] `unsafe` パッケージの不正使用がないか
- [ ] `InsecureSkipVerify: true` がないか

### HIGH
- [ ] エラーが `_` で無視されていないか
- [ ] エラーにコンテキストが `%w` でラップされているか
- [ ] goroutine にキャンセル機構があるか
- [ ] `context.Context` が第1引数か
- [ ] 50行を超える関数がないか
- [ ] 4段階を超えるネストがないか

### MEDIUM
- [ ] ループ内の文字列結合に `strings.Builder` を使っているか
- [ ] スライスの事前確保（`make([]T, 0, cap)`）があるか
- [ ] テーブル駆動テストパターンを使っているか
- [ ] パッケージ命名規則に従っているか
- [ ] エラーメッセージが小文字で句読点なしか
