import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '/utils/token_manager.dart';
import '/config/flavor_config.dart';

/// 進階 WebView 配置工具類別
/// 使用 flutter_inappwebview 提供更強大的功能
class WebViewAdvancedConfig {
  /// InAppWebView 的標準設定
  static InAppWebViewSettings getDefaultSettings() {
    return InAppWebViewSettings(
      // 基本設定
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,

      // JavaScript 設定
      javaScriptEnabled: true,
      javaScriptCanOpenWindowsAutomatically: true,

      // 快取設定
      cacheEnabled: true,
      clearCache: false,

      // 縮放設定
      supportZoom: true,
      builtInZoomControls: true,
      displayZoomControls: false,

      // 文字設定
      textZoom: 100,
      minimumFontSize: 0,

      // 安全性設定
      allowFileAccessFromFileURLs: false,
      allowUniversalAccessFromFileURLs: false,

      // 其他設定
      transparentBackground: false,
      disableHorizontalScroll: false,
      disableVerticalScroll: false,

      // 平台特定設定
      useHybridComposition: true, // Android
      allowsBackForwardNavigationGestures: true, // iOS
    );
  }

  /// 建立帶 Token 的 URL
  static Future<String> buildAuthenticatedUrl(String path) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getAccessToken() ?? '';
    final baseUrl = FlavorConfig.instance.baseUrl;

    // 處理路徑正規化
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    // 智能分隔符選擇
    final separator = normalizedPath.contains('?') ? '&' : '?';

