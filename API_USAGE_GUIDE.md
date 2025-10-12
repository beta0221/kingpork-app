# API Utility 使用指南

本文件說明如何使用專案中的 API 呼叫工具。

---

## 📁 架構概覽

```
lib/
├── services/
│   ├── api/                      # 核心 API 基礎設施
│   │   ├── api_client.dart       # HTTP 客戶端 (處理所有 HTTP 請求)
│   │   ├── api_endpoints.dart    # API 端點定義 (所有 URL 集中管理)
│   │   └── api_exception.dart    # 異常處理 (統一錯誤格式)
│   │
│   ├── auth_service.dart         # 認證服務 (登入、註冊、登出)
│   ├── landing_service.dart      # 首頁服務 (分類、輪播圖)
│   ├── shop_service.dart         # 商品服務 (取得商品列表)
│   ├── cart_service.dart         # 購物車服務 (加入、移除、查詢)
│   ├── order_service.dart        # 訂單服務 (結帳、訂單查詢、付款)
│   └── contact_service.dart      # 聯絡服務 (聯絡表單)
│
├── models/                       # 資料模型
│   ├── auth_models.dart          # User, LoginResponse, RegisterRequest...
│   ├── address_model.dart        # Address
│   ├── banner_model.dart         # BannerModel
│   ├── api_category_model.dart   # ApiCategory, ApiProduct
│   ├── cart_models.dart          # CartItem, CartResponse
│   ├── order_models.dart         # Order, OrderDetail, CheckoutRequest
│   └── contact_model.dart        # ContactRequest, ContactResponse
│
└── utils/                        # 工具類別
    ├── token_manager.dart        # Token 管理 (儲存、讀取、清除)
    └── network_utils.dart        # 網路狀態檢查
```

---

## 🔧 核心組件說明

### 1. ApiClient (HTTP 客戶端)

**位置**: `lib/services/api/api_client.dart`

**功能**:
- 處理所有 HTTP 請求 (GET, POST, PUT, DELETE)
- 自動添加 Authorization Header
- 統一錯誤處理
- 請求超時控制 (預設 30 秒)

**使用方式**:
```dart
final apiClient = ApiClient();

// GET 請求
final response = await apiClient.get('/landing/categories');

// POST 請求
final response = await apiClient.post(
  '/auth/login',
  body: {'email': 'user@example.com', 'password': '123456'},
);

// 需要認證的請求
final response = await apiClient.get(
  '/auth/user',
  requiresAuth: true,  // 自動添加 Bearer Token
);
```

---

### 2. ApiEndpoints (端點管理)

**位置**: `lib/services/api/api_endpoints.dart`

**功能**:
- 集中管理所有 API URL
- 支援環境切換 (開發/正式)
- 避免 URL 字串散落各處

**配置**:
```dart
// 修改 Base URL
static const String baseUrl = 'https://stageapi.kingpork.com.tw';
```

**使用範例**:
```dart
// 靜態端點
ApiEndpoints.login           // '/auth/login'
ApiEndpoints.categories      // '/landing/categories'

// 動態端點
ApiEndpoints.shopCategory('pork')     // '/shop/pork'
ApiEndpoints.billDetail(100)          // '/bill/detail/100'

// 完整 URL
ApiEndpoints.buildUrl('/auth/login')
// 'https://stageapi.kingpork.com.tw/api/next/auth/login'
```

---

### 3. ApiException (異常處理)

**位置**: `lib/services/api/api_exception.dart`

**異常類型**:
- `ApiException` - 通用 API 錯誤
- `UnauthorizedException` (401) - 未授權，需要登入
- `ForbiddenException` (403) - 無權限
- `NotFoundException` (404) - 資源不存在
- `ValidationException` (422) - 驗證錯誤
- `ServerException` (500) - 伺服器錯誤
- `NetworkException` - 無網路連線
- `TimeoutException` - 請求超時

**使用範例**:
```dart
try {
  final response = await authService.login(email, password);
  print('登入成功');
} on ValidationException catch (e) {
  // 422 驗證錯誤
  print('欄位錯誤: ${e.getAllErrors()}');
  print('Email 錯誤: ${e.getFieldError('email')}');
} on UnauthorizedException catch (e) {
  // 401 未授權
  print('登入失敗: $e');
  Navigator.pushReplacementNamed(context, '/login');
} on NetworkException catch (e) {
  // 無網路連線
  print('請檢查網路: $e');
} on ApiException catch (e) {
  // 其他錯誤
  print('錯誤 ${e.statusCode}: $e');
}
```

