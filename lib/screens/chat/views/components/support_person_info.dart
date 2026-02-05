import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/components/chat_active_dot.dart';
import 'package:tklab_ec_v2/components/network_image_with_loader.dart';
import 'package:tklab_ec_v2/services/chat_polling_service.dart';

class SupportPersonInfo extends StatelessWidget {
  const SupportPersonInfo({
    super.key,
    required this.image,
    required this.name,
    required this.connectionState,
    this.isTyping = false,
  });

  final String image, name;
  final ChatConnectionState connectionState;
  final bool isTyping;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).iconTheme.color!.withValues(alpha: 0.05),
      child: ListTile(
        title: Row(
          children: [
            Text("$name "),
            _buildStatusText(),
          ],
        ),
        minLeadingWidth: 24,
        leading: CircleAvatar(
          radius: 12,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              NetworkImageWithLoader(
                image,
                radius: 40,
              ),
              if (_isActive)
                const Positioned(
                  right: -4,
                  top: -4,
                  child: ChatActiveDot(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 判斷是否為活躍狀態
  bool get _isActive => connectionState == ChatConnectionState.connected;

  /// 根據連線狀態建立狀態文字
  Widget _buildStatusText() {
    if (isTyping && connectionState == ChatConnectionState.connected) {
      return const Text(
        "輸入中...",
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }

    switch (connectionState) {
      case ChatConnectionState.connected:
        return const Text(
          "線上",
          style: TextStyle(color: Colors.green),
        );
      case ChatConnectionState.connecting:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("連線中"),
            const SizedBox(width: 4),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
              ),
            ),
          ],
        );
      case ChatConnectionState.reconnecting:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("重新連線中"),
            const SizedBox(width: 4),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
              ),
            ),
          ],
        );
      case ChatConnectionState.disconnected:
        return const Text(
          "離線",
          style: TextStyle(color: Colors.grey),
        );
    }
  }
}
