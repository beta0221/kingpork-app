import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';
import '../../../../components/network_image_with_loader.dart';

/// 購物車商品卡片元件
/// 包含勾選框、商品資訊、數量控制、刪除按鈕
class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.image,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onQuantityIncrement,
    required this.onQuantityDecrement,
    required this.onDelete,
  });

  final String image;
  final String productName;
  final double price;
  final int quantity;
  final bool isSelected;
  final VoidCallback onSelectionChanged;
  final VoidCallback onQuantityIncrement;
  final VoidCallback onQuantityDecrement;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding / 2),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 勾選框
          Checkbox(
            value: isSelected,
            onChanged: (_) => onSelectionChanged(),
            activeColor: primaryColor,
          ),

          // 商品圖片
          SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
              child: NetworkImageWithLoader(
                image,
                radius: defaultBorderRadious / 2,
              ),
            ),
          ),

          const SizedBox(width: defaultPadding / 2),

          // 商品資訊與操作
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 商品名稱
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                const SizedBox(height: defaultPadding / 4),

                // 價格
                Text(
                  "NT\$${price.toInt()}",
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: defaultPadding / 2),

                // 數量控制與刪除按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 數量控制
                    _buildQuantityControl(context),

                    // 刪除按鈕
                    IconButton(
                      onPressed: onDelete,
                      icon: SvgPicture.asset(
                        "assets/icons/Close-Circle.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color ?? blackColor60,
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                      tooltip: "刪除",
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

  /// 數量控制元件
  Widget _buildQuantityControl(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 減少按鈕
        SizedBox(
          height: 32,
          width: 32,
          child: OutlinedButton(
            onPressed: quantity > 1 ? onQuantityDecrement : null,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
              ),
            ),
            child: SvgPicture.asset(
              "assets/icons/Minus.svg",
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                quantity > 1
                    ? (Theme.of(context).iconTheme.color ?? blackColor)
                    : blackColor40,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),

        // 數量顯示
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              quantity.toString(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),

        // 增加按鈕
        SizedBox(
          height: 32,
          width: 32,
          child: OutlinedButton(
            onPressed: onQuantityIncrement,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
              ),
            ),
            child: SvgPicture.asset(
              "assets/icons/Plus1.svg",
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color ?? blackColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
