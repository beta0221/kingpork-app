import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/components/cart_button.dart';
import 'package:tklab_ec_v2/components/custom_modal_bottom_sheet.dart';
import 'package:tklab_ec_v2/components/product/product_card.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/screens/product/views/product_info_screen.dart';
import 'package:tklab_ec_v2/screens/product/views/product_returns_screen.dart';
import 'package:tklab_ec_v2/screens/product/views/shipping_methods_screen.dart';
import 'package:tklab_ec_v2/viewmodels/product_details_view_model.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.sku,
  });

  final String sku;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // 在 Widget 構建完成後初始化資料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailsViewModel>().initialize(widget.sku);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ProductDetailsViewModel>(
          builder: (context, viewModel, child) {
            // 載入狀態
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
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
                      viewModel.errorMessage ?? '載入產品詳情失敗',
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

            // 檢查產品資料是否存在
            final product = viewModel.productDetail;
            if (product == null) {
              return const Center(
                child: Text('產品不存在'),
              );
            }

            // 成功狀態 - 顯示產品詳情
            return Scaffold(
              bottomNavigationBar: product.isAvailable
                  ? CartButton(
                      price: product.price,
                      press: () {
                        customModalBottomSheet(
                          context,
                          height: MediaQuery.of(context).size.height * 0.92,
                          child: const ProductBuyNowScreen(),
                        );
                      },
                    )
                  :
                  // 如果產品無庫存則顯示 NotifyMeCard
                  NotifyMeCard(
                      isNotify: false,
                      onChanged: (value) {},
                    ),
              body: RefreshIndicator(
                onRefresh: viewModel.refresh,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      floating: true,
                      actions: [
                        IconButton(
                          onPressed: () {},
                          icon: SvgPicture.asset(
                            "assets/icons/Bookmark.svg",
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).textTheme.bodyLarge!.color!,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 產品圖片
                    ProductImages(
                      images: product.images,
                    ),
                    // 產品資訊
                    ProductInfo(
                      brand: product.brand,
                      title: product.title,
                      isAvailable: product.isAvailable,
                      description: product.description,
                      rating: product.rating,
                      numOfReviews: product.numOfReviews,
                    ),
                    // 商品規格
                    ProductListTile(
                      svgSrc: "assets/icons/Product.svg",
                      title: "商品規格",
                      press: () {
                        customModalBottomSheet(
                          context,
                          height: MediaQuery.of(context).size.height * 0.92,
                          child: const ProductInfoScreen(),
                        );
                      },
                    ),
                    // 送貨與付款方式
                    ProductListTile(
                      svgSrc: "assets/icons/Delivery.svg",
                      title: "送貨與付款方式",
                      press: () {
                        customModalBottomSheet(
                          context,
                          height: MediaQuery.of(context).size.height * 0.92,
                          child: const ShippingMethodsScreen(),
                        );
                      },
                    ),
                    // 退貨須知
                    ProductListTile(
                      svgSrc: "assets/icons/Return.svg",
                      title: "退貨須知",
                      isShowBottomBorder: true,
                      press: () {
                        customModalBottomSheet(
                          context,
                          height: MediaQuery.of(context).size.height * 0.92,
                          child: const ProductReturnsScreen(),
                        );
                      },
                    ),
                    // 相關產品標題
                    if (viewModel.hasRelatedProducts)
                      SliverPadding(
                        padding: const EdgeInsets.all(defaultPadding),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            "其他人也看了",
                            style: Theme.of(context).textTheme.titleSmall!,
                          ),
                        ),
                      ),
                    // 相關產品列表
                    if (viewModel.hasRelatedProducts)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: viewModel.relatedProducts.length,
                            itemBuilder: (context, index) {
                              final relatedProduct = viewModel.relatedProducts[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: defaultPadding,
                                  right: index == viewModel.relatedProducts.length - 1 ? defaultPadding : 0,
                                ),
                                child: ProductCard(
                                  image: relatedProduct.image,
                                  title: relatedProduct.title,
                                  brandName: relatedProduct.brandName,
                                  price: relatedProduct.price,
                                  priceAfetDiscount: relatedProduct.priceAfterDiscount,
                                  dicountpercent: relatedProduct.discountPercent,
                                  press: () {
                                    // 導航到相關產品的詳情頁
                                    // Navigator.pushNamed(
                                    //   context,
                                    //   productDetailsScreenRoute,
                                    //   arguments: relatedProduct.id.toString(),
                                    // );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: defaultPadding),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
