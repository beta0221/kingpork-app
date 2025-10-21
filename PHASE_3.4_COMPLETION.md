# Phase 3.4 - JavaScript Bridge 完成總結

## 完成日期
2025-01-06

## 實作內容

### 1. JavaScript Bridge Handler

#### js_bridge_handler.dart

**檔案位置**: `lib/utils/js_bridge_handler.dart`

**程式碼行數**: 528 行

**主要功能**:

統一處理來自 WebView 的所有 JavaScript 訊息，提供結構化的 Action 處理機制。

##### 類別結構

```dart
class JsBridgeHandler {
  final BuildContext context;

  // WebView 控制回調
  final Future<void> Function()? onReload;
  final Future<void> Function(String url)? onLoadUrl;
  final Future<bool> Function()? onCanGoBack;
  final Future<void> Function()? onGoBack;

  // 導航回調
  final VoidCallback? onGoHome;
  final VoidCallback? onClose;
  final VoidCallback? onGoMemberEdit;

  // 認證回調
  final Future<void> Function()? onLogin;
  final Future<void> Function()? onLogout;

  // 資料同步回調
  final Function(int count)? onCartCountUpdate;
  final Function(String title)? onTitleUpdate;

  // 其他回調
  final Function(String message, {int? duration})? onShowToast;
}
```

##### 支援的 Actions（20+）

**1. 頁面操作類** (2 個):
- `reload` - 重新載入頁面
- `loadurl` - 載入新 URL

**2. 導航類** (7 個):
- `go_to_home` - 返回首頁
- `go_back` - 返回上一頁
- `close` - 關閉 WebView
- `go_member_edit` - 前往會員編輯
- `open_new_webview` - 開啟新 WebView
- `open_web_dialog` - 開啟彈窗 WebView

**3. 認證類** (2 個):
- `login` - 執行登入流程
- `logout` - 執行登出（含確認對話框）

**4. 資料同步類** (2 個):
- `getCount` - 同步購物車數量
- `set_title` - 更新頁面標題

**5. UI 互動類** (4 個):
- `toast` - 顯示 Toast 提示
- `share` - 分享內容
- `copy_to_clipboard` - 複製到剪貼簿
- `vibrate` - 觸發震動

**6. 外部開啟類** (2 個):
- `launch` - 開啟外部連結
- `open_external_browser` - 在外部瀏覽器開啟

**7. 訂單相關** (2 個):
- `order_comment` - 訂單評論（待實作）
- `returnOrder` - 訂單退貨（待實作）

**8. 支付相關** (1 個):
- `line_pay_open` - LINE Pay 支付（待實作）

**9. 其他** (1 個):
- `agree_open` - 開啟訂閱頁面

##### 核心方法

```dart
/// 處理來自 JavaScript 的訊息
Future<void> handle(String message) async {
  try {
    final data = json.decode(message) as Map<String, dynamic>;
    final action = data['action'] as String?;

    if (action == null) {
      debugPrint('JS Bridge: Missing action in message');
      return;
    }

    switch (action) {
      case 'reload': await _handleReload(); break;
      case 'loadurl': await _handleLoadUrl(data); break;
      case 'go_to_home': _handleGoHome(); break;
      // ... 20+ actions
      default:
        debugPrint('JS Bridge: Unhandled action: $action');
        _showUnhandledActionWarning(action);
    }
  } catch (e) {
    debugPrint('JS Bridge: Error handling message: $e');
  }
}
```

##### 錯誤處理機制

1. **JSON 解析錯誤**: 捕獲並記錄錯誤訊息
2. **缺少 action 欄位**: 記錄警告並提前返回
3. **未處理的 action**: 記錄警告，開發模式顯示 SnackBar
4. **context 有效性檢查**: 使用 `context.mounted` 避免 async gap

##### 待實作功能（TODO）

