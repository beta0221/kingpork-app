import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/components/chat_active_dot.dart';
import 'package:tklab_ec_v2/components/network_image_with_loader.dart';

class SupportPersonInfo extends StatelessWidget {
  const SupportPersonInfo({
    super.key,
    required this.image,
    required this.name,
    required this.isActive,
    required this.isConnected,
    this.isTyping = false,
  });

  final String image, name;
  final bool isActive, isConnected, isTyping;

  @override
  Widget build(BuildContext context) {
    return Container(
  color: Theme.of(context).iconTheme.color!.withValues(alpha: 0.05),
      child: ListTile(
        title: Row(
          children: [
            Text("$name is "),
            if (isConnected && !isTyping) const Text("線上"),
            if (isConnected && isTyping) const Text("輸入中..."),
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
              if (isActive)
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
}
