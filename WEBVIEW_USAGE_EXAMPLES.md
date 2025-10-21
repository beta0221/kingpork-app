# WebView 使用範例文件

## 概述

tklabAppV2 的 WebView 功能提供完整的網頁瀏覽體驗，支援 Token 自動注入、JavaScript 雙向通訊、URL 過濾等進階功能。

## 基本使用

### 1. 透過路由導航至 WebView

最簡單的方式是使用命名路由：

```dart
import 'package:tklab_ec_v2/route/route_constants.dart';

// 基本用法
Navigator.pushNamed(
  context,
  webViewScreenRoute,
  arguments: {
    'url': '/products',
    'title': '產品列表',
  },
);
```

### 2. 使用 MaterialPageRoute 直接導航

如果需要更多控制：

```dart
import 'package:tklab_ec_v2/screens/webview/webview_screen.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const WebViewScreen(
      url: '/checkout',
      title: '結帳',
      showAppBar: true,
    ),
  ),
);
```

## 進階用法

### 全螢幕 WebView（無 AppBar）

```dart
Navigator.pushNamed(
  context,
  webViewScreenRoute,
  arguments: {
    'url': '/fullscreen-content',
    'showAppBar': false,
  },
);
```

### 載入外部 URL（完整 URL）

```dart
// 注意：WebViewConfig 會自動處理 URL 建構
// 如果需要載入外部完整 URL，請使用相對路徑
Navigator.pushNamed(
  context,
  webViewScreenRoute,
  arguments: {
    'url': '/external-content?redirect=https://example.com',
    'title': '外部內容',
  },
);
```

### 帶查詢參數的 URL

```dart
Navigator.pushNamed(
  context,
  webViewScreenRoute,
  arguments: {
    'url': '/products?category=electronics&sort=price',
    'title': '電子產品',
  },
);
```

## JavaScript 雙向通訊

### 從網頁發送訊息到 Flutter

在您的網頁 HTML/JavaScript 中：

#### 1. 顯示 Toast 訊息

```javascript
function showFlutterToast(message) {
  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({
      action: 'toast',
      message: message
    })
  );
}

// 使用範例
showFlutterToast('商品已加入購物車！');
```

#### 2. 更新頁面標題

```javascript
function updateAppBarTitle(newTitle) {
  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({
      action: 'set_title',
      title: newTitle
    })
  );
}

// 使用範例
updateAppBarTitle('購物車 (3)');
```

#### 3. 載入新頁面

```javascript
function loadPage(url) {
  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({
      action: 'loadurl',
      url: url
    })
  );
}

// 使用範例
loadPage('/checkout');
```

#### 4. 關閉 WebView

```javascript
function closeWebView() {
  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({
      action: 'close'
    })
  );
}

// 使用範例：完成支付後
document.getElementById('completeBtn').addEventListener('click', closeWebView);
```

#### 5. 返回上一頁

```javascript
function goBack() {
  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({
      action: 'go_back'
    })
  );
}
```

#### 6. 返回首頁

```javascript
function goHome() {
  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({
      action: 'go_to_home'
    })
  );
}
```

#### 7. 重新載入頁面

```javascript
function reloadPage() {
  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({
      action: 'reload'
    })
  );
}
```

#### 8. 觸發登入（TODO）

```javascript
function requestLogin() {
  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({
      action: 'login'
    })
  );
}
```

#### 9. 執行登出（TODO）

```javascript
function requestLogout() {
  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({
      action: 'logout'
    })
  );
}
```

#### 10. 分享內容（TODO）

```javascript
function shareContent(title, url, description) {
  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({
      action: 'share',
      data: {
        title: title,
        url: url,
        description: description
      }
    })
  );
}
```

### 完整的網頁範例

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TKLab 產品頁面</title>
</head>
<body>
  <h1>產品詳情</h1>
  <button onclick="addToCart()">加入購物車</button>
  <button onclick="goToCheckout()">前往結帳</button>
  <button onclick="closeWindow()">關閉</button>

  <script>
    // 加入購物車
    function addToCart() {
      // 執行加入購物車邏輯...

      // 顯示 Toast
      window.webviewFlutterJavascriptChannel.postMessage(
        JSON.stringify({
          action: 'toast',
          message: '已加入購物車'
        })
      );

      // 更新標題顯示購物車數量
      window.webviewFlutterJavascriptChannel.postMessage(
        JSON.stringify({
          action: 'set_title',
          title: '購物車 (1)'
        })
      );
    }

    // 前往結帳
    function goToCheckout() {
      window.webviewFlutterJavascriptChannel.postMessage(
        JSON.stringify({
          action: 'loadurl',
          url: '/checkout'
        })
      );
    }

    // 關閉視窗
    function closeWindow() {
      window.webviewFlutterJavascriptChannel.postMessage(
        JSON.stringify({
          action: 'close'
        })
      );
    }

    // 檢測是否在 Flutter WebView 中
    function isInFlutterApp() {
      return typeof window.webviewFlutterJavascriptChannel !== 'undefined';
    }

    // 條件式功能
    if (isInFlutterApp()) {
      console.log('Running inside Flutter WebView');
      // 啟用 Flutter 特定功能
    } else {
      console.log('Running in regular browser');
      // 使用瀏覽器標準 API
    }
  </script>
