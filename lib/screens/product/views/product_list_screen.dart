import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tklab_ec_v2/components/Banner/L/banner_l_style_1.dart';
import 'package:tklab_ec_v2/components/webview/tk_webview.dart';
import 'package:tklab_ec_v2/models/product_model.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';
import 'package:tklab_ec_v2/screens/on_sale/views/on_sale_screen.dart';
import 'package:tklab_ec_v2/screens/product/views/components/product_grid_card.dart';
import 'package:tklab_ec_v2/screens/product/views/components/quick_category_icons.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

import '../../../constants.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              // TabBar Header
              SliverAppBar(
                pinned: true,
                toolbarHeight: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        isScrollable: false,
                        labelColor: Theme.of(context).brightness == Brightness.light
                            ? blackColor
                            : whiteColor,
                        unselectedLabelColor: blackColor40,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        indicatorColor: errorColor,
                        indicatorWeight: 2,
                        tabs: const [
                          Tab(text: "優惠"),
                          Tab(text: "保養"),
                          Tab(text: "保健"),
                          Tab(text: "彩妝"),
                          Tab(text: "面膜"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent("優惠"),
              _buildTestWebViewContent(),
              const OnSaleScreen(), // 使用 OnSaleScreen
              _buildTestWebViewContent(),
              _buildTabContent("面膜")
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String categoryName) {
    // Assign TOP rankings to demo products
    final productsWithRanking = List.generate(
      demoPopularProducts.length,
      (index) => {
        'product': demoPopularProducts[index],
        'ranking': index < 9 ? index + 1 : null, // TOP 1-9 for first 9 products
      },
    );

    return CustomScrollView(
      slivers: [
        // Banner Section
        SliverToBoxAdapter(
          child: AspectRatio(
            aspectRatio: 2 / 1,
            child: BannerLStyle1(
              image: "https://i.ytimg.com/vi/kTHkf_rapiE/maxresdefault.jpg?sqp=-oaymwEmCIAKENAF8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGGUgZShlMA8=&rs=AOn4CLA3jy5V_AGYfrbN2ZRzdWKjUeJkMQ",
              title: "雙11特賣",
              subtitle: "NEW ARRIVAL",
              discountPercent: 11,
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
    );
  }

  Widget _buildTestWebViewContent() {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/html/example_webview.html'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '載入 HTML 時發生錯誤: ${snapshot.error}',
              style: const TextStyle(color: errorColor),
            ),
          );
        }

        final htmlContent = snapshot.data ?? '';

        return TkWebView(
          htmlContent: htmlContent,
          htmlBaseUrl: ApiEndpoints.baseUrl,
          showLoading: true,
          loadingMessage: '載入中...',
          enableJavaScript: true,
        );
      },
    );
  }
}
