import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/components/Banner/L/banner_l_style_1.dart';
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
                        // 切換分類並載入產品
                        viewModel.selectCategory(category);
                      },
                    ),
                  ),

                // 產品網格標題
                if (viewModel.hasProducts)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      defaultPadding,
                      defaultPadding,
                      defaultPadding,
                      8,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '產品列表',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '共 ${viewModel.products.length} 件商品',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 產品網格（使用 API 資料）
                if (viewModel.hasProducts)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: defaultPadding,
                        crossAxisSpacing: defaultPadding,
                        childAspectRatio: 0.515, // 調整以容納 4:3 圖片 + 3行標題 + 產品資訊
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final product = viewModel.products[index];

                          return ProductGridCard(
                            image: product.imgUrl,
                            title: product.name,
                            price: product.price,
                            priceAfterDiscount: product.hasSpecialOffer ? product.spacialOffer : null,
                            topRanking: product.ranking,
                            press: () {
                              Navigator.pushNamed(
                                context,
                                productDetailsScreenRoute,
                                arguments: {'id': product.id},
                              );
                            },
                            onAddToCart: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('已將「${product.name}」加入購物車'),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: '查看',
                                    onPressed: () {
                                      // TODO: 導航到購物車頁面
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: viewModel.products.length,
                      ),
                    ),
                  ),

                // 產品載入中指示器（局部 loading）
                if (viewModel.isLoadingProducts && !viewModel.hasProducts)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: defaultPadding),
                          Text('載入產品中...'),
                        ],
                      ),
                    ),
                  ),

                // 空狀態提示（有分類但無產品）
                if (!viewModel.hasProducts && !viewModel.isLoadingProducts && viewModel.hasData)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(height: defaultPadding),
                          Text(
                            '此分類目前沒有產品',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '請選擇其他分類或稍後再試',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 無分類資料的空狀態
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
                            '此產品線尚無分類',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                        ],
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
}