    return '$baseUrl$normalizedPath${separator}app=true&token=$token';
  }

  /// 建立初始選項配置
  /// Note: InAppWebViewInitialOptions 已棄用，現在直接使用 InAppWebViewSettings
  static InAppWebViewSettings getInitialOptions({
    Color? backgroundColor,
    InAppWebViewSettings? customSettings,
  }) {
    return customSettings ?? getDefaultSettings();
  }

  /// URL 過濾邏輯
  static NavigationActionPolicy shouldAllowNavigation(String url) {
    // 阻止 App Store 連結
    if (url.contains('apps.apple.com') ||
        url.contains('itunes.apple.com') ||
        url.contains('play.google.com')) {
      debugPrint('WebView: Blocked app store navigation to $url');
      return NavigationActionPolicy.CANCEL;
    }

    // 阻止特定支付 URL scheme
    if (url.startsWith('upwrp://') ||
        url.startsWith('gwpay://') ||
        url.startsWith('payment://')) {
      debugPrint('WebView: Blocked payment scheme $url');
      return NavigationActionPolicy.CANCEL;
    }

    // 允許一般導航
    return NavigationActionPolicy.ALLOW;
  }

  /// Cookie 管理工具
  static Future<void> setCookie({
    required String url,
    required String name,
    required String value,
    String? domain,
    String? path,
    int? expiresDate,
    int? maxAge,
    bool? isSecure,
    bool? isHttpOnly,
    HTTPCookieSameSitePolicy? sameSite,
  }) async {
    final cookieManager = CookieManager.instance();

    await cookieManager.setCookie(
      url: WebUri(url),
      name: name,
      value: value,
      domain: domain,
      path: path ?? '/',
      expiresDate: expiresDate,
      maxAge: maxAge,
      isSecure: isSecure,
      isHttpOnly: isHttpOnly,
      sameSite: sameSite ?? HTTPCookieSameSitePolicy.LAX,
    );
  }

  /// 清除所有 Cookie
  static Future<void> clearAllCookies() async {
    final cookieManager = CookieManager.instance();
    await cookieManager.deleteAllCookies();
  }

  /// 清除特定網域的 Cookie
  static Future<void> clearCookiesForDomain(String domain) async {
    final cookieManager = CookieManager.instance();
    final cookies = await cookieManager.getCookies(url: WebUri(domain));

    for (var cookie in cookies) {
      await cookieManager.deleteCookie(
        url: WebUri(domain),
        name: cookie.name,
      );
    }
  }

  /// 清除快取
  static Future<void> clearCache() async {
    final webStorageManager = WebStorageManager.instance();
    await webStorageManager.deleteAllData();
  }

  /// 執行 JavaScript 並取得結果
  static Future<dynamic> evaluateJavaScript(
    InAppWebViewController controller,
    String script,
  ) async {
    try {
      final result = await controller.evaluateJavascript(source: script);
      return result;
    } catch (e) {
      debugPrint('WebView: JavaScript evaluation error: $e');
      return null;
    }
  }

  /// 注入 JavaScript 檔案
  static Future<void> injectJavaScriptFile(
    InAppWebViewController controller,
    String filePath,
  ) async {
    try {
      await controller.injectJavascriptFileFromAsset(assetFilePath: filePath);
    } catch (e) {
      debugPrint('WebView: JavaScript file injection error: $e');
    }
  }

  /// 注入 CSS
  static Future<void> injectCSS(
    InAppWebViewController controller,
    String css,
  ) async {
    try {
      await controller.injectCSSCode(source: css);
    } catch (e) {
      debugPrint('WebView: CSS injection error: $e');
    }
  }

  /// 注入 CSS 檔案
  static Future<void> injectCSSFile(
    InAppWebViewController controller,
    String filePath,
  ) async {
    try {
      await controller.injectCSSFileFromAsset(assetFilePath: filePath);
    } catch (e) {
      debugPrint('WebView: CSS file injection error: $e');
    }
  }

  /// 截圖功能
  static Future<Uint8List?> takeScreenshot(
    InAppWebViewController controller,
  ) async {
    try {
      final screenshot = await controller.takeScreenshot();
      return screenshot;
    } catch (e) {
      debugPrint('WebView: Screenshot error: $e');
      return null;
    }
  }

  /// 取得頁面標題
  static Future<String?> getTitle(InAppWebViewController controller) async {
    try {
      final title = await controller.getTitle();
      return title;
    } catch (e) {
      debugPrint('WebView: Get title error: $e');
      return null;
    }
  }

  /// 取得當前 URL
  static Future<String?> getCurrentUrl(
    InAppWebViewController controller,
  ) async {
    try {
      final url = await controller.getUrl();
      return url?.toString();
    } catch (e) {
      debugPrint('WebView: Get URL error: $e');
      return null;
    }
  }

  /// 列印頁面（僅限 iOS）
  static Future<void> printPage(InAppWebViewController controller) async {
    try {
      await controller.printCurrentPage();
    } catch (e) {
      debugPrint('WebView: Print page error: $e');
    }
  }

  /// 縮放頁面
  static Future<void> zoomBy(
    InAppWebViewController controller,
    double zoomFactor,
  ) async {
    try {
      await controller.zoomBy(
        zoomFactor: zoomFactor,
        animated: true,
      );
    } catch (e) {
      debugPrint('WebView: Zoom error: $e');
    }
  }

  /// 取得縮放比例
  static Future<double?> getZoomScale(
    InAppWebViewController controller,
  ) async {
    try {
      final scale = await controller.getZoomScale();
      return scale;
    } catch (e) {
      debugPrint('WebView: Get zoom scale error: $e');
      return null;
    }
  }

  /// 停止載入
  static Future<void> stopLoading(InAppWebViewController controller) async {
    try {
      await controller.stopLoading();
    } catch (e) {
      debugPrint('WebView: Stop loading error: $e');
    }
  }

  /// 重新載入
  static Future<void> reload(InAppWebViewController controller) async {
    try {
      await controller.reload();
    } catch (e) {
      debugPrint('WebView: Reload error: $e');
    }
  }

  /// 前往上一頁
  static Future<void> goBack(InAppWebViewController controller) async {
    try {
      if (await controller.canGoBack()) {
        await controller.goBack();
      }
    } catch (e) {
      debugPrint('WebView: Go back error: $e');
    }
  }

  /// 前往下一頁
  static Future<void> goForward(InAppWebViewController controller) async {
    try {
      if (await controller.canGoForward()) {
        await controller.goForward();
      }
    } catch (e) {
      debugPrint('WebView: Go forward error: $e');
    }
  }

  /// 檢查是否可以返回
  static Future<bool> canGoBack(InAppWebViewController controller) async {
    try {
      return await controller.canGoBack();
    } catch (e) {
      debugPrint('WebView: Can go back check error: $e');
      return false;
    }
  }

  /// 檢查是否可以前進
  static Future<bool> canGoForward(InAppWebViewController controller) async {
    try {
      return await controller.canGoForward();
    } catch (e) {
      debugPrint('WebView: Can go forward check error: $e');
      return false;
    }
  }

  /// 取得載入進度
  static Stream<int> getProgressStream(InAppWebViewController controller) {
    // Note: 需要在 InAppWebView 的 onProgressChanged 回調中更新
    // 這裡提供介面定義，實際實作在 WebView Widget 中
    throw UnimplementedError('Use onProgressChanged callback in InAppWebView');
  }

  /// 建立 User-Agent 字串
  static String buildUserAgent({
    required String appVersion,
    String? customSuffix,
  }) {
    final suffix = customSuffix ?? 'TKLabApp';
    return 'Mozilla/5.0 (Mobile; $suffix/$appVersion)';
  }

  /// 取得 HTTP 認證憑證（用於 onReceivedHttpAuthRequest）
  static URLAuthenticationChallenge? getHttpAuthCredential({
    required String username,
    required String password,
  }) {
    // Note: 實際使用時需要在 onReceivedHttpAuthRequest 回調中處理
    // 這裡提供介面定義
    debugPrint('WebView: HTTP auth with username: $username');
    return null;
  }

  /// 處理檔案選擇（用於檔案上傳）
  static Future<void> handleFileChooser({
    required InAppWebViewController controller,
  }) async {
    // Note: 實作檔案選擇邏輯
    // 可以使用 file_picker 套件
    // 在 InAppWebView 的 onCreateWindow 或檔案上傳事件中調用
    debugPrint('WebView: File chooser not implemented');
  }
}

/// JavaScript Handler 包裝類別
/// 用於封裝 JavaScript 處理邏輯
class JavaScriptHandler {
  final String name;
  final Function(List<dynamic>) callback;

  const JavaScriptHandler({
    required this.name,
    required this.callback,
  });

  /// 執行回調
  void execute(List<dynamic> args) {
    callback(args);
  }
}

/// WebView 狀態追蹤器
class WebViewStateTracker {
  int progress = 0;
  String? currentUrl;
  String? currentTitle;
  bool isLoading = false;
  bool canGoBack = false;
  bool canGoForward = false;

  void reset() {
    progress = 0;
    currentUrl = null;
    currentTitle = null;
    isLoading = false;
    canGoBack = false;
    canGoForward = false;
  }

  @override
  String toString() {
    return 'WebViewState(progress: $progress%, url: $currentUrl, '
        'title: $currentTitle, loading: $isLoading, '
        'canGoBack: $canGoBack, canGoForward: $canGoForward)';
  }
}