---

### 4. TokenManager (Token 管理)

**位置**: `lib/utils/token_manager.dart`

**功能**:
- 使用 SharedPreferences 儲存 Token
- Token 自動注入到請求 Header
- 401 錯誤時自動清除 Token

**使用範例**:
```dart
final tokenManager = TokenManager();

// 儲存 Token (登入後)
await tokenManager.saveTokenData(
  accessToken: 'eyJ0eXAiOiJKV1QiLCJhbGc...',
  tokenType: 'Bearer',
  expiresIn: 3600,
);

// 檢查是否已登入
if (await tokenManager.isLoggedIn()) {
  print('使用者已登入');
}

// 登出時清除 Token
await tokenManager.clearTokens();
```

---

## 🌐 服務層使用指南

### AuthService (認證服務)

**位置**: `lib/services/auth_service.dart`

#### 1. 登入

```dart
final authService = AuthService();

try {
  final response = await authService.login(
    'user@example.com',
    'password123',
  );

  print('歡迎 ${response.user.name}');
  print('Token: ${response.accessToken}');

  // Token 已自動儲存，無需手動處理

} on ValidationException catch (e) {
  print('驗證錯誤: ${e.getAllErrors()}');
} on UnauthorizedException catch (e) {
  print('帳號或密碼錯誤');
}
```

#### 2. 註冊

```dart
try {
  final response = await authService.register(
    name: '王小明',
    email: 'user@example.com',
    password: 'password123',
    passwordConfirmation: 'password123',
  );

  print('註冊成功，歡迎 ${response.user.name}');

} on ValidationException catch (e) {
  // 顯示驗證錯誤
  if (e.errors != null) {
    e.errors!.forEach((field, messages) {
      print('$field: ${messages.join(', ')}');
    });
  }
}
```

#### 3. 取得用戶資訊 (需要登入)

```dart
try {
  final user = await authService.getUser();
  print('名稱: ${user.name}');
  print('Email: ${user.email}');
  print('紅利點數: ${user.bonus}');
} on UnauthorizedException {
  // 未登入或 Token 過期
  Navigator.pushReplacementNamed(context, '/login');
}
```

#### 4. 登出

```dart
await authService.logout();
// Token 已自動清除
Navigator.pushReplacementNamed(context, '/login');
```

#### 5. 取得地址列表

```dart
final addresses = await authService.getAddresses();

for (var address in addresses) {
  print('${address.name}: ${address.fullAddress}');
  if (address.isDefault) {
    print('(預設地址)');
  }
}
```

---

### LandingService (首頁服務)

**位置**: `lib/services/landing_service.dart`

#### 1. 取得分類

```dart
final landingService = LandingService();

final categories = await landingService.getCategories();

for (var category in categories) {
  print('${category.name} (${category.slug})');
  print('圖片: ${category.image}');
}
```

#### 2. 取得輪播圖

```dart
final banners = await landingService.getBanners();

for (var banner in banners) {
  print('${banner.title}');
  print('圖片: ${banner.image}');
  print('連結: ${banner.link}');
}
```

---

### ShopService (商品服務)

**位置**: `lib/services/shop_service.dart`

#### 1. 取得分類路徑

```dart
final shopService = ShopService();

final paths = await shopService.getCategoryPaths();

for (var category in paths) {
  if (category.parentId == null) {
    print('主分類: ${category.name}');
  } else {
    print('  子分類: ${category.name}');
  }
}
```

#### 2. 取得分類商品

```dart
final result = await shopService.getProductsByCategory('pork');

print('分類: ${result.category.name}');
print('說明: ${result.category.description}');
print('商品數量: ${result.products.length}');

for (var product in result.products) {
  print('${product.name}');
  print('  價格: \$${product.price}');

  if (product.isOnSale) {
    print('  特價: \$${product.salePrice}');
    print('  折扣: ${product.discountPercent}%');
  }

  print('  庫存: ${product.stock} ${product.unit}');
}
```

---

### CartService (購物車服務)

**位置**: `lib/services/cart_service.dart`

#### 1. 取得購物車

```dart
final cartService = CartService();

final cart = await cartService.getCartItems();

print('購物車總計: \$${cart.total}');
print('商品數量: ${cart.itemCount}');
print('總件數: ${cart.totalQuantity}');

for (var item in cart.items) {
  print('${item.productName}');
  print('  單價: \$${item.price}');
  print('  數量: ${item.quantity}');
  print('  小計: \$${item.subtotal}');
}
```

