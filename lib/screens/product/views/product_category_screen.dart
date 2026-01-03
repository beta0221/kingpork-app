import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/components/Banner/L/banner_l_style_1.dart';
import 'package:tklab_ec_v2/models/product_model.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';
import 'package:tklab_ec_v2/screens/product/views/components/product_grid_card.dart';
import 'package:tklab_ec_v2/screens/product/views/components/quick_category_icons.dart';
import 'package:tklab_ec_v2/viewmodels/product_category_view_model.dart';

import '../../../constants.dart';

/// 產品分類頁面
///
/// 顯示特定分類的產品列表，包含橫幅、快速分類圖示和產品網格
/// 使用 MVVM 架構，整合 ProductCategoryViewModel
class ProductCategoryScreen extends StatefulWidget {
  /// 分類名稱（用於 API 呼叫）
  final String categoryName;

  /// 顯示標題（可選，預設使用 categoryName）
  final String? displayTitle;

  const ProductCategoryScreen({
    super.key,
    required this.categoryName,
    this.displayTitle,
  });

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  @override
  void initState() {
    super.initState();
    // 在畫面初始化後載入資料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCategoryViewModel>().initialize(widget.categoryName);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用 displayTitle 或 categoryName 作為標題
    final screenTitle = widget.displayTitle ?? widget.categoryName;

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
        centerTitle: true,
      ),
      body: Consumer<ProductCategoryViewModel>(
        builder: (context, viewModel, child) {
          // 載入狀態
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 錯誤狀態
          if (viewModel.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: errorColor,
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    viewModel.errorMessage ?? '載入資料失敗',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton.icon(
                    onPressed: viewModel.refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重試'),
                  ),
                ],
              ),
            );
          }

          // 成功狀態 - 顯示內容
          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: CustomScrollView(
              slivers: [
                // Banner Section（如果 API 有回傳 bannerUrl）
                if (viewModel.hasBanner)
                  SliverToBoxAdapter(
                    child: AspectRatio(
                      aspectRatio: 2 / 1,
                      child: BannerLStyle1(
                        image: viewModel.bannerUrl,
                        title: '',
                        subtitle: '',
                        discountPercent: 0,
                        press: () {},
                      ),
                    ),
                  ),

                // Quick Category Icons（從 API 載入）
                if (viewModel.hasData)
                  SliverToBoxAdapter(
                    child: QuickCategoryIcons(
                      categories: viewModel.categories,
                      onCategoryTap: (category) {
                        // 暫時不處理點擊事件
                        // 未來可導航到該分類的產品列表
                      },
                    ),
                  ),

                // 空狀態提示（如果沒有分類資料）
                if (!viewModel.hasData)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(height: defaultPadding),
                          Text(
                            '此分類尚無子分類',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Product Grid（暫時保留 demo 資料，之後需要另外 API）
                if (viewModel.hasData)
                  SliverPadding(
                    padding: const EdgeInsets.all(defaultPadding),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: defaultPadding,
                        crossAxisSpacing: defaultPadding,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          // TODO: 未來需要替換為實際的產品 API
                          final productsWithRanking = _getDemoProducts();
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
                        childCount: _getDemoProducts().length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 取得 demo 產品資料（暫時使用，未來需替換為實際 API）
  List<Map<String, dynamic>> _getDemoProducts() {
    return List.generate(
      demoPopularProducts.length,
      (index) => {
        'product': demoPopularProducts[index],
        'ranking': index < 9 ? index + 1 : null,
      },
    );
  }
}
