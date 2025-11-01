import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/constants.dart';

class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/Illustration/NoResultDarkTheme.png",
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            const SizedBox(height: defaultPadding),
            Text(
              "購物車是空的",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: defaultPadding),
            const Text(
              "您的購物車目前沒有商品，快去挑選喜歡的商品吧！",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
