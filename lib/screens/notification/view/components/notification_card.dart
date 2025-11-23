import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tklab_ec_v2/components/chat_active_dot.dart';
import 'package:tklab_ec_v2/components/network_image_with_loader.dart';
import 'package:tklab_ec_v2/constants.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.title,
    this.body,
    this.imageUrl,
    this.svgSrc = "assets/icons/Notification.svg",
    required this.time,
    this.isRead = false,
    this.press,
    this.iconBgColor = const Color(0xFFE5614F),
  });

  final String title, svgSrc, time;
  final String? body;
  final String? imageUrl;
  final bool isRead;
  final Color iconBgColor;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: 圖示、標題、時間
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading icon with unread dot
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: iconBgColor,
                      child: SvgPicture.asset(
                        svgSrc,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    if (!isRead)
                      const ChatActiveDot(
                        dotColor: Color(0xFFE5614F),
                      ),
                  ],
                ),
                const SizedBox(width: defaultPadding),
                // Title, body, time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (body != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          body!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Image (if provided)
          if (imageUrl != null && imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: defaultPadding,
                right: defaultPadding,
                bottom: defaultPadding,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: NetworkImageWithLoader(
                    imageUrl!,
                    fit: BoxFit.cover,
                    radius: 0,
                  ),
                ),
              ),
            ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
