# Phase 2.1 - ViewModel Layer Setup 完成總結

## 完成日期
2025-01-06

## 實作內容

### 1. ViewModels 創建

成功創建了 6 個核心 ViewModels，涵蓋 tklabAppV2 的主要功能：

#### ✅ BaseViewModel (`lib/viewmodels/base_view_model.dart`)
- **狀態**: 已存在，無需修改
- **功能**:
  - ViewState 管理（idle/loading/success/error）
  - 統一的錯誤處理機制
  - `setLoading()`, `setSuccess()`, `setError()`, `setIdle()` 方法
  - `handleError()` 輔助方法

#### ✅ HomeViewModel (`lib/viewmodels/home_view_model.dart`)
- **狀態**: 已存在（FlutterShop 模板）
- **功能**:
  - Banner 資料管理
  - 商品分類管理
  - 商品列表載入（按分類）
  - 初始化和刷新功能
- **依賴**: LandingService, ShopService

#### ✅ CartViewModel (`lib/viewmodels/cart_view_model.dart`)
- **狀態**: 新創建
- **功能**:
  - 購物車資料管理
  - 加入購物車
  - 更新商品數量
  - 移除商品
  - 清空購物車
  - 本地即時更新 + 後端同步
- **依賴**: CartService
- **特色**: 樂觀更新（optimistic updates）模式

#### ✅ MemberViewModel (`lib/viewmodels/member_view_model.dart`)
- **狀態**: 新創建
- **功能**:
  - 用戶登入/登出
  - 用戶註冊
  - 用戶資料載入
  - 用戶資料更新
  - Token 有效性檢查
  - 自動初始化（檢查登入狀態）
- **依賴**: AuthService, TokenManager

#### ✅ CommunityViewModel (`lib/viewmodels/community_view_model.dart`)
- **狀態**: 新創建
- **功能**:
  - 社群貼文列表管理
  - 分頁載入（pagination）
  - 發佈新貼文
  - 按讚/取消按讚
  - 刪除貼文
  - 下拉刷新
- **依賴**: 預留 CommunityService（Phase 2.2 實作）
- **特色**: 樂觀更新模式

#### ✅ ChatViewModel (`lib/viewmodels/chat_view_model.dart`)
- **狀態**: 新創建
- **功能**:
  - 聊天訊息管理
  - 發送文字訊息
  - 發送圖片訊息
  - WebSocket 連接管理（預留）
  - 訊息狀態追蹤（sending/sent/failed/read）
  - 重新發送失敗訊息
  - 輸入狀態指示
- **依賴**: 預留 ChatService 和 WebSocket（Phase 3 實作）
- **特色**: 訊息狀態管理、WebSocket 重連機制

### 2. Models 創建

為支援新 ViewModels 創建了以下 Model 類別：

#### ✅ CommunityModels (`lib/models/community_models.dart`)
- `PostAuthor` - 貼文作者資訊
- `CommunityPost` - 社群貼文（含 copyWith 方法）
- `PostComment` - 貼文評論
- `CreatePostRequest` - 發佈貼文請求
- `CommunityPostsResponse` - 貼文列表回應（含分頁資訊）

#### ✅ ChatModels (`lib/models/chat_models.dart`)
- `ChatMessage` - 聊天訊息（含 copyWith 方法）
- `MessageStatus` - 訊息狀態 enum
- `ChatRoom` - 聊天室資訊
- `SendMessageRequest` - 發送訊息請求
- `WSMessage` - WebSocket 訊息
- `WSMessageType` - WebSocket 訊息類型 enum

#### ✅ CartModels 增強 (`lib/models/cart_models.dart`)
- 為 `CartItem` 添加 `copyWith()` 方法
- 為 `CartResponse` 添加 `copyWith()` 方法

### 3. 程式碼品質

- ✅ 所有 ViewModels 繼承 BaseViewModel
- ✅ 統一的狀態管理模式
- ✅ 統一的錯誤處理
- ✅ 符合 Dart 編碼規範
- ✅ Flutter analyze 通過（僅剩 info 級別提示）
- ✅ 預留 TODO 標記，方便 Phase 2.2 和 Phase 3 實作

## ViewModels 架構圖

```
┌─────────────────────────────────────────────────────────────┐
│                    BaseViewModel                            │
│  • ViewState (idle/loading/success/error)                   │
│  • Error handling                                           │
│  • ChangeNotifier                                           │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┬────────────────────┐
         │               │               │                    │
         ▼               ▼               ▼                    ▼
┌─────────────────┐ ┌──────────────┐ ┌─────────────────┐ ┌──────────────┐
│ HomeViewModel   │ │ CartViewModel│ │ MemberViewModel │ │CommunityVM   │
│                 │ │              │ │                 │ │              │
│ • Banners       │ │ • Cart items │ │ • Current user  │ │ • Posts list │
│ • Categories    │ │ • Add/Remove │ │ • Login/Logout  │ │ • Like/Unlike│
│ • Products      │ │ • Update qty │ │ • Register      │ │ • Create post│
│                 │ │ • Clear cart │ │ • Profile       │ │ • Pagination │
└────────┬────────┘ └──────┬───────┘ └────────┬────────┘ └──────┬───────┘
         │                 │                  │                  │
         ▼                 ▼                  ▼                  ▼
┌─────────────────┐ ┌──────────────┐ ┌─────────────────┐ ┌──────────────┐
│ LandingService  │ │ CartService  │ │  AuthService    │ │CommunityServ.│
│ ShopService     │ │              │ │  TokenManager   │ │(Phase 2.2)   │
└─────────────────┘ └──────────────┘ └─────────────────┘ └──────────────┘

┌─────────────────┐
│  ChatViewModel  │
│                 │
│ • Messages      │
│ • Send message  │
│ • WebSocket     │
│ • Retry failed  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   ChatService   │
│   WebSocket     │
│   (Phase 3)     │
└─────────────────┘
```

