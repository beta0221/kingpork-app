import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tklab_ec_v2/models/chat_models.dart';

import '../../../../constants.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({
    super.key,
    required this.message,
    required this.isSent,
    this.isRead = false,
    this.isSender = false,
    required this.time,
    this.isShowTime = true,
    this.status,
    this.onRetry,
  });

  final String message, time;
  final bool isSent, isRead, isSender, isShowTime;
  final MessageStatus? status;
  final VoidCallback? onRetry;

  /// 從 ChatMessage 模型建立 TextMessage
  factory TextMessage.fromChatMessage(
    ChatMessage chatMessage, {
    bool isShowTime = true,
    VoidCallback? onRetry,
  }) {
    return TextMessage(
      message: chatMessage.message,
      time: _formatTime(chatMessage.createdAt),
      isSender: chatMessage.isFromUser,
      isSent: chatMessage.status == MessageStatus.sent || chatMessage.status == MessageStatus.read,
      isRead: chatMessage.status == MessageStatus.read,
      isShowTime: isShowTime,
      status: chatMessage.status,
      onRetry: onRetry,
    );
  }

  /// 格式化時間顯示
  static String _formatTime(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(defaultPadding, defaultPadding, defaultPadding / 2, 0),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isSender
                  ? (status == MessageStatus.failed ? errorColor.withValues(alpha: 0.8) : primaryColor)
                  : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(defaultBorderRadious),
                topRight: const Radius.circular(defaultBorderRadious),
                bottomLeft: Radius.circular(isSender ? defaultBorderRadious : 0),
                bottomRight: Radius.circular(isSender ? 0 : defaultBorderRadious),
              ),
            ),
            child: Column(
              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isSender ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                if (isSender)
                  Column(
                    children: [
                      const SizedBox(height: defaultPadding / 4),
                      _buildStatusIndicator(),
                    ],
                  ),
                if (!isSent & !isRead) const SizedBox(height: defaultPadding / 4),
                const SizedBox(height: defaultPadding / 2),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding / 4),
          // 時間和重試按鈕
          if (isShowTime || status == MessageStatus.failed)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isShowTime)
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (status == MessageStatus.failed && onRetry != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onRetry,
                    child: const Text(
                      '重試',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: errorColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          if (isShowTime || status == MessageStatus.failed) const SizedBox(height: defaultPadding / 2),
        ],
      ),
    );
  }

  /// 建立訊息狀態指示器
  Widget _buildStatusIndicator() {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        );
      case MessageStatus.failed:
        return const Icon(
          Icons.error_outline,
          size: 16,
          color: Colors.white,
        );
      case MessageStatus.read:
        return SvgPicture.asset(
          "assets/icons/Doublecheck.svg",
          height: 16,
        );
      case MessageStatus.sent:
      default:
        if (isSent && !isRead) {
          return SvgPicture.asset(
            "assets/icons/Singlecheck.svg",
            height: 16,
          );
        }
        if (isSent && isRead) {
          return SvgPicture.asset(
            "assets/icons/Doublecheck.svg",
            height: 16,
          );
        }
        return const SizedBox.shrink();
    }
  }
}
