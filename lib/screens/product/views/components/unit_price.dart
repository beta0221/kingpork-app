import 'package:flutter/material.dart';

import '../../../../constants.dart';

class UnitPrice extends StatelessWidget {
  const UnitPrice({
    super.key,
    required this.price,
    this.priceAfterDiscount,
  });

  final double price;
  final double? priceAfterDiscount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "單價",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: defaultPadding / 1),
        Text.rich(
          TextSpan(
            text: priceAfterDiscount == null
                ? "\$${price.toStringAsFixed(2)}  "
                : "\$${priceAfterDiscount!.toStringAsFixed(2)}  ",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
            children: [
              if (priceAfterDiscount != null)
                TextSpan(
                  text: "\$${price.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      decoration: TextDecoration.lineThrough),
                ),
            ],
          ),
        )
      ],
    );
  }
}
