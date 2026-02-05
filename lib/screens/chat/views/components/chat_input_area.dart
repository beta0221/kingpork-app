import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/theme/input_decoration_theme.dart';

class ChatInputArea extends StatelessWidget {
  const ChatInputArea({
    super.key,
    required this.controller,
    required this.onSend,
    this.isEnabled = true,
    this.hintText = '輸入訊息...',
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isEnabled;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // 輸入框
            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: isEnabled,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) => _handleSend(),
                decoration: InputDecoration(
                  filled: false,
                  hintText: isEnabled ? hintText : '連線中...',
                  border: secodaryOutlineInputBorder(context),
                  enabledBorder: secodaryOutlineInputBorder(context),
                  focusedBorder: focusedOutlineInputBorder,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: defaultPadding / 2,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
              ),
            ),
            const SizedBox(width: defaultPadding / 2),
            // 發送按鈕
            _SendButton(
              onTap: _handleSend,
              isEnabled: isEnabled,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() {
    if (controller.text.trim().isNotEmpty && isEnabled) {
      onSend();
    }
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.onTap,
    required this.isEnabled,
  });

  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isEnabled ? primaryColor : greyColor,
      borderRadius: BorderRadius.circular(defaultBorderRadious),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            "assets/icons/Send.svg",
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