</body>
</html>
```

### 從 Flutter 發送訊息到網頁

在 WebViewScreen 內部，您可以使用 WebViewConfig 發送訊息：

```dart
// 在 WebViewScreen 的 State 中
await WebViewConfig.sendMessageToWeb(
  _controller,
  {
    'action': 'updateCart',
    'itemCount': 5,
    'totalPrice': 1999.99,
  },
);
```

網頁端接收訊息：

```html
<script>
// 定義接收函數
window.receiveMessageFromFlutter = function(message) {
  console.log('Received from Flutter:', message);

  if (message.action === 'updateCart') {
    document.getElementById('cartCount').textContent = message.itemCount;
    document.getElementById('totalPrice').textContent = message.totalPrice;
  }
};
</script>
```

## 環境配置

WebView 會自動根據 FlavorConfig 使用不同的環境：

### 開發環境
```dart
// lib/config/flavor_config.dart
ServiceSet.flavor = Flavor.dev;

// WebView 會載入：https://rd.tklab.com.tw/products?app=true&token=xxx
```

### UAT 環境
```dart
ServiceSet.flavor = Flavor.uat;

// WebView 會載入：https://test.tklab.com.tw/products?app=true&token=xxx
```

### 正式環境
```dart
ServiceSet.flavor = Flavor.release;

// WebView 會載入：https://www.tklab.com.tw/products?app=true&token=xxx
```

## Token 自動注入

WebView 會自動從 TokenManager 取得 access token 並注入到 URL 中：

```
原始 URL: /products
最終 URL: https://www.tklab.com.tw/products?app=true&token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

這讓網頁端可以直接使用 token 進行 API 請求，無需額外的認證流程。

### 網頁端取得 Token

```javascript
// 從 URL 參數取得 token
const urlParams = new URLSearchParams(window.location.search);
const token = urlParams.get('token');

// 使用 token 進行 API 請求
fetch('/api/user/profile', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
})
.then(response => response.json())
.then(data => console.log(data));
```

## URL 過濾

WebView 會自動阻擋以下類型的 URL：

### 阻擋的 URL
- ❌ `https://apps.apple.com/*` - App Store 連結
- ❌ `https://itunes.apple.com/*` - iTunes 連結
- ❌ `https://play.google.com/*` - Play Store 連結
- ❌ `upwrp://*` - 特定支付 scheme
- ❌ `gwpay://*` - 特定支付 scheme
- ❌ `payment://*` - 通用支付 scheme

### 允許的 URL
- ✅ 相同網域的所有頁面
- ✅ HTTPS/HTTP 一般連結
- ✅ JavaScript 導航

## 錯誤處理

### 顯示載入中狀態

```dart
// WebViewScreen 內部自動處理
// 載入中會顯示 WebViewLoading 元件
```

### 顯示錯誤狀態

```dart
// 若需要自定義錯誤頁面，可以在網頁端處理
import 'package:tklab_ec_v2/screens/webview/components/webview_loading.dart';

// 在您的自定義 WebView 實作中
if (hasError) {
  return WebViewError(
    message: '載入失敗，請稍後再試',
    onRetry: () {
      // 重試邏輯
      _controller.reload();
    },
  );
}
```

## 返回鍵處理

WebView 實作了智能返回鍵處理：

1. **WebView 有歷史記錄** → 返回上一頁（在 WebView 內）
2. **WebView 無歷史記錄** → 關閉 WebView 畫面（Navigator.pop）

這提供了原生應用程式般的導航體驗。

### 測試返回鍵

```dart
// 使用者按下返回鍵時：
// 1. 如果在 /checkout/step2，會返回 /checkout/step1
// 2. 如果在 /checkout/step1（第一頁），會關閉 WebView
```

## 常見使用情境

### 情境 1：產品詳情頁

```dart
// 從產品列表點擊產品
onTap: () {
  Navigator.pushNamed(
    context,
    webViewScreenRoute,
    arguments: {
      'url': '/products/${product.id}',
      'title': product.name,
    },
  );
}
```

### 情境 2：結帳流程

```dart
// 開始結帳
Navigator.pushNamed(
  context,
  webViewScreenRoute,
  arguments: {
    'url': '/checkout/cart',
    'title': '結帳',
  },
);

// 網頁端可以透過 JavaScript 通訊：
// - 完成付款時關閉 WebView
// - 更新標題顯示步驟 (1/3)
// - 顯示 Toast 提示
```

