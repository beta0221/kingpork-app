import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  });

  final String message, time;
  final bool isSent, isRead, isSender, isShowTime;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
                defaultPadding, defaultPadding, defaultPadding / 2, 0),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isSender
                  ? primaryColor
                  : Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(defaultBorderRadious),
                topRight: const Radius.circular(defaultBorderRadious),
                bottomLeft:
                    Radius.circular(isSender ? defaultBorderRadious : 0),
                bottomRight:
                    Radius.circular(isSender ? 0 : defaultBorderRadious),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                      color: isSender
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge!.color),
                ),
                if (isSender)
                  Column(
                    children: [
                      const SizedBox(height: defaultPadding / 4),
                      if (isSent & !isRead)
                        SvgPicture.asset(
                          "assets/icons/Singlecheck.svg",
                          height: 16,
                        ),
                      if (isSent & isRead)
                        SvgPicture.asset(
                          "assets/icons/Doublecheck.svg",
                          height: 16,
                        ),
                    ],
                  ),
                if (!isSent & !isRead)
                  const SizedBox(height: defaultPadding / 4),
                const SizedBox(height: defaultPadding / 2),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding / 4),
          if (isShowTime)
            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (isShowTime) const SizedBox(height: defaultPadding / 2),
        ],
      ),
    );
  }
}
