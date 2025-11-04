import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/viewmodels/order_confirmation_view_model.dart';
import '/route/route_constants.dart';

class OrderConfirmationBottomBar extends StatelessWidget {
  const OrderConfirmationBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderConfirmationViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // 左側：總計
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '總計',
                        style: TextStyle(
                          fontSize: 12,
                          color: blackColor60,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        viewModel.formattedTotal,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // 右側：送出訂單按鈕
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            // 提交訂單
                            final success = await viewModel.submitOrder();

                            if (success && context.mounted) {
                              // 導航到訂單成功頁面
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                thanksForOrderScreenRoute,
                                (route) => false,
                              );
                            } else if (!success && context.mounted) {
                              // 顯示錯誤訊息
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    viewModel.errorMessage ?? '訂單提交失敗',
                                  ),
                                  backgroundColor: errorColor,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                      ),
                      elevation: 0,
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(whiteColor),
                            ),
                          )
                        : Text(
                            '送出訂單(${viewModel.itemCount})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
