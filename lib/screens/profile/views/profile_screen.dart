import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/components/list_tile/divider_list_tile.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';
import 'package:tklab_ec_v2/viewmodels/member_view_model.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';
import 'components/rewards_card.dart';
import 'components/membership_level_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const ProfileCard(
            useViewModel: true,
            press: null, // Will be handled by separate logic
          ),
          // Edit Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding),
            child: Consumer<MemberViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoggedIn) {
                  return OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, userInfoScreenRoute);
                    },
                    child: const Text("查看個人資料"),
                  );
                }
                return OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, logInScreenRoute);
                  },
                  child: const Text("登入"),
                );
              },
            ),
          ),

          // Rewards Card (TK幣 & 現金券)
          const RewardsCard(),

          // Membership Level Card
          const MembershipLevelCard(),

          const SizedBox(height: defaultPadding / 2),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              "帳戶",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ProfileMenuListTile(
            text: "訂單",
            svgSrc: "assets/icons/Order.svg",
            press: () {
              Navigator.pushNamed(context, ordersScreenRoute);
            },
          ),
          // ProfileMenuListTile(
          //   text: "退貨",
          //   svgSrc: "assets/icons/Return.svg",
          //   press: () {},
          // ),
          ProfileMenuListTile(
            text: "願望清單",
            svgSrc: "assets/icons/Wishlist.svg",
            press: () {},
          ),
          ProfileMenuListTile(
            text: "設定收件地址",
            svgSrc: "assets/icons/Address.svg",
            press: () {
              Navigator.pushNamed(context, addressesScreenRoute);
            },
          ),
          // ProfileMenuListTile(
          //   text: "付款方式",
          //   svgSrc: "assets/icons/card.svg",
          //   press: () {
          //     Navigator.pushNamed(context, emptyPaymentScreenRoute);
          //   },
          // ),
          ProfileMenuListTile(
            text: "錢包",
            svgSrc: "assets/icons/Wallet.svg",
            press: () {
              // Navigator.pushNamed(context, walletScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "個人化設定",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          DividerListTileWithTrilingText(
            svgSrc: "assets/icons/Notification.svg",
            title: "通知",
            trilingText: "關閉",
            press: () {
              Navigator.pushNamed(context, enableNotificationScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "偏好設定",
            svgSrc: "assets/icons/Preferences.svg",
            press: () {
              Navigator.pushNamed(context, preferencesScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "更多服務",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "海外購物須知",
            svgSrc: "assets/icons/info.svg",
            press: () {
              Navigator.pushNamed(context, selectLanguageScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "付款貨運說明",
            svgSrc: "assets/icons/info.svg",
            press: () {},
          ),
          ProfileMenuListTile(
            text: "退貨相關",
            svgSrc: "assets/icons/info.svg",
            press: () {},
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "幫助與支援",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "取得幫助",
            svgSrc: "assets/icons/Help.svg",
            press: () {
              Navigator.pushNamed(context, getHelpScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "常見問題",
            svgSrc: "assets/icons/FAQ.svg",
            press: () {},
            isShowDivider: false,
          ),
          ProfileMenuListTile(
            text: "申請刪除帳號",
            svgSrc: "assets/icons/Danger Circle.svg",
            press: () {},
            isShowDivider: false,
          ),
          const SizedBox(height: defaultPadding),

          // Log Out
          Consumer<MemberViewModel>(
            builder: (context, viewModel, child) {
              if (!viewModel.isLoggedIn) {
                return const SizedBox.shrink();
              }

              return ListTile(
                onTap: () => _handleLogout(context, viewModel),
                minLeadingWidth: 24,
                leading: SvgPicture.asset(
                  "assets/icons/Logout.svg",
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    errorColor,
                    BlendMode.srcIn,
                  ),
                ),
                title: const Text(
                  "登出",
                  style: TextStyle(color: errorColor, fontSize: 14, height: 1),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future<void> _handleLogout(
      BuildContext context, MemberViewModel viewModel) async {
    // 顯示確認對話框
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("登出"),
        content: const Text("您確定要登出嗎？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: errorColor),
            child: const Text("登出"),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      // 執行登出
      await viewModel.logout();

      if (context.mounted) {
        // 顯示成功訊息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("登出成功"),
            duration: Duration(seconds: 2),
          ),
        );

        // 導航到登入頁面
        Navigator.pushNamedAndRemoveUntil(
          context,
          logInScreenRoute,
          (route) => false,
        );
      }
    }
  }
}
