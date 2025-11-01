import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '/utils/webview_config.dart';
import '/utils/js_bridge_handler.dart';
import '/screens/webview/components/webview_loading.dart';

/// TKLab 可重用 WebView 元件
/// 提供統一的 WebView 介面，整合 JS Bridge 和標準配置
class TkWebView extends StatefulWidget {
  /// 要載入的 URL 路徑
  /// - 相對路徑（如 /category/skincare）：會自動加上 baseUrl 和 token
  /// - 絕對路徑（如 https://www.apple.com）：直接載入，不添加 token
  final String? url;

  /// 要載入的 HTML 字串內容（與 url 互斥，優先使用）
  final String? htmlContent;

  /// 載入 HTML 時的 baseUrl（用於解析相對資源）
  final String? htmlBaseUrl;

  /// 是否顯示載入中指示器
  final bool showLoading;

  /// 載入中訊息
  final String? loadingMessage;

  /// JavaScript 訊息回調
  /// 如果提供此回調，則不使用預設的 JsBridgeHandler
  final Function(String action, Map<String, dynamic> data)? onJsMessage;

  /// WebView 控制器創建完成回調
  final Function(WebViewController controller)? onControllerCreated;

  /// 頁面載入開始回調
  final Function(String url)? onPageStarted;

  /// 頁面載入完成回調
  final Function(String url)? onPageFinished;

  /// 頁面載入進度回調（0-100）
  final Function(int progress)? onProgress;

  /// 背景顏色
  final Color? backgroundColor;

  /// 是否啟用 JavaScript
  final bool enableJavaScript;

  /// 自訂 JsBridgeHandler 回調
  final JsBridgeHandler Function(BuildContext context)? bridgeHandlerBuilder;

  /// 自定義手勢識別器
  /// 如果不提供，將使用默認手勢配置（支持垂直/水平滾動、點擊、長按、縮放）
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const TkWebView({
    super.key,
    this.url,
    this.htmlContent,
    this.htmlBaseUrl,
    this.showLoading = true,
    this.loadingMessage,
    this.onJsMessage,
    this.onControllerCreated,
    this.onPageStarted,
    this.onPageFinished,
    this.onProgress,
    this.backgroundColor,
    this.enableJavaScript = true,
    this.bridgeHandlerBuilder,
    this.gestureRecognizers,
  }) : assert(
          url != null || htmlContent != null,
          'Either url or htmlContent must be provided',
        );

  @override
  State<TkWebView> createState() => _TkWebViewState();
}

class _TkWebViewState extends State<TkWebView> {
  late WebViewController _controller;
  late JsBridgeHandler _bridgeHandler;
  bool _isLoading = true;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initBridgeHandler();
    _initController();
  }

  void _initBridgeHandler() {
    if (widget.bridgeHandlerBuilder != null) {
      _bridgeHandler = widget.bridgeHandlerBuilder!(context);
    } else {
      _bridgeHandler = JsBridgeHandler(
        context: context,
        onReload: () async {
          await _controller.reload();
        },
        onLoadUrl: (url) async {
          final fullUrl = await WebViewConfig.buildAuthenticatedUrl(url);
          await _controller.loadRequest(Uri.parse(fullUrl));
        },
        onCanGoBack: () async {
          return await _controller.canGoBack();
        },
        onGoBack: () async {
          if (await _controller.canGoBack()) {
            await _controller.goBack();
          }
        },
      );
    }
  }

  Future<void> _initController() async {
    _controller = await WebViewConfig.createController(
      url: widget.url,
      htmlContent: widget.htmlContent,
      htmlBaseUrl: widget.htmlBaseUrl,
      onJsMessage: _handleJavaScriptMessage,
      backgroundColor: widget.backgroundColor ?? const Color(0xFFFFFFFF),
      enableJavaScript: widget.enableJavaScript,
    );

    // 設定頁面載入監聽
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (url) {
          if (widget.onPageStarted != null) {
            widget.onPageStarted!(url);
          }
        },
        onPageFinished: (url) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          if (widget.onPageFinished != null) {
            widget.onPageFinished!(url);
          }
        },
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _loadingProgress = progress;
            });
          }
          if (widget.onProgress != null) {
            widget.onProgress!(progress);
          }
        },
        onNavigationRequest: (request) {
          // URL 過濾邏輯
          final url = request.url;
          if (url.contains('apps.apple.com') ||
              url.contains('play.google.com')) {
            return NavigationDecision.prevent;
          }
          if (url.startsWith('upwrp://') || url.startsWith('gwpay://')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );

    if (widget.onControllerCreated != null) {
      widget.onControllerCreated!(_controller);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _handleJavaScriptMessage(String message) {
    if (widget.onJsMessage != null) {
      // 使用自訂回調
      try {
        final data = json.decode(message) as Map<String, dynamic>;
        final action = data['action'] as String? ?? '';
        widget.onJsMessage!(action, data);
      } catch (e) {
        debugPrint('TkWebView: Failed to parse JS message: $e');
      }
    } else {
      // 使用預設的 JsBridgeHandler
      _bridgeHandler.handle(message);
    }
  }

  /// 默認手勢識別器配置
  /// 支持垂直滾動、水平滾動、點擊、長按、縮放
  Set<Factory<OneSequenceGestureRecognizer>> _defaultGestureRecognizers() {
    return {
      Factory<VerticalDragGestureRecognizer>(
        () => VerticalDragGestureRecognizer(),
      ),
      Factory<HorizontalDragGestureRecognizer>(
        () => HorizontalDragGestureRecognizer(),
      ),
      Factory<TapGestureRecognizer>(
        () => TapGestureRecognizer(),
      ),
      Factory<LongPressGestureRecognizer>(
        () => LongPressGestureRecognizer(),
      ),
      Factory<ScaleGestureRecognizer>(
        () => ScaleGestureRecognizer(),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.showLoading) {
      return WebViewLoading(
        message: widget.loadingMessage ?? '載入中...',
        progress: _loadingProgress,
      );
    }

    return WebViewWidget(
      controller: _controller,
      gestureRecognizers: widget.gestureRecognizers ?? _defaultGestureRecognizers(),
    );
  }

  @override
  void dispose() {
    // WebViewController 不需要手動 dispose
    super.dispose();
  }
}
