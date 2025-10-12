import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserImageUpload extends StatelessWidget {
  const UserImageUpload({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
          radius: 60,
          child: SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/Profile.svg",
                  height: 40,
                  width: 40,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withValues(alpha: 0.3),
                    BlendMode.srcIn,
                  ),
                ),
                Positioned(
                  height: 40,
                  width: 40,
                  right: 0,
                  bottom: 0,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/Camera-Bold.svg",
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).scaffoldBackgroundColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text("Upload Image"),
        )
      ],
    );
  }
}