#### 2. 加入購物車

```dart
try {
  final result = await cartService.addToCart(
    productId: 10,
    quantity: 2,
  );

  print(result.message);  // "已加入購物車"

  // 重新載入購物車
  final cart = await cartService.getCartItems();

} on ApiException catch (e) {
  print('加入失敗: $e');
}
```

#### 3. 移除購物車項目

```dart
await cartService.removeFromCart(cartItemId);
print('已從購物車移除');
```

---

### OrderService (訂單服務)

**位置**: `lib/services/order_service.dart`

#### 1. 結帳 (需要登入)

```dart
final orderService = OrderService();

try {
  final result = await orderService.checkout(
    recipient: '王小明',
    phone: '0912345678',
    city: '台北市',
    district: '中正區',
    address: '重慶南路一段122號',
    paymentMethod: 'credit_card',
    useBonus: 50,              // 使用 50 點紅利
    note: '請在下午送達',       // 備註 (選填)
  );

  print('訂單編號: ${result.billId}');
  print('原價: \$${result.total}');
  print('使用紅利: ${result.bonusUsed} 點');
  print('實付金額: \$${result.finalTotal}');
  print('付款網址: ${result.paymentUrl}');

  // 導向付款頁面
  launchUrl(Uri.parse(result.paymentUrl));

} on UnauthorizedException {
  Navigator.pushNamed(context, '/login');
} on ValidationException catch (e) {
  print('欄位錯誤: ${e.getAllErrors()}');
}
```

#### 2. 取得訂單列表 (需要登入)

```dart
final orders = await orderService.getOrderList();

for (var order in orders) {
  print('訂單編號: ${order.billNo}');
  print('狀態: ${order.statusText}');
  print('金額: \$${order.total}');
  print('商品數: ${order.itemsCount}');
  print('建立時間: ${order.createdAt}');
  print('---');
}
```

#### 3. 取得訂單詳情 (需要登入)

```dart
final detail = await orderService.getOrderDetail(100);

print('訂單編號: ${detail.billNo}');
print('狀態: ${detail.status}');
print('收件人: ${detail.recipient}');
print('電話: ${detail.phone}');
print('地址: ${detail.address}');
print('總金額: \$${detail.total}');

print('訂單項目:');
for (var item in detail.items) {
  print('  ${item.productName}');
  print('    數量: ${item.quantity}');
  print('    單價: \$${item.price}');
  print('    小計: \$${item.subtotal}');
}
```

#### 4. 取得付款 Token (需要登入)

```dart
final tokenResponse = await orderService.getPaymentToken(100);

print('Token: ${tokenResponse.token}');
print('付款網址: ${tokenResponse.paymentUrl}');
```

#### 5. 執行付款 (需要登入)

```dart
final paymentResult = await orderService.pay(
  billId: 100,
  paymentMethod: 'credit_card',
);

if (paymentResult.success) {
  print('付款成功');
  launchUrl(Uri.parse(paymentResult.paymentUrl));
}
```

---

### ContactService (聯絡服務)

**位置**: `lib/services/contact_service.dart`

#### 發送聯絡表單

```dart
final contactService = ContactService();

try {
  final result = await contactService.sendContactForm(
    name: '王小明',
    email: 'contact@example.com',
    phone: '0912345678',
    message: '我想詢問商品資訊',
  );

  print(result.message);  // "已收到您的訊息，我們會盡快回覆"

} on ValidationException catch (e) {
  print('欄位錯誤: ${e.getAllErrors()}');
}
```

---

## 🎯 完整使用範例

### 範例 1: 登入流程

```dart
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/api/api_exception.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      // 登入成功，導向首頁
      Navigator.pushReplacementNamed(context, '/home');

    } on ValidationException catch (e) {
      setState(() {
        _errorMessage = e.getAllErrors().join('\n');
      });
    } on UnauthorizedException {
      setState(() {
        _errorMessage = '帳號或密碼錯誤';
      });
    } on NetworkException {
      setState(() {
        _errorMessage = '無網路連線，請檢查網路設定';
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('登入'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 範例 2: 商品列表頁面

```dart
import 'package:shop/services/shop_service.dart';
import 'package:shop/models/api_category_model.dart';

class ProductListScreen extends StatefulWidget {
  final String categorySlug;

  ProductListScreen({required this.categorySlug});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _shopService = ShopService();
  CategoryWithProducts? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final result = await _shopService.getProductsByCategory(
        widget.categorySlug,
      );

