import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tklab_ec_v2/constants.dart';

class NoAddressScreen extends StatelessWidget {
  const NoAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("地址"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/DotsV.svg",
              colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!, BlendMode.srcIn),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(flex: 2),
          Image.asset(
            Theme.of(context).brightness == Brightness.light
                ? "assets/Illustration/EmptyState_lightTheme.png"
                : "assets/Illustration/EmptyState_darkTheme.png",
            width: MediaQuery.of(context).size.width * 0.6,
          ),
          const Spacer(),
          Text(
            "沒有地址",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: defaultPadding),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding * 1.5),
            child: Text(
              "啟用推播通知可讓我們向您傳送有關新產品、促銷活動等資訊！",
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("新增地址"),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
