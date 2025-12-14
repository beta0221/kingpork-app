import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';
import 'package:tklab_ec_v2/viewmodels/member_view_model.dart';

import '../../profile/views/components/profile_card.dart';
import 'components/user_info_list_tile.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("個人資料"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, editUserInfoScreenRoute);
            },
            child: const Text("編輯"),
          )
        ],
      ),
      body: Consumer<MemberViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("請登入以檢視您的個人資料"),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, logInScreenRoute);
                    },
                    child: const Text("登入"),
                  ),
                ],
              ),
            );
          }

          final member = viewModel.currentMember;
          final name = member?.name ?? "N/A";
          final email = member?.email ?? "N/A";
          final phone = member?.mobile ?? "未提供";

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: defaultPadding),
                const ProfileCard(
                  useViewModel: true,
                  isShowHi: false,
                  isShowArrow: false,
                ),
                const SizedBox(height: defaultPadding * 1.5),
                UserInfoListTile(
                  leadingText: "姓名",
                  trailingText: name,
                ),
                const UserInfoListTile(
                  leadingText: "出生日期",
                  trailingText: "未提供",
                ),
                UserInfoListTile(
                  leadingText: "電話號碼",
                  trailingText: phone,
                ),
                const UserInfoListTile(
                  leadingText: "性別",
                  trailingText: "未提供",
                ),
                UserInfoListTile(
                  leadingText: "電子郵件",
                  trailingText: email,
                ),
                ListTile(
                  leading: const Text("密碼"),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, currentPasswordScreenRoute);
                    },
                    child: const Text("變更密碼"),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
