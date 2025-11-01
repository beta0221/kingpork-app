import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/screens/order/views/components/order_summary_card.dart';

import '../../../../constants.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.orderId,
    required this.amount,
  });

  final String orderId;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius:
            const BorderRadius.all(Radius.circular(defaultBorderRadious)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "訂單摘要",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: defaultPadding),
          OrderSummaryText(
            leadingText: "訂單編號",
            trilingText: "#$orderId",
          ),
          const SizedBox(height: defaultPadding / 2),
          OrderSummaryText(
            leadingText: "付款金額",
            trilingText: "\$${amount.toStringAsFixed(2)}",
            trilingTextColor: successColor,
          ),
        ],
      ),
    );
  }
}