- `_handleOrderComment` - 整合訂單評論頁面
- `_handleReturnOrder` - 整合訂單退貨頁面
- `_handleLinePayOpen` - 整合 LINE Pay 流程
- `_handleGetCount` - 整合 CartViewModel 取得購物車數量

---

### 2. TkWebView 可重用元件

#### tk_webview.dart

**檔案位置**: `lib/components/webview/tk_webview.dart`

**程式碼行數**: 183 行

**主要功能**:

提供統一的 WebView 介面，整合 JS Bridge 和標準配置，簡化 WebView 的使用。

##### 元件參數

```dart
class TkWebView extends StatefulWidget {
  // 基本參數
  final String url;                // URL 路徑（相對路徑）
  final bool showLoading;          // 顯示載入指示器
  final String? loadingMessage;    // 載入訊息

  // 自訂回調
  final Function(String action, Map<String, dynamic> data)? onJsMessage;
  final Function(WebViewController controller)? onControllerCreated;
  final Function(String url)? onPageStarted;
  final Function(String url)? onPageFinished;
  final Function(int progress)? onProgress;

  // 視覺配置
  final Color? backgroundColor;
  final bool enableJavaScript;

  // JS Bridge 配置
  final JsBridgeHandler Function(BuildContext context)? bridgeHandlerBuilder;
}
```

##### 核心功能

**1. 自動 JS Bridge 初始化**:
```dart
void _initBridgeHandler() {
  if (widget.bridgeHandlerBuilder != null) {
    _bridgeHandler = widget.bridgeHandlerBuilder!(context);
  } else {
    _bridgeHandler = JsBridgeHandler(
      context: context,
      onReload: () async => await _controller.reload(),
      onLoadUrl: (url) async {
        final fullUrl = await WebViewConfig.buildAuthenticatedUrl(url);
        await _controller.loadRequest(Uri.parse(fullUrl));
      },
      // ... 其他回調
    );
  }
}
```

**2. 彈性的訊息處理**:
```dart
void _handleJavaScriptMessage(String message) {
  if (widget.onJsMessage != null) {
    // 使用自訂回調
    final data = json.decode(message);
    widget.onJsMessage!(data['action'], data);
  } else {
    // 使用預設的 JsBridgeHandler
    _bridgeHandler.handle(message);
  }
}
```

**3. 載入進度追蹤**:
```dart
onProgress: (progress) {
  setState(() {
    _loadingProgress = progress;
  });
  widget.onProgress?.call(progress);
}
```

**4. URL 過濾邏輯**:
```dart
onNavigationRequest: (request) {
  final url = request.url;
  if (url.contains('apps.apple.com') || url.contains('play.google.com')) {
    return NavigationDecision.prevent;
  }
  if (url.startsWith('upwrp://') || url.startsWith('gwpay://')) {
    return NavigationDecision.prevent;
  }
  return NavigationDecision.navigate;
}
```

##### 使用範例

**基本用法**:
```dart
TkWebView(
  url: '/products',
  showLoading: true,
  loadingMessage: '載入產品中...',
)
```

**自訂 JS 訊息處理**:
```dart
TkWebView(
  url: '/checkout',
  onJsMessage: (action, data) {
    if (action == 'payment_success') {
      // 處理支付成功
    }
  },
)
```

**自訂 Bridge Handler**:
```dart
TkWebView(
  url: '/special-page',
  bridgeHandlerBuilder: (context) => JsBridgeHandler(
    context: context,
    onLogin: () async {
      // 自訂登入邏輯
    },
  ),
)
```

---

### 3. WebViewScreen 整合 JS Bridge

#### webview_screen.dart 更新

**檔案位置**: `lib/screens/webview/webview_screen.dart`

**程式碼行數**: 137 行（重寫）

**主要變更**:

##### 整合 JsBridgeHandler

**Before** (舊版):
```dart
void _handleJavaScriptMessage(String message) {
  final data = json.decode(message);
  final action = data['action'];

  switch (action) {
    case 'go_to_home': _goToHome(); break;
    case 'go_back': _goBack(); break;
    // 手動處理每個 action...
  }
}
```

