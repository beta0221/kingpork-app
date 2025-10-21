import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/components/list_tile/divider_list_tile.dart';
import 'package:tklab_ec_v2/components/network_image_with_loader.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';
import 'package:tklab_ec_v2/viewmodels/member_view_model.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Consumer<MemberViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoggedIn) {
                  return OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, userInfoScreenRoute);
                    },
                    child: const Text("View Profile"),
                  );
                }
                return OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, logInScreenRoute);
                  },
                  child: const Text("Log In"),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding * 1.5),
            child: GestureDetector(
              onTap: () {},
              child: const AspectRatio(
                aspectRatio: 1.8,
                child:
                    NetworkImageWithLoader("https://i.imgur.com/dz0BBom.png"),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              "Account",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ProfileMenuListTile(
            text: "Orders",
            svgSrc: "assets/icons/Order.svg",
            press: () {
              Navigator.pushNamed(context, ordersScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Returns",
            svgSrc: "assets/icons/Return.svg",
            press: () {},
          ),
          ProfileMenuListTile(
            text: "Wishlist",
            svgSrc: "assets/icons/Wishlist.svg",
            press: () {},
          ),
          ProfileMenuListTile(
            text: "Addresses",
            svgSrc: "assets/icons/Address.svg",
            press: () {
              Navigator.pushNamed(context, addressesScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Payment",
            svgSrc: "assets/icons/card.svg",
            press: () {
              Navigator.pushNamed(context, emptyPaymentScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Wallet",
            svgSrc: "assets/icons/Wallet.svg",
            press: () {
              Navigator.pushNamed(context, walletScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Personalization",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          DividerListTileWithTrilingText(
            svgSrc: "assets/icons/Notification.svg",
            title: "Notification",
            trilingText: "Off",
            press: () {
              Navigator.pushNamed(context, enableNotificationScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Preferences",
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
              "Settings",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "Language",
            svgSrc: "assets/icons/Language.svg",
            press: () {
              Navigator.pushNamed(context, selectLanguageScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Location",
            svgSrc: "assets/icons/Location.svg",
            press: () {},
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Help & Support",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "Get Help",
            svgSrc: "assets/icons/Help.svg",
            press: () {
              Navigator.pushNamed(context, getHelpScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "FAQ",
            svgSrc: "assets/icons/FAQ.svg",
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
                  "Log Out",
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
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: errorColor),
            child: const Text("Log Out"),
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
            content: Text("You have been logged out successfully"),
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
