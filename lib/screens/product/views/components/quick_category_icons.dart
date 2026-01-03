import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/models/product_line_model.dart';
import 'package:tklab_ec_v2/components/network_image_with_loader.dart';

import '../../../../constants.dart';

/// QuickCategoryIcons - 快速分類圖示列表
///
/// 支援從 API 傳入的 categories 資料
class QuickCategoryIcons extends StatelessWidget {
  final List<ProductCategory>? categories;
  final Function(ProductCategory)? onCategoryTap;

  const QuickCategoryIcons({
    super.key,
    this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    // 如果沒有傳入 categories，顯示空狀態
    final displayCategories = categories ?? [];

    if (displayCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          final category = displayCategories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 4),
            child: QuickCategoryIcon(
              name: category.name,
              imageUrl: category.imgUrl.isNotEmpty ? category.imgUrl : null,
              press: () {
                if (onCategoryTap != null) {
                  onCategoryTap!(category);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

/// QuickCategoryIcon - 單個快速分類圖示
class QuickCategoryIcon extends StatelessWidget {
  const QuickCategoryIcon({
    super.key,
    required this.name,
    this.imageUrl,
    required this.press,
  });

  final String name;
  final String? imageUrl;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? lightGreyColor
                    : darkGreyColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? ClipOval(
                        child: NetworkImageWithLoader(
                          imageUrl!,
                          fit: BoxFit.cover,
                          radius: 28,
                        ),
                      )
                    : Icon(
                        Icons.category,
                        size: 28,
                        color: Theme.of(context).brightness == Brightness.light
                            ? blackColor60
                            : whiteColor,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            // Category Name
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 10,
                    height: 1.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
