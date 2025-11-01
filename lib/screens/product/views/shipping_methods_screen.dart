import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tklab_ec_v2/constants.dart';

import 'components/express_shipping_method_card.dart';
import 'components/shipping_method_card.dart';
import 'components/standard_shopping_method_card.dart';

class ShippingMethodsScreen extends StatelessWidget {
  const ShippingMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(),
                  Text(
                    "配送方式",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      "assets/icons/Danger Circle.svg",
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color!, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    const StandardShippingMethodCard(),
                    const SizedBox(height: defaultPadding),
                    const ExpressShippingMethodCard(),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                      child: ShippingMethodCard(
                        title: "急件",
                        price: 21.95,
                        subtitle: "1-2個工作天送達",
                        press: () {},
                      ),
                    ),
                    ShippingMethodCard(
                      title: "卡車配送",
                      price: 102.50,
                      subtitle: "出貨後2-4週送達",
                      press: () {},
                    ),
                    const SizedBox(height: defaultPadding),
                    const Text(
                      "急件配送可能因履行地點而無法適用於所有訂單。",
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: defaultPadding / 2),
                      child: Text.rich(
                        TextSpan(
                          text: "配送至海外？請參閱我們的",
                          children: [
                            TextSpan(
                              text: "國際運費資訊。",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to s hipping rates page
                                },
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      "此商品可配送至我們的便利取貨點。",
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
