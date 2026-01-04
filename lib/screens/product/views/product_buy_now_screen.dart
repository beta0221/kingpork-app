import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/components/cart_button.dart';
import 'package:tklab_ec_v2/components/custom_modal_bottom_sheet.dart';
import 'package:tklab_ec_v2/components/network_image_with_loader.dart';
import 'package:tklab_ec_v2/screens/product/views/added_to_cart_message_screen.dart';
import 'package:tklab_ec_v2/screens/product/views/components/product_list_tile.dart';
import 'package:tklab_ec_v2/screens/product/views/location_permission_store_availability_screen.dart';
import 'package:tklab_ec_v2/screens/product/views/size_guide_screen.dart';
import 'package:tklab_ec_v2/viewmodels/cart_view_model.dart';
import 'package:tklab_ec_v2/viewmodels/product_details_view_model.dart';

import '../../../constants.dart';
import 'components/product_quantity.dart';
import 'components/selected_size.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  const ProductBuyNowScreen({super.key});

  @override
  ProductBuyNowScreenState createState() => ProductBuyNowScreenState();
}

class ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  int _selectedSkuIndex = 0;  // 選中的 SKU 索引
  int _quantity = 1;           // 購買數量

  // 增加數量
  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  // 減少數量
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  // 選擇 SKU
  void _selectSku(int index) {
    setState(() {
      _selectedSkuIndex = index;
    });
  }

  // 計算總價
  double _calculateTotalPrice(double unitPrice) {
    return unitPrice * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailsViewModel>(
      builder: (context, viewModel, child) {
        // 處理載入狀態
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 處理錯誤或資料不存在
        if (viewModel.isError || !viewModel.hasProductDetail) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('產品詳情'),
              leading: const BackButton(),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: errorColor),
                  const SizedBox(height: defaultPadding),
                  Text(
                    viewModel.errorMessage ?? '無法載入產品資料',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('返回'),
                  ),
                ],
              ),
            ),
          );
        }

        // 獲取產品資料
        final product = viewModel.productDetail!;

        // 處理 SKU 列表為空
        if (product.skuList.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(product.title),
              leading: const BackButton(),
            ),
            body: const Center(
              child: Text('此產品暫無可選規格'),
            ),
          );
        }

        // 確保選中索引在有效範圍內
        if (_selectedSkuIndex >= product.skuList.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedSkuIndex = 0;
            });
          });
        }

        // 計算總價
        final totalPrice = _calculateTotalPrice(product.price);

        // 渲染主要 UI
        return Scaffold(
          bottomNavigationBar: CartButton(
            price: totalPrice,
            title: "加入購物車",
            subTitle: "總價",
            press: () async {
              // 獲取選中的 SKU
              final selectedSku = product.skuList[_selectedSkuIndex];

              try {
                // 調用 CartViewModel 添加到購物車
                await context.read<CartViewModel>().addToCartWithSku(
                      productId: product.id,
                      productName: product.title,
                      price: product.price,
                      quantity: _quantity,
                      image: product.primaryImage,
                      skuId: selectedSku.id,
                      skuName: selectedSku.name,
                    );

                // 成功後顯示提示
                if (!mounted) return;
                customModalBottomSheet(
                  context,
                  isDismissible: false,
                  child: const AddedToCartMessageScreen(),
                );
              } catch (e) {
                // 錯誤處理
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('加入購物車失敗: ${e.toString()}'),
                    backgroundColor: errorColor,
                  ),
                );
              }
            },
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding / 2, vertical: defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackButton(),
                    Expanded(
                      child: Text(
                        product.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                        child: AspectRatio(
                          aspectRatio: 1.05,
                          child: NetworkImageWithLoader(
                            product.hasImages
                                ? product.primaryImage
                                : "https://via.placeholder.com/400",
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(defaultPadding),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: UnitPrice(
                                price: product.price,
                                priceAfterDiscount: null,
                              ),
                            ),
                            ProductQuantity(
                              numOfItem: _quantity,
                              onIncrement: _incrementQuantity,
                              onDecrement: _decrementQuantity,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: Divider()),
                    SliverToBoxAdapter(
                      child: SelectedSize(
                        sizes: product.skuList.map((sku) => sku.name).toList(),
                        selectedIndex: _selectedSkuIndex,
                        press: _selectSku,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                      sliver: ProductListTile(
                        title: "尺寸指南",
                        svgSrc: "assets/icons/Sizeguid.svg",
                        isShowBottomBorder: true,
                        press: () {
                          customModalBottomSheet(
                            context,
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: const SizeGuideScreen(),
                          );
                        },
                      ),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: defaultPadding),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: defaultPadding / 2),
                            Text(
                              "門市取貨可用性",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: defaultPadding / 2),
                            const Text(
                                "選擇尺寸以查看門市庫存與門市取貨選項。")
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                      sliver: ProductListTile(
                        title: "查詢門市",
                        svgSrc: "assets/icons/Stores.svg",
                        isShowBottomBorder: true,
                        press: () {
                          customModalBottomSheet(
                            context,
                            height: MediaQuery.of(context).size.height * 0.92,
                            child: const LocationPermissonStoreAvailabilityScreen(),
                          );
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: defaultPadding))
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
