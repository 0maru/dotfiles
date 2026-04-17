---
name: typescript-patterns
description: TypeScript コードの作成・レビュー時に使用。TypeScript パターン、セキュリティ、テスト規約、レビューチェックリストを含む。`.ts`, `.tsx` ファイルの編集・作成・レビュー時にトリガーする。
---

# TypeScript パターン & ベストプラクティス

## コーディングスタイル

- **strict mode**: `tsconfig.json` で `"strict": true` を必須に
- **命名**: camelCase（変数・関数）、PascalCase（型・インターフェース・クラス）、UPPER_SNAKE_CASE（定数）
- **型アノテーション**: 推論可能な場合は省略可。関数の引数と戻り値には明示
- **`any` 禁止**: `unknown` + 型ガード or ジェネリクスで代替
- **不変性**: `const`, `readonly`, `as const` を優先
- **関数サイズ**: 50行以下を目安
- **ファイルサイズ**: 800行以下を目安

```typescript
// Good: strict types, readonly
interface User {
  readonly id: string;
  readonly name: string;
  readonly email: string;
  readonly roles: readonly string[];
}
```

## パターン

### Discriminated Unions
- 型安全な状態管理に Discriminated Union を使用
- `switch` の `exhaustive check` で全ケースをカバー

```typescript
type LoadingState<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: Error };

function renderState<T>(state: LoadingState<T>): string {
  switch (state.status) {
    case "idle":
      return "Ready";
    case "loading":
      return "Loading...";
    case "success":
      return `Data: ${state.data}`;
    case "error":
      return `Error: ${state.error.message}`;
    default: {
      const _exhaustive: never = state;
      return _exhaustive;
    }
  }
}
```

### 型ガード
- ユーザー定義型ガードで `unknown` を安全にナローイング
- `zod` 等のバリデーションライブラリで外部入力を検証

```typescript
// Good: type guard
function isUser(value: unknown): value is User {
  return (
    typeof value === "object" &&
    value !== null &&
    "id" in value &&
    "name" in value
  );
}

// Good: zod validation at system boundary
const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1).max(100),
  email: z.string().email(),
});
type User = z.infer<typeof UserSchema>;
```

### ジェネリクス
- 再利用可能な型安全パターンにジェネリクスを活用
- 制約（`extends`）で型パラメータを制限

```typescript
// Good: generic repository
interface Repository<T extends { id: string }> {
  findById(id: string): Promise<T | null>;
  save(entity: T): Promise<T>;
  delete(id: string): Promise<void>;
}

// Good: generic result type
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

### エラーハンドリング
- `try/catch` でエラーをハンドリング（`catch (e: unknown)` で型安全に）
- `Result` 型パターンで例外を避ける選択肢
- `console.log` は本番コードでは使わない（適切なロガーを使用）

```typescript
// Good: typed error handling
try {
  const user = await fetchUser(id);
} catch (error: unknown) {
  if (error instanceof NotFoundError) {
    return null;
  }
  throw error;
}
```

### React パターン（`.tsx` の場合）
- 関数コンポーネント + hooks を使用（class コンポーネントは非推奨）
- props は `interface` で型定義
- `children` は `React.ReactNode` 型
- カスタムフックで状態ロジックを分離
- `useCallback` / `useMemo` は実際のパフォーマンス問題がある場合のみ

```typescript
interface UserCardProps {
  user: User;
  onEdit: (id: string) => void;
}

function UserCard({ user, onEdit }: UserCardProps) {
  return (
    <div>
      <h2>{user.name}</h2>
      <button onClick={() => onEdit(user.id)}>Edit</button>
    </div>
  );
}
```

## セキュリティ

### CRITICAL
- **XSS**: ユーザー入力を安全でないHTML挿入APIに渡さない。サニタイズには `DOMPurify` を使用。React の unsafe HTML props を使う場合は必ずサニタイズ済みデータのみ
- **SQLインジェクション**: ORM のパラメータ化クエリを使用。文字列結合でクエリを組み立てない
- **CSRF**: 状態変更リクエストに CSRF トークンを含める
- **ハードコードされたシークレット**: ソースコードにAPIキー・パスワードを含めない
- **動的コード実行禁止**: ユーザー入力から動的にコードを生成・実行しない

### HIGH
- **入力バリデーション**: `zod` 等でシステム境界（API入力、フォーム）でバリデーション
- **CORS**: `Access-Control-Allow-Origin: *` は本番環境で使わない
- **依存関係**: `npm audit` で脆弱性チェック
- **環境変数**: フロントエンドで `NEXT_PUBLIC_` 以外の環境変数を参照しない
- **認証**: 全エンドポイントで認証チェック。ミドルウェアで一元管理

### MEDIUM
- **セキュアCookie**: `httpOnly`, `secure`, `sameSite` フラグを設定
- **レート制限**: 全エンドポイントにレート制限を設定
- **CSP ヘッダー**: Content Security Policy を設定

## テスト

- **Vitest** or **Jest** を使用
- テストファイルは `*.test.ts` / `*.spec.ts`
- **describe/it** で構造化
- **AAA パターン**: Arrange-Act-Assert
- React コンポーネントは `@testing-library/react` でテスト

```typescript
describe("UserService", () => {
  let service: UserService;
  let mockRepo: MockUserRepository;

  beforeEach(() => {
    mockRepo = new MockUserRepository();
    service = new UserService(mockRepo);
  });

  describe("getUser", () => {
    it("should return user for valid id", async () => {
      // Arrange
      const expected: User = { id: "123", name: "Alice", email: "a@b.com", roles: [] };
      mockRepo.add(expected);

      // Act
      const result = await service.getUser("123");

      // Assert
      expect(result).toEqual(expected);
    });

    it.each([
      { id: "", error: "id must not be empty" },
      { id: "999", error: "user not found" },
    ])("should throw for $id", async ({ id, error }) => {
      await expect(service.getUser(id)).rejects.toThrow(error);
    });
  });
});
```

### 診断コマンド
```bash
npx tsc --noEmit
npx eslint .
npx vitest run --coverage
npm audit
```

## レビューチェックリスト

### CRITICAL
- [ ] `any` 型が使われていないか（`unknown` + 型ガードで代替）
- [ ] XSS 脆弱性がないか（安全でないHTML挿入）
- [ ] SQLインジェクション脆弱性がないか
- [ ] 動的コード実行がないか
- [ ] ハードコードされたシークレットがないか
- [ ] CSRF 対策があるか

### HIGH
- [ ] `strict: true` が tsconfig で有効か
- [ ] システム境界で入力バリデーション（`zod` 等）があるか
- [ ] エラーハンドリングが `catch (e: unknown)` で型安全か
- [ ] `console.log` が本番コードに残っていないか
- [ ] 認証チェックが全エンドポイントにあるか
- [ ] 50行を超える関数がないか
- [ ] 800行を超えるファイルがないか

### MEDIUM
- [ ] `readonly` / `as const` で不変性を保っているか
- [ ] Discriminated Union で状態を型安全に管理しているか
- [ ] React で関数コンポーネント + hooks を使っているか
- [ ] テストが AAA パターンで書かれているか
- [ ] 依存関係の脆弱性がないか（`npm audit`）
