import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:tklab_ec_v2/utils/token_manager.dart';
import 'package:tklab_ec_v2/config/flavor_config.dart';

/// WebView configuration utility
class WebViewConfig {
  static const String jsChannelName = 'webviewFlutterJavascriptChannel';

  /// Build authenticated URL with token
  ///
  /// Example:
  /// ```dart
  /// final url = await WebViewConfig.buildAuthenticatedUrl('/products');
  /// // Returns: https://rd.tklab.com.tw/products?app=true&token=xxx
  /// ```
  static Future<String> buildAuthenticatedUrl(String path) async {
    final tokenManager = TokenManager();
    final token = await tokenManager.getAccessToken() ?? '';
    final baseUrl = FlavorConfig.instance.baseUrl;

    // Ensure path starts with /
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    // Determine separator
    final separator = normalizedPath.contains('?') ? '&' : '?';

    return '$baseUrl$normalizedPath${separator}app=true&token=$token';
  }

  /// Create standard WebView controller
  ///
  /// Example:
  /// ```dart
  /// final controller = await WebViewConfig.createController(
  ///   url: '/products',
  ///   onJsMessage: (message) => print(message),
  /// );
  /// ```
  static Future<WebViewController> createController({
    required String url,
    required Function(String) onJsMessage,
    Color backgroundColor = const Color(0xFFFFFFFF),
    bool enableJavaScript = true,
  }) async {
    final fullUrl = await buildAuthenticatedUrl(url);

    final controller = WebViewController()
      ..setBackgroundColor(backgroundColor)
      ..setJavaScriptMode(
        enableJavaScript ? JavaScriptMode.unrestricted : JavaScriptMode.disabled,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('WebView: Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('WebView: Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView: Error occurred: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            return _shouldAllowNavigation(request.url);
          },
        ),
      )
      ..addJavaScriptChannel(
        jsChannelName,
        onMessageReceived: (JavaScriptMessage message) {
          onJsMessage(message.message);
        },
      );

    await controller.loadRequest(Uri.parse(fullUrl));
    return controller;
  }

  /// URL filtering logic
  ///
  /// Prevents navigation to:
  /// - App Store links
  /// - Play Store links
  /// - Payment URL schemes
  static NavigationDecision _shouldAllowNavigation(String url) {
    // Prevent App Store links
    if (url.contains('apps.apple.com') || url.contains('itunes.apple.com')) {
      debugPrint('WebView: Blocked App Store link: $url');
      return NavigationDecision.prevent;
    }

    // Prevent Play Store links
    if (url.contains('play.google.com')) {
      debugPrint('WebView: Blocked Play Store link: $url');
      return NavigationDecision.prevent;
    }

    // Prevent specific payment URL schemes
    if (url.startsWith('upwrp://') ||
        url.startsWith('gwpay://') ||
        url.startsWith('payment://')) {
      debugPrint('WebView: Blocked payment scheme: $url');
      return NavigationDecision.prevent;
    }

    // Allow other navigations
    return NavigationDecision.navigate;
  }

  /// Inject JavaScript code into WebView
  ///
  /// Example:
  /// ```dart
  /// await WebViewConfig.injectJavaScript(
  ///   controller,
  ///   'alert("Hello from Flutter!");',
  /// );
  /// ```
  static Future<void> injectJavaScript(
    WebViewController controller,
    String script,
  ) async {
    try {
      await controller.runJavaScript(script);
    } catch (e) {
      debugPrint('WebView: Failed to inject JavaScript: $e');
    }
  }

  /// Send message to web page via JavaScript
  ///
  /// Example:
  /// ```dart
  /// await WebViewConfig.sendMessageToWeb(
  ///   controller,
  ///   {'action': 'refresh', 'data': 'something'},
  /// );
  /// ```
  static Future<void> sendMessageToWeb(
    WebViewController controller,
    Map<String, dynamic> message,
  ) async {
    final script = '''
      if (window.receiveMessageFromFlutter) {
        window.receiveMessageFromFlutter(${_jsonEncode(message)});
      }
    ''';
    await injectJavaScript(controller, script);
  }

  /// Simple JSON encode for JavaScript injection
  static String _jsonEncode(Map<String, dynamic> data) {
    final buffer = StringBuffer('{');
    var first = true;
    data.forEach((key, value) {
      if (!first) buffer.write(',');
      buffer.write('"$key":');
      if (value is String) {
        buffer.write('"${value.replaceAll('"', '\\"')}"');
      } else if (value is num || value is bool) {
        buffer.write(value);
      } else {
        buffer.write('null');
      }
      first = false;
    });
    buffer.write('}');
    return buffer.toString();
  }
}
