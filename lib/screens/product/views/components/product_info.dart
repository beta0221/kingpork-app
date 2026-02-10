import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../constants.dart';
import 'product_availability_tag.dart';

class ProductInfo extends StatelessWidget {
  const ProductInfo({
    super.key,
    required this.title,
    required this.brand,
    required this.description,
    required this.rating,
    required this.numOfReviews,
    required this.isAvailable,
    required this.price,
    required this.dealPrice,
  });

  final String title, brand, description;
  final double rating;
  final int numOfReviews;
  final bool isAvailable;
  final double price;      // 原價 (PPrice)
  final double dealPrice;  // 特價 (PDealPrice)

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(defaultPadding),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              brand.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              title,
              maxLines: 2,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: defaultPadding / 2),
            // 價格區塊
            Text.rich(
              TextSpan(
                text: "NT\$${dealPrice.toInt()}  ",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: const Color(0xFFFF6B00),
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  if (price > dealPrice)
                    TextSpan(
                      text: "NT\$${price.toInt()}",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.5),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            // Row(
            //   children: [
            //     ProductAvailabilityTag(isAvailable: isAvailable),
            //     const Spacer(),
            //     SvgPicture.asset("assets/icons/Star_filled.svg"),
            //     const SizedBox(width: defaultPadding / 4),
            //     Text(
            //       "$rating ",
            //       style: Theme.of(context).textTheme.bodyLarge,
            //     ),
            //     Text("($numOfReviews 則評價)")
            //   ],
            // ),
            const SizedBox(height: defaultPadding),
            Text(
              "商品介紹",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: defaultPadding / 2),
            HtmlWidget(
              description,
              textStyle: const TextStyle(height: 1.4),
            ),
            const SizedBox(height: defaultPadding / 2),
          ],
        ),
      ),
    );
  }
}
