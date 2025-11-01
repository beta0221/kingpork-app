import 'package:flutter/material.dart';

import '../../../../constants.dart';

class NoNotification extends StatelessWidget {
  const NoNotification({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        Image.asset(
          Theme.of(context).brightness == Brightness.light
              ? "assets/Illustration/NoResult.png"
              : "assets/Illustration/NoResultDarkTheme.png",
          width: MediaQuery.of(context).size.width * 0.7,
        ),
        const Spacer(),
        Text(
          "沒有通知",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: defaultPadding / 1),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultPadding * 1.5),
          child: Text(
            "目前沒有任何通知。當您收到新通知時，它們將顯示在這裡。",
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
