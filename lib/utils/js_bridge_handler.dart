import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:url_launcher/url_launcher.dart';
import '/route/route_constants.dart';

/// JavaScript Bridge 處理器
/// 統一處理來自 WebView 的 JavaScript 訊息
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

  JsBridgeHandler({
    required this.context,
    this.onReload,
    this.onLoadUrl,
    this.onCanGoBack,
    this.onGoBack,
    this.onGoHome,
    this.onClose,
    this.onGoMemberEdit,
    this.onLogin,
    this.onLogout,
    this.onCartCountUpdate,
    this.onTitleUpdate,
    this.onShowToast,
  });

  /// 處理來自 JavaScript 的訊息
  Future<void> handle(String message) async {
    try {
      final data = json.decode(message) as Map<String, dynamic>;
      final action = data['action'] as String?;

      if (action == null) {
        debugPrint('JS Bridge: Missing action in message');
        return;
      }

      debugPrint('JS Bridge: Handling action: $action');

      switch (action) {
        // ===== 頁面操作類 =====
        case 'reload':
          await _handleReload();
          break;

        case 'loadurl':
          await _handleLoadUrl(data);
          break;

        // ===== 導航類 =====
        case 'go_to_home':
          _handleGoHome();
          break;

        case 'go_back':
          await _handleGoBack();
          break;

        case 'close':
          _handleClose();
          break;

        case 'go_member_edit':
          _handleGoMemberEdit();
          break;

        case 'open_new_webview':
          await _handleOpenNewWebView(data);
          break;

        case 'open_web_dialog':
          await _handleOpenDialog(data);
          break;

        // ===== 認證類 =====
        case 'login':
          await _handleLogin();
          break;

        case 'logout':
          await _handleLogout();
          break;

        // ===== 資料同步類 =====
        case 'getCount':
          await _handleGetCount();
          break;

        case 'set_title':
          _handleSetTitle(data);
          break;

        // ===== UI 互動類 =====
        case 'toast':
          _handleToast(data);
          break;

        case 'share':
          await _handleShare(data);
          break;

        case 'copy_to_clipboard':
          await _handleCopyToClipboard(data);
          break;

        case 'vibrate':
          await _handleVibrate(data);
          break;

        // ===== 外部開啟類 =====
        case 'launch':
        case 'open_external_browser':
          await _handleLaunch(data);
          break;

        // ===== 訂單相關 =====
        case 'order_comment':
          await _handleOrderComment(data);
          break;

        case 'returnOrder':
          await _handleReturnOrder(data);
          break;

        // ===== 支付相關 =====
        case 'line_pay_open':
          await _handleLinePayOpen(data);
          break;

        // ===== 其他 =====
        case 'agree_open':
          await _handleAgreeOpen(data);
          break;

        default:
          debugPrint('JS Bridge: Unhandled action: $action');
          _showUnhandledActionWarning(action);
      }
    } catch (e) {
      debugPrint('JS Bridge: Error handling message: $e');
      debugPrint('JS Bridge: Original message: $message');
    }
  }

  // ==================== 頁面操作類處理器 ====================

  Future<void> _handleReload() async {
    if (onReload != null) {
      await onReload!();
      debugPrint('JS Bridge: Page reloaded');
    }
  }

  Future<void> _handleLoadUrl(Map<String, dynamic> data) async {
    final url = data['url'] as String?;
    if (url != null && onLoadUrl != null) {
      await onLoadUrl!(url);
      debugPrint('JS Bridge: Loading URL: $url');
    } else {
      debugPrint('JS Bridge: Missing URL in loadurl action');
    }
  }

  // ==================== 導航類處理器 ====================

  void _handleGoHome() {
    if (onGoHome != null) {
      onGoHome!();
    } else if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    debugPrint('JS Bridge: Navigating to home');
  }

  Future<void> _handleGoBack() async {
    if (onGoBack != null) {
      await onGoBack!();
    } else if (context.mounted) {
      // 檢查 WebView 是否可以返回
      if (onCanGoBack != null) {
        final canGoBack = await onCanGoBack!();
        if (canGoBack) {
          // WebView 內部返回
          return;
        }
      }
      // 關閉 WebView 畫面
      Navigator.of(context).pop();
    }
    debugPrint('JS Bridge: Go back');
  }

  void _handleClose() {
    if (onClose != null) {
      onClose!();
    } else if (context.mounted) {
      Navigator.of(context).pop();
    }
    debugPrint('JS Bridge: Closing WebView');
  }

  void _handleGoMemberEdit() {
    if (onGoMemberEdit != null) {
      onGoMemberEdit!();
    } else if (context.mounted) {
      Navigator.pushNamed(context, editUserInfoScreenRoute);
    }
    debugPrint('JS Bridge: Navigating to member edit');
  }

  Future<void> _handleOpenNewWebView(Map<String, dynamic> data) async {
    final url = data['url'] as String?;
    final title = data['title'] as String?;

    if (url != null && context.mounted) {
      await Navigator.pushNamed(
        context,
        webViewScreenRoute,
        arguments: {
          'url': url,
          'title': title,
        },
      );
      debugPrint('JS Bridge: Opened new WebView: $url');
    } else {
      debugPrint('JS Bridge: Missing URL in open_new_webview');
    }
  }

  Future<void> _handleOpenDialog(Map<String, dynamic> data) async {
    final url = data['url'] as String?;
    final title = data['title'] as String?;

    if (url == null || !context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // 標題列
              if (title != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              // WebView 內容（待實作）
              Expanded(
                child: Center(
                  child: Text('WebView Dialog: $url'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    debugPrint('JS Bridge: Opened web dialog: $url');
  }

  // ==================== 認證類處理器 ====================

  Future<void> _handleLogin() async {
    if (onLogin != null) {
      await onLogin!();
    } else if (context.mounted) {
      final result = await Navigator.pushNamed(context, logInScreenRoute);
      if (result == true && onReload != null) {
        // 登入成功後重新載入頁面
        await onReload!();
      }
    }
    debugPrint('JS Bridge: Login triggered');
  }

  Future<void> _handleLogout() async {
    if (onLogout != null) {
      await onLogout!();
    } else if (context.mounted) {
      // 顯示登出確認對話框
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('確認登出'),
          content: const Text('確定要登出嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('確定'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // 執行登出邏輯（待整合 MemberViewModel）
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    }
    debugPrint('JS Bridge: Logout triggered');
  }

  // ==================== 資料同步類處理器 ====================

  Future<void> _handleGetCount() async {
    // 從 CartProvider 取得購物車數量
    // 然後透過 JavaScript 發送回網頁
    // TODO: 整合 CartViewModel
    debugPrint('JS Bridge: Get cart count requested');

    if (onCartCountUpdate != null) {
      // 假設從 Provider 取得數量
      onCartCountUpdate!(0); // 暫時返回 0
    }
  }

  void _handleSetTitle(Map<String, dynamic> data) {
    final title = data['title'] as String?;
    if (title != null && onTitleUpdate != null) {
      onTitleUpdate!(title);
      debugPrint('JS Bridge: Title updated: $title');
    }
  }

  // ==================== UI 互動類處理器 ====================

  void _handleToast(Map<String, dynamic> data) {
    final message = data['message'] as String?;
    final duration = data['duration'] as int?;

    if (message != null) {
      if (onShowToast != null) {
        onShowToast!(message, duration: duration);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: Duration(milliseconds: duration ?? 2000),
          ),
        );
      }
      debugPrint('JS Bridge: Toast: $message');
    }
  }

  Future<void> _handleShare(Map<String, dynamic> data) async {
    final shareData = data['data'] as Map<String, dynamic>?;

    if (shareData != null) {
      final title = shareData['title'] as String? ?? '';
      final url = shareData['url'] as String? ?? '';
      final description = shareData['description'] as String? ?? '';

      final shareText = '$title\n$description\n$url'.trim();

      await share_plus.Share.share(shareText);
      debugPrint('JS Bridge: Shared: $shareText');
    } else {
      debugPrint('JS Bridge: Missing share data');
    }
  }

  Future<void> _handleCopyToClipboard(Map<String, dynamic> data) async {
    final text = data['text'] as String?;

    if (text != null) {
      await Clipboard.setData(ClipboardData(text: text));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已複製到剪貼簿')),
        );
      }
      debugPrint('JS Bridge: Copied to clipboard: $text');
    }
  }

  Future<void> _handleVibrate(Map<String, dynamic> data) async {
    await HapticFeedback.mediumImpact();
    debugPrint('JS Bridge: Vibrate triggered');
  }

  // ==================== 外部開啟類處理器 ====================

  Future<void> _handleLaunch(Map<String, dynamic> data) async {
    final url = data['url'] as String?;

    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('JS Bridge: Launched external URL: $url');
      } else {
        debugPrint('JS Bridge: Cannot launch URL: $url');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('無法開啟此連結')),
          );
        }
      }
    }
  }

  // ==================== 訂單相關處理器 ====================

  Future<void> _handleOrderComment(Map<String, dynamic> data) async {
    final orderId = data['orderId'] ?? data['order_id'];
    debugPrint('JS Bridge: Order comment for order: $orderId');

    // TODO: 導航到訂單評論頁面
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('訂單評論功能待實作')),
      );
    }
  }

  Future<void> _handleReturnOrder(Map<String, dynamic> data) async {
    final orderId = data['orderId'] ?? data['order_id'];
    debugPrint('JS Bridge: Return order: $orderId');

    // TODO: 導航到訂單退貨頁面
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('訂單退貨功能待實作')),
      );
    }
  }

  // ==================== 支付相關處理器 ====================

  Future<void> _handleLinePayOpen(Map<String, dynamic> data) async {
    final url = data['url'] as String?;
    debugPrint('JS Bridge: LINE Pay: $url');

    // TODO: 開啟 LINE Pay 流程
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LINE Pay 功能待實作')),
      );
    }
  }

  // ==================== 其他處理器 ====================

  Future<void> _handleAgreeOpen(Map<String, dynamic> data) async {
    final url = data['url'] as String?;
    debugPrint('JS Bridge: Agree open: $url');

    // TODO: 開啟訂閱頁面
    if (url != null && context.mounted) {
      await Navigator.pushNamed(
        context,
        webViewScreenRoute,
        arguments: {
          'url': url,
          'title': '訂閱條款',
        },
      );
    }
  }

  // ==================== 輔助方法 ====================

  void _showUnhandledActionWarning(String action) {
    if (context.mounted) {
      // 僅在開發模式顯示警告
      assert(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('未處理的 Action: $action')),
        );
        return true;
      }());
    }
  }
}