**After** (新版):
```dart
void _initializeJsBridge() {
  _jsBridge = JsBridgeHandler(
    context: context,
    onReload: () async => await _controller.reload(),
    onLoadUrl: (url) async {
      final fullUrl = await WebViewConfig.buildAuthenticatedUrl(url);
      await _controller.loadRequest(Uri.parse(fullUrl));
    },
    onGoHome: () => Navigator.of(context).popUntil((route) => route.isFirst),
    onClose: () => Navigator.of(context).pop(),
    onTitleUpdate: (title) => setState(() { _pageTitle = title; }),
    onShowToast: (message, {duration}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: Duration(...)),
      );
    },
  );
}

Future<void> _initializeWebView() async {
  _controller = await WebViewConfig.createController(
    url: widget.url,
    onJsMessage: (message) => _jsBridge.handle(message),
  );
}
```

##### 功能改進

1. **統一的訊息處理**: 所有 JS 訊息都透過 JsBridgeHandler 處理
2. **動態標題更新**: 支援從網頁更新 AppBar 標題
3. **Toast 支援**: 網頁可觸發 Flutter SnackBar
4. **回調解耦**: WebView 邏輯與 UI 邏輯分離

---

### 4. WebViewLoading 元件更新

#### webview_loading.dart 更新

**新增功能**: 支援顯示載入進度百分比

**Before**:
```dart
class WebViewLoading extends StatelessWidget {
  final String? message;
}
```

**After**:
```dart
class WebViewLoading extends StatelessWidget {
  final String? message;
  final int? progress; // 載入進度 0-100
}
```

**UI 改進**:
```dart
Widget build(BuildContext context) {
  return Center(
    child: Column(
      children: [
        const CircularProgressIndicator(),
        if (message != null) Text(message),
        if (progress != null) Text('$progress%'),
      ],
    ),
  );
}
```

---

## 技術亮點

### 1. 可擴展的 Action 處理機制

**優點**:
- 新增 Action 只需在 JsBridgeHandler 的 switch 中加一個 case
- 每個 Action 有獨立的處理方法，易於測試和維護
- 統一的錯誤處理邏輯

**範例 - 新增 Action**:
```dart
// 1. 在 JsBridgeHandler.handle() 中加入 case
case 'custom_action':
  await _handleCustomAction(data);
  break;

// 2. 實作處理方法
Future<void> _handleCustomAction(Map<String, dynamic> data) async {
  // 處理邏輯
}
```

### 2. 回調驅動的設計

**優點**:
- 高度可配置，適應不同場景
- 鬆耦合，易於單元測試
- 支援自訂行為覆蓋預設行為

**範例**:
```dart
// 預設行為
JsBridgeHandler(
  context: context,
  // 不提供 onLogin 回調，使用預設登入邏輯
);

// 自訂行為
JsBridgeHandler(
  context: context,
  onLogin: () async {
    // 自訂登入邏輯，覆蓋預設行為
    await customLoginFlow();
  },
);
```

### 3. 錯誤容錯機制

**三層防護**:
1. **JSON 解析錯誤捕獲**: 防止格式錯誤導致崩潰
2. **必填欄位檢查**: 缺少 action 時記錄警告並提前返回
3. **未知 Action 處理**: 記錄警告但不影響程式運行

**程式碼**:
```dart
try {
  final data = json.decode(message);  // 第一層
  final action = data['action'];
  if (action == null) return;         // 第二層

  switch (action) {
    // ...
    default:
      debugPrint('Unhandled: $action'); // 第三層
  }
} catch (e) {
  debugPrint('Error: $e');
}
```

### 4. Context 安全性

**問題**: `BuildContext` 在 async 操作後可能已失效

**解決方案**: 使用 `context.mounted` 檢查

