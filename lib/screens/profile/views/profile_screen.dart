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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // 在初始化時載入會員資料
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<MemberViewModel>();
      // 檢查是否有 token（表示已登入）
      final isLoggedIn = await viewModel.checkTokenValidity();
      if (isLoggedIn && mounted) {
        // 只在有 token 時才載入會員資料
        await viewModel.loadMemberProfile();
        if (mounted && viewModel.errorMessage != null) {
          // 如果載入失敗，顯示錯誤訊息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage!),
              backgroundColor: errorColor,
            ),
          );
        }
      }
    });
  }

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
          Consumer<MemberViewModel>(
            builder: (context, viewModel, child) {
              return ProfileMenuListTile(
                text: "申請刪除帳號",
                svgSrc: "assets/icons/Danger Circle.svg",
                press: () {
                  if (viewModel.isLoggedIn) {
                    _handleDeleteAccount(viewModel);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("請先登入"),
                        backgroundColor: warningColor,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                isShowDivider: false,
              );
            },
          ),
          const SizedBox(height: defaultPadding),

          // Log Out
          Consumer<MemberViewModel>(
            builder: (context, viewModel, child) {
              if (!viewModel.isLoggedIn) {
                return const SizedBox.shrink();
              }

              return ListTile(
                onTap: () => _handleLogout(viewModel),
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

  Future<void> _handleLogout(MemberViewModel viewModel) async {
    // 先獲取需要的 context 相關物件
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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

    if (shouldLogout == true) {
      // 執行登出
      await viewModel.logout();

      // 顯示成功訊息
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("登出成功"),
          duration: Duration(seconds: 2),
        ),
      );

      // 不需要導航，保持在 ProfileScreen
      // UI 會自動更新為訪客狀態（透過 Consumer<MemberViewModel>）
    }
  }

  Future<void> _handleDeleteAccount(MemberViewModel viewModel) async {
    // 先獲取需要的 context 相關物件
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // 顯示確認對話框
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("申請刪除帳號"),
        content: const Text(
          "您確定要刪除帳號嗎？\n\n"
          "刪除後將無法復原，您的所有資料將被永久刪除：\n"
          "• 個人資料\n"
          "• 訂單記錄\n"
          "• TK幣與現金券\n"
          "• 會員等級\n\n"
          "此操作無法撤銷，請謹慎考慮。",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: errorColor),
            child: const Text("確認刪除"),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      // 顯示載入對話框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // 執行刪除帳號
        final success = await viewModel.deleteAccount();

        // 關閉載入對話框
        if (mounted) {
          navigator.pop();
        }

        if (success) {
          // 顯示成功訊息
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text("帳號已成功刪除"),
              backgroundColor: successColor,
              duration: Duration(seconds: 3),
            ),
          );

          // token 和使用者資料已由 viewModel.deleteAccount() 清除
          // UI 會自動更新為訪客狀態，無需導航
        } else {
          // 顯示錯誤訊息
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? '刪除帳號失敗'),
              backgroundColor: errorColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        // 關閉載入對話框
        if (mounted) {
          navigator.pop();
        }

        // 顯示錯誤訊息
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('刪除帳號時發生錯誤：${e.toString()}'),
            backgroundColor: errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
