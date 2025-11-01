import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class SetupFaceIdScreen extends StatelessWidget {
  const SetupFaceIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "如何設定 Face ID",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: defaultPadding),
              const Text(
                "首先，將您的臉部對準相機框架。然後以圓圈方式移動您的頭部，以顯示臉部的所有角度。",
              ),
              const Spacer(),
              Center(
                child: Image.asset(
                  Theme.of(context).brightness == Brightness.light
                      ? "assets/Illustration/faceId.png"
                      : "assets/Illustration/faceId_dark.png",
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: SvgPicture.asset(
                  "assets/icons/FaceId.svg",
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).scaffoldBackgroundColor,
                    BlendMode.srcIn,
                  ),
                ),
                label: const Text("設定 Face ID"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