**Before** (不安全):
```dart
Future<void> handleAction() async {
  await someAsyncOperation();
  Navigator.of(context).pop();  // context 可能已失效
}
```

**After** (安全):
```dart
Future<void> handleAction() async {
  await someAsyncOperation();
  if (context.mounted) {
    Navigator.of(context).pop();  // 確保 context 有效
  }
}
```

---

## 使用範例

### 範例 1：基本 WebView 使用

```dart
import 'package:tklab_ec_v2/screens/webview/webview_screen.dart';

// 導航到 WebView
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => WebViewScreen(
      url: '/products',
      title: '產品列表',
    ),
  ),
);
```

### 範例 2：使用 TkWebView 元件

```dart
import 'package:tklab_ec_v2/components/webview/tk_webview.dart';

// 在任意 Widget 中嵌入 WebView
Scaffold(
  body: TkWebView(
    url: '/checkout',
    showLoading: true,
    loadingMessage: '正在載入結帳頁面...',
    onPageFinished: (url) {
      print('Page loaded: $url');
    },
  ),
)
```

### 範例 3：網頁端發送訊息

```html
<script>
// 檢查是否在 Flutter WebView 中
function isInFlutterApp() {
  return typeof window.webviewFlutterJavascriptChannel !== 'undefined';
}

// 發送訊息到 Flutter
function sendToFlutter(action, data = {}) {
  if (!isInFlutterApp()) {
    console.log('Not in Flutter WebView');
    return;
  }

  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({ action, ...data })
  );
}

// 使用範例
document.getElementById('addToCart').addEventListener('click', () => {
  // 執行加入購物車邏輯...

  // 通知 Flutter 顯示 Toast
  sendToFlutter('toast', {
    message: '已加入購物車',
    duration: 2000
  });

  // 更新標題
  sendToFlutter('set_title', {
    title: '購物車 (3)'
  });
});

// 關閉 WebView
document.getElementById('closeBtn').addEventListener('click', () => {
  sendToFlutter('close');
});

// 分享商品
document.getElementById('shareBtn').addEventListener('click', () => {
  sendToFlutter('share', {
    data: {
      title: '精選商品',
      url: 'https://www.tklab.com.tw/products/123',
      description: '查看這個超棒的商品！'
    }
  });
});
</script>
```

### 範例 4：自訂 JS Bridge Handler

```dart
import 'package:tklab_ec_v2/components/webview/tk_webview.dart';
import 'package:tklab_ec_v2/utils/js_bridge_handler.dart';
import 'package:provider/provider.dart';

TkWebView(
  url: '/special-feature',
  bridgeHandlerBuilder: (context) {
    final cartProvider = context.read<CartProvide>();
    final memberProvider = context.read<MemberViewModel>();

    return JsBridgeHandler(
      context: context,
      onLogin: () async {
        // 自訂登入邏輯
        await memberProvider.login();
      },
      onLogout: () async {
        // 自訂登出邏輯
        await memberProvider.logout();
      },
      onCartCountUpdate: (count) {
        // 同步購物車數量到 Provider
        cartProvider.updateCount(count);
      },
    );
  },
)
```

---

## 驗證檢查清單

- ✅ JsBridgeHandler 已創建（528 行）
- ✅ 支援 20+ 個 Actions
- ✅ TkWebView 可重用元件已創建（183 行）
- ✅ WebViewScreen 已整合 JS Bridge
- ✅ WebViewLoading 支援進度顯示
- ✅ 錯誤處理機制完善
- ✅ Context 安全性確保（context.mounted）
- ✅ flutter analyze 通過（無錯誤）
- ✅ 所有回調都是可選的（彈性配置）
- ✅ 支援自訂 Bridge Handler
- ✅ 支援自訂 JS 訊息處理

---

## 檔案清單

### 新創建的檔案 (2 個)
- ✅ `lib/utils/js_bridge_handler.dart` (528 行)
- ✅ `lib/components/webview/tk_webview.dart` (183 行)

