import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';
import 'package:tklab_ec_v2/screens/order/views/components/order_summary_card.dart';
import 'package:tklab_ec_v2/viewmodels/cart_view_model.dart';

import '../../../constants.dart';
import 'components/cart_item_card.dart';
import 'components/coupon_code.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // 進入畫面時載入購物車資料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CartViewModel>(
        builder: (context, cartViewModel, child) {
          final items = cartViewModel.items;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: CustomScrollView(
              slivers: [
                // 標題
                SliverToBoxAdapter(
                  child: Text(
                    "確認您的訂單",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),

                // 全選勾選框
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: defaultPadding / 2),
                    child: Row(
                      children: [
                        Checkbox(
                          value: cartViewModel.isAllSelected,
                          onChanged: (_) => cartViewModel.toggleSelectAll(),
                          activeColor: primaryColor,
                        ),
                        GestureDetector(
                          onTap: () => cartViewModel.toggleSelectAll(),
                          child: Text(
                            "全選",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "已選 ${cartViewModel.selectedItems.length} 件商品",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: blackColor60,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 購物車商品列表
                if (items.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: defaultPadding * 2),
                      child: Center(
                        child: Text(
                          "購物車是空的",
                          style: TextStyle(color: blackColor60),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: defaultPadding),
                          child: CartItemCard(
                            image: item.image,
                            productName: item.productName,
                            price: item.price,
                            quantity: item.quantity,
                            isSelected: item.isSelected,
                            onSelectionChanged: () =>
                                cartViewModel.toggleItemSelection(item.id),
                            onQuantityIncrement: () => cartViewModel
                                .updateItemQuantity(item.id, item.quantity + 1),
                            onQuantityDecrement: () => cartViewModel
                                .updateItemQuantity(item.id, item.quantity - 1),
                            onDelete: () => _showDeleteConfirmDialog(
                              context,
                              item.productName,
                              () => cartViewModel.deleteItem(item.id),
                            ),
                          ),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),

                // 優惠券
                const SliverToBoxAdapter(
                  child: CouponCode(),
                ),

                // 訂單摘要
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
                  sliver: SliverToBoxAdapter(
                    child: OrderSummaryCard(
                      subTotal: cartViewModel.selectedTotal,
                      discount: 0,
                      totalWithVat: cartViewModel.selectedTotal,
                      vat: 0,
                    ),
                  ),
                ),

                // 繼續按鈕
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: ElevatedButton(
                      onPressed: cartViewModel.hasSelectedItems
                          ? () {
                              Navigator.pushNamed(
                                  context, orderConfirmationScreenRoute);
                            }
                          : null,
                      child: Text(
                        cartViewModel.hasSelectedItems
                            ? "繼續 (${cartViewModel.selectedItems.length} 件商品)"
                            : "請選擇商品",
                      ),
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

  /// 顯示刪除確認對話框
  void _showDeleteConfirmDialog(
    BuildContext context,
    String productName,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("確認刪除"),
        content: Text("確定要從購物車中移除「$productName」嗎？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: errorColor),
            child: const Text("刪除"),
          ),
        ],
      ),
    );
  }
}
