import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tklab_ec_v2/constants.dart';

import 'components/notification_card.dart';

// 假資料
final List<Map<String, dynamic>> _demoNotifications = [
  {
    "title": "限時優惠活動開跑！",
    "body": "全館商品 85 折起，滿千再折百！活動只到本週日，立即選購您喜愛的商品。",
    "imageUrl": "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800",
    "svgSrc": "assets/icons/Discount.svg",
    "iconBgColor": const Color(0xFFF3B923),
    "time": "2 分鐘前",
    "isRead": false,
  },
  {
    "title": "您的訂單已出貨",
    "body": "訂單編號 #20231128001 已由物流中心發出，預計 2-3 個工作天內送達。",
    "imageUrl": null,
    "svgSrc": "assets/icons/diamond.svg",
    "iconBgColor": primaryColor,
    "time": "1 小時前",
    "isRead": false,
  },
  {
    "title": "新品上市通知",
    "body": "2024 春季新品正式開賣！探索最新流行趨勢，打造專屬於您的時尚風格。",
    "imageUrl": "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800",
    "svgSrc": "assets/icons/Notification.svg",
    "iconBgColor": const Color(0xFF4CAF50),
    "time": "3 小時前",
    "isRead": false,
  },
  {
    "title": "會員積分到帳",
    "body": "恭喜您！本次消費獲得 150 積分，目前累積 2,350 積分。",
    "imageUrl": null,
    "svgSrc": "assets/icons/diamond.svg",
    "iconBgColor": primaryColor,
    "time": "昨天",
    "isRead": true,
  },
  {
    "title": "專屬生日禮券已發放",
    "body": "親愛的會員，祝您生日快樂！我們為您準備了專屬的 \$200 生日禮券，有效期限 30 天。",
    "imageUrl": "https://images.unsplash.com/photo-1513885535751-8b9238bd345a?w=800",
    "svgSrc": "assets/icons/Discount.svg",
    "iconBgColor": const Color(0xFFE91E63),
    "time": "3 天前",
    "isRead": true,
  },
  {
    "title": "系統維護通知",
    "body": "本週六凌晨 2:00-4:00 進行系統維護，期間服務將暫停。",
    "imageUrl": null,
    "svgSrc": "assets/icons/Notification.svg",
    "iconBgColor": const Color(0xFF9E9E9E),
    "time": "5 天前",
    "isRead": true,
  },
];

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("通知"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/DotsV.svg",
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        // For no notification use
        // NoNotification()
        child: ListView.builder(
          itemCount: _demoNotifications.length,
          itemBuilder: (context, index) {
            final notification = _demoNotifications[index];
            return NotificationCard(
              title: notification["title"],
              body: notification["body"],
              imageUrl: notification["imageUrl"],
              svgSrc: notification["svgSrc"],
              iconBgColor: notification["iconBgColor"],
              time: notification["time"],
              isRead: notification["isRead"],
            );
          },
        ),
      ),
    );
  }
}
