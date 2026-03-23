---
name: swift-patterns
description: Swift/iOS コードの作成・レビュー時に使用。Swift パターン、セキュリティ、テスト規約、レビューチェックリストを含む。`.swift` ファイルの編集・作成・レビュー時にトリガーする。
---

# Swift パターン & ベストプラクティス

## コーディングスタイル

- **命名**: camelCase（変数・関数）、PascalCase（型・プロトコル）
- **アクセス制御**: デフォルトは `private`、必要に応じて公開範囲を広げる
- **guard 文**: 早期リターンに `guard` を使用（`if` のネストを避ける）
- **Optional**: 強制アンラップ（`!`）は原則禁止。`guard let`, `if let`, `??` を使用
- **関数サイズ**: 50行以下を目安

```swift
// Good: guard for early return
func processUser(_ user: User?) throws -> Result {
    guard let user = user else {
        throw AppError.invalidInput("user is nil")
    }
    guard user.isActive else {
        throw AppError.inactiveUser(user.id)
    }
    return try performProcessing(user)
}

// Bad: nested optionals
func processUser(_ user: User?) throws -> Result {
    if let user = user {
        if user.isActive {
            return try performProcessing(user)
        } else {
            throw AppError.inactiveUser(user.id)
        }
    } else {
        throw AppError.invalidInput("user is nil")
    }
}
```

## パターン

### Protocol-Oriented Programming
- クラス継承より Protocol + Extension を優先
- Protocol にデフォルト実装を提供して共通ロジックを共有
- 関連型（`associatedtype`）で型安全なジェネリクスを実現

```swift
protocol Repository {
    associatedtype Entity
    func find(by id: String) async throws -> Entity?
    func save(_ entity: Entity) async throws
}

extension Repository {
    func findOrThrow(by id: String) async throws -> Entity {
        guard let entity = try await find(by: id) else {
            throw AppError.notFound(id)
        }
        return entity
    }
}
```

### 値型 vs 参照型
- データモデルには `struct`（値型）を優先
- 共有状態やアイデンティティが必要な場合のみ `class`（参照型）
- `enum` で有限の状態を表現（Associated Values 活用）

```swift
// Good: enum with associated values for state
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case failed(Error)
}

// Good: struct for data model
struct User: Codable, Equatable {
    let id: String
    var name: String
    var email: String
}
```

### Structured Concurrency
- `async/await` を使用（コールバック地獄を避ける）
- `TaskGroup` で並行タスクを管理
- `Actor` で共有状態の安全なアクセス
- `@Sendable` でクロージャのスレッド安全性を保証

```swift
// Good: structured concurrency
func fetchAllData() async throws -> DashboardData {
    async let users = userService.fetchUsers()
    async let orders = orderService.fetchOrders()
    async let stats = analyticsService.fetchStats()
    return DashboardData(
        users: try await users,
        orders: try await orders,
        stats: try await stats
    )
}

// Good: actor for shared state
actor CacheManager {
    private var cache: [String: Data] = [:]

    func get(_ key: String) -> Data? {
        cache[key]
    }

    func set(_ key: String, value: Data) {
        cache[key] = value
    }
}
```

### エラーハンドリング
- `Error` プロトコルに準拠したカスタムエラー型を定義
- `do/catch` でエラーを適切にハンドリング
- `Result` 型でエラーを値として扱う

```swift
enum AppError: LocalizedError {
    case notFound(String)
    case invalidInput(String)
    case networkError(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notFound(let id): return "Resource not found: \(id)"
        case .invalidInput(let msg): return "Invalid input: \(msg)"
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        }
    }
}
```

## セキュリティ

### CRITICAL
- **Keychain**: パスワード・トークン・APIキーは Keychain に保存（UserDefaults 禁止）

```swift
// Good: Keychain
try KeychainManager.save(token, forKey: "authToken")

// Bad: UserDefaults for secrets
UserDefaults.standard.set(token, forKey: "authToken")
```

- **ATS (App Transport Security)**: `NSAllowsArbitraryLoads` は原則 `false`。例外は個別ドメインで設定
- **入力バリデーション**: ユーザー入力は必ずバリデーション。WebView の URL スキーム検証必須
- **ハードコードされたシークレット**: ソースコードにAPIキー・パスワードを含めない

### HIGH
- **Jailbreak検出**: セキュリティ重要なアプリでは Jailbreak チェックを実装
- **証明書ピンニング**: 重要なAPI通信では SSL Pinning を検討
- **バイオメトリクス**: `LAContext` の適切な使用（フォールバック認証の提供）
- **データ保護**: `FileProtectionType.complete` で機密ファイルを保護
- **ログ出力**: 本番ビルドで機密情報をログに出力しない

```swift
// Good: data protection
try data.write(to: url, options: .completeFileProtection)

// Good: conditional logging
#if DEBUG
print("Debug: user token = \(token)")
#endif
```

### MEDIUM
- **Codable**: `CodingKeys` でプロパティ名の明示的マッピング
- **URL スキーム**: `canOpenURL` で事前検証

## テスト

- **XCTest** フレームワークを使用
- テストメソッドは `test` プレフィックス + 説明的な名前
- `XCTAssertEqual`, `XCTAssertThrowsError` 等を適切に使用
- `async` テストは `async throws` で宣言
- Mock は Protocol ベースで作成

```swift
final class UserServiceTests: XCTestCase {
    private var sut: UserService!
    private var mockRepo: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockUserRepository()
        sut = UserService(repository: mockRepo)
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    func testGetUser_withValidID_returnsUser() async throws {
        // Arrange
        let expected = User(id: "123", name: "Alice")
        mockRepo.stubbedUser = expected

        // Act
        let result = try await sut.getUser(id: "123")

        // Assert
        XCTAssertEqual(result, expected)
        XCTAssertEqual(mockRepo.findCallCount, 1)
    }

    func testGetUser_withEmptyID_throwsError() async {
        do {
            _ = try await sut.getUser(id: "")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? AppError, .invalidInput("id is empty"))
        }
    }
}
```

### 診断コマンド
```bash
swift build
swift test
swiftlint lint
swift-format lint -r .
```

## レビューチェックリスト

### CRITICAL
- [ ] 強制アンラップ（`!`）が正当な理由なく使われていないか
- [ ] Keychain を使わずに機密情報を保存していないか
- [ ] ハードコードされたシークレットがないか
- [ ] ATS の例外設定が最小限か
- [ ] ユーザー入力のバリデーションがあるか

### HIGH
- [ ] `guard` による早期リターンパターンを使っているか
- [ ] `async/await` を使っているか（コールバック地獄を避けているか）
- [ ] Protocol-Oriented で設計されているか
- [ ] アクセス制御が適切か（デフォルト `private`）
- [ ] エラーハンドリングが適切か（カスタムエラー型使用）
- [ ] 本番ビルドで機密情報のログ出力がないか

### MEDIUM
- [ ] 値型（`struct`）を優先しているか
- [ ] `enum` で有限状態を表現しているか
- [ ] テストが Protocol ベースの Mock を使っているか
- [ ] `@Sendable` で適切にスレッド安全性を保証しているか
