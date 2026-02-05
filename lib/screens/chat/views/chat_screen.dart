import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/models/chat_models.dart';
import 'package:tklab_ec_v2/services/chat_polling_service.dart';
import 'package:tklab_ec_v2/viewmodels/chat_view_model.dart';

import 'components/chat_input_area.dart';
import 'components/support_person_info.dart';
import 'components/text_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ChatViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initialize();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // 停止 Long Polling 當離開頁面
    _viewModel.disconnect();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    final success = await context.read<ChatViewModel>().sendMessage(message);
    if (success) {
      // 發送成功後滾動到底部
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildAppBar(context, viewModel),
          body: _buildBody(context, viewModel),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, ChatViewModel viewModel) {
    return AppBar(
      title: const Text("客服聊天"),
      actions: [
        // 連線狀態指示器
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: _buildConnectionIndicator(viewModel.connectionState),
          ),
        ),
        IconButton(
          onPressed: () {
            // 顯示服務時間資訊
            _showServiceInfo(context);
          },
          icon: SvgPicture.asset(
            "assets/icons/info.svg",
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionIndicator(ChatConnectionState state) {
    Color color;
    String tooltip;

    switch (state) {
      case ChatConnectionState.connected:
        color = successColor;
        tooltip = '已連線';
        break;
      case ChatConnectionState.connecting:
        color = warningColor;
        tooltip = '連線中...';
        break;
      case ChatConnectionState.reconnecting:
        color = warningColor;
        tooltip = '重新連線中...';
        break;
      case ChatConnectionState.disconnected:
        color = errorColor;
        tooltip = '離線';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  void _showServiceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('服務時間'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('平日：09:30 ~ 20:30'),
            SizedBox(height: 8),
            Text('假日：13:00 ~ 17:00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChatViewModel viewModel) {
    // 處理初始化載入中狀態
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在連線...'),
          ],
        ),
      );
    }

    // 處理錯誤狀態
    if (viewModel.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage ?? '發生錯誤',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => viewModel.initialize(),
                icon: const Icon(Icons.refresh),
                label: const Text('重試'),
              ),
            ],
          ),
        ),
      );
    }

    // 成功狀態 - 顯示聊天界面
    return Column(
      children: [
        // 客服資訊
        SupportPersonInfo(
          image: "https://i.imgur.com/IXnwbLk.png",
          name: "TKLab 客服",
          connectionState: viewModel.connectionState,
          isTyping: viewModel.isTyping,
        ),

        // 連線狀態提示條
        _buildConnectionStatusBar(viewModel),

        // 訊息列表
        Expanded(
          child: _buildMessageList(viewModel),
        ),

        // 輸入區域
        ChatInputArea(
          controller: _messageController,
          onSend: _sendMessage,
          isEnabled: viewModel.connectionState == ChatConnectionState.connected,
        ),
      ],
    );
  }

  Widget _buildConnectionStatusBar(ChatViewModel viewModel) {
    if (viewModel.connectionState == ChatConnectionState.connected) {
      return const SizedBox.shrink();
    }

    String message;
    Color backgroundColor;
    Widget? action;

    switch (viewModel.connectionState) {
      case ChatConnectionState.connecting:
        message = '正在連線...';
        backgroundColor = warningColor.withValues(alpha: 0.2);
        break;
      case ChatConnectionState.reconnecting:
        message = '重新連線中...';
        backgroundColor = warningColor.withValues(alpha: 0.2);
        break;
      case ChatConnectionState.disconnected:
        message = '已斷線';
        backgroundColor = errorColor.withValues(alpha: 0.2);
        action = TextButton(
          onPressed: () => viewModel.reconnect(),
          child: const Text('重新連線'),
        );
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 8),
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (viewModel.connectionState != ChatConnectionState.disconnected)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (viewModel.connectionState != ChatConnectionState.disconnected) const SizedBox(width: 8),
          Text(message),
          if (action != null) ...[
            const Spacer(),
            action,
          ],
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatViewModel viewModel) {
    final messages = viewModel.messages;

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                '歡迎使用客服聊天！\n有任何問題都可以詢問我們',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 當訊息更新時滾動到底部
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showTime = _shouldShowTime(messages, index);

        return TextMessage.fromChatMessage(
          message,
          isShowTime: showTime,
          onRetry: message.status == MessageStatus.failed
              ? () => viewModel.retryMessage(message.id)
              : null,
        );
      },
    );
  }

  /// 判斷是否顯示時間（與上一則訊息間隔超過 5 分鐘才顯示）
  bool _shouldShowTime(List<ChatMessage> messages, int index) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    try {
      final currentTime = DateTime.parse(currentMessage.createdAt);
      final previousTime = DateTime.parse(previousMessage.createdAt);
      return currentTime.difference(previousTime).inMinutes >= 5;
    } catch (e) {
      return true;
    }
  }
}
