import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/notification.png",
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 0,
                    child: SafeArea(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, preferredLanuageScreenRoute);
                        },
                        child: Text(
                          "跳過",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  children: [
                    Text(
                      "通知最新優惠和商品供應狀況",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: defaultPadding),
                    const Text(
                      "啟用通知功能，即可第一時間獲取最新資訊。",
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(defaultBorderRadious)),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/Notification.svg",
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).iconTheme.color!,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: defaultPadding),
                          Text(
                            "通知",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          CupertinoSwitch(
                            activeTrackColor: primaryColor,
                            onChanged: (value) {},
                            value: false,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, preferredLanuageScreenRoute);
                      },
                      child: const Text("下一步"),
                    ),
                    const SizedBox(height: defaultPadding),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
