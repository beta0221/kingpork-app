import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/viewmodels/cart_view_model.dart';
import '/components/network_image_with_loader.dart';

/// 本次購買商品列表區塊
class OrderItemsSection extends StatelessWidget {
  const OrderItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        final items = cartViewModel.selectedItems;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題列
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '本次購買商品',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '共 ${items.length} 件',
                  style: TextStyle(
                    fontSize: 14,
                    color: blackColor60,
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),

            // 商品列表
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: blackColor10),
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              child: items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(defaultPadding * 2),
                      child: Center(
                        child: Text(
                          '尚無選購商品',
                          style: TextStyle(color: blackColor60),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: blackColor10,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _OrderItemTile(
                          image: item.image,
                          productName: item.productName,
                          price: item.price,
                          quantity: item.quantity,
                        );
                      },
                    ),
            ),

            // 小計
            Padding(
              padding: const EdgeInsets.only(top: defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '商品小計',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'NT\$${cartViewModel.selectedTotal.toInt()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 單一商品項目
class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({
    required this.image,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  final String image;
  final String productName;
  final double price;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品圖片
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: NetworkImageWithLoader(
                image,
                radius: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 商品資訊
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NT\$${price.toInt()} x $quantity',
                      style: TextStyle(
                        fontSize: 13,
                        color: blackColor60,
                      ),
                    ),
                    Text(
                      'NT\$${(price * quantity).toInt()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
