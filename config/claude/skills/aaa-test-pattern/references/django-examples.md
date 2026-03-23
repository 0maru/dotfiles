# Django テストコード例

## FactoryBoy 定義

```python
import factory
from django.contrib.auth import get_user_model
from apps.orders.models import Order

User = get_user_model()


class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = User

    email = factory.Sequence(lambda n: f"user{n}@example.com")
    username = factory.Sequence(lambda n: f"user{n}")
    is_active = True

    class Params:
        inactive = factory.Trait(is_active=False)

    @classmethod
    def build_dict(cls, **kwargs):
        """API テスト用のリクエストデータを生成"""
        obj = cls.build(**kwargs)
        return {
            "email": obj.email,
            "username": obj.username,
        }


class OrderFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Order

    user = factory.SubFactory(UserFactory)
    total_amount = factory.Faker("random_int", min=100, max=10000)
    status = "pending"

    class Params:
        completed = factory.Trait(status="completed")
```

---

## Model テスト

### Good

```python
from django.test import TestCase
from apps.orders.models import Order
from tests.factories import OrderFactory, UserFactory


class TestOrderCompletion(TestCase):
    def test_complete_order_with_pending_status_sets_completed_at(self):
        # Arrange
        order = OrderFactory(status="pending")

        # Act
        order.complete()

        # Assert
        order.refresh_from_db()
        self.assertEqual(order.status, "completed")
        self.assertIsNotNone(order.completed_at)

    def test_complete_order_with_already_completed_status_raises_error(self):
        # Arrange
        order = OrderFactory(completed=True)

        # Act & Assert
        with self.assertRaises(ValueError):
            order.complete()

    def test_calculate_total_with_multiple_items_returns_sum(self):
        # Arrange
        order = OrderFactory()
        OrderItemFactory(order=order, price=1000, quantity=2)
        OrderItemFactory(order=order, price=500, quantity=1)

        # Act
        total = order.calculate_total()

        # Assert
        self.assertEqual(total, 2500)
```

### Bad

```python
# BAD: 複数の Act、曖昧な命名、FactoryBoy 未使用
class TestOrder(TestCase):
    def setUp(self):
        # BAD: setUp で全テストデータを作りすぎ
        self.user = User.objects.create(email="test@example.com", username="test")
        self.order = Order.objects.create(user=self.user, total_amount=1000, status="pending")

    def test_order(self):
        # BAD: 複数の振る舞いを1メソッドでテスト
        self.order.complete()
        self.assertEqual(self.order.status, "completed")

        self.order.cancel()  # BAD: 2つ目の Act
        self.assertEqual(self.order.status, "cancelled")

    def test_success(self):
        # BAD: メソッド名が曖昧
        self.assertIsNotNone(self.order)  # BAD: 浅いアサーション
```

---

## API (View) テスト

### Good

```python
from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from tests.factories import UserFactory


class TestUserRegistration(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_register_user_with_valid_data_creates_active_user(self):
        # Arrange
        user_data = UserFactory.build_dict(email="new@example.com")

        # Act
        response = self.client.post("/api/users/", user_data)

        # Assert
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["email"], "new@example.com")
        self.assertTrue(
            User.objects.filter(email="new@example.com", is_active=True).exists()
        )

    def test_register_user_with_duplicate_email_returns_400(self):
        # Arrange
        UserFactory(email="existing@example.com")
        user_data = UserFactory.build_dict(email="existing@example.com")

        # Act
        response = self.client.post("/api/users/", user_data)

        # Assert
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("email", response.data)


class TestUserDetail(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_get_user_with_valid_id_returns_user_data(self):
        # Arrange
        user = UserFactory(email="test@example.com")
        self.client.force_authenticate(user=user)

        # Act
        response = self.client.get(f"/api/users/{user.id}/")

        # Assert
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["email"], "test@example.com")

    def test_get_user_without_auth_returns_401(self):
        # Arrange
        user = UserFactory()

        # Act
        response = self.client.get(f"/api/users/{user.id}/")

        # Assert
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
```

### Bad

```python
# BAD: 過剰な mock、アサーション不足
from unittest.mock import patch, MagicMock


class TestUserAPI(TestCase):
    @patch("apps.users.views.User.objects")  # BAD: DB を mock する必要はない
    def test_create(self, mock_objects):
        mock_objects.create.return_value = MagicMock(id=1)
        response = self.client.post("/api/users/", {"email": "test@example.com"})
        self.assertEqual(response.status_code, 201)  # BAD: レスポンスボディを検証していない
        # BAD: DB にデータが作られたかも検証していない
```

---

## Serializer テスト

### Good

```python
from django.test import TestCase
from apps.users.serializers import UserSerializer
from tests.factories import UserFactory


class TestUserSerializer(TestCase):
    def test_serialize_user_returns_expected_fields(self):
        # Arrange
        user = UserFactory(email="test@example.com", username="testuser")

        # Act
        data = UserSerializer(user).data

        # Assert
        self.assertEqual(data["email"], "test@example.com")
        self.assertEqual(data["username"], "testuser")
        self.assertNotIn("password", data)

    def test_deserialize_with_valid_data_passes_validation(self):
        # Arrange
        input_data = {"email": "new@example.com", "username": "newuser", "password": "securepass123"}

        # Act
        serializer = UserSerializer(data=input_data)

        # Assert
        self.assertTrue(serializer.is_valid())

    def test_deserialize_with_invalid_email_fails_validation(self):
        # Arrange
        input_data = {"email": "not-an-email", "username": "newuser", "password": "securepass123"}

        # Act
        serializer = UserSerializer(data=input_data)

        # Assert
        self.assertFalse(serializer.is_valid())
        self.assertIn("email", serializer.errors)

    def test_deserialize_with_short_password_fails_validation(self):
        # Arrange
        input_data = {"email": "new@example.com", "username": "newuser", "password": "123"}

        # Act
        serializer = UserSerializer(data=input_data)

        # Assert
        self.assertFalse(serializer.is_valid())
        self.assertIn("password", serializer.errors)
```

### Bad

```python
# BAD: 正常系と異常系を1メソッドに混在
class TestSerializer(TestCase):
    def test_user_serializer(self):
        # BAD: 正常系
        data = {"email": "test@example.com", "username": "test", "password": "pass123"}
        serializer = UserSerializer(data=data)
        self.assertTrue(serializer.is_valid())

        # BAD: 同じメソッド内で異常系もテスト（2つ目の Act）
        data["email"] = "invalid"
        serializer = UserSerializer(data=data)
        self.assertFalse(serializer.is_valid())
```