      setState(() {
        _data = result;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _shopService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('錯誤: $_error'));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_data!.category.name)),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
        ),
        itemCount: _data!.products.length,
        itemBuilder: (context, index) {
          final product = _data!.products[index];
          return Card(
            child: Column(
              children: [
                Image.network(product.image),
                Text(product.name),
                if (product.isOnSale)
                  Text(
                    '\$${product.salePrice}',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text('\$${product.price}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

### 範例 3: 加入購物車

```dart
import 'package:shop/services/cart_service.dart';

Future<void> addProductToCart(int productId) async {
  final cartService = CartService();

  try {
    final result = await cartService.addToCart(
      productId: productId,
      quantity: 1,
    );

    // 顯示成功訊息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    // 更新購物車數量 Badge
    // ...

  } on ApiException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('加入失敗: $e')),
    );
  } finally {
    cartService.dispose();
  }
}
```

---

## ⚙️ 環境配置

### 修改 API Base URL

編輯 `lib/services/api/api_endpoints.dart`:

```dart
class ApiEndpoints {
  // 開發環境
  static const String baseUrl = 'https://stageapi.kingpork.com.tw';

  // 正式環境
  // static const String baseUrl = 'https://api.kingpork.com.tw';

  static const String apiPrefix = '/api/next';
  // ...
}
```

---

## 🔍 常見錯誤處理

### 1. 401 Unauthorized (未授權)

```dart
try {
  final user = await authService.getUser();
} on UnauthorizedException {
  // Token 過期或無效，導向登入頁
  Navigator.pushReplacementNamed(context, '/login');
}
```

### 2. 422 Validation Error (驗證錯誤)

```dart
try {
  await authService.register(...);
} on ValidationException catch (e) {
  // 取得所有錯誤訊息
  print(e.getAllErrors());

  // 取得特定欄位錯誤
  final emailError = e.getFieldError('email');
  if (emailError != null) {
    print('Email 錯誤: $emailError');
  }

  // 遍歷所有欄位錯誤
  e.errors?.forEach((field, messages) {
    print('$field: ${messages.join(', ')}');
  });
}
```

### 3. Network Error (網路錯誤)

```dart
try {
  await shopService.getProducts();
} on NetworkException {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('無網路連線'),
      content: Text('請檢查您的網路設定'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('確定'),
        ),
      ],
    ),
  );
}
```

---

## 💡 最佳實踐

### 1. 使用 try-catch-finally

```dart
bool _isLoading = false;

Future<void> loadData() async {
  setState(() => _isLoading = true);

  try {
    final data = await service.getData();
    // 處理資料
  } on ApiException catch (e) {
    // 處理錯誤
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 2. 在 dispose 時清理資源

```dart
@override
void dispose() {
  _authService.dispose();
  _shopService.dispose();
  super.dispose();
}
```

### 3. 統一的錯誤處理

```dart
void handleApiError(ApiException e) {
  String message;

  if (e is NetworkException) {
    message = '請檢查網路連線';
  } else if (e is UnauthorizedException) {
    Navigator.pushReplacementNamed(context, '/login');
    return;
  } else if (e is ValidationException) {
    message = e.getAllErrors().join('\n');
  } else {
    message = e.message;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

// 使用
try {
  await service.doSomething();
} on ApiException catch (e) {
  handleApiError(e);
}
```

### 4. 檢查網路狀態

```dart
import 'package:shop/utils/network_utils.dart';

Future<void> loadData() async {
  final hasConnection = await NetworkUtils.hasConnection();

  if (!hasConnection) {
    showNoNetworkDialog();
    return;
  }

  // 繼續執行 API 請求
}
```

---

## 📚 資料模型說明

### 保留的 UI Demo 模型
- `ProductModel` (lib/models/product_model.dart) - UI 展示用
- `CategoryModel` (lib/models/category_model.dart) - UI 展示用

### API 對應的模型
- `ApiProduct` (lib/models/api_category_model.dart) - 實際 API 商品資料
- `ApiCategory` (lib/models/api_category_model.dart) - 實際 API 分類資料

---

## 🎓 總結

本 API Utility 架構提供:
- ✅ 統一的 HTTP 請求處理
- ✅ 自動化的 Token 管理
- ✅ 完善的錯誤處理機制
- ✅ 清晰的服務層分離
- ✅ 型別安全的資料模型
- ✅ 詳細的使用範例

所有服務都已包含完整的錯誤處理和文件註解，可直接在 IDE 中查看使用說明。
