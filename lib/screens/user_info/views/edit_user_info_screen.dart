import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:tklab_ec_v2/components/network_image_with_loader.dart';
import 'package:tklab_ec_v2/constants.dart';

import 'components/user_info_form.dart';

class EditUserInfoScreen extends StatelessWidget {
  const EditUserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/info.svg",
              colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!, BlendMode.srcIn),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          child: NetworkImageWithLoader(
                            "https://i.imgur.com/IXnwbLk.png",
                            radius: 100,
                          ),
                        ),
                        Positioned(
                          bottom: -14,
                          right: -14,
                          child: SizedBox(
                            height: 56,
                            width: 56,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                side: BorderSide(
                                    width: 4,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                              ),
                              child: SvgPicture.asset(
                                "assets/icons/Edit-Bold.svg",
                                colorFilter: const ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Edit photo"),
                    ),
                    const SizedBox(height: defaultPadding),
                    const UserInfoForm()
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding / 2),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
