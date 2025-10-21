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
        title: const Text("Profile"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, editUserInfoScreenRoute);
            },
            child: const Text("Edit"),
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
                  const Text("Please log in to view your profile"),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, logInScreenRoute);
                    },
                    child: const Text("Log In"),
                  ),
                ],
              ),
            );
          }

          final user = viewModel.currentUser;
          final name = user?.name ?? "N/A";
          final email = user?.email ?? "N/A";
          final phone = user?.phone ?? "Not provided";

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
                  leadingText: "Name",
                  trailingText: name,
                ),
                const UserInfoListTile(
                  leadingText: "Date of birth",
                  trailingText: "Not provided",
                ),
                UserInfoListTile(
                  leadingText: "Phone number",
                  trailingText: phone,
                ),
                const UserInfoListTile(
                  leadingText: "Gender",
                  trailingText: "Not provided",
                ),
                UserInfoListTile(
                  leadingText: "Email",
                  trailingText: email,
                ),
                if (user?.bonus != null)
                  UserInfoListTile(
                    leadingText: "Bonus Points",
                    trailingText: "${user!.bonus}",
                  ),
                ListTile(
                  leading: const Text("Password"),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, currentPasswordScreenRoute);
                    },
                    child: const Text("Change password"),
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
