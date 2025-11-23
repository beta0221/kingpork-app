import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/components/Banner/L/banner_l_style_1.dart';
import 'package:tklab_ec_v2/models/product_model.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';
import 'package:tklab_ec_v2/screens/product/views/components/product_grid_card.dart';
import 'package:tklab_ec_v2/screens/product/views/components/quick_category_icons.dart';

import '../../../constants.dart';

/// 產品分類頁面
///
/// 顯示特定分類的產品列表，包含橫幅、快速分類圖示和產品網格
class ProductCategoryScreen extends StatelessWidget {
  /// 分類名稱
  final String categoryName;

  /// 分類 ID（選用，供 API 使用）
  final String? categoryId;

  /// 橫幅圖片 URL（選用）
  final String? bannerImage;

  /// 橫幅標題（選用）
  final String? bannerTitle;

  /// 橫幅副標題（選用）
  final String? bannerSubtitle;

  /// 折扣百分比（選用）
  final int? discountPercent;

  const ProductCategoryScreen({
    super.key,
    required this.categoryName,
    this.categoryId,
    this.bannerImage,
    this.bannerTitle,
    this.bannerSubtitle,
    this.discountPercent,
  });

  @override
  Widget build(BuildContext context) {
    // Assign TOP rankings to demo products
    final productsWithRanking = List.generate(
      demoPopularProducts.length,
      (index) => {
        'product': demoPopularProducts[index],
        'ranking': index < 9 ? index + 1 : null, // TOP 1-9 for first 9 products
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Banner Section
          if (bannerImage != null)
            SliverToBoxAdapter(
              child: AspectRatio(
                aspectRatio: 2 / 1,
                child: BannerLStyle1(
                  image: bannerImage!,
                  title: bannerTitle ?? categoryName,
                  subtitle: bannerSubtitle ?? "NEW ARRIVAL",
                  discountPercent: discountPercent ?? 0,
                  press: () {},
                ),
              ),
            ),

          // Quick Category Icons
          const SliverToBoxAdapter(
            child: QuickCategoryIcons(),
          ),

          // Product Grid
          SliverPadding(
            padding: const EdgeInsets.all(defaultPadding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: defaultPadding,
                crossAxisSpacing: defaultPadding,
                childAspectRatio: 0.68, // Adjust card height/width ratio
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final productData = productsWithRanking[index];
                  final product = productData['product'] as ProductModel;
                  final ranking = productData['ranking'] as int?;

                  return ProductGridCard(
                    image: product.image,
                    title: product.title,
                    price: product.price,
                    priceAfterDiscount: product.priceAfetDiscount,
                    topRanking: ranking,
                    press: () {
                      Navigator.pushNamed(
                        context,
                        productDetailsScreenRoute,
                      );
                    },
                    onAddToCart: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已加入購物車'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
                childCount: productsWithRanking.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
