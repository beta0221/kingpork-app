import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/components/order_process.dart';
import 'package:tklab_ec_v2/components/order_status_card.dart';
import 'package:tklab_ec_v2/components/product/secondary_product_card.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/models/product_model.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';
import 'package:tklab_ec_v2/screens/profile/views/components/profile_menu_item_list_tile.dart';

import 'components/help_line.dart';
import 'components/order_summary_card.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("訂單詳情"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: OrderStatusCard(
                  orderId: "FDS6398220",
                  placedOn: "Jun 10, 2021",
                  orderStatus: OrderProcessStatus.done,
                  processingStatus: OrderProcessStatus.processing,
                  packedStatus: OrderProcessStatus.notDoneYeat,
                  shippedStatus: OrderProcessStatus.notDoneYeat,
                  deliveredStatus: OrderProcessStatus.notDoneYeat,
                ),
              ),
              const SizedBox(height: defaultPadding / 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "配送地址",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: defaultPadding / 2),
                          const Text("Zabiniec 12/222, 31-215 \nCracow, Poland")
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "預計送達時間",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: defaultPadding / 2),
                          const Text(
                            "今天 \n上午 9 點到 10 點",
                            textAlign: TextAlign.end,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding / 2),
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text(
                  "商品",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ...List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.only(
                      bottom: defaultPadding,
                      left: defaultPadding,
                      right: defaultPadding),
                  child: SecondaryProductCard(
                    image: demoPopularProducts[index].image,
                    brandName: demoPopularProducts[index].brandName,
                    title: demoPopularProducts[index].title,
                    price: demoPopularProducts[index].price,
                    priceAfetDiscount:
                        demoPopularProducts[index].priceAfetDiscount,
                    style: ElevatedButton.styleFrom(
                      maximumSize: const Size(double.infinity, 80),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding / 2),
              const Divider(height: 1),
              ProfileMenuListTile(
                svgSrc: "assets/icons/Delivery.svg",
                text: "查看貨運",
                press: () {},
              ),
              const Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: OrderSummaryCard(
                  subTotal: 169.0,
                  discount: 10,
                  totalWithVat: 185,
                  vat: 5,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: defaultPadding / 2),
                child: HelpLine(number: "+02 9629 4884"),
              ),
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, cancleOrderScreenRoute);
                  },
                  child: Text(
                    "取消訂單",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color!),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
