# WebView JavaScript Actions 文檔

## 概述

本文檔定義了 tklabAppV2 WebView 支援的所有 JavaScript Actions，用於網頁與 Flutter App 之間的雙向通訊。

## 通訊機制

### 從網頁發送訊息到 Flutter

使用 JavaScript Channel 發送 JSON 格式訊息：

```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({
    action: 'action_name',
    // 其他參數...
  })
);
```

### 從 Flutter 發送訊息到網頁

Flutter 端調用 JavaScript 函數：

```dart
await WebViewConfig.sendMessageToWeb(controller, {
  'action': 'action_name',
  'data': {...}
});
```

網頁端定義接收函數：

```javascript
window.receiveMessageFromFlutter = function(message) {
  // 處理訊息
};
```

---

## 支援的 Actions

### 1. 導航類 Actions

#### 1.1 go_to_home

返回應用程式首頁（popUntil first route）

**參數**: 無

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({ action: 'go_to_home' })
);
```

**Flutter 處理**:
```dart
case 'go_to_home':
  Navigator.of(context).popUntil((route) => route.isFirst);
  break;
```

---

#### 1.2 go_back

返回上一頁

**參數**: 無

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({ action: 'go_back' })
);
```

**Flutter 處理**:
```dart
case 'go_back':
  if (await _controller.canGoBack()) {
    await _controller.goBack();
  } else {
    Navigator.of(context).pop();
  }
  break;
```

---

#### 1.3 close

關閉當前 WebView 畫面

**參數**: 無

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({ action: 'close' })
);
```

**Flutter 處理**:
```dart
case 'close':
  Navigator.of(context).pop();
  break;
```

---

#### 1.4 loadurl

載入新的 URL

**參數**:
- `url` (string, required): 要載入的 URL 路徑

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({
    action: 'loadurl',
    url: '/products/123'
  })
);
```

**Flutter 處理**:
```dart
case 'loadurl':
  final url = data['url'];
  if (url != null) {
    final fullUrl = await WebViewConfig.buildAuthenticatedUrl(url);
    await _controller.loadRequest(Uri.parse(fullUrl));
  }
  break;
```

---

#### 1.5 go_member_edit

前往會員編輯頁面

**參數**: 無

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({ action: 'go_member_edit' })
);
```

**Flutter 處理**:
```dart
case 'go_member_edit':
  Navigator.pushNamed(context, editUserInfoScreenRoute);
  break;
```

---

#### 1.6 open_new_webview

開啟新的 WebView 畫面

**參數**:
- `url` (string, required): 要載入的 URL
- `title` (string, optional): WebView 標題

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({
    action: 'open_new_webview',
    url: '/help',
    title: '幫助中心'
  })
);
```

**Flutter 處理**:
```dart
case 'open_new_webview':
  Navigator.pushNamed(
    context,
    webViewScreenRoute,
    arguments: {
      'url': data['url'],
      'title': data['title'],
    },
  );
  break;
```

---

#### 1.7 open_web_dialog

開啟彈窗式 WebView

**參數**:
- `url` (string, required): 要載入的 URL
- `title` (string, optional): 彈窗標題

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({
    action: 'open_web_dialog',
    url: '/terms',
    title: '服務條款'
  })
);
```

**Flutter 處理**:
```dart
case 'open_web_dialog':
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: WebViewScreen(
        url: data['url'],
        title: data['title'],
      ),
    ),
  );
  break;
```

---

### 2. 資料同步類 Actions

#### 2.1 getCount

同步購物車數量到網頁

**參數**: 無

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({ action: 'getCount' })
);
```

**Flutter 處理**:
```dart
case 'getCount':
  final cartProvider = context.read<CartProvide>();
  final count = cartProvider.cartItemCount;

  // 發送回網頁
  await WebViewConfig.sendMessageToWeb(_controller, {
    'action': 'updateCartCount',
    'count': count,
  });
  break;
```

**網頁端接收**:
```javascript
window.receiveMessageFromFlutter = function(message) {
  if (message.action === 'updateCartCount') {
    document.getElementById('cartBadge').textContent = message.count;
  }
};
```

---

#### 2.2 login

執行登入流程

**參數**: 無

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({ action: 'login' })
);
```

**Flutter 處理**:
```dart
case 'login':
  final result = await Navigator.pushNamed(context, logInScreenRoute);
  if (result == true) {
    // 登入成功，重新載入頁面
    await _controller.reload();
  }
  break;
```

---

#### 2.3 logout

執行登出

**參數**: 無

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({ action: 'logout' })
);
```

**Flutter 處理**:
```dart
case 'logout':
  final memberProvider = context.read<MemberViewModel>();
  await memberProvider.logout();

  // 返回首頁
  Navigator.of(context).popUntil((route) => route.isFirst);
  break;
```

---

### 3. 頁面操作類 Actions

#### 3.1 reload

重新載入當前頁面

**參數**: 無

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({ action: 'reload' })
);
```

**Flutter 處理**:
```dart
case 'reload':
  await _controller.reload();
  break;
```

---

#### 3.2 share

分享內容

**參數**:
- `data` (object, required): 分享資料
  - `title` (string): 分享標題
  - `url` (string): 分享連結
  - `description` (string): 分享描述

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({
    action: 'share',
    data: {
      title: '精選商品',
      url: 'https://www.tklab.com.tw/products/123',
      description: '查看這個超棒的商品！'
    }
  })
);
```

