import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/viewmodels/member_view_model.dart';

import '../../../../constants.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    this.name,
    this.email,
    this.imageSrc,
    this.proLableText = "Pro",
    this.isPro = false,
    this.press,
    this.isShowHi = true,
    this.isShowArrow = true,
    this.useViewModel = false,
  });

  final String? name, email, imageSrc;
  final String proLableText;
  final bool isPro, isShowHi, isShowArrow;
  final VoidCallback? press;
  final bool useViewModel;

  @override
  Widget build(BuildContext context) {
    if (useViewModel) {
      return Consumer<MemberViewModel>(
        builder: (context, viewModel, child) {
          final displayName = viewModel.memberName ?? name ?? "王小明";
          final displayEmail = viewModel.currentMember?.email ?? email ?? "";
          final displayImage = imageSrc ?? "assets/icons/user-circle-svgrepo-com.svg";

          return _buildCard(
            context: context,
            name: displayName,
            email: displayEmail,
            imageSrc: displayImage,
          );
        },
      );
    }

    return _buildCard(
      context: context,
      name: name ?? "Guest",
      email: email ?? "",
      imageSrc: imageSrc ?? "assets/icons/user-circle-svgrepo-com.svg",
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String name,
    required String email,
    required String imageSrc,
  }) {
    return ListTile(
      onTap: press,
      leading: CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: ClipOval(
            child: SvgPicture.asset(
              imageSrc,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          )),
      title: Row(
        children: [
          Text(
            isShowHi ? "Hi, $name" : name,
            style: const TextStyle(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: defaultPadding / 2),
          if (isPro)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding / 2, vertical: defaultPadding / 4),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius:
                    BorderRadius.all(Radius.circular(defaultBorderRadious)),
              ),
              child: Text(
                proLableText,
                style: const TextStyle(
                  fontFamily: grandisExtendedFont,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.7,
                  height: 1,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(email),
      trailing: isShowArrow
          ? SvgPicture.asset(
              "assets/icons/miniRight.svg",
              colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!.withValues(alpha: 0.4),
                  BlendMode.srcIn),
            )
          : null,
    );
  }
}
