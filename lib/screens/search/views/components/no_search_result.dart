import 'package:flutter/material.dart';

import '../../../../constants.dart';

class NoSearchResult extends StatelessWidget {
  const NoSearchResult({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: defaultPadding),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Image.asset(
            Theme.of(context).brightness == Brightness.dark
                ? "assets/Illustration/NoResultDarkTheme.png"
                : "assets/Illustration/NoResult.png",
          ),
        ),
        Text(
          "找不到結果",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: defaultPadding / 2),
        const Text(
          "很抱歉，我們找不到符合您搜尋條件的商品。請嘗試使用其他關鍵字或調整篩選條件。",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