### 情境 3：活動頁面

```dart
// 顯示活動頁面（全螢幕）
Navigator.pushNamed(
  context,
  webViewScreenRoute,
  arguments: {
    'url': '/events/summer-sale',
    'showAppBar': false,  // 全螢幕顯示
  },
);
```

### 情境 4：客服聊天（Web 版）

```dart
// 如果客服系統是網頁版
Navigator.pushNamed(
  context,
  webViewScreenRoute,
  arguments: {
    'url': '/support/chat',
    'title': '線上客服',
  },
);
```

## 效能優化建議

### 1. 預載入常用頁面

```dart
// 在 App 初始化時預先建立 WebView
class PreloadService {
  static WebViewController? _cachedController;

  static Future<void> preloadHomePage() async {
    _cachedController = await WebViewConfig.createController(
      url: '/home',
      onJsMessage: (message) {},
    );
  }
}
```

### 2. 快取策略

```dart
// 在 WebViewConfig.createController 中加入快取
controller.setCacheMode(CacheMode.LOAD_DEFAULT);
```

### 3. 圖片延遲載入

```html
<!-- 網頁端使用 lazy loading -->
<img src="product.jpg" loading="lazy" alt="產品">
```

## 除錯技巧

### 啟用 Chrome DevTools

1. 在 Android 裝置上執行應用程式
2. 打開 Chrome 瀏覽器
3. 訪問 `chrome://inspect`
4. 選擇您的 WebView 進行除錯

### 查看 JavaScript Console

```dart
// 在 WebViewConfig.createController 中加入
controller.setJavaScriptMode(JavaScriptMode.unrestricted);

// 網頁端
console.log('Debug message');
// 會顯示在 Chrome DevTools Console
```

### 監控網路請求

```javascript
// 網頁端攔截 fetch 請求
const originalFetch = window.fetch;
window.fetch = function(...args) {
  console.log('Fetch:', args);
  return originalFetch.apply(this, args);
};
```

## 安全性注意事項

### 1. Token 保護

- ✅ Token 只透過 URL 參數傳遞（HTTPS 加密）
- ✅ 網頁應該在使用後立即從 URL 中移除 token
- ❌ 不要將 token 儲存在 localStorage（除非有安全機制）

### 2. JavaScript Bridge 安全

```javascript
// ✅ 驗證訊息來源
function sendMessage(action, data) {
  if (typeof window.webviewFlutterJavascriptChannel === 'undefined') {
    console.error('Not in Flutter WebView');
    return;
  }

  window.webviewFlutterJavascriptChannel.postMessage(
    JSON.stringify({ action, ...data })
  );
}

// ❌ 不要信任所有來源的訊息
window.addEventListener('message', (event) => {
  // 需要驗證 event.origin
});
```

### 3. XSS 防護

```javascript
// ✅ 使用 textContent 而非 innerHTML
element.textContent = userInput;

// ❌ 避免直接插入 HTML
element.innerHTML = userInput; // 危險！
```

## 故障排除

### 問題 1：WebView 顯示空白頁

**可能原因**：
- URL 路徑錯誤
- Token 無效或過期
- 網路連線問題

**解決方案**：
```dart
// 檢查 URL 是否正確
debugPrint('Loading URL: ${await WebViewConfig.buildAuthenticatedUrl('/products')}');

// 檢查 Token
final token = await TokenManager().getAccessToken();
debugPrint('Token: $token');
```

### 問題 2：JavaScript 通道無回應

**可能原因**：
- JavaScript 未正確載入
- 通道名稱錯誤

**解決方案**：
```javascript
// 檢查通道是否存在
if (typeof window.webviewFlutterJavascriptChannel !== 'undefined') {
  console.log('Channel is available');
} else {
  console.error('Channel not found');
}
```

### 問題 3：返回鍵不工作

**可能原因**：
- PopScope 設定錯誤

**解決方案**：
已在 WebViewScreen 中正確實作 PopScope，應該可以正常工作。

## 未來擴展

以下功能目前標記為 TODO，可在後續 Phase 實作：

- [ ] `_handleLogin()` - 完整的登入流程整合
- [ ] `_handleLogout()` - 登出後的狀態清理
- [ ] `_handleShare()` - 原生分享功能
- [ ] 檔案上傳支援
- [ ] 下載管理
- [ ] Cookie 同步
- [ ] 推播通知整合
- [ ] Deep Link 處理

---

**文件版本**：1.0.0
**最後更新**：2025-01-06
**適用專案**：tklabAppV2
**相關文件**：PHASE_3.1_COMPLETION.md, TKLABAPPV2_MIGRATION_PLAN.md
