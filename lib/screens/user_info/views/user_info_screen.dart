import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            const ProfileCard(
              name: "Sepide",
              email: "theflutterway@gmail.com",
              imageSrc: "https://i.imgur.com/IXnwbLk.png",
              // proLableText: "Sliver",
              // isPro: true, if the user is pro
              isShowHi: false,
              isShowArrow: false,
            ),
            const SizedBox(height: defaultPadding * 1.5),
            const UserInfoListTile(
              leadingText: "Name",
              trailingText: "Sepide",
            ),
            const UserInfoListTile(
              leadingText: "Date of birth",
              trailingText: "Date of birth",
            ),
            const UserInfoListTile(
              leadingText: "Phone number",
              trailingText: "+1-202-555-0162",
            ),
            const UserInfoListTile(
              leadingText: "Gender",
              trailingText: "Female",
            ),
            const UserInfoListTile(
              leadingText: "Email",
              trailingText: "theflutterway@gmail.com",
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
      ),
    );
  }
}
