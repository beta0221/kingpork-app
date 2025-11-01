import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/constants.dart';

import 'components/cupertino_switch_divided_list_tile.dart';

class NotificationOptionsScreen extends StatelessWidget {
  const NotificationOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("通知"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("重設"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: defaultPadding),
        child: Column(
          children: [
            CupertinoSwitchDividedListTile(
              title: "允許通知",
              value: true,
              onChanged: (value) {},
            ),
            CupertinoSwitchDividedListTile(
              title: "折扣通知",
              subTitle: "接收有關促銷和折扣的通知。",
              value: true,
              onChanged: (value) {},
            ),
            CupertinoSwitchDividedListTile(
              title: "商店通知",
              subTitle: "接收來自商店的更新和消息。",
              value: false,
              onChanged: (value) {},
            ),
            CupertinoSwitchDividedListTile(
              title: "系統通知",
              subTitle: "接收系統更新和重要消息。",
              value: false,
              onChanged: (value) {},
            ),
            CupertinoSwitchDividedListTile(
              title: "位置通知",
              subTitle: "根據您的位置接收通知。",
              value: false,
              onChanged: (value) {},
            ),
            CupertinoSwitchDividedListTile(
              title: "付款通知",
              subTitle: "接收有關付款和交易的通知。",
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}
