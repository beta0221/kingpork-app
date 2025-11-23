import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/components/product/product_card.dart';
import 'package:tklab_ec_v2/models/product_model.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';

import '/constants.dart';

/// 推薦商品區塊 - 顯示「其他人也買了」商品列表
class RecommendedProductsSection extends StatelessWidget {
  const RecommendedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標題列
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "其他人也買了",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextButton(
              onPressed: () {
                // 可導航至更多推薦商品頁面
              },
              child: const Text("查看更多"),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding / 2),

        // 水平滑動商品列表
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: demoPopularProducts.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                right: index == demoPopularProducts.length - 1 ? 0 : defaultPadding,
              ),
              child: ProductCard(
                image: demoPopularProducts[index].image,
                brandName: demoPopularProducts[index].brandName,
                title: demoPopularProducts[index].title,
                price: demoPopularProducts[index].price,
                priceAfetDiscount: demoPopularProducts[index].priceAfetDiscount,
                dicountpercent: demoPopularProducts[index].dicountpercent,
                press: () {
                  Navigator.pushNamed(
                    context,
                    productDetailsScreenRoute,
                    arguments: index.isEven,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
