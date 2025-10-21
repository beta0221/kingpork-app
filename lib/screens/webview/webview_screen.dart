import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:tklab_ec_v2/utils/webview_config.dart';
import 'package:tklab_ec_v2/utils/js_bridge_handler.dart';
import 'package:tklab_ec_v2/screens/webview/components/webview_loading.dart';

/// WebView Screen for displaying web content with JS Bridge integration
class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;
  final bool showAppBar;

  const WebViewScreen({
    super.key,
    required this.url,
    this.title,
    this.showAppBar = true,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _controller;
  late JsBridgeHandler _jsBridge;
  bool _isLoading = true;
  String? _pageTitle;

  @override
  void initState() {
    super.initState();
    _initializeJsBridge();
    _initializeWebView();
  }

  void _initializeJsBridge() {
    _jsBridge = JsBridgeHandler(
      context: context,
      // WebView 控制回調
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
      // 導航回調
      onGoHome: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      onClose: () {
        Navigator.of(context).pop();
      },
      // 資料同步回調
      onTitleUpdate: (title) {
        setState(() {
          _pageTitle = title;
        });
      },
      onShowToast: (message, {duration}) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: Duration(milliseconds: duration ?? 2000),
          ),
        );
      },
    );
  }

  Future<void> _initializeWebView() async {
    try {
      _controller = await WebViewConfig.createController(
        url: widget.url,
        onJsMessage: (message) {
          _jsBridge.handle(message);
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('WebView initialization error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final canGoBack = await _controller.canGoBack();
        if (canGoBack) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: Text(_pageTitle ?? widget.title ?? 'WebView'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      _controller.reload();
                    },
                  ),
                ],
              )
            : null,
        body: _isLoading
            ? const WebViewLoading(message: '載入中...')
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