**Flutter 處理**:
```dart
case 'share':
  final shareData = data['data'];
  if (shareData != null) {
    await Share.share(
      '${shareData['title']}\n${shareData['description']}\n${shareData['url']}',
      subject: shareData['title'],
    );
  }
  break;
```

---

#### 3.3 set_title

動態更新 AppBar 標題

**參數**:
- `title` (string, required): 新的標題

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({
    action: 'set_title',
    title: '購物車 (3)'
  })
);
```

**Flutter 處理**:
```dart
case 'set_title':
  setState(() {
    _pageTitle = data['title'];
  });
  break;
```

---

#### 3.4 toast

顯示 Toast 提示訊息

**參數**:
- `message` (string, required): 提示訊息內容
- `duration` (int, optional): 顯示時長（毫秒），預設 2000

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({
    action: 'toast',
    message: '商品已加入購物車',
    duration: 3000
  })
);
```

**Flutter 處理**:
```dart
case 'toast':
  final message = data['message'];
  if (message != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(
          milliseconds: data['duration'] ?? 2000,
        ),
      ),
    );
  }
  break;
```

---

### 4. 特殊功能類 Actions

#### 4.1 copy_to_clipboard

複製文字到剪貼簿

**參數**:
- `text` (string, required): 要複製的文字

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({
    action: 'copy_to_clipboard',
    text: 'PROMO2024'
  })
);
```

**Flutter 處理**:
```dart
case 'copy_to_clipboard':
  final text = data['text'];
  if (text != null) {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已複製到剪貼簿')),
    );
  }
  break;
```

---

#### 4.2 open_external_browser

在外部瀏覽器開啟連結

**參數**:
- `url` (string, required): 要開啟的 URL

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({
    action: 'open_external_browser',
    url: 'https://www.google.com'
  })
);
```

**Flutter 處理**:
```dart
case 'open_external_browser':
  final url = data['url'];
  if (url != null && await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }
  break;
```

---

#### 4.3 vibrate

觸發手機震動

**參數**:
- `duration` (int, optional): 震動時長（毫秒），預設 100

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({
    action: 'vibrate',
    duration: 200
  })
);
```

**Flutter 處理**:
```dart
case 'vibrate':
  final duration = data['duration'] ?? 100;
  HapticFeedback.vibrate();
  // 或使用 vibration 套件進行更精細控制
  break;
```

---

#### 4.4 request_permission

請求特定權限

**參數**:
- `permission` (string, required): 權限類型（camera, location, storage 等）

**範例**:
```javascript
window.webviewFlutterJavascriptChannel.postMessage(
  JSON.stringify({
    action: 'request_permission',
    permission: 'camera'
  })
);
```

**Flutter 處理**:
```dart
case 'request_permission':
  final permission = data['permission'];
  // 使用 permission_handler 套件
  // final result = await Permission.camera.request();
  break;
```

---

## Flutter → Web Actions

以下是 Flutter 可以發送到網頁的 Actions：

### updateCartCount

更新購物車數量

```dart
await WebViewConfig.sendMessageToWeb(controller, {
  'action': 'updateCartCount',
  'count': 5,
});
```

### updateUserInfo

更新使用者資訊

```dart
await WebViewConfig.sendMessageToWeb(controller, {
  'action': 'updateUserInfo',
  'user': {
    'name': 'John Doe',
    'email': 'john@example.com',
  },
});
```

### refreshPage

通知網頁重新整理資料

```dart
await WebViewConfig.sendMessageToWeb(controller, {
  'action': 'refreshPage',
});
```

### tokenUpdated

通知網頁 Token 已更新

```dart
await WebViewConfig.sendMessageToWeb(controller, {
  'action': 'tokenUpdated',
  'token': 'new_access_token',
});
```

---

## 錯誤處理

### JavaScript 端錯誤處理

```javascript
function sendToFlutter(action, data = {}) {
  try {
    if (typeof window.webviewFlutterJavascriptChannel === 'undefined') {
      console.error('WebView channel not available');
      return false;
    }

    window.webviewFlutterJavascriptChannel.postMessage(
      JSON.stringify({ action, ...data })
    );
    return true;
  } catch (error) {
    console.error('Error sending message to Flutter:', error);
    return false;
  }
}
```

### Flutter 端錯誤處理

```dart
void _handleJavaScriptMessage(String message) {
  try {
    final data = json.decode(message);
    final action = data['action'] as String?;

    if (action == null) {
      debugPrint('WebView: Missing action in message');
      return;
    }

    switch (action) {
      // ... handle actions
      default:
        debugPrint('WebView: Unhandled action: $action');
    }
  } catch (e) {
    debugPrint('WebView: JavaScript message parsing error: $e');
  }
}
```

---

## 版本控制

**文件版本**: 1.0.0
**最後更新**: 2025-01-06
**適用專案**: tklabAppV2

---

## 擴展 Actions

如需新增自訂 Action，請遵循以下步驟：

1. 在本文檔新增 Action 定義
2. 在 `webview_screen.dart` 的 `_handleJavaScriptMessage` 方法中新增 case
3. 更新 `WEBVIEW_USAGE_EXAMPLES.md` 中的使用範例
4. 通知後端團隊更新網頁端程式碼

---

## 相關文件

- `WEBVIEW_USAGE_EXAMPLES.md` - WebView 使用範例
- `PHASE_3.1_COMPLETION.md` - Phase 3.1 完成總結
- `webview_screen.dart` - WebView 畫面實作
- `webview_config.dart` - WebView 配置工具
- `webview_advanced_config.dart` - 進階 WebView 配置
