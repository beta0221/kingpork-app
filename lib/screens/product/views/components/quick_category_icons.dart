import 'package:flutter/material.dart';

import '../../../../constants.dart';

class QuickCategoryModel {
  final String name;
  final String? imagePath;
  final IconData? icon;
  final Color? backgroundColor;

  QuickCategoryModel({
    required this.name,
    this.imagePath,
    this.icon,
    this.backgroundColor,
  });
}

// Demo data
final List<QuickCategoryModel> demoQuickCategories = [
  QuickCategoryModel(
    name: "全部商品",
    icon: Icons.grid_view_rounded,
    backgroundColor: const Color(0xFFF5F5F5),
  ),
  QuickCategoryModel(
    name: "鍾明軒推薦\n精選",
    icon: Icons.storefront,
    backgroundColor: const Color(0xFFFFE5E5),
  ),
  QuickCategoryModel(
    name: "美容大王\n大S代言",
    icon: Icons.stars_rounded,
    backgroundColor: const Color(0xFFFFF4E5),
  ),
  QuickCategoryModel(
    name: "謝佳見\nTKLAB酒神飲",
    icon: Icons.local_offer,
    backgroundColor: const Color(0xFFE5F5FF),
  ),
  QuickCategoryModel(
    name: "國際巨星小S\n膠原蛋白飲",
    icon: Icons.card_giftcard,
    backgroundColor: const Color(0xFFFFE5F5),
  ),
  QuickCategoryModel(
    name: "王子代言\n亮白面膜",
    icon: Icons.favorite,
    backgroundColor: const Color(0xFFE5FFE5),
  ),
  QuickCategoryModel(
    name: "語安輕仙\n酵素飲",
    icon: Icons.shopping_bag,
    backgroundColor: const Color(0xFFFFE5E5),
  ),
];

class QuickCategoryIcons extends StatelessWidget {
  const QuickCategoryIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
        itemCount: demoQuickCategories.length,
        itemBuilder: (context, index) {
          final category = demoQuickCategories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 4),
            child: QuickCategoryIcon(
              name: category.name,
              imagePath: category.imagePath,
              icon: category.icon,
              backgroundColor: category.backgroundColor,
              press: () {
                // Handle category selection
              },
            ),
          );
        },
      ),
    );
  }
}

class QuickCategoryIcon extends StatelessWidget {
  const QuickCategoryIcon({
    super.key,
    required this.name,
    this.imagePath,
    this.icon,
    this.backgroundColor,
    required this.press,
  });

  final String name;
  final String? imagePath;
  final IconData? icon;
  final Color? backgroundColor;
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
                color: backgroundColor ??
                    (Theme.of(context).brightness == Brightness.light
                        ? lightGreyColor
                        : darkGreyColor),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: imagePath != null
                    ? ClipOval(
                        child: Image.asset(
                          imagePath!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        icon ?? Icons.category,
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