### 修改的檔案 (2 個)
- ✅ `lib/screens/webview/webview_screen.dart` (重寫，137 行)
- ✅ `lib/screens/webview/components/webview_loading.dart` (新增 progress 參數)

### 總程式碼變更
- 新增程式碼：711 行
- 重寫程式碼：137 行
- 修改程式碼：~10 行

---

## Action 處理對照表

| Action | 處理方法 | 實作狀態 | 說明 |
|--------|----------|---------|------|
| reload | _handleReload | ✅ | 重新載入頁面 |
| loadurl | _handleLoadUrl | ✅ | 載入新 URL |
| go_to_home | _handleGoHome | ✅ | 返回首頁 |
| go_back | _handleGoBack | ✅ | 返回上一頁 |
| close | _handleClose | ✅ | 關閉 WebView |
| go_member_edit | _handleGoMemberEdit | ✅ | 前往會員編輯 |
| open_new_webview | _handleOpenNewWebView | ✅ | 開啟新 WebView |
| open_web_dialog | _handleOpenDialog | ✅ | 開啟彈窗 WebView |
| login | _handleLogin | ✅ | 執行登入流程 |
| logout | _handleLogout | ✅ | 執行登出（含確認） |
| getCount | _handleGetCount | 📝 | 同步購物車數量（TODO） |
| set_title | _handleSetTitle | ✅ | 更新頁面標題 |
| toast | _handleToast | ✅ | 顯示 Toast 提示 |
| share | _handleShare | ✅ | 分享內容 |
| copy_to_clipboard | _handleCopyToClipboard | ✅ | 複製到剪貼簿 |
| vibrate | _handleVibrate | ✅ | 觸發震動 |
| launch | _handleLaunch | ✅ | 開啟外部連結 |
| open_external_browser | _handleLaunch | ✅ | 在外部瀏覽器開啟 |
| order_comment | _handleOrderComment | 📝 | 訂單評論（TODO） |
| returnOrder | _handleReturnOrder | 📝 | 訂單退貨（TODO） |
| line_pay_open | _handleLinePayOpen | 📝 | LINE Pay（TODO） |
| agree_open | _handleAgreeOpen | ✅ | 開啟訂閱頁面 |

---

## 待實作功能（後續 Phase）

### 高優先級
- [ ] 整合 CartViewModel 取得購物車數量（`getCount` action）
- [ ] 整合訂單評論頁面（`order_comment` action）
- [ ] 整合訂單退貨頁面（`returnOrder` action）

### 中優先級
- [ ] 整合 LINE Pay 支付流程（`line_pay_open` action）
- [ ] WebView ↔ Flutter 雙向資料同步
- [ ] 進階錯誤處理（顯示錯誤頁面）

### 低優先級
- [ ] JS Bridge 單元測試
- [ ] Widget 測試
- [ ] 整合測試

---

## 後續步驟

根據 TKLABAPPV2_MIGRATION_PLAN.md：

**Phase 4 - Feature Migration**（下一階段）
- 開始遷移具體功能頁面
- 整合 ViewModels 與 WebView
- 實作完整的業務邏輯
- 整合 Provider 狀態管理

**建議順序**:
1. Phase 4.1 - 認證流程（登入/註冊）
2. Phase 4.2 - 首頁功能
3. Phase 4.3 - 購物車功能
4. Phase 4.4 - 會員功能
5. Phase 4.5 - 社群功能

---

**Phase 3.4 狀態：✅ 完成**

**總結**: 成功實作了完整的 JavaScript Bridge 系統，包含 JsBridgeHandler（20+ Actions）、TkWebView 可重用元件、以及 WebViewScreen 整合。建立了可擴展的 Action 處理機制，支援自訂回調和錯誤容錯。所有程式碼遵循 Flutter 最佳實踐，無編譯錯誤，並確保了 Context 安全性。JavaScript Bridge 已完全準備好支援後續的功能遷移。
