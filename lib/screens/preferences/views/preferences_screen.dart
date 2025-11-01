import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/constants.dart';

import 'components/prederence_list_tile.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cookie 偏好設定"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("重設"),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: defaultPadding),
        child: Column(
          children: [
            PreferencesListTile(
              titleText: "分析",
              subtitleTxt:
                  "分析 Cookie 透過收集和報告您使用應用程式的資訊，幫助我們改善應用程式。它們以不直接識別任何人的方式收集資訊。",
              isActive: true,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "個人化",
              subtitleTxt:
                  "個人化 Cookie 收集您使用此應用程式的資訊，以顯示與您相關的內容和體驗。",
              isActive: false,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "行銷",
              subtitleTxt:
                  "行銷 Cookie 收集您使用此應用程式和其他應用程式的資訊，以便顯示與您更相關的廣告和其他行銷內容。",
              isActive: false,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "社群媒體 Cookie",
              subtitleTxt:
                  "這些 Cookie 由我們新增到網站的一系列社群媒體服務設定，讓您能夠與朋友和網路分享我們的內容。",
              isActive: false,
              press: () {},
            ),
          ],
        ),
      ),
    );
  }
}
