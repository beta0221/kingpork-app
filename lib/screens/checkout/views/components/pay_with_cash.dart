import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';

import '../../../../constants.dart';

class PayWithCash extends StatelessWidget {
  const PayWithCash({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          children: [
            const Spacer(),
            Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? "assets/Illustration/PayWithCash_darkTheme.png"
                  : "assets/Illustration/PayWithCash_lightTheme.png",
              width: MediaQuery.of(context).size.width * 0.55,
            ),
            const SizedBox(height: defaultPadding * 2),
            Text(
              "貨到付款",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: defaultPadding * 1.5),
            const Text(
              "使用貨到付款將收取可退款的 \$24.00 手續費，如果您想節省此費用，請切換至信用卡付款。",
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, thanksForOrderScreenRoute);
                  },
                  child: const Text("確認"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