## 使用範例

### 1. HomeViewModel 使用

```dart
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/viewmodels/home_view_model.dart';

// 在 Screen 中使用
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return CircularProgressIndicator();
        }

        if (viewModel.isError) {
          return Text('Error: ${viewModel.errorMessage}');
        }

        return ListView.builder(
          itemCount: viewModel.products.length,
          itemBuilder: (context, index) {
            final product = viewModel.products[index];
            return ListTile(title: Text(product.name));
          },
        );
      },
    );
  }
}
```

### 2. CartViewModel 使用

```dart
// 加入購物車
await context.read<CartViewModel>().addToCart(productId, quantity);

// 移除商品
await context.read<CartViewModel>().removeFromCart(cartItemId);

// 監聽購物車變化
Consumer<CartViewModel>(
  builder: (context, cart, child) {
    return Text('總計: \$${cart.total}');
  },
)
```

### 3. MemberViewModel 使用

```dart
final memberVM = context.read<MemberViewModel>();

// 登入
final success = await memberVM.login(email, password);
if (success) {
  // 導航到首頁
}

// 檢查登入狀態
if (memberVM.isLoggedIn) {
  print('用戶: ${memberVM.userName}');
}

// 登出
await memberVM.logout();
```

### 4. CommunityViewModel 使用

```dart
// 載入貼文
await context.read<CommunityViewModel>().initialize();

// 按讚
await context.read<CommunityViewModel>().toggleLike(postId);

// 發佈新貼文
final success = await context.read<CommunityViewModel>().createPost(
  content: '這是我的新貼文',
  images: ['image1.jpg', 'image2.jpg'],
);

// 分頁載入
await context.read<CommunityViewModel>().loadMorePosts();
```

### 5. ChatViewModel 使用

```dart
// 初始化聊天
await context.read<ChatViewModel>().initialize();

// 發送訊息
await context.read<ChatViewModel>().sendMessage('你好！');

// 發送圖片
await context.read<ChatViewModel>().sendImageMessage(imageUrl);

// 重試失敗的訊息
await context.read<ChatViewModel>().retryMessage(messageId);

// 連接 WebSocket（Phase 3）
await context.read<ChatViewModel>().connectWebSocket();
```

## 特色功能

### 1. 樂觀更新（Optimistic Updates）
- **CartViewModel**: 本地先更新數量，再同步後端
- **CommunityViewModel**: 按讚立即反映在 UI，失敗時回退

### 2. 錯誤處理
- 統一的錯誤訊息格式
- 失敗時自動回退到上一個穩定狀態
- 用戶友善的錯誤提示

### 3. 狀態管理
- 使用 ViewState 清楚表達載入狀態
- isLoading / isError / isSuccess 布林值方便 UI 判斷
- 統一的 setLoading/setSuccess/setError 模式

### 4. 可測試性
- 所有 Service 都可以透過構造函數注入
- 方便單元測試和 mock
- 清晰的職責分離

## 待完成項目（後續 Phase）

### Phase 2.2 - Service Layer
- [ ] 實作 CommunityService（社群相關 API）
- [ ] 實作 ChatService（聊天相關 API）
- [ ] 實作 MessageService（通知訊息 API）

### Phase 3 - WebSocket Integration
- [ ] ChatViewModel 中的 WebSocket 連接實作
- [ ] 即時訊息接收
- [ ] 重連機制完善
- [ ] 訊息已讀狀態同步

## 驗證檢查清單

- ✅ BaseViewModel 存在且功能完整
- ✅ 所有 6 個核心 ViewModels 已創建
- ✅ CommunityModels 和 ChatModels 已創建
- ✅ CartItem 和 CartResponse 有 copyWith 方法
- ✅ 所有 ViewModels 繼承 BaseViewModel
- ✅ 統一的錯誤處理模式
- ✅ Flutter analyze 通過（無 error，僅 info）
- ✅ 程式碼符合 Dart 編碼規範
- ✅ 適當的 TODO 標記供後續實作

## 檔案清單

### ViewModels
- ✅ `lib/viewmodels/base_view_model.dart` (已存在)
- ✅ `lib/viewmodels/home_view_model.dart` (已存在)
- ✅ `lib/viewmodels/cart_view_model.dart` (新創建)
- ✅ `lib/viewmodels/member_view_model.dart` (新創建)
- ✅ `lib/viewmodels/community_view_model.dart` (新創建)
- ✅ `lib/viewmodels/chat_view_model.dart` (新創建)

### Models
- ✅ `lib/models/community_models.dart` (新創建)
- ✅ `lib/models/chat_models.dart` (新創建)
- ✅ `lib/models/cart_models.dart` (增強)

## 後續步驟

根據 TKLABAPPV2_MIGRATION_PLAN.md，下一個階段是：

**Phase 2.2 - Service Layer Migration**
- 創建 CommunityService
- 創建 ChatService
- 創建 MessageService
- 整合到對應的 ViewModels

或

**Phase 2.3 - Model Classes**
- 創建更多 Models（如需要）
- 完善現有 Models

---

**Phase 2.1 狀態：✅ 完成**
